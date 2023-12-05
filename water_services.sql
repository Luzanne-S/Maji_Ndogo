-- We should make some notes here
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

-- Task 2: Dive into the water sources
SELECT DISTINCT
	type_of_water_source
FROM
   md_water_services.water_source;

this is the only step in task 2,Finding unique water sources 



-- Task 3: Unpack the visits to water sources
SELECT 
    *
FROM
   md_water_services.visits
WHERE
	time_in_queue > 500
    LIMIT 10;
/* 
finding which visits were longer than 500 mins  
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
finding water source nad source id that matches source id in visits for over 500 mins and 0  mins  
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
above is the right code just to see the number of rows
*/

