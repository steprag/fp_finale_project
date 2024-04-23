-- check gender counts
select gender, count(*) from population
group by 1;

drop table gender;
-- create a new dimension table for the gender dimension
create table if not exists gender (
gender_id bigint auto_increment,
gender varchar(10),
primary key (gender_id));

-- check the table was created...
select * from employees_mod.my_gender;

-- lets populate the table by inserting the unique values for that dimension
insert into employees_mod.my_gender(gender)
select distinct gender from employees_mod.employee_yearly_overview;

insert into gender (gender)
values ('Female');


-- check it has correctly populated
select * from gender;

-- now lets adjust the original table so we will use this table
-- alter table employees_mod.employee_yearly_overview add column gender_id int after gender;

-- lets set up the foreign key reference
alter table population ADD CONSTRAINT gender_fk1 FOREIGN KEY (gender) REFERENCES gender (gender_id);

-- check the extra column has appeared
-- select * from employees_mod.employee_yearly_overview limit 10;

-- populate the column using the dimension table we created
-- update employees_mod.employee_yearly_overview e, employees_mod.my_gender g
-- set e.gender_id = g.gender_id
where e.gender = g.gender;

-- check it is populated
-- select * from employees_mod.employee_yearly_overview limit 10;

-- lets drop the original column now
alter table employees_mod.employee_yearly_overview drop column gender;

-- check everything is as expected
-- select * from employees_mod.employee_yearly_overview limit 10;
-- select g.gender, count(*) from employees_mod.employee_yearly_overview e
-- inner join employees_mod.my_gender g on e.gender_id = g.gender_id
-- group by 1;

/*****************************************

We can now use from the menu, "database" -> "reverse engineer" in order to generate the ERM.

*****************************************/


-- age & job
-- check gender counts
select age_cat, count(*) from population
group by 1;
select job_cat, count(*) from population
group by 1;

drop table age_cat;
-- create a new dimension table for the gender dimension
create table if not exists age_cat (
age_cat_id int auto_increment,
age_cat varchar(10),
age_cat_desc varchar(10),
primary key (age_cat_id));

drop table job_cat;
create table if not exists job_cat (
job_cat_id int auto_increment,
job_cat varchar(50),
primary key (job_cat_id));

-- check the table was created...
-- select * from employees_mod.my_gender;

-- lets populate the table by inserting the unique values for that dimension
insert into job_cat(job_cat)
select distinct job_cat from population;

insert into job_cat (job_cat)
values ('unemployed');


insert into age_cat (age_cat, age_cat_desc)
values ('young', '< 25');
insert into age_cat (age_cat, age_cat_desc)
values ('medium', '[25 - 50[');
insert into age_cat (age_cat, age_cat_desc)
values ('old', '>= 50');
select * from age_cat;

-- check it has correctly populated
select * from job_cat;

-- now lets adjust the original table so we will use this table
alter table population add column job_cat_id int after job_cat;
alter table population add column age_cat_id int after age_cat;

-- lets set up the foreign key reference
alter table population ADD CONSTRAINT job_cat_fk1 FOREIGN KEY (job_cat_id) REFERENCES job_cat (job_cat_id);
alter table population ADD CONSTRAINT age_cat_fk1 FOREIGN KEY (age_cat_id) REFERENCES age_cat (age_cat_id);

-- check the extra column has appeared
select * from population limit 10;

-- populate the column using the dimension table we created
update population p, job_cat j
set p.job_cat_id = j.job_cat_id
where p.job_cat = j.job_cat;

update population p, age_cat a
set p.age_cat_id = a.age_cat_id
where p.age_cat = a.age_cat;

-- check it is populated
select * from population limit 10;

-- lets drop the original column now
alter table population drop column job_cat;
alter table population drop column age_cat;

-- check everything is as expected
-- select * from employees_mod.employee_yearly_overview limit 10;
-- select g.gender, count(*) from employees_mod.employee_yearly_overview e
-- inner join employees_mod.my_gender g on e.gender_id = g.gender_id
-- group by 1;

/*****************************************

We can now use from the menu, "database" -> "reverse engineer" in order to generate the ERM.

*****************************************/

