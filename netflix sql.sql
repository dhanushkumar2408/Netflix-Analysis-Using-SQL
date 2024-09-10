--SCHEMA
create table netflix(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year INT,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);


-- Count the number of Movies vs TV Shows

select 
type,
count(*) as total_content
from netflix
group by type;

--Find the most common rating for movies and TV shows
select
type,
rating
from
(select 
type,
rating,
count(*),
rank()over(partition by type order by count(*)desc)as ranking
from netflix
group by type,rating) as t1
where ranking = 1

--List all movies released in a specific year (e.g., 2020)

select
*from netflix
where type='Movie' and release_year=2020;

--Find the top 5 countries with the most content on Netflix

select
unnest(string_to_array(country,','))as new_country,
count(show_id) as total_content
from netflix 
group by country
order by count(show_id)desc
limit 5;

---Identify the longest movies

select*from netflix where type='Movie' and 
duration=
(select
max(duration)from netflix)

--Find content added in the last 5 years

select*
from netflix
where 
TO_DATE(date_added,'Month DD,YYYY')>= current_date - interval '5 years'

--Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT*from netflix
where director like '%Rajiv Chilaka%'

--List all TV shows with more than 5 seasons

select*
from netflix
where
type='TV Show'
and
SPLIT_PART(duration,' ',1)::numeric > 5;

-- Count the number of content items in each genre

select
UNNEST(string_to_array(listed_in,','))as genre,
count(show_id) total_content
from netflix
group by 1;

-- List all movies that are documentaries

select*from netflix
where listed_in like '%Documentaries';

-- Find all content without a director

select*from netflix
where director is null;

--Find how many movies actor 'Salman Khan' appeared in last 10 years!

select*from netflix
where casts like '%Salman Khan%'
and
release_year > extract(YEAR from current_date) - 10

---Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
UNNEST(string_to_array(casts,','))AS actor,
count(*)
from netflix
where country= 'India'
group by 1
order by 2 desc
limit 10;

/*Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

select
category,
type,
count(*) as content_count
from
(select*,
case
when description like '%kill%' or description like '%violence%' then 'Bad'
else 'Good'
end as category
from netflix) as categ_content
group by 1,2
