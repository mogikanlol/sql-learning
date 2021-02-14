

CREATE TABLE person
(
	person_id BIGINT,
	fname VARCHAR(20),
	lname VARCHAR(20),
	eye_color VARCHAR(20) CHECK (eye_color in ('BR', 'BL', 'GR')),
	birth_date DATE,
	street VARCHAR(30),
	city VARCHAR(20),
	state VARCHAR(20),
	country VARCHAR(20),
	postal_code VARCHAR(20),
	CONSTRAINT pk_person PRIMARY KEY (person_id)
);


CREATE TABLE favorite_food
(
	person_id BIGINT,
	food VARCHAR(20),
	CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
	CONSTRAINT fk_favorite_food_person_id FOREIGN KEY (person_id) REFERENCES person (person_id)
);

	
-- https://www.postgresqltutorial.com/postgresql-serial/
-- SERIAL type
-- https://www.postgresql.org/docs/9.1/datatype-numeric.html
CREATE SEQUENCE person_id_seq;

ALTER TABLE person ALTER COLUMN person_id SET DEFAULT nextval('person_id_seq');

INSERT INTO person (eye_color)
VALUES ('BR');
-- each time query failed cuz of check, sequence is being incremented
-- SHOW search_path;


ALTER SEQUENCE person_id_seq RESTART WITH 1;

INSERT INTO person
(fname, lname, eye_color, birth_date)
VALUES ('William','Turner', 'BR', '1972-05-27');

SELECT person_id, fname, lname, birth_date
FROM person
WHERE person_id = 1;

SELECT person_id, fname, lname, birth_date
FROM person
WHERE lname = 'Turner';


INSERT INTO favorite_food (person_id, food)
VALUES 
(1, 'pizza'),
(1, 'cookies'),
(1, 'nachos');


SELECT food 
FROM favorite_food
WHERE person_id = 1
ORDER BY food;


INSERT INTO person
(fname, lname, eye_color, birth_date,
street, city, state, country, postal_code)
VALUES ('Susan','Smith', 'BL', '1975-11-02',
'23 Maple St.', 'Arlington', 'VA', 'USA', '20220');


SELECT person_id, fname, lname, birth_date
FROM person;



UPDATE person
SET 
street = '1225 Tremont St.',
city = 'Boston',
state = 'MA',
country = 'USA',
postal_code = '02138'
WHERE person_id = 1;


DELETE FROM person
WHERE person_id = 2;



-- SHOULD RETURN ERROR
-- nonunique primary key
INSERT INTO person
(person_id, fname, lname, eye_color, birth_date)
VALUES (1, 'Charles','Fulton', 'GR', '1968-01-1');

-- nonexistent foreign key
INSERT INTO favorite_food (person_id, food)
VALUES (43, 'lazagna');

-- column value violation
UPDATE person
SET eye_color = 'ZZ'
WHERE person_id = 1;

-- invalid date conversion
-- works in PostgreSQL
-- https://www.postgresql.org/docs/9.1/datatype-datetime.html
UPDATE person
SET birth_date = 'DEC-21-1980'
WHERE person_id = 1;



-- Filtering
-- AND, OR, NOT, !=, <> BETWEEN, IN, LIKE _%
-- _ - exactly one character
-- % - any number of characters (including 0)

-- WRONG: column != NULL
-- CORRECTLY: column IS NOT NULL


-- JOIN
-- CROSS JOIN
-- INNER JOIN
-- USING


-- UNION
-- UNION ALL - doesn't remove duplicates
-- INTERSECT
-- INTERSECT ALL - doesn't remove duplicates
-- EXCEPT
-- EXCEPT ALL - removes only one occurence of duplicate data

-- Strings functions
-- CHAR(), ASCII(), CONCAT()
-- LENGTH(), POSITION() first character is 1, not 0, SUBSTRING()

-- Numeric functions
-- ()+-*/
-- float(3, 1) -> 10.0: 3 (presicion) - amount of all numbers, 1 (scale) - amount of floating point numbers
-- ACOS(), ASIN(), ATAN(), COS(), COT(), EXP(), LN(), SIN(), SQRT(), TAN()
-- MOD() %
-- POW()
-- CEIL(), FLOOR(), ROUND(), TRUNCATE()
-- CEIL - always up
-- FLOOR - always down
-- ROUND - up if number >= 5, otherwise down
-- TRUNCATE - discards without rounding
-- ROUND(17, -1) -> 20, TRUNCATE(17, -1) -> 10
-- SIGN(), ABS()

-- Temporal data
-- functions that return dates
-- timezone (global and session)
-- CAST('2020-10-10 15:30:00' AS DATETIME)
-- str_to_date - (to_date in postgresql)
-- current_date(), current_time(), current_timestamp(), now(), 
-- date_add()
-- last_day()

-- functions that return strings
-- dayname(), extract()

-- functions that return numbers
-- datediff()

-- conversion functions
-- cast()


SELECT SUBSTRING('Please find the substring in this string' from 17 for 9);
SELECT ABS(-25.76823), SIGN(-25.76823), ROUND(-25.76823, 2);
SELECT extract(month from now());


-- Grouping and Aggregates

SELECT customer_id
FROM rental
GROUP BY customer_id;

SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id;


SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
ORDER BY count(*) DESC;

-- we can't use WHERE Since the GROUP BY clause runs after the WHERE clause has been evaluated
-- WRONG
SELECT customer_id, count(*)
FROM rental
WHERE count(*) >= 40
GROUP BY customer_id;

-- CORRECTLY
SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
HAVING count(*) >= 40;


-- Aggregates functions
-- max(), min(), avg(), sum(), count()

SELECT 
	MAX(amount) as max_amt,
	MIN(amount) as min_amt,
	AVG(amount) as avg_amt,
	SUM(amount) as tot_amt,
	COUNT(*) as num_payments
FROM payment;

SELECT 
	customer_id,
	MAX(amount) as max_amt,
	MIN(amount) as min_amt,
	AVG(amount) as avg_amt,
	SUM(amount) as tot_amt,
	COUNT(*) as num_payments
FROM payment
GROUP BY customer_id;

-- Counting distinct values
SELECT 
	COUNT(customer_id) as num_rows
	COUNT(DISTINCT customer_id) as num_customers
FROM payment;


-- Using Expressions (nesting)
-- use a function call as an argument
SELECT MAX(datediff(return_date, rental_date))
FROM rental;

-- How Nulls are Handled

CREATE TABLE number_table
(value BIGINT);

INSERT INTO number_table VALUES (1);

INSERT INTO number_table VALUES (3);

INSERT INTO number_table VALUES (5);

SELECT 
	COUNT(*) as num_rows,
	COUNT(value) as num_values,
	SUM(value) as total,
	MAX(value) as max_value,
	AVG(value) as avg_value
FROM number_table;

INSERT INTO number_table VALUES (NULL);



-- Multicolumn Group

SELECT 
	fa.actor_id, 
	f.rating, 
	count(*)
FROM 
	film_actor AS fa
	INNER JOIN film AS f
	ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating
ORDER BY fa.actor_id, f.rating;

-- Grouping by Expressions

SELECT 
	extract(YEAR FROM rental_date) AS year,
	COUNT(*) as how_many
FROM rental
GROUP BY extract(YEAR FROM rental_date);


-- Generating Rollups

SELECT 
	fa.actor_id, 
	f.rating, 
	count(*)
FROM 
	film_actor AS fa
	INNER JOIN film AS f
	ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating WITH ROLLUP
ORDER BY fa.actor_id, f.rating;

-- additionally counts total films for each distinct actor

-- Group Filter Conditions

SELECT 
	fa.actor_id, 
	f.rating, 
	count(*)
FROM 
	film_actor AS fa
	INNER JOIN film AS f
	ON fa.film_id = f.film_id
WHERE f.rating IN ('G', 'PG')
GROUP BY fa.actor_id, f.rating
HAVING count(*) > 9;


-- Filters in the WHERE are evaluated before the groupping occurs. 
-- If we want to filter grouped data we should use HAVING clause


-- Subqueries

SELECT 
	customer_id,
	first_name,
	last_name
FROM customer
WHERE customer_id = (SELECT MAX(customer_id) FROM customer);


-- Noncorrelated Subqueries

SELECT 
	city_id,
	city
FROM city
WHERE country_id <>
	(SELECT country_id FROM country WHERE country = 'India');


-- Following query will produce an error because you can't use subquery that returns multiple results in an equality condition
SELECT 
	city_id,
	city
FROM city
WHERE country_id <>
	(SELECT country_id FROM country WHERE country <> 'India');

-- Single thing can not be equated to a set of things


-- Multiple-Row, Single-Column Subqueries
-- IN
SELECT 
	city_id,
	city
FROM city
WHERE country_id IN
	(
		SELECT country_id
		FROM country
		WHERE country IN ('Canada', 'Mexico')
	);

-- NOT IN
SELECT 
	city_id,
	city
FROM city
WHERE country_id NOT IN
	(
		SELECT country_id
		FROM country
		WHERE country IN ('Canada', 'Mexico')
	);


-- ALL
SELECT 
	fist_name,
	last_name
FROM customer 
WHERE customer_id <> ALL
	(
		SELECT customer_id
		FROM payment
		WHERE amount = 0
	);

-- It's the same as following:
SELECT 
	fist_name,
	last_name
FROM customer 
WHERE customer_id NOT IN
	(
		SELECT customer_id
		FROM payment
		WHERE amount = 0
	); 

-- The right-hand side is a parenthesized expression, which must yield an array value. 
-- The left-hand expression is evaluated and compared to each element of the array using the given operator, 
-- which must yield a Boolean result. The result of ALL is "true" if all comparisons yield true 
-- (including the case where the array has zero elements). The result is "false" if any false result is found.


-- ANY
-- The right-hand side is a parenthesized expression, which must yield an array value. 
-- The left-hand expression is evaluated and compared to each element of the array using the given operator, 
-- which must yield a Boolean result. The result of ANY is "true" if any true result is obtained. 
-- The result is "false" if no true result is found (including the case where the array has zero elements).	



-- Multicolumn Subqueries


-- single-column subquery
SELECT 
	fa.actor_id,
	fa.film_id
FROM
	film_actor AS fa
WHERE fa.actor_id IN 
	(SELECT actor_id FROM actor WHERE last_name = 'MONROE')
	AND fa.film_id IN
	(SELECT film_id FROM film WHERE rating = 'PG');

SELECT 
	actor_id,
	film_id
FROM film_actor
WHERE (actor_id, film_id) IN
	(SELECT a.actor_id, f.film_id
		FROM actor AS a
			CROSS JOIN film AS f
		WHERE a.last_name = 'MONROE'
		AND f.rating = 'PG'
	);


-- Correlated Subqueries

SELECT 
	c.first_name,
	c.last_name
FROM customer AS c
WHERE 20 = 
	(SELECT count(*) FROM rental as r
		WHERE r.customer_id = c.customer_id);

SELECT 
	c.first_name,
	c.last_name
FROM customer AS c
WHERE 
	(SELECT sum(p.amount) FROM payment AS p
		WHERE p.customer_id = c.customer_id)
	BETWEEN	180 AND 240;


-- The exists Operator

SELECT
	c.first_name,
	c.last_name
FROM customer AS c
WHERE EXISTS
	(SELECT 1 FROM rental AS r
		WHERE r.customer_id = c.customer_id
			AND date(r.rental_date) < '2005-05-25'
	); 


-- It doesn't matter what to retrieve

SELECT
	c.first_name,
	c.last_name
FROM customer AS c
WHERE EXISTS
	(SELECT r.rental_date, r.customer_id, 'ABCD' AS str, 2 * 3 / 7 AS nmbr FROM rental AS r
		WHERE r.customer_id = c.customer_id
			AND date(r.rental_date) < '2005-05-25'
	); 

-- the convention is to specify either select 1 or select * when using exists

-- Not Exists
SELECT 
	a.first_name,
	a.last_name
FROM actor AS a
WHERE NOT EXISTS
	(
		SELECT 1
		FROM film_actor AS fa
			INNER JOIN film AS f 
			ON f.film_id = fa.film_id
		WHERE fa.actor_id = a.actor_id
			AND f.rating = 'R'  
	);




-- Data Manpulation Using Correlated Subqueries

UPDATE customer AS c
SET c.last_update =
	(
		SELECT max(r.rental_date)
		FROM rental AS r
		WHERE r.customer_id = c.customer_id
	);
-- modifies every row in the customer table

UPDATE customer AS c
SET c.last_update = 
	(
		SELECT max(r.rental_date)
		FROM rental AS r
		WHERE r.customer_id = c.customer_id
	)
WHERE EXISTS 
	(
		SELECT 1
		FROM rental AS r
		WHERE r.customer_id = c.customer_id
	);


DELETE FROM customer AS c
WHERE 365 < ALL 
	(
		SELECT datediff(now(), r.rental_date) AS days_since_last_rental
		FROM rental AS r
		WHERE r.customer_id = c.customer_id
	);

-- When to Use Subqueries

-- Subqueries as Data Sources

SELECT
	c.fisrt_name,
	c.last_name,
	pymnt.num_rentals,
	pymnt.tot_payments
FROM customer AS c
	INNER JOIN 
	(
		SELECT 
			customer_id,
			count(*) AS num_rentals,
			sum(amount) AS tot_payments
		FROM payment
		GROUP BY customer_id
	) AS pymnt
	ON c.customer_id = pymnt.customer_id;

-- Data fabrication


SELECT 
	pymnt_grps.name,
	count(*) AS num_customers,
FROM 
	(
		SELECT 
			customer_id,
			count(*) AS num_rentals,
			sum(amount) AS tot_payments
		FROM payment
		GROUP BY customer_id
	) AS pymnt
	INNER JOIN 
	(
		SELECT 
			'Small Fry' AS name,
			0 AS low_limit,
			74.99 AS high_limit
		UNION ALL
		SELECT 
			'Average Joes' AS name,
			75 AS low_limit,
			149.99 AS high_limit
		UNION ALL
		SELECT 
			'Heavy Hitters' AS name,
			150 AS low_limit,
			9999999.99 AS high_limit
	) pymnt_grps
	ON pymnt.tot_payments
		BETWEEN pymnt_grps.low_limit AND pymnt_grps.high_limit
GROUP BY pymnt_grps.name;


-- Task-oriented subqueries


SELECT 
	c.first_name,
	c.last_name,
	ct.city,
	sum(p.amount) AS tot_payments,
	count(*) AS tot_rentals
FROM payment AS p
	INNER JOIN customer AS c
	ON p.customer_id = c.customer_id
	INNER JOIN address AS a
	ON c.address_id = a.address_id
	INNER JOIN city AS ct
	ON a.city_id = ct.city_id
GROUP BY 
	c.fist_name, 
	c.last_name, 
	ct.city;

-- Can be written as following query

SELECT 
	c.first_name,
	c.last_name,
	ct.city,
	pymnt.tot_payments,
	pymnt.tot_rentals,
FROM 
	(
		SELECT 
			customer_id,
			count(*) AS tot_rentals,
			sum(amount) AS tot_payments
		FROM payment
		GROUP BY customer_id
	) AS pymnt
	INNER JOIN customer AS c
	ON pymnt.customer_id = c.customer_id
	INNER JOIN address AS a
	ON c.address_id = a.address_id
	INNER JOIN city AS ct
	ON a.city_id = ct.city_id;


-- Common table expressions

WITH actors_s AS 
	(	SELECT
			actor_id,
			fist_name,
			last_name
		FROM actor
		WHERE last_name LIKE 'S%' 
	),
	actor_s_pg AS 
	(
		SELECT
			s.actor_id,
			s.first_name,
			s.last_name,
			f.film_id,
			f.title
		FROM actors_s AS s
			INNER JOIN film_actor AS fa
			ON s.actor_id = fa.actor_id
			INNER JOIN film AS f
			ON f.film_id = fa.film_id
		WHERE f.rating = 'PG'
	),
	actor_s_pg_revenue AS
	(
		SELECT 
			spg.first_name,
			spg.last_name,
			p.amount
		FROM actors_s_pg AS spg
			INNER JOIN inventory AS i
			ON i.film_id = spg.film_id
			INNER JOIN rental AS r
			ON i.inventory_id = r.inventory_id
			INNER JOIN payment AS p
			ON r.rental_id = p.rental_id
	) -- end of With clause
SELECT 
	spg_rev.first_name,
	spg_rev.last_name,
	sum(spg_rev.amount) AS tot_revenue
FROM actors_s_pg_revenue AS spg_rev
GROUP BY 
	spg_rev.first_name,
	spg_rev.last_name
ORDER BY 3 DESC;


-- Subqueries as Expression Generators

SELECT 
	(
		SELECT
			c.first_name
		FROM customer AS c
		WHERE c.customer_id = p.customer_id
	) AS fist_name,
	(
		SELECT 
			c.last_name
		FROM customer AS c
		WHERE c.customer_id = p.customer_id
	) AS last_name,
	(
		SELECT
			ct.city
		FROM customer AS c
		INNER JOIN address AS a
			ON c.address_id = a.address_id
		INNER JOIN city AS ct
			ON a.city_id = ct.city_id
		WHERE c.customer_id = p.customer_id
	) AS city,
	sum(p.amount) AS tot_payments,
	count(*) AS tot_rentals
FROM payment AS p
GROUP BY 
	p.customer_id;

-- There are two main differences between this query and the earlier version using a subquery in the from clause:
-- • Instead of joining the customer, address, and city tables to the payment data,
-- correlated scalar subqueries are used in the select clause to look up the customer’s first/last names and city.
-- • The customer table is accessed three times (once in each of the three subqueries) rather than just once



SELECT
	a.actor_id,
	a.first_name,
	a.last_name
FROM actor AS a
ORDER BY
	(
		SELECT 
			count(*)
		FROM film_actor AS fa
		WHERE fa.actor_id = a.actor_id
	) DESC;


INSERT INTO film_actor (actor_id, film_id, last_update)
VALUES 
(
	(
		SELECT 
			actor_id 
		FROM actor
		WHERE first_name = 'JENNIFER' AND last_name = 'DAVIS'
	),
	(
		SELECT
			film_id
		FROM film
		WHERE title = 'ACE GOLDFINGER'
	),
	now()
);


-- Joins Revisited
-- Outer Joins

SELECT 
	f.film_id,
	f.title,
	count(*) AS num_copies
FROM film AS f
	INNER JOIN inventory AS i
	ON f.film_id = i.film_id
GROUP BY 
	f.film_id,
	f.title;

-- LEFT OUTER JOIN
SELECT 
	f.film_id,
	f.title,
	count(i.inventory_id) AS num_copies
FROM film AS f
	LEFT OUTER JOIN inventory AS i
	ON f.film_id = i.film_id
GROUP BY 
	f.film_id,
	f.title;

-- Previous queries without group by
SELECT 
	f.film_id,
	f.title,
	i.inventory_id
FROM film AS f
	INNER JOIN inventory AS i
	ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

SELECT 
	f.film_id,
	f.title,
	i.inventory_id
FROM film AS f
	LEFT OUTER JOIN inventory AS i
	ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;


-- Left Versus Right Outer Joins

-- Previous query using RIGHT OUTER JOIN

SELECT 
	f.film_id,
	f.title,
	i.inventory_id
FROM inventory AS i
	RIGHT OUTER JOIN film AS film
	ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

-- Three-Way Outer Joins

SELECT 
	f.film_id,
	f.title,
	i.inventory_id,
	r.rental_date
FROM film AS f
	LEFT OUTER JOIN inventory AS i
	ON f.film_id = i.film_id
	LEFT OUTER JOIN rental AS r
	ON i.inventory_id = r.inventory_id
WHERE f.film_id BETWEEN 13 AND 15;


-- Cross Joins
-- Used for Cartesian product

SELECT 
	c.name AS category_name,
	l.name AS language_name
FROM category AS c
	CROSS JOIN language AS l;


SELECT DATE_ADD('2020-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) AS dt
FROM
	(
		SELECT 0 num UNION ALL
		SELECT 1 num UNION ALL
		SELECT 2 num UNION ALL
		SELECT 3 num UNION ALL
		SELECT 4 num UNION ALL
		SELECT 5 num UNION ALL
		SELECT 6 num UNION ALL
		SELECT 7 num UNION ALL
		SELECT 8 num UNION ALL
		SELECT 9 num
	) AS ones
	CROSS JOIN
	(
		SELECT 0 num UNION ALL
		SELECT 10 num UNION ALL
		SELECT 20 num UNION ALL
		SELECT 30 num UNION ALL
		SELECT 40 num UNION ALL
		SELECT 50 num UNION ALL
		SELECT 60 num UNION ALL
		SELECT 70 num UNION ALL
		SELECT 80 num UNION ALL
		SELECT 90 num
	) AS tens
	CROSS JOIN
	(
		SELECT 0 num UNION ALL
		SELECT 100 num UNION ALL
		SELECT 200 num UNION ALL
		SELECT 300 num
	) AS hundreds
WHERE DATE_ADD('2020-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY ) < '2021-01-01'
ORDER BY 1;




SELECT 
	days.dt, 
	COUNT(r.rental_id) AS num_rentals
FROM rental AS r
	RIGHT OUTER JOIN
	(
		SELECT DATE_ADD('2005-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) AS  dt
		FROM
		(	SELECT 0 num UNION ALL
			SELECT 1 num UNION ALL
			SELECT 2 num UNION ALL
			SELECT 3 num UNION ALL
			SELECT 4 num UNION ALL
			SELECT 5 num UNION ALL
			SELECT 6 num UNION ALL
			SELECT 7 num UNION ALL
			SELECT 8 num UNION ALL
			SELECT 9 num
		) AS ones
		CROSS JOIN
		(	SELECT 0 num UNION ALL
			SELECT 10 num UNION ALL
			SELECT 20 num UNION ALL
			SELECT 30 num UNION ALL
			SELECT 40 num UNION ALL
			SELECT 50 num UNION ALL
			SELECT 60 num UNION ALL
			SELECT 70 num UNION ALL
			SELECT 80 num UNION ALL
			SELECT 90 num
		) AS tens
		CROSS JOIN
		(	SELECT 0 num UNION ALL
			SELECT 100 num UNION ALL
			SELECT 200 num UNION ALL
			SELECT 300 num
		) AS hundreds
		WHERE DATE_ADD('2005-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) < '2006-01-01'
	) AS days
	ON days.dt = date(r.rental_date)
GROUP BY 
	days.dt
ORDER BY 1;


-- Natural Joins

SELECT 
	c.first_name,
	c.last_name,
	date(r.rental_date)
FROM customer AS c
	NATURAL JOIN rental AS r;


SELECT 
	cust.fist_name,
	cust.last_name,
	date(r.rental_date)
FROM
	(
		SELECT 
			customer_id,
			fist_name,
			last_name
		FROM customer
	) AS cust
	NATURAL JOIN rental AS r;

-- Avoid this Join type;


-- Conditional Logic

SELECT 
	first_name,
	last_name
	CASE 
		WHEN active = 1 THEN 'ACTIVE'
		ELSE 'INACTIVE'
	END AS activity_type
FROM customer;

-- Case expression is part of the SQL standard (SQL92)

-- Searched case Expressions

CASE 
	WHEN C1 THEN E1
	WHEN C2 THEN E2
	...
	WHEN CN THEN EN
	[ELSE ED]
END
-- C - condition, E - expression, ED - default expression, else clause is optional

CASE 
	WHEN category.name IN ('Children', 'Family', 'Sports', 'Animation')
		THEN 'All Ages'
	WHEN category.name = 'Horror'
		THEN 'Adult'
	WHEN category.name IN ('Music', 'Games')
		THEN 'Teens'
	ELSE 'Other'
END


SELECT 
	c.fist_name,
	c.last_name,
	CASE 
		WHEN active = 0 THEN 0
		ELSE 
			(
				SELECT count(*) FROM rental AS r
				WHERE r.customer_id = c.customer_id
			)
	END AS num_rentals
FROM customer AS c;


-- Simple case Expression

CASE V0
	WHEN V1 THEN E1
	WHEN V2 THEN E2
	...
	WHEN VN THEN EN
	[ELSE ED]
END

-- V0 - value, V1, V2, VN - values to be compared to V0
-- E1, E2, EN - expressions, ED - default expression

CASE category.name
	WHEN 'Children' THEN 'All Ages'
	WHEN 'Family' THEN 'All Ages'
	WHEN 'Sports' THEN 'All Ages'
	WHEN 'Animation' THEN 'All Ages'
	WHEN 'Horror' THEN 'Adult'
	WHEN 'Music' THEN 'Teens'
	WHEN 'Games' THEN 'Teens'
	ELSE 'Other'
END



-- Result Set Transformations

SELECT 
	monthname(rental_date) AS rental_month,
	count(*) AS num_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01'
GROUP BY monthname(rental_date);

------------------------------ 
| rental_month | num_rentals |
------------------------------ 
| May          |        1156 |
| June         |        2311 |
| July         |        6709 |
------------------------------

-- Translates previous query result into single row result 

SELECT 
	SUM(CASE WHEN monthname(rental_date) = 'May' THEN 1 ELSE 0 END) AS May_rentals,
	SUM(CASE WHEN monthname(rental_date) = 'June' THEN 1 ELSE 0 END) AS June_rentals,
	SUM(CASE WHEN monthname(rental_date) = 'July' THEN 1 ELSE 0 END) AS July_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01';

---------------------------------------------
| May_rentals | June_rentals | July_rentals |
---------------------------------------------
|        1156 |         2311 |         6709 |
---------------------------------------------
-- SQL Server and Oracle Database include pivot clauses specifically for these types of queries



-- Checking for Existence

SELECT 
	a.fist_name,
	a.last_name,
	CASE
		WHEN EXISTS (
						SELECT 1 
						FROM film_actor AS fa
							INNER JOIN film AS f
							ON fa.film_id = f.film_id
						WHERE fa.actor_id = a.actor_id
							AND f.rating = 'G'
					) THEN 'Y'
		ELSE 'N'
	END AS g_actor,
	CASE 
		WHEN EXISTS (
						SELECT 1
						FROM film_actor AS fa
							INNER JOIN film AS f
							ON fa.film_id = f.film_id
						WHERE fa.actor_id = a.actor_id
							AND f.rating = 'PG'
					) THEN 'Y'
		ELSE 'N'
	END AS pg_actor,
	CASE 
		WHEN EXISTS (
						SELECT 1
						FROM film_actor AS fa
							INNER JOIN film AS f
							ON fa.film_id = f.film_id
						WHERE fa.actor_id = a.actor_id
							AND f.rating = 'NC-17'
					) THEN 'Y'
		ELSE 'N'
	END AS nc17_actor
FROM actor AS a
WHERE a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';


SELECT 
	f.title,
	CASE (
	     	SELECT count(*)
	     	FROM inventory AS i
	     	WHERE i.film_id = f.film_id
		 )
		WHEN 0 THEN 'Out Of Stock'
		WHEN 1 THEN 'Scarce'
		WHEN 2 THEN 'Scarce'
		WHEN 3 THEN 'Available'
		WHEN 4 THEN 'Available'
		ELSE 'Common'
	END AS film_availability
FROM film AS f;


-- Division-by-Zero Errors
-- Some databases throw an error, but others set result of the calculation to null

-- To avoid this you should wrap all denominators in conditional logic

SELECT 
	c.first_name,
	c.last_name,
	sum(p.amount) AS tot_payment_amt,
	count(p.amount) AS num_payments,
	sum(p.amount) / 
		CASE WHEN count(p.amount) = 0 THEN 1
			ELSE count(p.amount)
		END AS avg_payment
FROM customer AS c
	LEFT OUTER JOIN payment AS p
	ON c.customer_id = p.customer_id
GROUP BY
	c.first_name,
	c.last_name;


-- Conditional Updates

UPDATE customer
SET active = 
	CASE
		WHEN 90 <= (SELECT datediff(now(), max(rental_date))
					FROM rental AS r
					WHERE r.customer_id = customer.customer_id)
			THEN 0
		ELSE 1
	END 
WHERE active = 1;


-- Handling Null Values

SELECT 
	c.fist_name,
	c.last_name,
	CASE 
		WHEN a.address IS NULL THEN 'Unknown'
		ELSE a.address
	END AS address,
	CASE
		WHEN ct.city IS NULL THEN 'Unknown'
		ELSE ct.city
	END AS city,
	CASE
		WHEN cn.county IS NULL THEN 'Unknown'
		ELSE cn.country
	END AS country
FROM customer AS c
	LEFT OUTER JOIN address AS a
	ON c.address_id = a.address_id
	LEFT OUTER JOIN city AS ct
	ON a.city_id = ct.city_id
	LEFT OUTER JOIN country AS cn
	ON ct.country_id = cn.country_id;


-- SELECT 100 * NULL will result as NULL



-- Transactions

-- Locking
-- 1) Read-Write Locking
-- 2) Versioning (MVCC - Multiversion concurrency control)


-- Lock Granularities

-- Table locks
-- Page locks
-- Row locks


-- What is a Transaction?
-- Transaction is a device for grouping together multiple SQL statements such that either all or none of the statements succeed


-- Pseudocode

START TRANSACTION;
/* withdraw money from first account, making sure balance is sufficient */
UPDATE account SET avail_balance = avail_balance - 500
WHERE account_id = 9988
	AND avail_balance > 500;

IF <exactly one row was updated by the previous statement> THEN

	/* deposit money into second account */
	UPDATE account SET avail_balance = avail_balance + 500
	WHERE account_id = 9989;

	IF <exactly one row was updated by the previous statement> THEN 
		/* everything worked, make the changes permanent */
		COMMIT;
	ELSE
		/* something went wrong, undo all changes in this transaction */
		ROLLBACK;
	END IF;
ELSE 
	/* insufficient funds, or error encountered during update */
	ROLLBACK;
END IF;


-- Starting a Transaction
START TRANSACTION;
-- Autocommit Mode Disabling
-- SQL Server
SET IMPLICIT_TRANSACTIONS ON

-- MySQL
SET AUTOCOMMIT=0


-- Ending a Transaction
COMMIT;
ROLLBACK;
	
-- Scenarious by which transaction can end, as an indirect result of our actions or as a result of something outside our control:

-- The server shuts down -> Transaction will be rolled back
-- Issuing an SQL schema statement, such as ALTER TABLE -> Current Transaction will be committed and new Transaction will be started
	-- Alterations to database cannot be rolled back  
-- Issuing another START TRANSACTION command -> Current Transaction will be committed
-- The server detects a deadlock -> Transaction will be rolled back with an error


-- Transaction Savepoints

SAVEPOINT my_savepoint;

ROLLBACK TO SAVEPOINT my_savepoint;

START TRANSACTION;

UPDATE product
SET date_retired = CURRENT_TIMESTAMP()
WHERE product_cd = 'XYZ';

SAVEPOINT before_close_accounts;

UPDATE account
SET status = 'CLOSED', close_date = CURRENT_TIMESTAMP(),
	last_activity_date = CURRENT_TIMESTAMP()
WHERE product_cd = 'XYZ';

ROLLBACK TO SAVEPOINT before_close_accounts;

COMMIT;

-- If we use ROLLBACK without naming a savepoints, all savepoints will be ignored and the entire transaction will be undone


-- Indexeds and Constraints


-- Indexes
-- Index is a mechanism for finding a specific item within a resource
-- Indexes are special tables that are kept in a specific order. Instead of containing all of the data about an entity, 
-- an index contains only the column (or columns) used to locate rows in the data table, 
-- along with information describing where the rows are physically localted 

-- Index Creation

-- MySQL
ALTER TABLE customer
ADD INDEX idx_email (email);

ALTER TABLE customer
DROP INDEX idx_email;


-- Unique Indexes

-- MySQL
ALTER TABLE customer
ADD UNIQUE idx_email (email);


-- Multicolumn indexes
ALTER TABLE customer
ADD INDEX idx_full_name (last_name, first_name);
-- This index will be useful for queries that specify the first and last names or just the last name
-- But it would not be useful for queries that specify only the customer's first name
-- Order of columns matters


-- Types of Indexes

-- B-tree indexes (Balanced-tree indexes)

				-----------------------------------------
			    | A-M                               N-Z |
			    -----------------------------------------
		         /                                     \
  ------------------------------	     --------------------------------  
  |	A-C,  D-F,   G-I,      J-M |         | N-P,   Q-S,     T-V,     W-Z |
  ------------------------------         --------------------------------
   /       |      |           \           /        |        |          \	
Barker   Fleming Gooding   Jameson      Parker    Roberts  Tucker   Ziegler
Blake    Fowler  Grossman  Markham      Portman   Smith    Tulman
                 Hawthorne Mason                           Tyler




-- Bitmap indexes

-- Used for low-cardinality data
-- There are low-cardinality and high-cardinality data

-- Text indexes

-- `Explain` statement 


-- The Downside of Indexes

-- Every index is a table (a special type of table)



-- Constraints

-- Primary key constraints
	-- Identify the column of columns that guarantee uniqueness within a table
-- Foreign key constraints
	-- Restrict one or more columns to contain only values found in another table's primary key columns
-- Unique constraints
	-- Restrict one or more columns to contain unique values within a table
	-- (primary key constraints are a special type of unique constraint)
-- Check constraints
	-- Restrict the allowable values for a column


-- Constraint Creation

ALTER TABLE customer
ADD CONSTRAINT fk_customer_address FOREGIN KEY (address_id)
REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- ON DELETE RESTRICT - the server raises an error if a row is deleted in the parent table (address) that is referenced in the child table (customer)
-- ON UPDATE CASCADE - the server propagates a change to the primary key value of a parent table (address) to the child table (customer)


-- ON DELETE RESTRICT
-- ON UPDATE CASCADE
-- ON DELETE SET NULL
-- ON UPDATE RESTRICT
-- ON UPDATE SET NULL




-- Views

-- A view is a mechanism for querying data. Views do not involve data storage


CREATE VIEW customer_vw
(
	customer_id,
	first_name,
	last_name,
	email
)
AS
SELECT
	customer_id,
	first_name,
	last_name,
	concat(substr(email, 1, 2), '*****', substr(email, -4)) AS email
FROM customer;


SELECT 
	first_name,
	last_name,
	email
FROM
	customer_vw;

SELECT
	first_name,
	count(*),
	min(last_name),
	max(last_name)
FROM customer_vw
WHERE first_name LIKE 'J%'
GROUP BY first_name
HAVING count(*) > 1
ORDER BY 1;


SELECT 
	cv.first_name,
	cv.last_name,
	p.amount
FROM customer_vw AS cv
	INNER JOIN payment AS p
	ON cv.customer_id = p.customer_id
WHERE p.amount >= 11;



-- Why Use Views?

-- Data Security

CREATE VIEW customer_vw
(
	customer_id,
	first_name,
	last_name,
	email
)
AS
SELECT
	customer_id,
	first_name,
	last_name,
	concat(substr(email, 1, 2), '*****', substr(email, -4)) AS email
FROM customer
WHERE active = 1;

-- This view excludes inactive customers



-- Data Aggregation

CREATE VIEW sales_by_film_category
AS
SELECT
	c.name AS category,
	SUM(p.amount) AS total_sales
FROM payment AS p
	INNER JOIN rental AS r ON p.rental_id = r.rental_id
	INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
	INNER JOIN film AS f ON i.film_id = f.film_id
	INNER JOIN film_category AS fc ON f.film_id = fc.film_id
	INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;



-- Hiding Complexity

CREATE VIEW film_stats
AS
SELECT 
	f.film_id, 
	f.title, 
	f.description, 
	f.rating,
	(	SELECT 
			c.name
		FROM category AS c
			INNER JOIN film_category AS fc
			ON c.category_id = fc.category_id
		WHERE fc.film_id = f.film_id
	) AS category_name,
	(	SELECT 
			count(*)
		FROM film_actor AS fa
		WHERE fa.film_id = f.film_id
	) AS num_actors,
	(	SELECT 
			count(*)
		FROM inventory AS i
		WHERE i.film_id = f.film_id
	) AS inventory_cnt,
	(	SELECT 
			count(*)
		FROM inventory AS i
			INNER JOIN rental AS r
			ON i.inventory_id = r.inventory_id
		WHERE i.film_id = f.film_id
	) AS num_rentals
FROM film AS f;

-- from clause has only one table
-- If someone uses this view but does not reference the category_name, num_actors, inventory_cnt, or num_rentals column
-- then none of the subqueries will be executed


-- Joining Partitioned Data

CREATE VIEW payment_all
(
payment_id,
customer_id,
staff_id,
rental_id,
amount,
payment_date,
last_update
)
AS 
SELECT
	payment_id,
	customer_id,
	staff_id,
	rental_id,
	amount,
	payment_date,
	last_update
FROM payment_historic
UNION ALL
SELECT
	payment_id,
	customer_id,
	staff_id,
	rental_id,
	amount,
	payment_date,
	last_update
FROM payment_current;




-- Updatable Views

-- Conditions for MySQL:

-- No aggregate functions are used
-- The view does not employ group by or having clauses 
-- No subqueries exist in the select or from clause, and any subqueries in the where clause do not refer to tables in the from clause
-- The view does not utilize union, union all, or distinct
-- The from clause includes at least one table or updatable view
-- The from clause uses only inner joins if there is more than one table or view


-- Updating Simple Views

CREATE VIEW customer_vw
(
	customer_id,
	first_name,
	last_name,
	email
)
AS
SELECT
	customer_id,
	first_name,
	last_name,
	concat(substr(email, 1, 2), '*****', substr(email, -4)) AS email
FROM customer;


UPDATE customer_vw
SET last_name = 'SMITH-ALLEN'
WHERE customer_id = 1;


-- But we can't modify the email column
-- customer_vw cannot be used for inserting data, because it contains a derived column



-- Updating Complex Views


CREATE VIEW customer_details
AS
SELECT
	c.customer_id,
	c.store_id,
	c.last_name,
	c.address_id,
	c.active,
	c.create_date,
	a.address,
	ct.city,
	cn.country,
	a.postal_code
FROM customer AS c
	INNER JOIN address AS a
	ON c.address_id = a.address_id
	INNER JOIN city AS ct
	ON a.city_id = ct.city_id
	INNER JOIN country AS cn
	ON ct.country_id = cn.country_id;


-- Modify the customer.last_name and customer.active columns
UPDATE customer_details
SET 
	last_name = 'SMITH-ALLEN',
	active = 0
WHERE customer_id = 1;

-- Modify the address.address column
UPDATE customer_details
SET address = '999 Mockingbird Lane'
WHERE customer_id = 1; 

-- We can't modify the customer and address tables in one statement
-- It will produce an error
UPDATE customer_details
SET last_name = 'SMITH-ALLEN',
	active = 0,
	address = '999 Mockingbird Lane'
WHERE customer_id = 1; 


-- Inserting in customer table columns works fine
INSERT INTO customer_details
(
customer_id, store_id, first_name, last_name, address_id, active, create_date
)
VALUES (9998, 1, 'BRIAN', 'SALAZAR', 5, 1, now());




-- Inserting in customer and address tables doesn't work. It will produce an error
INSERT INTO customer_details
(
customer_id, store_id, first_name, last_name, address_id, active, create_date, address
)
VALUES (9998, 1, 'BRIAN', 'SALAZAR', 5, 1, now(), '999 Mockingbird Lane');




-- Metadata

-- information_schema


-- information about all tables and views
SELECT 
	table_name,
	table_type
FROM information_schema.tables
WHERE table_schema = 'sakila'
ORDER BY 1;


-- information about tables without views
SELECT 
	table_name,
	table_type
FROM information_schema.tables
WHERE table_schema = 'sakila'
	AND table_type = 'BASE TABLE'
ORDER BY 1;


-- information about views
SELECT 
	table_name,
	is_updatable
FROM information_schema.views
WHERE table_schema = 'sakila'
ORDER BY 1;



-- information about columns
SELECT
	column_name,
	data_type,
	character_maximum_length AS char_max_len,
	numeric_precision AS num_prcsn,
	numeric_scale AS num_scale
FROM information_schema.columns
WHERE table_schema = 'sakila' AND table_name = 'film'
ORDER BY ordinal_position;


-- information about indexes

SELECT
	index_name,
	non_unique,
	seq_in_index,
	column_name
FROM information_schema.statistics
WHERE table_schema = 'sakila' AND table_name = 'rental'
ORDER BY 1, 3;


-- information about constraints

SELECT 
	constraint_name,
	table_name,
	constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'sakila'
ORDER BY 3, 1;


-- MySQL information_schema views:
	-- schemata
	-- tables
	-- columns
	-- statistics
	-- user_privileges
	-- schema_privileges
	-- table_privileges
	-- column_privileges
	-- character_sets
	-- collations
	-- collation_character_set_applicability
	-- table_constraints
	-- key_column_usage
	-- routines
	-- views
	-- triggers
	-- plugins
	-- engines
	-- partitions
	-- events
	-- processlist
	-- referential_constraints
	-- parameters
	-- profiling




-- Working with Metadata

-- Schema Generation Scripts

CREATE TABLE category
(
category_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
name VARCHAR(25) NOT NULL,
last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
	ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


SELECT 'CREATE TABLE category (' AS create_table_statement
UNION ALL
SELECT cols.txt
FROM 
	(
		SELECT concat(' ', column_name, ' ', column_type,
			CASE 
				WHEN is_nullable = 'NO' THEN ' not null'
				ELSE ''
			END,
			CASE
				WHEN extra IS NOT NULL AND extra LIKE 'DEFAULT_GENERATED%'
					THEN concat(' DEFAULT ', column_default, substr(extra, 18))
				WHEN extra IS NOT NULL THEN concat(' ', extra)
				ELSE ''
			END,
			',') AS txt
		FROM information_schema.columns
		WHERE table_schema = 'sakila' AND table_name = 'category'
		ORDER BY ordinal_position
	) AS cols
UNION ALL
SELECT ')';




SELECT 'CREATE TABLE category (' AS create_table_statement
UNION ALL
SELECT cols.txt
FROM
	(
		SELECT concat(' ',column_name, ' ', column_type,
		CASE
			WHEN is_nullable = 'NO' THEN ' not null'
			ELSE ''
		END,
		CASE
			WHEN extra IS NOT NULL AND extra LIKE 'DEFAULT_GENERATED%'
				THEN concat(' DEFAULT ',column_default,substr(extra,18))
			WHEN extra IS NOT NULL THEN concat(' ', extra)
			ELSE ''
		END,
		','
	) AS txt
	FROM information_schema.columns
	WHERE table_schema = 'sakila' AND table_name = 'category'
	ORDER BY ordinal_position
	) as cols
UNION ALL
SELECT concat(' constraint primary key (')
FROM information_schema.table_constraints
WHERE table_schema = 'sakila' AND table_name = 'category'
AND constraint_type = 'PRIMARY KEY'
UNION ALL
SELECT cols.txt
FROM
	(
		SELECT concat(CASE WHEN ordinal_position > 1 THEN ' ,'
		ELSE ' ' END, column_name) AS txt
		FROM information_schema.key_column_usage
		WHERE table_schema = 'sakila' AND table_name = 'category'
		AND constraint_name = 'PRIMARY'
		ORDER BY ordinal_position
	) AS cols
UNION ALL
SELECT ' )'
UNION ALL
SELECT ')';





-- Deployment Verification

-- that query returns the number of columns, number of indexes, and number of primary key constraints (0 or 1) for each table in the Sakila schema

SELECT tbl.table_name,
	(
		SELECT count(*) 
		FROM information_schema.columns AS clm
		WHERE clm.table_schema = tbl.table_schema
		AND clm.table_name = tbl.table_name
	) AS num_columns,
	(
		SELECT count(*) 
		FROM information_schema.statistics AS sta
		WHERE sta.table_schema = tbl.table_schema
		AND sta.table_name = tbl.table_name
	) AS num_indexes,
	(
		SELECT count(*) 
		FROM information_schema.table_constraints AS tc
		WHERE tc.table_schema = tbl.table_schema
		AND tc.table_name = tbl.table_name
		AND tc.constraint_type = 'PRIMARY KEY'
	) AS num_primary_keys
FROM information_schema.tables AS tbl
WHERE tbl.table_schema = 'sakila' AND tbl.table_type = 'BASE TABLE'
ORDER BY 1;



-- Dynamic SQL Generation

SET @qry = 'SELECT customer_id, first_name, last_name FROM customer';
PREPARE dynsql1 FROM @qry;
EXECUTE dynsql1;
DEALLOCATE PREPARE dynsql1;


SET @qry = 'SELECT customer_id, first_name, last_name FROM customer WHERE customer_id = ?'

PREPARE dynsql2 FROM @qry;
SET @custid = 9;
EXECUTE dynsql2 USING @custid;

SET @custid = 145;
EXECUTE dynsql2 USING @custid;
DEALLOCATE PREPARE dynsql2;



SELECT concat('SELECT ',
	concat_ws(',', cols.col1, cols.col2, cols.col3, cols.col4,
		cols.col5, cols.col6, cols.col7, cols.col8, cols.col9),
		' FROM customer WHERE customer_id = ?')
		INTO @qry
FROM
	(
		SELECT
		max(CASE WHEN ordinal_position = 1 THEN column_name
		ELSE NULL END) AS col1,
		max(CASE WHEN ordinal_position = 2 THEN column_name
		ELSE NULL END) AS col2,
		max(CASE WHEN ordinal_position = 3 THEN column_name
		ELSE NULL END) AS col3,
		max(CASE WHEN ordinal_position = 4 THEN column_name
		ELSE NULL END) AS col4,
		max(CASE WHEN ordinal_position = 5 THEN column_name
		ELSE NULL END) AS col5,
		max(CASE WHEN ordinal_position = 6 THEN column_name
		ELSE NULL END) AS col6,
		max(CASE WHEN ordinal_position = 7 THEN column_name
		ELSE NULL END) AS col7,
		max(CASE WHEN ordinal_position = 8 THEN column_name
		ELSE NULL END) AS col8,
		max(CASE WHEN ordinal_position = 9 THEN column_name
		ELSE NULL END) AS col9
		FROM information_schema.columns
		WHERE table_schema = 'sakila' AND table_name = 'customer'
		GROUP BY table_name
	) AS cols;

PREPARE dynsql3 FROM @qry;

SET @custid = 45;
EXECUTE dynsql3 USING @custid;
DEALLOCATE PREPARE dynsql3;



-- Analytic Functions



-- Data Windows

-- over
-- partition by

SELECT
	quarter(payment_date) AS quarter,
	monthname(payment_date) AS month_nm,
	sum(smount) AS monthly_sales
FROM payment
WHERE year(payment_date) = 2005
GROUP BY 
	quarter(payment_date), 
	monthname(payment_date);


SELECT
	quarter(payment_date) AS quarter,
	monthname(payment_date) AS month_nm,
	sum(smount) AS monthly_sales,
	max(sum(amount))
		over () AS max_overall_sales,
	max(sum(amount))
		over (partition by quarter(payment_date)) AS max_qrtr_sales
FROM payment
WHERE year(payment_date) = 2005
GROUP BY 
	quarter(payment_date), 
	monthname(payment_date);




-- Localized Sorting

SELECT
	quarter(payment_date) AS quarter,
	monthname(payment_date) AS month_nm,
	sum(smount) AS monthly_sales,
	rank() over (order by sum(amount) desc) AS sales_rank
FROM payment
WHERE year(payment_date) = 2005
GROUP BY 
	quarter(payment_date), 
	monthname(payment_date)
ORDER BY 1, month(payment_date);



-- `order by` with `partition by`

SELECT
	quarter(payment_date) AS quarter,
	monthname(payment_date) AS month_nm,
	sum(smount) AS monthly_sales,
	rank() over (partition by quarter(payment_date) order by sum(amount) desc) AS qtr_sales_rank
FROM payment
WHERE year(payment_date) = 2005
GROUP BY 
	quarter(payment_date), 
	monthname(payment_date)
ORDER BY 1, month(payment_date);



-- Ranking

-- Ranking Functions
	-- row_number() - Returns a unique number for each row, with rankings arbitrarily assigned in case of a tie
	-- rank() - Returns the same ranking in case of a tie, with gaps in the rankings
	-- dense_rank() - Returns the same ranking in case of a tie, with no gaps in the rankings


SELECT 
	customer_id,
	count(*) AS num_rentals
FROM rental
GROUP BY customer_id
ORDER BY 2 DESC;




SELECT
	customer_id,
	count(*) AS num_rentals,
	row_number() over (order by count(*) desc) AS row_number_rnk,
	rank() over (order by count(*) desc) AS rank_rnk,
	dense_rank() over (order by count(*) desc) AS dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 DESC;


-- Example of the gap:
	-- num_rentals | rank_rnk
	-- 42		   | 3
	-- 42		   | 3
	-- 43          | 5



-- Generating Multiple Rankings

SELECT 
	customer_id,
	monthname(rental_date) AS rental_month,
	count(*) AS num_rentals
FROM rental
GROUP BY 
	customer_id,
	monthname(rental_date)
ORDER BY 2, 3 DESC;


SELECT 
	customer_id,
	monthname(rental_date) AS rental_month,
	count(*) AS num_rentals,
	rank() over (partition by monthname(rental_date) order by count(*) desc) AS rank_rnk
FROM rental
GROUP BY 
	customer_id,
	monthname(rental_date)
ORDER BY 2, 3 DESC;



SELECT
	customer_id,
	rental_month,
	num_rentals,
	rank_rnk AS ranking
FROM
	(
		SELECT 
			customer_id,
			monthname(rental_date) AS rental_month,
			count(*) AS num_rentals,
			rank() over (partition by monthname(rental_date) order by count(*) desc) AS rank_rnk
		FROM rental
		GROUP BY 
			customer_id,
			monthname(rental_date);
	)
WHERE rank_rnk <= 5
ORDER BY rental_month, num_rentals DESC, rank_rnk;




-- Reporting Functions

-- min(), max(), avg(), sum(), count()

SELECT 
	monthname(payment_date) AS payment_month,
	amount,
	sum(amount)
		over (partition by monthname(payment_date)) AS monthly_total,
	sum(amount) over () AS grand_total
FROM payment
WHERE amount >= 10
ORDER BY 1;





SELECT 
	monthname(payment_date) AS payment_month,
	sum(amount) AS month_total,
	round(sum(amount) / sum(sum(amount)) over ()
		* 100, 2) AS pct_of_total
FROM payment
GROUP BY monthname(payment_date);

-- This query calculates the total payments for each month by summing the amount column, 
-- and then calculates the percentage of the total payments for each month by
-- summing the monthly sums to use as the denominator in the calculation.



SELECT 
	monthname(payment_date) AS payment_month,
	sum(amount) AS month_total,
	CASE sum(amount)
		WHEN max(sum(amount)) over () THEN 'Highest'
		WHEN min(sum(amount)) over () THEN 'Lowest'
		ELSE 'Middle'
	END AS descriptor
FROM payment;



-- Window Frames


SELECT
	yearweek(payment_date) AS payment_week,
	sum(amount) AS week_total,
	sum(sum(amount))
		over (order by yearweek(payment_date)
			rows unbounded preceding) AS rolling_sum
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY 1;

-- The rolling_sum column expression includes the rows unbounded preceding subclause
-- to define a data window from the beginning of the result set up to and including the current row. 
-- The data window consists of a single row for the first row in the result set, two rows for the second row, etc.
-- The value for the last row is the summation of the entire result set



SELECT 
	yearweek(payment_date) AS payment_week,
	sum(amount) AS week_total,
	avg(sum(amount))
		over (order by yearweek(payment_date)
			rows between 1 precending and 1 following) AS rolling_3wk_avg
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY 1;


# I don't understand, maybe I will learn it later




 



do $$
	declare 
		counter integer := 0;
	begin
		while (counter < 5) loop
			IF counter = 4 THEN
				RAISE EXCEPTION 'my-test-exception';
			END IF;
			
			INSERT INTO my_table (name, age) VALUES ('test-' || counter, counter);
			counter := counter + 1;
		end loop;
	end
$$;

https://www.postgresqltutorial.com/plpgsql-while-loop/
https://www.postgresql.org/docs/current/sql-do.html


Relational database
NoSQL (database)















