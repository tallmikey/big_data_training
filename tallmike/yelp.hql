create database review_db
comment 'by Michael Shi on 2018-06-05';

use review_db;

create table ratings
(userid int,
 itemid int,
 rating int)
 row format delimited
 fields TERMINATED by '\t';

 load data INPATH '/tmp/hivedemo/data/ratings.tsv' OVERWRITE into table review_db;

create EXTERNAL table items 
( itemid int, 
  category string)
row format DELIMITED
FIELDS TERMINATED by '\t'
location '/tmp/data/yelp';

load data inpath '/tmp/hivedemo/data/items.tsv' OVERWRITE into table items;


select r.*, i.category 
from ratings r 
left join items i 
on r.itemid = i.itemid
limit 30;

create table top_ratings
( userid int,
  itemid int)
PARTITIONED by (rating int)
row FORMAT DELIMITED
fields TERMINATED by '\t';

alter table top_ratings add partition (rating = 5);
load data inpath '/tmp/hivedemo/data/top_ratings.tsv' OVERWRITE into table top_ratings PARTITION (rating = 5); 
