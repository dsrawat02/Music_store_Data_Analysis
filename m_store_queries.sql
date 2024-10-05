--------------------------------------------------------------------------------------------------------
----------------------------------------------- EASY ---------------------------------------------------
--------------------------------------------------------------------------------------------------------

-- (1)
-- Who is the senior most employee based on job title?

SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;


-- (2)
-- Which countries have the most invoices?

SELECT billing_country, COUNT(billing_country) AS most_invoices
FROM invoice
GROUP BY billing_country
ORDER BY most_invoices DESC;


-- (3)
-- What are top 3 values of total invoice?

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;


-- (4)
-- Which city has the best customers? We woukd like to throw a promotional music festival in the city
-- we made the most money. Write a query that returns one city that has the highest sum of invoice total.
-- Return both the city name and sum of all invoive total.

SELECT billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;


-- (5)
-- Who is the best customer?The customer who has spent the most money will be declared as best customer.
-- Write a query that returns the person who has spent the most money.


SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_invoice
FROM customer AS c
JOIN invoice AS i ON i.customer_id=c.customer_id
GROUP BY c.customer_id
ORDER BY total_invoice DESC
LIMIT 1;


--------------------------------------------------------------------------------------------------------
------------------------------------------ MODERATE ----------------------------------------------------
--------------------------------------------------------------------------------------------------------

-- (1)
-- Write a query to return the email, first name, last name and genre of all rock music listeners. Return your
-- list ordered alphabetically by email starting the A.

SELECT email, first_name, last_name
FROM customer c
JOIN invoice i ON i.customer_id=c.customer_id
JOIN invoice_line il ON il.invoice_id=i.invoice_id
JOIN track t ON t.track_id=il.track_id
JOIN genre g ON g.genre_id=t.genre_id
WHERE g.name LIKE '%Rock%'
GROUP BY email, first_name, last_name
ORDER BY email

-------------------------- OR ----------------------------

SELECT distinct email, first_name, last_name
FROM customer c
JOIN invoice i ON i.customer_id=c.customer_id
JOIN invoice_line il ON il.invoice_id=i.invoice_id
WHERE track_id IN (
	SELECT t.track_id
	FROM track t
	JOIN genre g ON g.genre_id=t.genre_id
	WHERE g.name='Rock'
)
ORDER BY email



-- (2)
-- Let's invite the artist who has written the most rock music in our dataset. Write a query that returns
-- the artist name and track counts of the top 10 rock bands.

SELECT a.artist_id, a.name, COUNT(t.track_id) track_count
FROM artist a
JOIN album ab ON ab.artist_id=a.artist_id
JOIN track t ON t.album_id=ab.album_id
JOIN genre g ON g.genre_id=t.genre_id
WHERE g.name='Rock'
GROUP BY a.artist_id
ORDER BY track_count DESC
LIMIT 10;




-- (3)
-- Return all the track names that have a song length longer than the average song length. Return the name
-- and millisecond for each track. Order by the song length with the longest songs listed first?

SELECT track_id, name, milliseconds as song_length
FROM track
WHERE milliseconds > (
		SELECT AVG(milliseconds)
	    FROM track
)
ORDER BY milliseconds DESC


---------------------------------------------------------------------------------------------------------
------------------------------------------- ADVANCED ----------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- (1)
-- Find how much amount spent by each customer on artists? Write a query to return customer name, artist
-- name and total spent.

-- Below query will give you the output for, amount spent by each customer on different artist's album. 
SELECT c.customer_id, c.first_name, c.last_name, at.name as artist_name, 
SUM(il.unit_price * il.quantity) as total_amount_spent
FROM customer c
JOIN invoice i ON i.customer_id=c.customer_id
JOIN invoice_line il ON il.invoice_id=i.invoice_id
JOIN track t ON t.track_id=il.track_id
JOIN album a ON a.album_id=t.album_id
JOIN artist at ON at.artist_id=a.artist_id
GROUP BY 1, 2, 3, 4
order by 2 DESC


-- Below query will give you the output for, amount spent by each customer on highest selling artist's album.
WITH cte1 AS(
	SELECT at.artist_id, at.name, SUM(il.unit_price * il.quantity) as total_spent
	FROM invoice_line il
	JOIN track t ON t.track_id=il.track_id
	JOIN album a ON a.album_id=t.album_id
	JOIN artist at ON at.artist_id=a.artist_id
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, ct.name as artist_name, 
SUM(il.unit_price * il.quantity) as total_amount_spent
FROM customer c
JOIN invoice i ON i.customer_id=c.customer_id
JOIN invoice_line il ON il.invoice_id=i.invoice_id
JOIN track t ON t.track_id=il.track_id
JOIN album a ON a.album_id=t.album_id
JOIN cte1 ct ON ct.artist_id=a.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC



-- (2)
-- We want to find the most popular music genre for each country. We determine the most popular genre as 
-- the genre with the highest amount of purchases. Write a query that returns each country along with the 
-- top genre. For countries where the maximum number of purchases is shared return all genres.

WITH cte1 AS(
	SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS Row_No
	FROM invoice_line il
	JOIN invoice i ON i.invoice_id=il.invoice_id
	JOIN customer c ON c.customer_id=i.customer_id
	JOIN track t ON t.track_id=il.track_id
	JOIN genre g ON g.genre_id=t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC
)
SELECT * 
FROM cte1
WHERE Row_No<=1;

--------------------------------- OR --------------------

WITH RECURSIVE cte1 AS(
	SELECT COUNT(*) AS purchases, c.country, g.name, g.genre_id
	FROM invoice_line il
	JOIN invoice i ON i.invoice_id=il.invoice_id
	JOIN customer c ON c.customer_id=i.customer_id
	JOIN track t ON t.track_id=il.track_id
	JOIN genre g ON g.genre_id=t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2
),
cte2 AS (
	SELECT MAX(purchases) AS max_genre_number, country
	FROM cte1
	GROUP BY 2
	ORDER BY 2
)
SELECT cte1.*
FROM cte1
JOIN cte2 ON cte1.country=cte2.country
WHERE cte1.purchases=cte2.max_genre_number



-- (3)
-- Write a query that determines the customer that has spent the most on music for each country. Write a 
-- query that returns the country along with the top customer and how much they spent. For countries where
-- the top amount spent is shared, provide all customers who spent this amount.

WITH cte1 AS(
	SELECT i.billing_country, i.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_amount_spent,
	ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS Row_No
	FROM invoice i
	JOIN customer c ON c.customer_id=i.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 1
)
SELECT * 
FROM cte1
WHERE Row_No<=1;

