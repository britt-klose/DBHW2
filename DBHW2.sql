/* 
DB Assignment 2
Brittany Klose
9/25/24

The following tables and entities were made via upload wizard as CVS files: 
	chefs (chefID, name, specialty)
	restaurants (restID, name, location)
	works (chefID, restID) - indicates which chef works at which restaurant
	foods (foodID, name, type, price) - information about each food item
	serves (restID, foodID, date_sold) - records of which foods are served at which restaurant
    
Below are the queries conducted to the given tables to find particular information
*/

-- -----------------------------------------------------------
-- Query 1: Average Price of Foods at Each Restaurant
-- ------------------------------------------------------------
-- Tables needed for join: restaurant, serves, foods
select r.name as 'Restaurant', avg(f.price) as 'avg_food_price'
from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID
group by r.name
order by avg_food_price asc;

-- -----------------------------------------------------------
-- Query 2: Maximum Food Price at Each Restaurant
-- -----------------------------------------------------------
	-- Tables needed for join: restaurant, serves, foods
select r.name as Restaurant, max(f.price) as max_food_price
from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID
group by r.name
order by max_food_price asc;

-- -----------------------------------------------------------
-- Query 3: Count of Different Food Types Served at Each Restaurant
-- -----------------------------------------------------------
	-- Tables needed for join: restaurant, serves, foods
select r.name as Restaurant, count(distinct f.type) as num_food_types
from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID
group by r.name;
 
-- -----------------------------------------------------------
-- Query 4: Average Price of Foods Served by Each Chef
-- -----------------------------------------------------------
	-- Tables needed for join: foods, chefs, 
-- version 1 with inner join
select c.name as chef, avg(f.price) as avgp_food_served
from chefs c
    inner join foods f on c.specialty = f.type
group by c.name
order by chef asc;

-- version 2 with left outer join
	-- By using left outer all 6 chefs are included and null is put where there are no prices.
select c.name as chef, avg(f.price) as avgp_food_served
from chefs c
    left outer join foods f on c.specialty = f.type
group by c.name
order by chef asc;


-- ----------------------------------------------------------------
-- Query 5: Find the Restaurant with the Highest Average Food Price 
-- ----------------------------------------------------------------
	-- Tables needed for join: restaurant, serves, foods

-- version 1 using having() >= all
select r.name as Restaurant, avg(f.price) as max_avg_price
from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID 
group by r.name
having avg(f.price) >= all (
	select avg(f.price)
    from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID 
	group by r.name
);

-- version 2 using having() = and as subquery 
select r.name as Restaurant, avg(f.price) as max_avg_price
from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID 
group by r.name
having avg(f.price) >= (
	select max(max_avg_price)
    from(
		select avg(f.price) as max_avg_price
        from restaurants r
			inner join serves s on r.restID = s.restID
			inner join foods f on s.foodID = f.foodID 
		group by r.name
	) AS subquery
);

-- -------------------------------------------------------------------
-- Attempt Query 6: Determine which chef has the highest average price of the 
-- foods served at the restaurants where they work.
-- ---------------------------------------------------------------------
-- Ran out of time for this one. Need nested for loop most likely
select c.name as chef, avg(f.price) as avgp_food_served, r.name
from chefs c
    inner join foods f on c.specialty = f.type
    inner join works w on c.chefID = w.chefID
    inner join restaurants r on w.restID = r.restID
group by c.name
order by avgp_food_served desc;


-- -----------------------------------------------------------
-- Table 1: Serves as reference/check for queries 1 & 2
-- Displays each restaurant, the foods they make, and the price of each food
-- -----------------------------------------------------------
select r.name as 'Restaurant', f.name as 'food', f.price as 'Price'
from restaurants r
	inner join serves s on r.restID = s.restID
	inner join foods f on s.foodID = f.foodID
order by restaurant;

-- -----------------------------------------------------------
-- Table 2: Services as a check for query 4
-- Displays chefs, the types of food they make, foods in that category, and their price
	-- *Note will only include chefs who specialize in a food type that has meals and prices.
-- -----------------------------------------------------------
select c.name as chef, c.specialty, f.name as food, f.price
from foods f
    inner join chefs c on f.type = c.specialty
order by chef;


-- -----------------------------------------------------------
-- Table 3: Services as a check for query 6
-- Displays chefs, the types of food they make, foods in that category, and their price
-- -----------------------------------------------------------
-- currently issue where restaurant name is coming up for certain types it doesn't serve.
select c.name as chef, c.chefID, f.name as food, f.type,  f.price, r.name as restaurant
from che c
    inner join foods f on c.specialty = f.type
    inner join works w on c.chefID = w.chefID
    inner join restaurants r on w.restID = r.restID
    inner join serves s on f.foodID = s.foodID
order by chef;