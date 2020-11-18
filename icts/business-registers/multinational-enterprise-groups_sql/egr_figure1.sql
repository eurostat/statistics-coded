---- Figure 1 Size of the MNE groups by country in 2017  -----------------------------

---In the second table of dissemination report DISS_T2, the enterprise groups are categorized by number of legal units.

 

drop table diss_t2;

 

create table diss_t2(

country varchar2(5),

"1000_or_more" number,

"500_to_999" number,

"250_to_499" number,

"50_to_249" number,

"20_to_49" number,

"10_to_19" number,

"3_to_9" number,

"2" number);

 

insert into diss_t2

  select geg_uci_country_code,0,0,0,0,0,0,0,0

  from diss_groups

  where geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','IS','LI','CH','NO')

  group by geg_uci_country_code

  order by geg_uci_country_code;

 

update diss_t2

set "1000_or_more"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>999)

                       

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

             

update diss_t2

set "500_to_999"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>499  and GEG_LEU_COUNT<1000)

                       

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

              

update diss_t2

set "250_to_499"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>249  and GEG_LEU_COUNT<500)

                       

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

 

update diss_t2

set "50_to_249"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>49  and GEG_LEU_COUNT<250)

                       

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

             

update diss_t2

set "20_to_49"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>19  and GEG_LEU_COUNT<50)

                      

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

 

update diss_t2

set "10_to_19"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>9  and GEG_LEU_COUNT<20)

                       

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

 

update diss_t2

set "3_to_9"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT>2  and GEG_LEU_COUNT<10

                      

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);

             

update diss_t2

set "2"  = ( select count(geg_egr_id)

from ta_fats_gegs

where geg_uci_country_code =diss_t2.country and frame_id=100051

    and  GEG_LEU_COUNT=2)

                      

where exists (select geg_uci_country_code

              from ta_fats_gegs

              where geg_uci_country_code = diss_t2.country);
