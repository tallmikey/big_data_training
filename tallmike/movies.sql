create table movies
(   m_index int,
title string,
year int,
rating double,
duration int
)
row format delimited fields terminated by '\t';

load data inpath '/tmp/movies_data.tsv' overwrite into table movies;

select * from movies
where rating > 4 
limit 10;

select year, avg(rating) as avg_rate
from movies group by year;


select count(*)
from movies
where rating > 2;


select sum(case when rating > 2 then 1 else 0 end) as rate_2_up,
count(*)
from movies;

select year, title, rnk
from (
select 
year, title, row_number() over(partition by year order by rating desc) as rnk
from movies) t
where rnk <=2
order by year;

select *, datediff(cast(year as string) + '-01-01', cast(current_date as string))
from movies;