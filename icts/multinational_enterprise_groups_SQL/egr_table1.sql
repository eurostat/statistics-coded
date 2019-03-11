drop table diss_t1 purge;

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
                      where frame_id=100048
                        and geg_c_w_empl>1
                        and geg_uci_country_code = diss_t1.country
                      group by geg_uci_country_code)
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t1.country);   

update diss_t1
set  groups_in_country = (select count (distinct (ten_geg_egr_id))
  from ta_fats_tens
  where frame_id=100048
    and ten_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','CH','NO','LI','IS')
    and ten_geg_egr_id in ( select geg_egr_id
                            from diss_groups
                            where frame_id=100048
                              and geg_c_w_empl>1)
  and ten_country_code = diss_t1.country);

insert into diss_t1(country)
values('EU-28');
              
update diss_t1
set     gdc_in_country = (  select sum(gdc_in_country)
                        from diss_t1
                        where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS'))
where country = 'EU-28';

update diss_t1
set groups_in_country = (  select  count (distinct (ten_geg_egr_id))
  from ta_fats_tens
  where frame_id=100048
    and ten_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
    and ten_geg_egr_id in ( select geg_egr_id
                            from diss_groups
                            where frame_id=100048
                              and geg_c_w_empl>1))
where country = 'EU-28';