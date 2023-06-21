CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');


CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;





--Q1--What is total amount spent by each customer ?

select a.userid,  sum(b.price) 
from sales  as a  
inner join product as b on a.product_id=b.product_id
group by a.userid

--Q2-- How many days each customer visited zomato ?

select  userid , count(distinct created_date) from sales  
group by userid;

--Q3-- what was the first product purchased by the customer ?

select * from
(select * , rank()over(partition by userid order by created_date ) rnk from sales ) a 
 where rnk  =1

--Q4-- What is the most purchased menu item and how many times was it purchased by all customers ?

select userid, count(product_id) cnt  
 from sales
where product_id =
(select product_id  from sales
group by product_id 
order by count(product_id) desc
limit 1)
group by userid

--Q5-- Which item was the most porpular for each customer ?

select * from
(select *, rank()over(partition by userid order by cnt desc) rnk
from
(select userid, product_id, count(product_id)cnt from sales group by userid, product_id)a)b
where rnk =1

--Q6--Which item was purchased first by the customer after they became a member ?

select * from 
(select c.*, rank()over(partition by userid order by created_date)rnk from
(Select a.userid, a.created_date, a.product_id , b.gold_signup_date 
from sales as a 
inner join goldusers_signup  b on a.userid =b.userid 
and created_date >= gold_signup_date) c )d
where rnk =1

--Q7-- What is the total orders and amount spent for each member before they became member ?

select userid , count(created_date),sum(price)from
(select c.* , d.price from
(Select a.userid, a.created_date, a.product_id , b.gold_signup_date 
from sales as a 
inner join goldusers_signup  b on a.userid =b.userid 
and created_date < gold_signup_date ) c
inner join product d on  c.product_id = d.product_id )e
group by userid ; 

--Q8-- If buying each product generate points for eg 5rs - 2 zomato points and each product has different points  for eg  5rs p1 =1 zomato points , for p2 10rs=5zomato points , for p3 5rs = 1 zomato points , calculate points for each customer  

select userid, sum(total_points) total_points_earned from
(select e.*, amt/points total_points from
(select d.* , case when product_id =1 then 5 
when product_id =2 then 2
when product_id =3 then 5 else 0 end as points from
(select c.userid, c.product_id, sum(price) amt from
(select a.*, b.price 
from sales as a
inner join product as b on a.product_id = b.product_id)c 
group by userid, product_id )d)e)f
group by userid ;
       
