# [LAB] - Day 4 - Window Functions

# We'll wotk on sakila dataset
USE sakila;

# --> Challenge 1



# [Challenge 1]
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
-- You will use it to rank films by their length, their length within the rating category, 
-- and by the actor or actress who has acted in the greatest number of films.



-- 1. Rank films by their length and create an output table that includes 
--    the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.



-- 2. Rank films by length within the rating category and create an output table that includes 
--   the title, length, rating and rank columns only. 
--  Filter out any rows with null or zero values in the length column.



-- 3. Produce a list that shows for each film in the Sakila database, 
--    the actor or actress who has acted in the greatest number of films, 
--    as well as the total number of films in which they have acted. 
--    Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.


# [ Challenge 2]
/*
 This challenge involves analyzing customer activity 
 and retention in the Sakila database to gain insight into business performance. 
 By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions 
 to improve customer retention and increase revenue.

 The goal of this exercise is to perform a comprehensive analysis of customer activity and retention 
 by conducting an analysis on the monthly percentage change in the number of active customers 
 and the number of retained customers. 
*/

-- Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., 
-- the number of unique customers who rented a movie in each month.


# Not the goos answer but useful to check
SELECT
-- customer table--
	DISTINCT customer.customer_id
    , customer.first_name
    , customer.last_name
-- rental table--
    , rental.rental_date
    , MONTH(rental_date)
    , WEEK(rental_date)
    , DAY(rental_date)
    FROM customer
    JOIN rental USING (customer_id)
    GROUP BY rental_date, customer_id
    ORDER BY rental_date;

# The good answer
SELECT
-- rental table--
	MONTH(rental.rental_date) AS month_of_rent
-- customer table--
    , COUNT(DISTINCT customer_id) AS nb_customers
    FROM customer
    JOIN rental USING (customer_id)
    GROUP BY month_of_rent 
    ORDER BY month_of_rent;



-- Step 2. Retrieve the number of active users in the previous month.
SELECT
	COUNT(DISTINCT customer_id) AS active_users
FROM rental
WHERE 
	MONTH(rental_date) = MONTH(CURRENT_DATE() - INTERVAL 1 MONTH)
	AND YEAR(rental_date) = YEAR(CURRENT_DATE() - INTERVAL 1 MONTH);

-- Step 3. Calculate the percentage change in the number of active customers 
-- between the current and previous month.

WITH previous_month_active_users AS (
    SELECT
        COUNT(DISTINCT customer_id) AS active_users_previous_month
    FROM
        rental
    WHERE
        MONTH(rental_date) = MONTH(CURRENT_DATE() - INTERVAL 1 MONTH)
        AND YEAR(rental_date) = YEAR(CURRENT_DATE() - INTERVAL 1 MONTH)
),
current_month_active_users AS (
    SELECT
        COUNT(DISTINCT customer_id) AS active_users_current_month
    FROM
        rental
    WHERE
        MONTH(rental_date) = MONTH(CURRENT_DATE())
        AND YEAR(rental_date) = YEAR(CURRENT_DATE())
)
SELECT
    active_users_current_month,
    active_users_previous_month,
    ROUND(
        ((active_users_current_month - active_users_previous_month) / 
        NULLIF(active_users_previous_month, 0)) * 100,
        2
    ) AS percentage_change
FROM
    current_month_active_users,
    previous_month_active_users;

-- Step 4. Calculate the number of retained customers every month, i.e., 
-- customers who rented movies in the current and previous months.


