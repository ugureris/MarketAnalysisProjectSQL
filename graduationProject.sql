--CREATİNG TABLE

create table market_sales_master(
ID int,
ITEMCODE VARCHAR(100),
ITEMNAME VARCHAR(100),
FICHENO VARCHAR(100),
DATE_ DATE,
AMOUNT numeric,
PRICE numeric,
LINENETTOTAL numeric,
LINENET numeric,
BRANCHNR int,
BRANCH VARCHAR(100),
SALESMAN VARCHAR(100),
CITY VARCHAR(100),
REGION VARCHAR(100),
LATITUDE numeric,
LONGITUDE numeric,
CLIENTCODE VARCHAR(100),
CLIENTNAME VARCHAR(100),
BRANDCODE VARCHAR(100),
BRAND VARCHAR(100),
CATEGORY_NAME1 VARCHAR(100),
CATEGORY_NAME2 VARCHAR(100),
CATEGORY_NAME3 VARCHAR(100),
START_DATE timestamp,
END_DATE timestamp,
GENDER CHAR
);


--PULLING DATA FROM AWS

create extension if not exists aws_s3 cascade;


--SAVING THE DATA IN THE TABLE

select aws_s3.table_import_from_s3 ('market_sales_master','','(FORMAT CSV,HEADER true)','sqlprojectbucket',
'test_market_utf_full (1).csv','eu-west-3');


--CREATING FACT AND DIMENSION TABLES

create table sales (
	id int,
	itemcode varchar(255),
	ficheno varchar(255),
	amount numeric,
	price numeric,
	linenettotal numeric,
	linenet numeric,
	branchnr int,
	salesman varchar(255),
	clientcode varchar(255),
	brandcode varchar(255),
	start_date timestamp,
	end_date timestamp
	);

create table item (
   itemcode varchar(100),
   itemname varchar(100),
   category_name1 varchar(100),
   category_name2 varchar(100),
   category_name3 varchar(100)
);

create table branch (
   branchnr int,
   branch varchar(100),
   city varchar(100),
   region varchar(100),
   latitude numeric,
   longitude numeric
);

create table client (
   clientcode varchar(100),
   clietname varchar(100),
   gender char
);

create table brand (
   brandcode varchar(100),
   brand varchar(100)
);


--SAVING DATA IN FACT AND DIMENSION TABLES

insert into sales (id, itemcode, ficheno, amount, price, linenettotal, linenet, branchnr,salesman, clientcode, brandcode, start_date, end_date)
select distinct id, itemcode, ficheno, amount, price, linenettotal, linenet, branchnr,salesman, clientcode, brandcode, start_date, end_date
from market_sales_master ;

insert into item ( itemcode, itemname, category_name1, category_name2,category_name3)
select distinct itemcode, itemname, category_name1, category_name2,category_name3
from market_sales_master ;

insert into branch (branchnr, branch, city, region, latitude, longitude)
select distinct branchnr, branch, city, region, latitude, longitude
from market_sales_master ;

insert into client (clientcode, clietname, gender)
select distinct clientcode , clientname , gender 
from market_sales_master ;

insert into brand (brandcode, brand)
select distinct brandcode , brand 
from market_sales_master ;


--CREATING INDEXS
--Indexs provide faster access to data

create index index_sales_id on sales (id);

create index index_sales_itemcode on sales (itemcode);

create index index_sales_salesman on sales (salesman);


--ANALYZING THE PERFORMANCE OF QUERIES WITH EXPLAIN ANALYZE

EXPLAIN ANALYZE
SELECT s.id, i.itemcode ,s.salesman 
FROM sales s
INNER JOIN item i ON s.itemcode = i.itemcode;


--CREATING VIEWS

create view region_total_sales as
select b.region , sum(s.amount) as total_sales_amont from branch b 
inner join sales s 
on b.branchnr = s.branchnr 
group by b.region ;

create view best_selling_products as
select i.itemname , sum(s.amount) as number_of_products_sold
from sales s 
inner join item i 
on s.itemcode =i.itemcode 
group by i.itemname 
order by number_of_products_sold desc ;

create view salesman_performance as
select s.salesman ,b.region ,sum(s.amount) as total_sales 
from sales s 
inner join branch b 
on s.branchnr = b.branchnr 
group by s.salesman , b.region 
order by total_sales desc;


