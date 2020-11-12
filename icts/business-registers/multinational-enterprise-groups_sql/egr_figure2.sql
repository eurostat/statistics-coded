---- Complexity of MNE groups by country in 2017 ------------------
--- In the third table of dissemination report DISS_T3, the enterprise groups are categorized based on their complexity.
--- Their complexity is calculated based on the distinct number of 2-digit NACE coded in each MNE group.

--- For
--- nace =1 the group is categorized as Mono-active group
--- 2-4 => the group is categorized as Diversified group
--- >4 =>  the group is categorized as Very diversified group


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
  group by geg_uci_country_code
  order by geg_uci_country_code;

 

update diss_t3

set moa = ( select count(geg_compl)

          from diss_groups

          where geg_uci_country_code = diss_t3.country

             and geg_compl='MOA'

            

                       )

where exists (select geg_uci_country_code

              from diss_groups

              where diss_groups.geg_uci_country_code = diss_t3.country); 

              

update diss_t3

set div = (select count(geg_compl) from diss_groups

         where geg_uci_country_code = diss_t3.country

            and geg_compl='DIV'

           

                       )

where exists (select geg_uci_country_code

              from diss_groups

              where diss_groups.geg_uci_country_code = diss_t3.country); 

              

update diss_t3

set vdiv = ( select count(geg_compl)

          from diss_groups

          where geg_uci_country_code = diss_t3.country

              and geg_compl='VDIV'

             

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

                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')),

    moa = ( select sum(moa)

          from diss_t3

          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')),

    div = ( select sum(div)

          from diss_t3

          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')),     

    vdiv = ( select sum(vdiv)

          from diss_t3

          where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')),

    total_class = ( select sum(total_class)

                    from diss_t3

                    where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')),

    missing_data = ( select sum(missing_data)

                     from diss_t3

                     where country in  ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR','GB','GR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK'))

where country = 'EU-28';
