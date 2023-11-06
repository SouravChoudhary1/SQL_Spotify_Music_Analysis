CREATE TABLE album2 (
    album_id INT PRIMARY KEY,
    title VARCHAR(20),
    artist_id INT
);

-- Question Set

/* Q1: Who is the senior most employee based on job title? */

select * from employee;
select * from employee order by levels desc limit 1;

/* Q2: Which countries have the most Invoices? */

select * from invoice;
select billing_country, count(*) as Max_Inv_Count from invoice group by billing_country order by Max_Inv_Count desc;

-- HINT: group by needed as USA appears mutliple times in the table--

/* Q3: What are top 3 values of total invoice? */

select total from invoice order by total desc limit 3;

/* Q4: Which 2 cities have the best customers? We would like to throw a promotional Music Festival in the cities we made the most money */

select billing_city, round(sum(total),2) as Total_Inv from invoice group by billing_city order by Total_Inv desc limit 2;

-- HINT: Write a query that returns 2 cities that having the highest sum of invoice totals--

-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer

select * from invoice;
select * from customer;
select customer_id, sum(total) as Total_Inv from invoice group by customer_id order by Total_Inv desc;


select s.customer_id, s.first_name, s.last_name, sum(a.total) as Total_Inv from customer as s
join invoice as a on
s.customer_id = a.customer_id
group by s.customer_id
order by Total_Inv desc


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select * from genre;
select * from customer;
Select * from invoice;
select * from track;
select * from invoice_line;

select distinct c.email as Email, c.first_name, c.last_name from customer as c
join invoice as i on i.customer_id = c.customer_id
join invoice_line as l on i.invoice_id = l.invoice_id
join track as p on p.track_id = l.track_id
join genre as t on t.genre_id = p.genre_id
where t.genre_id=1
order by Email;


-- Q2: Let's invite the artists who have written the most rock music in our dataset. 


SELECT artist.artist_id,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


--  Q3: Return all the track names that have a song length longer than the average song length. 

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1




/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

----------------------------------------------------------------