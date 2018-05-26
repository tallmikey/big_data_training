hdfs dfs -put *.txt /tmp/wordcount

create table alice
(line string)
row format delimited 
fields terminated by ' '
tblproperties("skip.header.line.count"="1");

load data inpath '/tmp/wordcount/alice-in-wonderland.txt' overwrite into table alice;


select line, count(*) as cnt
from alice
group by line
order by cnt desc 
limit 10;

create table alice_wordcount
( word string,
  cnt int);

insert overwrite table alice_wordcount select line as word, count(*) as cnt from alice group by line order by cnt desc; 


solution
----------------
-- Create the table and load data
CREATE TABLE alice(line STRING);
LOAD DATA LOCAL INPATH "../../alice/*.txt" OVERWRITE INTO TABLE alice;

-- Explore data
SELECT
    EXPLODE(SPLIT(line,' ')) AS word 
FROM alice
LIMIT 10; 

-- Perform by the nest query 
SELECT
    TRIM(w.word) AS word,
    SUM(1) AS cnt 
FROM (
    SELECT 
        EXPLODE(SPLIT(line,' ')) AS word 
    FROM alice) as w 
WHERE
    word <> ''
GROUP BY w.word
ORDER BY cnt DESC 
LIMIT 10;


/*
The right way to think about LATERAL VIEW is that it allows a table-generating function (UDTF) to be treated as a table source, so that it can be used like any other table, including selects, joins and more.
LATERAL VIEW is often used with explode, but explode is just one UDTF of many,
*/

-- Perform by the LATERAL VIEW
SELECT
    TRIM(w.word) AS word,
    SUM(1) AS cnt 
FROM
    alice 
LATERAL VIEW
    EXPLODE(SPLIT(line,' ')) w AS word 
WHERE
    word <> ''
GROUP BY w.word
ORDER BY cnt DESC 
LIMIT 10;

-- Store Results in new Table
CREATE TABLE alice_wordcount
STORED AS TEXTFILE 
AS SELECT 
    TRIM(w.word) AS word,
    SUM(1) AS cnt 
FROM (
    SELECT 
        EXPLODE(SPLIT(row,' ')) AS word 
    FROM alice) as w 
WHERE
    word <> ''
GROUP BY w.word;

-- Store Results into File
INSERT OVERWRITE LOCAL DIRECTORY 'alice_wordcount'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
SELECT 
    TRIM(w.word) AS word,
    SUM(1) AS cnt 
FROM (
    SELECT 
        EXPLODE(SPLIT(row,' ')) AS word 
    FROM alice) as w 
WHERE
    word <> ''
GROUP BY w.word
ORDER BY cnt;
