DROP TABLE IF EXISTS swiggy;

CREATE TABLE swiggy (
    id BIGINT,
    name TEXT,
    city TEXT,
    rating TEXT,
    rating_count TEXT,
    cost TEXT,
    cuisine TEXT,
    lic_no TEXT,
    link TEXT,
    address TEXT,
    menu TEXT
);

select * from swiggy


****************DATA CLEANING***************************************
-- Check total records
select count(*) from swiggy


-- Check for nulls in key columns


select
sum(case when id is null then 1 else 0 end) as null_ids,
sum(case when name is null then 1 else 0 end) as null_names,
sum(case when city is null then 1 else 0 end) as null_cities,
sum(case when rating is null then 1 else 0 end) as null_ratings,
sum(case when lic_no is null then 1 else 0 end) as null_license
from swiggy


-- Remove rows where rating is 'NEW' or '--' (not yet rated)

delete from swiggy
where rating ='New' or rating='--'


-- Standardise rating to numeric
select rating,count(*)
from swiggy
group by rating
order by rating desc;

update  swiggy
set rating=cast(rating as numeric)
where rating not in('New','--','NA')




****************************************Step 4 — Analysis queries****************************************

-- Q1: How many restaurants are listed per city?

select city,count(name)as total_restaurant from swiggy
group by city
order by total_restaurant desc;


-- Q2: What are the most popular cuisines across India?


select cuisine, count(*) as popular_cuisines from swiggy
group by cuisine
order by popular_cuisines desc
limit 10;


-- Q3: Which restaurant chains have the most branches?


select * from swiggy


select name,count(*) as no_of_branches from swiggy
group by name
order by  no_of_branches desc
limit 10;



-- Q4: Top 5 cities with highest average restaurant rating?

select city,round(avg(rating::numeric),2) as avg_rating from swiggy
where rating not in('NEW','--','NA')
group by city
order by avg_rating desc
limit 5;


-- Q5: What is the average cost for two across cities?

select * from swiggy
select city,round(avg(replace (cost,'₹',' ')::numeric),2) as avg_cost from swiggy
where cost not in ('NA')
group by city
order by avg_cost desc;


-- Q6: Which cuisines have the highest average rating?

select cuisine,round(avg(rating::numeric),2) as avg_rating
from swiggy
where rating not in('New','--','NA')
group by cuisine
order by highest_avg_rating desc;

-- Q7: Restaurants with rating above 4.5 and more than 1000 ratings

SELECT 
    name,
    city,
    rating,
    rating_count,
    cost
FROM swiggy
WHERE rating ~ '^[0-9]+(\.[0-9]+)?$'
  AND rating::numeric > 4.5
  AND (
        CASE
            WHEN rating_count LIKE '%K+ ratings'
                THEN REPLACE(rating_count, 'K+ ratings', '')::numeric * 1000
            ELSE REPLACE(rating_count, '+ ratings', '')::numeric
        END
      ) >= 1000
ORDER BY rating::numeric DESC;



-- Q8: Business insight — which city has best value for money?
-- (high rating, low cost)

select city,round(avg (rating::numeric),2) as avg_rating,round(avg(replace(cost,'₹','')::numeric),2) as avg_cost
from swiggy
where rating not in('New','--','NA')
and cost not in ('NA')
group by city
order by avg_rating desc, avg_cost ;


--Q.9 Which cities have more than 500 restaurants listed?
select * from swiggy

select city,count(name) as no_of_restaurant from swiggy
group by city
having count(name)>500


--Q10. Which restaurant chains have branches in the highest number of different cities?

select name,count(distinct city)  as total_cities
from swiggy
group by name
order by total_cities desc;

--Q11. Which cuisines are available in the largest number of cities?

select cuisine,count(distinct city) total_cities from swiggy
group by cuisine
order by total_cities desc;

--Q.12 What are the top 10 restaurant chains by total number of branches that operate across multiple cities?
select * from swiggy

select name,count(name) as total_branches
from swiggy
group by name
having count(distinct city)>1
order by total_branches desc
limit 10 ;

--Q13. Which cities have the largest variety of cuisines?

select city,count(distinct cuisine) as total_cuisine from swiggy
group by city
order by total_cuisine desc;


--Q14. Which cuisine is the most common cuisine in each city?

with rw as (
  select 
     distinct city,
     cuisine,count(name) as total_restaurant,
     dense_rank() over(partition by city order by count(name) desc ) as rnk from swiggy
   group by  city,cuisine
   order by total_restaurant desc
)
select 
 city,
 cuisine 
from rw
where rnk=1

--Q15. Find the top 3 restaurant chains in each city based on number of branches.
WITH ranked_restaurants AS (
    SELECT
        city,
        name,
        COUNT(*) AS total_branches,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM swiggy
    GROUP BY city, name
)
SELECT
    city,
    name,
    total_branches,
    rnk
FROM ranked_restaurants
WHERE rnk <= 3


Q16. Find restaurants whose branch count is above the overall average branch count of restaurants.
WITH rnk AS (
    SELECT 
        name,
        COUNT(*) AS rest_count
    FROM swiggy
    GROUP BY name
)
SELECT 
    name,
    rest_count
FROM rnk
WHERE rest_count > (SELECT AVG(rest_count) FROM rnk)
ORDER BY rest_count DESC;



Q17. Which restaurants have branches in more than 10 different cities?


with rnk as(
 select name,count(distinct city) city_count
 from swiggy
 group by name
 
)
select name from rnk
where city_count>10
order by city_count desc;




Q18. For each city, find the restaurant chain with the maximum number of branches.

WITH rw AS (
    SELECT city, name,
           COUNT(*) AS no_of_branches,
           DENSE_RANK() OVER(
               PARTITION BY city
               ORDER BY COUNT(*) DESC
           ) AS rnk
    FROM swiggy
    GROUP BY city, name
)
SELECT city, name
FROM rw
WHERE rnk = 1
order by city



Q19. Find the most popular cuisine in each city based on the number of restaurants.

with rw as (
select city,cuisine,count(name)  no_of_rest,dense_rank()over(partition by city order by count(name) desc) as rnk
from swiggy
group by city,cuisine
)

select city,cuisine,no_of_rest
from rw
where rnk=


SELECT current_user;
SELECT inet_server_addr(), inet_server_port();







SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT id) AS unique_ids
FROM swiggy;



SELECT COUNT(*) 
FROM swiggy;