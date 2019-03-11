drop table diss_t6 purge;

create table diss_t6(
country varchar2(5),
total_employment  number
);

insert into diss_t6
select ten_country_code, sum(ten_pers_empl)
from ta_fats_tens
where frame_id=100048
    and ten_country_code in ('AT','BE','BG','CY','CH','NO','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
    and ten_geg_egr_id in ( select geg_egr_id
                            from diss_groups
                            where frame_id=100048
                              and geg_c_w_empl>1)
group by ten_country_code
order by ten_country_code;