create database hr;

use hr;

create external table employee
(
name string,
work_place array<string>,
sex_age struct<sex:string, age:int>,
skills_score map<string, int>,
depart_title map<string, array<string>>
)
row format delimited 
fields terminated by '|'
collection items TERMINATED by ','
map keys TERMINATED by ':'
location '/tmp/hr_emp';

load data inpath '/tmp/hivedemo/data/employee2.txt' OVERWRITE into table employee;


create table emp_exp as 
with t1 as 
(select name, work_place[0], sex_age.age from employee)

select * from t1;

create table emp_exp1 as 
select name, work_place[0], sex_age.age from employee;



----CTAS
with 
t1 as (select concat_ws('|','HEADER', cast(current_timestamp as string), concat('employ_', cast(current_date as string), '.flat')) as val, 1 as key)
,
t2 as (select concat_ws('|', 'TRAILER', cast(current_date as string), concat('ROW COUNT:', cast( count(*) as string) ) ) as val, 3 as key from employee )
,
t3 as (select concat_ws('|', name, work_place[0], cast(sex_age.age as tring)) as val, 2 as key from employee),
emp_exp as (
select val from t1
union ALl 
select val from t2 
uninon ALL
select val from t3 
order by key
)

select val from emp_emp;
