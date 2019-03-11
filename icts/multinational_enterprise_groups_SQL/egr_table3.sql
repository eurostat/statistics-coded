drop table diss_t3 purge;

create table diss_t3(
country varchar2(5),
total_group number,
moa number,
DIV number,
VDIV number,
total_class number,
missing_data number);

insert into diss_t3
  select geg_uci_country_code, count(geg_egr_id),0,0,0,0,0
  from diss_groups
  where geg_uci_country_code in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','IS','LI','CH','NO')
    and geg_c_w_empl>1
  group by geg_uci_country_code
  order by geg_uci_country_code;
  
update diss_t3 
set moa = ( select count(geg_compl) 
          from diss_groups
          where geg_uci_country_code = diss_t3.country
             and geg_compl='MOA'
             and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t3.country);  
              
update diss_t3 
set div = (select count(geg_compl) from diss_groups
         where geg_uci_country_code = diss_t3.country
            and geg_compl='DIV'
            and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t3.country);  
              
update diss_t3 
set vdiv = ( select count(geg_compl) 
          from diss_groups
          where geg_uci_country_code = diss_t3.country
              and geg_compl='VDIV'
              and geg_c_w_empl>1
                       )
where exists (select geg_uci_country_code 
              from diss_groups
              where diss_groups.geg_uci_country_code = diss_t3.country);    
              
update diss_t3 
set total_class = moa+div+vdiv;

update diss_t3 
set missing_data = total_group - total_class;

insert into diss_t3(country)
values('EU-28');

update diss_t3
set total_group = ( select sum(total_group)
                    from diss_t3
                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),
    moa = ( select sum(moa)
          from diss_t3
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),
    div = ( select sum(div)
          from diss_t3
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')),      
    vdiv = ( select sum(vdiv)
          from diss_t3
          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')), 
    total_class = ( select sum(total_class)
                    from diss_t3
                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS')), 
    missing_data = ( select sum(missing_data)
                     from diss_t3
                     where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT', 'LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','LI','IS'))
where country = 'EU-28';