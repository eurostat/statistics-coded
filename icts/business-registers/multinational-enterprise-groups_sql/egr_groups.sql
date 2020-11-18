----Creation of DISS_GROUPS table
create table DISS_GROUPS (

          FRAME_ID NUMBER(6,0),

          GEG_EGR_ID NUMBER(18,0),

          GEG_NAME VARCHAR2(255 CHAR),

          GEG_UCI_EGR_ID NUMBER(18,0),

          GEG_UCI_LEID VARCHAR2(25 CHAR),

          geg_uci_country_code VARCHAR2(2 CHAR),

          GEG_PERS_EMPL NUMBER(7,0),

          GEG_NACE2_CODE VARCHAR2(8 CHAR),

          GEG_NACE2 NUMBER(6,0),

          GEG_COMPL VARCHAR2(4 CHAR),

);

 

comment on column diss_groups.FRAME_ID is 'ID number of the EGR frame.';

comment on column diss_groups.GEG_EGR_ID is 'Unique ID number of a global enterprise group created by EGR. ';

comment on column diss_groups.GEG_NAME is 'Official name of the global enterprise group.';

comment on column diss_groups.GEG_UCI_EGR_ID is 'Unique ID number of the UCI of the global enterprise group. The UCI is the decision centre of the group.';

comment on column diss_groups.GEG_UCI_LEID is 'Global decision centre (GDC) LEID';

comment on column diss_groups.geg_uci_country_code is 'ISO country code of the country where the UCI is located.';

comment on column diss_groups.GEG_PERS_EMPL is 'Number of persons employed of the global enterprise group.';

comment on column diss_groups.GEG_NACE2_CODE is 'Main activity code of the global enterprise group in EGR according to NACE v2 classification.';

comment on column diss_groups.GEG_NACE2 is 'Number of different 2-digit NACE codes within the group';

comment on column diss_groups.GEG_COMPL is 'The code based on number of NACEs';

 

-- Data from ta_fats_gegs

insert into diss_groups

select frame_id, geg_egr_id, geg_name,'', geg_uci_egr_id, geg_uci_leid, geg_uci_country_code, geg_pers_empl, '',geg_nace2_code,'','','',''

from ta_fats_gegs

where frame_id=100051

 

-- Calculation of geg_nace2 - number of 2-digit NACE (substring)

create table tmp (

ten_geg_egr_id number,

NbNace number);

insert into tmp

    select ten_geg_egr_id, count(distinct substr(ten_nace2_code,3,2)) NbNace

    from egr2ta.ta_fats_tens

    where frame_ID=100051

               group by ten_geg_egr_id;

 

update diss_groups gr

set geg_nace2 = (select NbNace from tmp

                        where gr.geg_egr_id = tmp.ten_geg_egr_id

                       )

where exists (select ten_geg_egr_id from tmp

              where gr.geg_egr_id = tmp.ten_geg_egr_id);

 

drop table tmp purge;

 

-- Calculation of geg_compl - the code based on number of NACEs - Count nace =1 => MOA; 2-4 => DIV; >4 => VDIV              

update diss_groups gr

set geg_compl = (case

                 when geg_nace2=1 then 'MOA'

                 when (geg_nace2>1 and geg_nace2<5) then 'DIV'

                 when geg_nace2>4 then  'VDIV'

                 else '-'

             end);
