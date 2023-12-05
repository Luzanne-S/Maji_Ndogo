-- Task 1: Getting to know the data
SELECT
   *
FROM
	data_dictionary,
   location,
   employee,
   global_water_access,
   visits,
   water_quality,
   water_source,
   well_pollution
LIMIT 5;

 -- location table
SELECT
   *
FROM
   location
LIMIT 5;
-- Add some notes
SELECT
   *
FROM
	water_source
   
LIMIT 5;
/*Understanding what is in the database to make sifting through it more efficient*/



-- Task 2: Dive into the water sources
SELECT DISTINCT
	type_of_water_source
FROM
   md_water_services.water_source;


/*Going through to find the unique types of water sources*/



-- Task 3: Unpack the visits to water sources
SELECT 
    *
FROM
   md_water_services.visits
WHERE
	time_in_queue > 500
    LIMIT 10;
/* 
finding out which visits were longer than 500 mins  
*/
SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served
FROM
   md_water_services.water_source

WHERE
    source_id = 'AkKi00881224'
    OR source_id = 'SoRu376352244'
    OR source_id = 'SoRu36096224'
    OR source_id = 'AkRu05234224'
    OR source_id = 'AkLu01628224'
    OR source_id = 'SoRu38776224'
    OR source_id = 'HaRu19601224'
     OR source_id = 'HaZa21742224';
/*  
Going through the log book, allows us to see which locations were visited numerous times and the signaficance that repeat visits by the team have on the outcome of the findings
*/


-- Task 4: Assess the quality of water sources
SELECT 
	record_id,
    subjective_quality_score,
    visit_count,
    type_of_water_source
FROM
   md_water_services.water_quality,
   md_water_services.water_source

WHERE
	subjective_quality_score = 10
    AND type_of_water_source = 'tap_in_home'
    AND visit_count >= 2
;
SELECT COUNT(*)

FROM
   md_water_services.water_quality

WHERE
	subjective_quality_score = 10
    AND visit_count = 2;
/* 
To find the water sources with a decent water quality score, these findings can help us in prioritising water sources with a lower water quality
*/

-- Task 5: Investigate any pollution issues
SELECT 
	*
FROM 
	md_water_services.well_pollution
    LIMIT 5
;
/* 
find the table 
*/

SELECT 
	source_id,
    date,
    description,
    pollutant_ppm,
    biological,
    results
    
FROM 
	md_water_services.well_pollution
    
WHERE
   results = 'Clean'
AND biological > 0.01;
/* 
find the inconsistency
*/
SELECT 
	*
    
FROM 
	md_water_services.well_pollution
    
WHERE
results LIKE 'Clean%';
/* 
find the inconsistency that has clean incorrectly
*/
SET SQL_SAFE_UPDATES = 0;
UPDATE
	well_pollution
SET
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';
--  updated new one
SET SQL_SAFE_UPDATES = 0;
UPDATE
	well_pollution
SET
	description = 'Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';
/* 
find the inconsistency that has clean incorrectly
*/
-- create new table as a copy so that we eliminate any mistake in the existing table
CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
   *
FROM
   md_water_services.well_pollution);
-- then make changes 
UPDATE
   well_pollution_copy
SET
   description = 'Bacteria: E.coli'
WHERE
   description = 'Clean Bacteria: E. coli';
UPDATE
   well_pollution_copy
SET
   description = 'Bacteria: Giardia Lamblia'
WHERE
   description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
   well_pollution_copy
SET
   results = 'Contaminated: Biological'
WHERE
   biological > 0.01 AND results = 'Clean';

-- when copy comes back clean then change in real copy 
UPDATE
   well_pollution
SET
   description = 'Bacteria: E. coli'
WHERE
   description = 'Clean Bacteria: E. coli';
UPDATE
   well_pollution
SET
   description = 'Bacteria: Giardia Lamblia'
WHERE
   description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
   well_pollution
SET
   results = 'Contaminated: Biological'
WHERE
   biological > 0.01 AND results = 'Clean';
DROP TABLE
   md_water_services.well_pollution_copy;
-- and delete copy table

