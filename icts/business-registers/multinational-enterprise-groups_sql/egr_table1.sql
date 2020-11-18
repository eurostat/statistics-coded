---- Table 1 Number of MNE grgroups operating in the EU and EFTA countries in 2017 --------
--- In this aggregated table the following fields are calculated:

------ Column 1: Number of multinational enterprise groups operating in the country

------ Column 2: Number of multinational enterprise groups with global decision centre in the country       

 

create table diss_t1(

country varchar2(5),

groups_in_country number,

gdc_in_country number);

 

-- Import Countries, RefYear, Source

Insert into diss_t1 (country)

select dic.edcc_code as country

from egr_dict.egr_dict_country_code dic

where dic.edcc_eu_indicator = 'Y'

group by dic.edcc_code

order by dic.edcc_code;

 

update diss_t1

set gdc_in_country = (select count (*)

                      from diss_groups

                      where frame_id=100051

                        and geg_uci_country_code = diss_t1.country

                      group by geg_uci_country_code)

where exists (select geg_uci_country_code

              from diss_groups

              where diss_groups.geg_uci_country_code = diss_t1.country);  

 

--- The calculation of the value MNE Groups operating in Country results by the union of the calculations of:

-----------The Groups which have LEUS with country code equal to the calculated country.

-----------The Groups which have Enterprises with country code equal to the calculated country.

-----------The Groups which have UCI_COUNTRY_CODE equal to the calculated country.

--- As example the Groups in country for NL will be calculated as follows:

 

create table temp1 as

select DISTINCT (tg.geg_egr_id)

from ta_leus leu , ta_geg_leu_links geg, ta_fats_gegs tg

where leu.frame_id=100051

and geg.frame_id=100051

and tg.frame_id=100051

and leu.leu_egr_id=geg.leu_egr_id

and tg.geg_egr_id=geg.geg_egr_id

and leu.LEU_COUNTRY_CODE in ('NL');

 

create table temp2 as

select geg_egr_id

from ta_fats_gegs

where FRAME_ID=100051

and GEG_UCI_COUNTRY_CODE in ('NL');

 

create table temp3 as

select distinct (ten_geg_egr_id)

  from ta_fats_tens

  where frame_id=100051

   and ten_country_code in ('NL')

   ;

 

create table temp4 as

   

select *

from temp1

union

select *

from temp2

union

select *

from temp3;

 

insert into diss_t1(country)

values('EU-28');

----- the EU28 calculation is a summary of the above calculations at national level

 

update diss_t1

set     gdc_in_country = (  select sum(gdc_in_country)

                        from diss_t1

                        where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK'))

where country = 'EU-28';
