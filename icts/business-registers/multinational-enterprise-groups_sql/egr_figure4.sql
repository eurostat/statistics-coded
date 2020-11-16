---- Top 5 EU partner countries in which the national MNE groups have the highest share of employment in 2017
---- In the fifth table of dissemination report DISS_T5, it is presented an aggregated report based on the share of employment in different countries for groups in frame. The calculation is based on each country's share of employment for the 5 foreign EU countries with highest employment in the reference year.

 

create table diss_t5 (

  COUNTRY varchar(2),

  SHARE_COUNTRY_1  varchar(15) default '-',

  SHARE_COUNTRY_2  varchar(15) default '-',

  SHARE_COUNTRY_3  varchar(15) default '-',

  SHARE_COUNTRY_4  varchar(15) default '-',

  SHARE_COUNTRY_5  varchar(15) default '-');

 

comment on column diss_t5.country is 'Country of group (GDC)';

comment on column diss_t5.share_country_1 is 'Share of employment - other EU country 1';

comment on column diss_t5.share_country_2 is 'Share of employment - other EU country 2';

comment on column diss_t5.share_country_3 is 'Share of employment - other EU country 3';

comment on column diss_t5.share_country_4 is 'Share of employment - other EU country 4';

comment on column diss_t5.share_country_5 is 'Share of employment - other EU country 5';

-----------------------------------------------------------------------------------------------------------------------

create table tmp

as

    select ten_geg_uci_country_code gdc, ten_country_code country,sum(geg_pers_empl) empl

    from egr2ta.ta_fats_tens tens

    join egr2ta.ta_fats_gegs gegs on tens.ten_geg_egr_id  = gegs.geg_egr_id

    where tens.frame_id=100051

 

      and geg_pers_empl>0

      and ten_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')

      and ten_geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','NO','IS','LI','CH')

      and ten_geg_uci_country_code<>ten_country_code

    group by ten_geg_uci_country_code, ten_country_code

    order by ten_geg_uci_country_code, empl desc;

 

create table tmp2

as

select  ten_geg_uci_country_code gdc ,sum(geg_pers_empl) empl

from egr2ta.ta_fats_tens tens

join egr2ta.ta_fats_gegs gegs on tens.ten_geg_egr_id  = gegs.geg_egr_id

where tens.frame_id=100051

 

  and geg_pers_empl >0

  and ten_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')

  and ten_geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','NO','IS','LI','CH')

  and ten_geg_uci_country_code<>ten_country_code

group by ten_geg_uci_country_code

order by ten_geg_uci_country_code ,empl;

 

insert into diss_t5 kpi

select * from (

  select e.gdc, mod(rownum,5) aggregats, e.country  || to_char(round(e.empl / e2.empl * 100,1),'99990D0')|| '%' share_per_country

  from tmp e, tmp2 e2

  where e.country in (select e2.country

                      from tmp e2

                      where rownum<=5

                        and e.gdc=e2.gdc)

          and e.gdc=e2.gdc)

pivot (

  min(share_per_country) for aggregats in (1 "country_1",2 "country 2",3 "country 3",4 "country 4",0  "country 5")

)

order by gdc;

 

drop table tmp purge;  

drop table tmp2 purge;
