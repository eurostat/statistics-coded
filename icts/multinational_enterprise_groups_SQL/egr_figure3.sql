drop table diss_t4 purge;

create table diss_t4(
country varchar2(5),
total_group number,
sei number,
mei number,
lei number,
total_class number,
missing_data number);

insert into diss_t4
  select geg_uci_country_code, count(geg_egr_id),0,0,0,0,0
  from diss_groups
  where geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','IS','LI','CH','NO')
    and geg_c_w_empl>1
  group by geg_uci_country_code
  order by geg_uci_country_code;
  
update diss_t4 
set sei = ( select count(geg_eu_infl) 
          from diss_groups
          where geg_uci_country_code = diss_t4.country
             and geg_eu_infl='SEI'
             and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t4.country);  
              
update diss_t4 
set mei = (select count(geg_eu_infl) from diss_groups
         where geg_uci_country_code = diss_t4.country
            and geg_eu_infl='MEI'
            and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t4.country);  
              
update diss_t4 
set lei = ( select count(geg_eu_infl) 
          from diss_groups
          where geg_uci_country_code = diss_t4.country
              and geg_eu_infl='LEI'
              and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t4.country);    
              
update diss_t4 
set total_class = sei+mei+lei;

update diss_t4 
set missing_data = total_group - total_class;

insert into diss_t4(country)
values('EU-28');

update diss_t4
set total_group = ( select sum(total_group)
                    from diss_t4
                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),
    sei = ( select sum(sei)
          from diss_t4
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),
    mei = ( select sum(mei)
          from diss_t4
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),      
    lei = ( select sum(lei)
          from diss_t4
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')), 
    total_class = ( select sum(total_class)
                    from diss_t4
                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')), 
    missing_data = ( select sum(missing_data)
                     from diss_t4
                     where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS'))
where country = 'EU-28';