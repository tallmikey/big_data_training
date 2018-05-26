create table stocks
(
ymd date, price_open decimal(10,2), 
price_high decimal(10,2), 
price_low decimal(10,2), 
price_close decimal(10,2), 
volumn int, 
price_adj_close  decimal(10,2)
)
partitioned by (exchanger string, symbol string)
row format delimited fields terminated by ',';


alter table stocks add partition (exchanger='NASDAQ', symbol='AAPL');
alter table stocks add partition (exchanger='NASDAQ', symbol='INTC');
alter table stocks add partition (exchanger='NYSE', symbol='GE');
alter table stocks add partition (exchanger='NYSE', symbol='IBM');

alter table stocks drop partition(exchanger='NYSE', symbol='GE');
TRUNCATE TABLE stocks PARTITION (exchanger='NYSE');

ß
show partitions stocks;

load data inpath '/tmp/stocks.csv' into table stocks partition (exchanger='NASDAQ', symbol='AAPL');
load data inpath '/tmp/stocks.csv' into table stocks partition (exchanger='NASDAQ', symbol='INTC');
load data inpath '/tmp/stocks.csv' into table stocks partition (exchanger='NYSE', symbol='GE');
load data inpath '/tmp/stocks.csv' into table stocks partition (exchanger='NYSE', symbol='IBM');

select exchanger, symbol, count(*) as cnt 
from stocks
--partitioned by exchanger, symbol;
group by exchanger, symbol;


select exchanger,symbol, max(price_high)
from stocks
group by exchanger, symbol;
