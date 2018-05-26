set hive.support.concurrency = true;
set hive.enforce.bucketing = true;
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.txn.manager = org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on = true;
set hive.compactor.worker.threads = 1;

CREATE DATABASE acid_demo;

use acid_demo;

set hive.enforce.bucketing = true;

CREATE TABLE IF NOT EXISTS employee(
emp_id int, 
emp_name string, 
dept_name string,
work_loc string
) 
PARTITIONED BY (start_date string)
CLUSTERED BY (emp_id) INTO 5 BUCKETS STORED AS ORC TBLPROPERTIES('transactional'='true');



INSERT INTO table employee PARTITION (start_date) VALUES
(1,'Will','IT','Toronto','20100701'),
(2,'Wyne','IT','Toronto','20100701'),
(3,'Judy','HR','Beijing','20100701'),
(4,'Lili','HR','Beijing','20101201'),
(5,'Mike','Sales','Beijing','20101201'),
(6,'Bang','Sales','Toronto','20101201'),
(7,'Wendy','Finance','Beijing','20101201');

INSERT INTO table employee PARTITION (start_date) VALUES
(8,'Joice','Finance','Toronto','20170101');


update employee set dept_name='IT' where emp_id=8;

— Demo Merge statement
CREATE TABLE employee_state(
emp_id int, 
emp_name string, 
dept_name string,
work_loc string,
start_date string,
state string
)
STORED AS ORC;

INSERT INTO table employee_state VALUES
(2,'Wyne','IT','Beijing','20100701','update'),
(4,'Lili','HR','Beijing','20101201','quit'), 
(10,'James','IT','Toronto','20170101','new')
;

MERGE INTO employee AS T 
USING employee_state AS S
ON T.emp_id = S.emp_id and T.start_date = S.start_date
WHEN MATCHED AND S.state = 'update' THEN UPDATE SET dept_name = S.dept_name, work_loc = S.work_loc
WHEN MATCHED AND S.state = 'quit' THEN DELETE
WHEN NOT MATCHED THEN INSERT VALUES (S.emp_id, S.emp_name, S.dept_name, S.work_loc, S.start_date);

select * from employee order by emp_id;