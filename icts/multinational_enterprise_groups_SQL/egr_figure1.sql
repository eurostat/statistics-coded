drop table diss_t2 purge;

create table diss_t2(
country varchar2(5),
total_group number,
s number,
m number,
l number,
total_class number,
missing_data number);

insert into diss_t2
  select geg_uci_country_code, count(geg_egr_id),0,0,0,0,0
  from diss_groups
  where geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','IS','LI','CH','NO')
    and geg_c_w_empl>1
  group by geg_uci_country_code
  order by geg_uci_country_code;
  
update diss_t2 
set s = ( select count(geg_size) 
          from diss_groups
          where geg_uci_country_code = diss_t2.country
             and geg_size='S'
             and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t2.country);  
              
update diss_t2 
set m = (select count(geg_size) from diss_groups
         where geg_uci_country_code = diss_t2.country
            and geg_size='M'
            and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t2.country);  
              
update diss_t2 
set l = ( select count(geg_size) 
          from diss_groups
          where geg_uci_country_code = diss_t2.country
              and geg_size='L'
              and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t2.country);    
              
update diss_t2 
set total_class = s+m+l;

update diss_t2 
set missing_data = total_group - total_class;

insert into diss_t2(country)
values('EU-28');

update diss_t2
set total_group = ( select sum(total_group)
                    from diss_t2
                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),
    s = ( select sum(s)
          from diss_t2
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),
    m = ( select sum(m)
          from diss_t2
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),      
    l = ( select sum(l)
          from diss_t2
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')), 
    total_class = ( select sum(total_class)
                    from diss_t2
                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')), 
    missing_data = ( select sum(missing_data)
                     from diss_t2
                     where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS'))
where country = 'EU-28';