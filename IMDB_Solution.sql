USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/
 

-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 
    table_name, table_rows
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'imdb';
 
-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT 
    SUM(CASE
        WHEN m.id IS NULL THEN 1
        ELSE 0
    END) AS ID_nulls,
    SUM(CASE
        WHEN m.title IS NULL THEN 1
        ELSE 0
    END) AS title_nulls,
    SUM(CASE
        WHEN m.year IS NULL THEN 1
        ELSE 0
    END) AS year_nulls,
    SUM(CASE
        WHEN m.date_published IS NULL THEN 1
        ELSE 0
    END) AS date_published_nulls,
    SUM(CASE
        WHEN m.duration IS NULL THEN 1
        ELSE 0
    END) AS duration_nulls,
    SUM(CASE
        WHEN m.country IS NULL THEN 1
        ELSE 0
    END) AS country_nulls,
    SUM(CASE
        WHEN m.worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS worldwide_gross_income_nulls,
    SUM(CASE
        WHEN m.languages IS NULL THEN 1
        ELSE 0
    END) AS languages_nulls,
    SUM(CASE
        WHEN m.production_company IS NULL THEN 1
        ELSE 0
    END) AS production_company_nulls
FROM
    movie AS m;
/* From above query we can see,country,worlwide_gross_income,languages,languages has null values */

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

SELECT 
    m.year, 
    COUNT(m.id) AS number_of_movies
FROM
    movie AS m
GROUP BY 
    m.year;
 
 /* Resultset:  2017	3052
                2018	2944
			    2019	2001*/   

SELECT 
    MONTH(m.date_published) AS month_num,
    COUNT(m.id) AS number_of_movies
FROM
    movie AS m
GROUP BY month_num
ORDER BY month_num;

/* From above query we can see,highest number of movies were produced in 2017 */

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
    COUNT(m.id) AS No_of_Movies, m.year
FROM
    movie AS m
WHERE
   (LOWER(country) LIKE '%usa%' OR LOWER(country) LIKE '%india%')
GROUP BY m.year
HAVING m.year = '2019' ;
/*From above query we can see,total 1059 movies were produced in USA and India in the year 2019 */

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT
	DISTINCT g.genre 
FROM 
	genre AS  g;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

WITH summary AS
(
	SELECT 
		genre,
		COUNT(movie_id) AS movie_count,
		RANK () OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM
		genre
	GROUP BY genre
)
SELECT 
    genre,
    movie_count
FROM
    summary
WHERE
    genre_rank = 1;

/* From above query we can see,Drama genre has highest number of movies produced which is 4285 */

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH ct_genre AS
(
	SELECT
		g.movie_id,
		COUNT(g.genre) AS Number_of_genres
		FROM
			genre AS g
		GROUP BY
			g.movie_id
)
SELECT 
	COUNT(ctg.movie_id) AS Number_of_movies
    FROM
    ct_genre AS ctg
    WHERE
    Number_of_genres=1;
    
/* From above query we can see,there are 3289 movies which are associated with only one genre */    

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
	g.genre, 
    ROUND(
    AVG(m.duration),2) AS avg_duration
FROM
	genre AS g
LEFT JOIN 
    movie AS m ON g.movie_id = m.id
GROUP BY
	g.genre
ORDER BY
	 avg_duration DESC;
   
/* The above query shows the average duration of movies for each genre rounded to 2 decimal points. */    

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_rank AS
(
	SELECT g.genre, 
    COUNT(g.movie_id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(g.movie_id) DESC) AS genre_rank
	FROM genre AS g
	GROUP BY g.genre
)
SELECT 
    gr.genre,
    gr.movie_count,
    gr.genre_rank
FROM 
    genre_rank AS gr
    WHERE
    lower(gr.genre) = 'thriller';

/* From above query we see that the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced  is 3*/

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:



-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT
	MIN(r.avg_rating) AS min_avg_rating,
    MAX(r.avg_rating) AS max_avg_rating,
    MIN(r.total_votes) AS min_total_votes,
    MAX(r.total_votes) AS max_total_votes,
    MIN(r.median_rating) AS min_median_rating,
    MAX(r.median_rating) AS max_median_rating
FROM 
	ratings AS r;
    
/*  min_avg_rating : 1.0
    max_avg_rating: 10.0
    min_total_votes: 100
    max_total_votes: 725138
    min_median_rating: 1
    max_median_rating:10    
  */
  
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- Keep in mind that multiple movies can be at the same rank. You only have to find out the top 10 movies (if there are more than one movies at the 10th place, consider them all.)

WITH movie_ranking AS
(SELECT
	m.title as title,
    r.avg_rating as avg_rating,
	DENSE_RANK()
	OVER (ORDER BY r.avg_rating DESC) AS movie_rank
FROM
	movie AS m 
INNER JOIN
    ratings AS r ON r.movie_id = m.id)
SELECT 
    mr.title,
    mr.avg_rating,
    mr.movie_rank
FROM
    movie_ranking AS mr
WHERE 
    mr.movie_rank<=10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, 
    COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY
     median_rating
ORDER BY 
     median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
WITH movie_ranks as
(SELECT
    m.production_company,
    COUNT(m.id) AS movie_count,
    DENSE_RANK() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM
    movie AS m
INNER JOIN
    ratings AS r ON r.movie_id = m.id
WHERE
    avg_rating > 8 AND production_company IS NOT NULL
GROUP BY 
    production_company
ORDER BY
    movie_count DESC)
SELECT 
	   mr.production_company ,
       mr.movie_count,
       mr.prod_company_rank
FROM
       movie_ranks AS mr
WHERE 
	   mr.prod_company_rank=1;
         
       
/*From above query we can see that 'Dream Warrior Pictures' and 'National Theatre Live' both have produced the most number of hit movies (average rating > 8) */

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT
	g.genre,
    COUNT(m.title) AS movie_count
FROM
	genre AS g 
INNER JOIN movie m ON g.movie_id = m.id
INNER JOIN ratings r ON r.movie_id = g.movie_id
WHERE
	lower(m.country) LIKE '%usa%' AND MONTH(m.date_published) = 3 AND YEAR(m.date_published) = 2017 AND r.total_votes >1000
GROUP BY
	genre
ORDER BY
	movie_count DESC;

/*  Resultset:
		Drama	24
		Comedy	9
		Action	8
		Thriller 8
		Sci-Fi	7
		Crime	6
		Horror	6
		Mystery	4
		Romance	4
		Fantasy	3
		Adventure 3
		Family	1*/
-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT 
      m.title, 
      r.avg_rating,
      g.genre 
FROM
      movie  AS m 
INNER JOIN 
      ratings AS r on m.id=r.movie_id
INNER JOIN 
       genre g on g.movie_id=m.id
WHERE 
     (r.avg_rating > 8 and title like 'The%')
ORDER BY 
      g.genre,r.avg_rating desc;

/* From the above query we ca see 'The Brighton Miracle' has highest average rating of 9.5 among movies of each genre that start with the word ‘The’ and which have an average rating > 8 */


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below :

SELECT
       COUNT(m.id) AS Movie_released_april2018_april2019 
FROM
       movie AS m 
INNER JOIN 
        ratings r on m.id=r.movie_id
WHERE 
	   (m.date_published BETWEEN '2018-04-01' AND '2019-04-01') AND (r.median_rating = 8);
        
 /* From the above query we can see of the movies released between 1 April 2018 and 1 April 2019, 361 were given a median rating of 8    */    
    
-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

WITH votes_summary AS
(
SELECT 
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN m.id END) AS german_movie_count,
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN m.id END) AS italian_movie_count,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN r.total_votes END) AS german_movie_votes,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN r.total_votes END) AS italian_movie_votes
FROM
    movie AS m 
	    INNER JOIN
	ratings AS r 
		ON m.id = r.movie_id
)
SELECT 
    ROUND(german_movie_votes / german_movie_count, 2) AS german_votes_per_movie,
    ROUND(italian_movie_votes / italian_movie_count, 2) AS italian_votes_per_movie
FROM
    votes_summary;
     
   

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT
        SUM(case when n.name is null then 1 else 0 end) as name_nulls,
        SUM(case when n.height is null then 1 else 0 end) as height_nulls,
        SUM(case when n.date_of_birth is null then 1 else 0 end) as date_of_birth_nulls,
        SUM(case when n.known_for_movies is null then 1 else 0 end) as known_for_movies_nulls
FROM
        names AS n;

/* Answer: 0 nulls in name; 17335 nulls in height; 13413 nulls in date_of_birth; 15226 nulls in known_for_movies.
   There are no null values in the 'name' column. */ 
   
/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH Top_Three_Genre AS (
    SELECT
        g.genre,
        COUNT(m.id) AS Movie_count
    FROM
        movie AS m
    INNER JOIN
        genre AS g ON m.id = g.movie_id
    INNER JOIN
        ratings r ON r.movie_id = m.id
    WHERE
        r.avg_rating > 8
    GROUP BY
        g.genre
    ORDER BY
        Movie_count DESC
    LIMIT 3
)
SELECT
    n.name AS director_name,
    COUNT(m.id) AS Movie_count
FROM
    movie AS m
INNER JOIN
    director_mapping AS d ON m.id = d.movie_id
INNER JOIN
    names AS n ON n.id = d.name_id
INNER JOIN
    genre AS g ON g.movie_id = m.id
INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    g.genre IN (SELECT genre FROM Top_Three_Genre)
    AND r.avg_rating > 8
GROUP BY
    director_name
ORDER BY
    Movie_count DESC
LIMIT 3;

/*The top three directors in the top three genres whose movies have an average rating > 8 are
James Mangold having directed 4 movies, Joe Russo,Anthony Russo having directed 3 movies 
with average rating > 8 are top directors */

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT
    n.name AS Actor_name,
    COUNT(m.id) AS Movie_count
FROM
    movie  AS m
INNER JOIN
    ratings AS r ON m.id = r.movie_id
INNER JOIN
    role_mapping AS rm ON m.id = rm.movie_id
INNER JOIN
    names n ON n.id = rm.name_id
WHERE
    median_Rating >= 8 AND category = 'ACTOR'
GROUP BY
    Actor_name
ORDER BY
    Movie_count DESC
LIMIT 2;

/*The top two actors whose movies have a median rating >= 8 are 'Mammootty' and 'Mohanlal' */
/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


WITH Ranked_Production_Companies AS (
    SELECT
        m.production_company,
        SUM(r.total_votes) AS Vote_count,
        ROW_NUMBER() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
    FROM
        movie AS m
    INNER JOIN
        ratings AS r ON m.id = r.movie_id
    GROUP BY
        m.production_company
)
SELECT
    production_company,
    Vote_count,
    prod_comp_rank
FROM
    Ranked_Production_Companies
WHERE
    prod_comp_rank <= 3;


/*The top three production houses based on the number of votes received by their movies are - 
'Marvel Studios','Twentieth Century Fox','Warner Bros.' */

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


SELECT
                n.NAME   AS actor_name,
                Sum(r.total_votes) as total_votes,
                Count(r.movie_id)  AS  movie_count,
                Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2) AS actor_avg_rating,
                Rank()  OVER(ORDER BY Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2)  DESC, Sum(r.total_votes) DESC) AS actor_rank
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
                INNER JOIN role_mapping AS rm
                        ON m.id = rm.movie_id
                INNER JOIN names AS n
                        ON rm.name_id = n.id
         WHERE  category = 'ACTOR'
                AND LOWER(country) like '%india%'
         GROUP  BY NAME
         HAVING movie_count >= 5;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT
		n.NAME AS actress_name,
		Sum(r.total_votes) AS total_votes,
		Count(r.movie_id)  AS  movie_count,
		Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2) AS actress_avg_rating,
		ROW_NUMBER() OVER ( ORDER BY ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) DESC, SUM(r.total_votes) DESC) AS actress_rank     
 FROM   movie AS m
		INNER JOIN ratings AS r
				ON m.id = r.movie_id
		INNER JOIN role_mapping AS rm
				ON m.id = rm.movie_id
		INNER JOIN names AS n
				ON rm.name_id = n.id
 WHERE  
        rm.category = 'actress'   AND m.country like  '%India%' AND m.languages like '%Hindi%'
 GROUP  BY 
        actress_name
 HAVING
        movie_count >= 3
 LIMIT 5;       
 
 /* Top 3 actresses are Taapsee Pannu,Kriti Sanon,Kriti Sanon*/

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	
    Note: Sort the output by average ratings (desc).
--------------------------------------------------------------------------------------------*/
/* Output format:
+---------------+-------------------+
| movie_name	|	movie_category	|
+---------------+-------------------+
|	Get Out		|			Hit		|
|		.		|			.		|
|		.		|			.		|
+---------------+-------------------+*/

-- Type your code below:
SELECT
    m.title as movie_name,    
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        WHEN r.avg_rating < 5 THEN 'Flop movies'
    END AS movie_category
FROM
    movie AS m
LEFT JOIN
    ratings AS r ON r.movie_id = m.id
LEFT JOIN
    genre AS g ON m.id = g.movie_id    
WHERE
    LOWER(g.genre) = 'thriller' AND r.total_votes >=25000
ORDER BY 
    r.avg_rating DESC;  

/* Joker tops the list of thriller movies */

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT
    g.genre,
    ROUND(AVG(m.duration)) AS avg_duration,
    SUM(ROUND(AVG(m.duration), 1)) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    ROUND(AVG(AVG(m.duration)) OVER (ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS moving_avg_duration
FROM
    movie AS m
INNER JOIN
    genre AS g ON m.id = g.movie_id
GROUP BY 
    g.genre
ORDER BY
    g.genre; 

-- Round is good to have and not a must have; Same thing applies to sorting
-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
	RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
,
top_grossing AS
(
SELECT 
    g.genre,
	year,
	m.title as movie_name,
    worlwide_gross_income,
    RANK() OVER (PARTITION BY g.genre, year
					ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), UNSIGNED INT) DESC) AS movie_rank
FROM
movie AS m
	INNER JOIN
genre AS g
	ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_genres WHERE genre_rank<=3)
)
SELECT * 
FROM
	top_grossing
WHERE movie_rank<=5;

-- Retrieve the results of the top movies in the top genres. 
-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH top_prod AS
(
SELECT 
    m.production_company,
    COUNT(m.id) AS movie_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE median_rating>=8 AND m.production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank <= 2;
    
    /* Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies */

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	  actress_avg_rating |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.6000		     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
WITH actress_summary AS
(
   SELECT     n.NAME AS actress_name,
			  SUM(r.total_votes) AS total_votes,
			  Count(r.movie_id) AS movie_count,
			  Round(Sum(r.avg_rating*r.total_votes)/Sum(r.total_votes),2) AS actress_avg_rating
   FROM     
   movie  AS m
   INNER JOIN  ratings  AS r   ON    m.id=r.movie_id
   INNER JOIN role_mapping AS rm  ON  m.id = rm.movie_id
   INNER JOIN names AS n ON rm.name_id = n.id
   INNER JOIN genre AS g ON g.movie_id = m.id
   WHERE 
   rm.category = 'actress'  AND  r.avg_rating > 8  AND lower(g.genre) = "drama"
   GROUP BY n.NAME 
	)
SELECT   
         sm.actress_name,
         sm.total_votes,
         sm.movie_count,
         sm.actress_avg_rating,
         Rank() OVER(ORDER BY  sm.actress_avg_rating DESC,sm.total_votes DESC,sm.actress_name ASC) AS actress_rank
FROM    
   actress_summary AS sm
LIMIT 3;

/* Amanda Lawrence,Denise Gough,Susan Brown are top  3 actresses based on the number of Super Hit movies  */
/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH top_directors AS
(
SELECT 
	n.id as director_id,
    n.name as director_name,
	COUNT(m.id) AS movie_count,
    RANK() OVER (ORDER BY COUNT(m.id) DESC) as director_rank
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
GROUP BY n.id
),
movie_summary AS
(
SELECT
	n.id as director_id,
    n.name as director_name,
    m.id AS movie_id,
    m.date_published,
	r.avg_rating,
    r.total_votes,
    m.duration,
    LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published) AS next_date_published,
    DATEDIFF(LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published),date_published) AS inter_movie_days
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE n.id IN (SELECT director_id FROM top_directors WHERE director_rank<=9)
)
SELECT 
	director_id,
	director_name,
	COUNT(DISTINCT movie_id) as number_of_movies,
	ROUND(AVG(inter_movie_days),0) AS avg_inter_movie_days,
	ROUND(
	SUM(avg_rating*total_votes)
	/
	SUM(total_votes)
		,2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM 
movie_summary
GROUP BY director_id
ORDER BY number_of_movies DESC, avg_rating DESC;
     
/* A.L. Vijay,Andrew Jones and Steven Soderbergh  are the top 3 directors (based on number of movies)*/     
    






