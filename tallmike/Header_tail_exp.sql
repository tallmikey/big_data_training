with emp as (
select 
concat_ws('|', name, sex_age.sex, cast(sex_age.age as string)) as val,
2 as key
from
employee
),
header as (
select 
concat_ws('|','HEADER',cast(current_timestamp as string), concat('employee_', cast(current_date as string), '.flat')) as val, 
1 as key
),
trailer as (
select 
concat_ws('|','TRAILER',cast(current_date as string), concat('DETAIL ROW COUNT: ',cast(count(*) as string))) as val, 
3 as key from emp
),
re as (
select * from header 
union all 
select * from emp 
union all
select * from trailer
order by key
)
from re
select val from re