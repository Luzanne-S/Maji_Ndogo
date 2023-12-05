-- Task 1:Clean the data
/*add new email address from employee names*/
SELECT 
	CONCAT(
	LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email
from
	employee
    
/*update column with new email addresses*/
SET SQL_SAFE_UPDATES =0;
UPDATE employee 
SET email =
	CONCAT(
	LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');
    
/*change phone number length*/
SELECT 
	phone_number,
    length(TRIM(phone_number))
    FROM
    employee;
        
/*TRIM and update phone number*/
SET SQL_SAFE_UPDATES =0;
UPDATE employee 
SET phone_number =
       TRIM(phone_number);
       


-- Task 2: Honouring the workers
/* aggregate data, count how many employees live in certain towns*/
SELECT
	town_name,
    COUNT(address)
FROM
	employee
GROUP BY
	town_name;
    
/*use the database to get the employee_ids and use those to get the names, email and phone numbers of the three field surveyors with the most location visits*/
SELECT
	assigned_employee_id,
    COUNT(visit_count) AS number_of_visits
FROM
	md_water_services.visits
GROUP BY 
	assigned_employee_id
ORDER BY  COUNT(visit_count) desc
LIMIT 3;          

/* find employees info matchin id */
SELECT
	employee_name,
    phone_number,
    email
FROM
	employee
WHERE
	assigned_employee_id = 1
	OR assigned_employee_id = 30
	OR assigned_employee_id = 34
	;




-- Task 3: Analysing Locations
/* Create a query that counts the number of records per town */
SELECT 
	town_name,
	COUNT(town_name) AS records_per_town
FROM location
	GROUP BY 
		town_name;

/* count the records per province */
SELECT 
	province_name,
	COUNT(province_name) AS records_per_province
FROM location
	GROUP BY 
		province_name;

/* count the records province and town*/
SELECT 
	province_name,
    town_name,
	COUNT(town_name) AS records_per_town
FROM location
GROUP BY 
		province_name,
        town_name
ORDER BY province_name DESC;

/*number of records for each location type*/
SELECT 
	location_type,
	COUNT(location_type) AS num_sources
FROM location
GROUP BY 
		location_type;
        SELECT ROUND(23740 / (15910 + 23740) * 100) -- Sees the number in percentage (rural percentage is 60%)
        


-- Task 4: Diving into the sources
/*How many people did we survey in total?*/
SELECT 
	SUM(number_of_people_served) AS total_people_surveyed
FROM water_source;


/*. How many wells, taps and rivers are there?*/
SELECT 
	type_of_water_source,
    COUNT(type_of_water_source) AS number_of_sources
FROM 	
	water_source
GROUP BY 
	type_of_water_source;


/*. How many people share particular types of water sources on average?*/
SELECT 
	type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS avg_people_per_source
FROM 	
	water_source
GROUP BY 
	type_of_water_source
ORDER BY avg_people_per_source;
                     -- MEANS THAT 1 TAP IN HOME = 644/ 6 = ROUGHLY 100 TAPS


/*.  How many people are getting water from each type of source?*/
SELECT 
	type_of_water_source,
    SUM(number_of_people_served) AS population_served
FROM 	
	water_source
GROUP BY 
	type_of_water_source
ORDER BY population_served DESC;
 -- to find the % of people use:
 SELECT 
	type_of_water_source,
    ROUND(SUM(number_of_people_served)/ 27628140 * 100)  AS percentage_people_per_source
FROM 	
	water_source
GROUP BY 
	type_of_water_source

ORDER BY 
    percentage_people_per_source;
 
 
 
 -- Task 5: Start of a solution
/* rank type of water source and population served */
SELECT 
	type_of_water_source,
    SUM(number_of_people_served) AS people_served,
    RANK () OVER(
		ORDER BY 
		SUM(number_of_people_served) DESC) AS rank_by_population
FROM 	
	md_water_services.water_source
GROUP BY type_of_water_source;
 
/* rank  with source id, sources, number of people, and rank*/ 
SELECT
	source_id,
	type_of_water_source,
    number_of_people_served,
    RANK () OVER(
		PARTITION BY type_of_water_source
		ORDER BY 
		 number_of_people_served) AS priority_rank
FROM 	
	water_source
WHERE
	type_of_water_source <> 'tap_in_home'
    AND type_of_water_source <> 'tap_in_home_broken'
    AND type_of_water_source <> 'well';   
   
    
    
-- Task 6: Analysing queues
/*Q1 - How long did the survey take*/
SELECT 
  DATEDIFF(MAX_time, MIN_time) AS days_elapsed
FROM (
  SELECT 
    MIN(time_of_record) AS MIN_time,
    MAX(time_of_record) AS MAX_time
  FROM md_water_services.visits
) AS subquery;


/*Q2 -  how long people have to queue on average*/
SELECT
	AVG(NULLIF(time_in_queue,0)) AS average_queue_time
from visits;


/*Q3 -  queue times aggregated across the different days of the week.*/
SELECT
	dayname(time_of_record) AS day_of_week,
	ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY day_of_week;  -- only sunday and saturday figures are the same as the example

/*Q4 -   what time during the day people collect water,  order the results*/
SELECT
	hour(time_of_record) AS hour_of_day,
	ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;
/* to get hours more readable */

SELECT
	TIME_FORMAT(time(time_of_record), '%H:00') AS hour_of_day,
	ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- to see if we only see specific day like sunday
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    DAYNAME(time_of_record),
    CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END AS Sunday
FROM
    visits
WHERE
    time_in_queue != 0;

-- specific to certain days and averaging it (we can then create a pivot table to compare results and see the times for each day by the hour)
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Sunday,

-- Monday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Monday,

-- Tuesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Tuesday,

-- Wednesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Wednesday,

-- Thursday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Thursday,

-- Friday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Friday,

-- Saturday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Saturday
FROM
    visits
WHERE
    time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day asc;

/*We can then see the pattern, 
1. Queues are very long on a Monday morning and Monday evenings
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue twice as long on Saturdays compared to the weekdays. 
4. The shortest queues are on Sundays, and this is a cultural thing. Or prioriting religion as most of the country is Christian*/
