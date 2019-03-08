

create table DISS_GROUPS (
          FRAME_ID NUMBER(6,0),
          GEG_EGR_ID NUMBER(18,0),
          GEG_NAME VARCHAR2(255 CHAR),
          GEG_C_W_EMPL NUMBER(6,0),
          GEG_UCI_EGR_ID NUMBER(18,0),
          GEG_UCI_LEID VARCHAR2(25 CHAR),
          geg_uci_country_code VARCHAR2(2 CHAR),
          GEG_PERS_EMPL NUMBER(7,0),
          GEG_SIZE VARCHAR2(2 CHAR),
          GEG_NACE2_CODE VARCHAR2(8 CHAR),
          GEG_NACE2_W_EMPL NUMBER(6,0),
          GEG_COMPL VARCHAR2(4 CHAR),
          GEG_EU_C_W_EMPL NUMBER(6,0),
          GEG_EU_INFL VARCHAR2(3 CHAR)
);

comment on column diss_groups.FRAME_ID is 'ID number of the EGR frame.';
comment on column diss_groups.GEG_EGR_ID is 'Unique ID number of a global enterprise group created by EGR. ';
comment on column diss_groups.GEG_NAME is 'Official name of the global enterprise group.';
comment on column diss_groups.GEG_C_W_EMPL is 'Number of country with employment';
comment on column diss_groups.GEG_UCI_EGR_ID is 'Unique ID number of the UCI of the global enterprise group. The UCI is the decision centre of the group.';
comment on column diss_groups.GEG_UCI_LEID is 'Global decision centre (GDC) LEID';
comment on column diss_groups.geg_uci_country_code is 'ISO country code of the country where the UCI is located.';
comment on column diss_groups.GEG_PERS_EMPL is 'Number of persons employed of the global enterprise group.';
comment on column diss_groups.GEG_SIZE is 'The code based on 0-249, 250-2499, 2500 or more';
comment on column diss_groups.GEG_NACE2_CODE is 'Main activity code of the global enterprise group in EGR according to NACE v2 classification.';
comment on column diss_groups.GEG_NACE2_W_EMPL is 'Number of 2-digit NACE with employment';
comment on column diss_groups.GEG_COMPL is 'The code based on number of NACEs';
comment on column diss_groups.GEG_EU_C_W_EMPL is 'Number of EU-28 country woth employment';
comment on column diss_groups.GEG_EU_INFL is 'The code based on EU countries number';

-- Data from ta_fats_gegs
insert into diss_groups
select frame_id, geg_egr_id, geg_name,'', geg_uci_egr_id, geg_uci_leid, geg_uci_country_code, geg_pers_empl, '',geg_nace2_code,'','','',''
from ta_fats_gegs
where frame_id=100048
and ta_fats_gegs.GEG_LEU_COUNT>1;

-- Calculation of geg_c_w_empl - calculated from TENS table where TENS of the group do have employment >0
create table tmp as
  select ten_geg_egr_id,count(distinct ten_country_code) NbCountry
  from ta_fats_tens 
  where frame_id = 100048
    and ten_pers_empl>0
  group by ten_geg_egr_id;
  
update diss_groups gr
set geg_c_w_empl = (select NbCountry from tmp
                    where gr.geg_egr_id = tmp.ten_geg_egr_id
                   )
where exists (select ten_geg_egr_id from tmp
              where gr.geg_egr_id = tmp.ten_geg_egr_id);
  
drop table tmp purge;


-- Calculation of geg_size - the code based on 0-249 => S, 250-2499 => M, 2500 or more => L- can also be null             
update diss_groups
set geg_size = (case 
                    when geg_pers_empl<250 then 'S' 
                    when (geg_pers_empl>249 and geg_pers_empl<2500) then 'M' 
                    when geg_pers_empl is null then '-'
                    else 'L' 
                end);   


-- Calculation of geg_nace2_w_empl - number of 2-digit NACE (substring) with employment - can be calculated from TEN table, where TENs of the group do have employment (>0 in a 2-digit NACE
create table tmp (
ten_geg_egr_id number,
NbNace number);

insert into tmp
    select ten_geg_egr_id, count(distinct substr(ten_nace2_code,3,2)) NbNace
    from egr2ta.ta_fats_tens
    where frame_ID=100048
      and ten_pers_empl>0
 	 	group by ten_geg_egr_id;
  
update diss_groups gr
set geg_nace2_w_empl = (select NbNace from tmp
                        where gr.geg_egr_id = tmp.ten_geg_egr_id
                       )
where exists (select ten_geg_egr_id from tmp
              where gr.geg_egr_id = tmp.ten_geg_egr_id);
  
drop table tmp purge;


-- Calculation of geg_compl - the code based on number of NACEs - Count nace =1 => MOA; 2-4 => DIV; >4 => VDIV               
update diss_groups gr
set geg_compl = (case 
                 when geg_nace2_w_empl=1 then 'MOA' 
                 when (geg_nace2_w_empl>1 and geg_nace2_w_empl<5) then 'DIV' 
                 when geg_nace2_w_empl>4 then  'VDIV' 
                 else '-'
             end);      

                
-- Calculation of geg_eu_c_w_empl - number of EU-28 country with employment - can be calculated from TEN table, where TENs of the group do have employment (>0 in one of the EU countries
create table tmp (
ten_geg_egr_id number,
NbCountry number);

insert into tmp
    select ten_geg_egr_id, count(distinct ten_country_code) NbCountry
    from egr2ta.ta_fats_tens
    where frame_ID=100048
      and ten_country_code  in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')
      and ten_pers_empl>0
 	 	group by ten_geg_egr_id;

update diss_groups gr
set geg_eu_c_w_empl = (select NbCountry from tmp
                       where gr.geg_egr_id = tmp.ten_geg_egr_id
                      )
where exists (select ten_geg_egr_id from tmp
              where gr.geg_egr_id = tmp.ten_geg_egr_id);
  
drop table tmp purge;


-- Calculation of geg_eu_infl - the code based on EU countries number - NbCountry <3 => SEI; 3-5 => MEI; >5 LEI
update diss_groups
set geg_eu_infl = (case 
                when geg_eu_c_w_empl<3 then 'SEI' 
                when (geg_eu_c_w_empl>2 and geg_eu_c_w_empl<6) then 'MEI' 
                when geg_eu_c_w_empl>5 then 'LEI' 
                else '-' 
            end);              