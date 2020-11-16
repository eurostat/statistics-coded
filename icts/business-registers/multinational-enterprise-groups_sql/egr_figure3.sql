---- European presence of MNE groups by country in 2017 ---------------------------------

--- In the fourth table of dissemination report DISS_T4, the enterprise groups are categorized based on their number of countries where group is operating.

--- For count of legal units operating in less than 3 countries the group is categorized as Low EU presence, between 3 and 6 the group is categorized as Medium EU presence and for 5 or more the group is categorized as High EU presence.

drop table diss_4;

create table diss_t4(

country varchar2(5),

total_group number,

lep number,

mep number,

hep number);

 

insert into diss_t4

  select geg_uci_country_code,0,0,0

  from ta_fats_gegs

where frame_id=100051

  and  geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','IS','LI','CH','NO')

  group by geg_uci_country_code

  order by geg_uci_country_code;

 

  drop table temp1;

 

create table temp1 (

geg_egr_id number,

gdc varchar2 (5),

count_leus varchar2 (5)

);

 

insert into temp1

select geg.GEG_EGR_ID,tg.geg_uci_country_code ,count(distinct leu.leu_country_code)

from ta_leus leu , ta_geg_leu_links geg, ta_fats_gegs tg

where leu.frame_id=100051

and geg.frame_id=100051

and tg.frame_id=100051

and leu.leu_egr_id=geg.leu_egr_id

and tg.geg_egr_id=geg.geg_egr_id

and tg.geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','IS','LI','CH','NO')

group by geg.GEG_EGR_ID,tg.geg_uci_country_code;

 

  select *

  from temp1;

 

update temp1

set count_leus = (case

                when count_leus<3 then 'LEP'

                when (count_leus>2 and count_leus<6) then 'MEP'

                when count_leus>5 then 'HEP'

                else '-'

            end);
