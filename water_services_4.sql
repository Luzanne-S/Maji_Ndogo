-- Task 1: JOINING PIECES TOGETHER
/*joining visit and location tables*/
SELECT 	
	location.province_name,
    location.town_name,
    visits.visit_count,
    location.location_id
    
    FROM
		location
	JOIN
    visits
		ON visits.location_id = location.location_id
   WHERE  province_name = 'Sokoto'; 
   
  /*joining adding water_source tables to visit and location tables with the shared key of source_id
  To find if there are provinces where water sources are abundant*/
  SELECT 	
	location.province_name,
    location.town_name,
    visits.visit_count,             
    location.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
    
    FROM
		location
	JOIN
    visits
		ON visits.location_id = location.location_id
	JOIN
    water_source
        ON visits.source_id = water_source.source_id;
   -- WHERE visits.location_id = 'AkHa00103' <-- this will see that a location had more than 1 visits  
   SELECT 	
	location.province_name,
    location.town_name,
    visits.visit_count,
    location.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
    
    FROM
		location
	JOIN
    visits
		ON visits.location_id = location.location_id
	JOIN
    water_source
        ON visits.source_id = water_source.source_id
        WHERE visits.visit_count = 1;  -- makes sure only 1 visit is being seen 
        
	/*remove location_id and visit_count and add type and queue*/
	SELECT 	
	location.province_name,
    location.town_name,
    water_source.type_of_water_source,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue
    
    FROM
		location
	JOIN
    visits
		ON visits.location_id = location.location_id
	JOIN
    water_source
        ON visits.source_id = water_source.source_id;
        
/*create left join for well pollution*/
SELECT
		water_source.type_of_water_source,
		location.town_name,
		location.province_name,
		location.location_type,
		water_source.number_of_people_served,
		visits.time_in_queue,
		well_pollution.results
	FROM
		visits
	LEFT JOIN
		well_pollution
	ON well_pollution.source_id = visits.source_id
	INNER JOIN
		location
	ON location.location_id = visits.location_id
	INNER JOIN
		water_source
	ON water_source.source_id = visits.source_id
	WHERE
		visits.visit_count = 1;

/*create view as reference */
CREATE VIEW combined_analysis_table AS        -- This view assembles data from different tables into one to simplify analysis
SELECT
		water_source.type_of_water_source,
		location.town_name,
		location.province_name,
		location.location_type,
		water_source.number_of_people_served,
		visits.time_in_queue,
		well_pollution.results
	FROM
		visits
	LEFT JOIN
		well_pollution
	ON well_pollution.source_id = visits.source_id
	INNER JOIN
		location
	ON location.location_id = visits.location_id
	INNER JOIN
		water_source
	ON water_source.source_id = visits.source_id
	WHERE
		visits.visit_count = 1;	
        
        
-- Task 2: THE LAST ANALYSIS
/*pivot table*/
WITH province_totals AS (      -- Calculates the population of each province in percentages
	SELECT
		province_name,
		SUM(number_of_people_served) AS total_ppl_serv
	FROM
		combined_analysis_table
	GROUP BY
		province_name
)
SELECT
		ct.province_name,
		-- These case statements create columns for each type of source.
		-- The results are aggregated and percentages are calculated
		ROUND((SUM(CASE WHEN type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN  type_of_water_source= 'shared_tap'
		THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN  type_of_water_source= 'tap_in_home'
		THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
		FROM
		combined_analysis_table ct
		JOIN
		province_totals pt ON ct.province_name = pt.province_name
		GROUP BY
		ct.province_name
		ORDER BY
		ct.province_name;      -- can take the table in sql and add it to excel to create a bar graph

/*distinguish between the 2 Harares, we have to group by province first, then by town, so that the duplicate towns are distinct because they are in different towns*/
WITH town_totals AS ( -- This CTE calculates the population of each town
					  -- Since there are two Harare towns, we have to group by province_name and town_name
	SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
	FROM combined_analysis_table
		GROUP BY province_name,town_name
	)
	SELECT
		ct.province_name,
		ct.town_name,
	ROUND((SUM(CASE WHEN type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
	FROM
		combined_analysis_table ct
	JOIN                           -- Since the town names are not unique, we have to join on a composite key
		town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
	GROUP BY 						-- We group by province first, then by town.
		ct.province_name,
		ct.town_name  -- helps with distingushing different harares
	ORDER BY
		ct.town_name;

/*Create temporary table to avoid lagging*/
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS ( 
	SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
	FROM combined_analysis_table
		GROUP BY province_name,town_name
	)
	SELECT
		ct.province_name,
		ct.town_name,
	ROUND((SUM(CASE WHEN type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
	FROM
		combined_analysis_table ct
	JOIN                           
		town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
	GROUP BY 						
		ct.province_name,
		ct.town_name
	ORDER BY
		ct.town_name;         -- WONT BE IN VIEWS BUT IF YOU SELECT * FROM TEMPORARY TABLE, YOULL BE ABLE TO SEE IT
        
/*Find differences in river and province*/
SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
	town_aggregated_water_access
	ORDER BY Pct_broken_taps asc;
    



-- Task 3: SUMMARY REPORT
/*summaries the issues and provides solutions*/

-- A PRACTICAL PLAN
CREATE TABLE Project_progress (
                 Project_id SERIAL PRIMARY KEY,
                source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
                Address VARCHAR(50),
                Town VARCHAR(30),
                Province VARCHAR(30),
                Source_type VARCHAR(50),
                Improvement VARCHAR(50),
                Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
                Date_of_completion DATE,
                Comments TEXT
);
/*implement plan in a database*/
/* Project_id −− Unique key for sources in case we visit the same
source more than once in the future.
*/
         
/* source_id −− Each of the sources we want to improve should exist,
and should refer to the source table. This ensures data integrity.
*/
-- Street address
-- What the engineers should do at that place
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
 -- Engineers will add this the day the source has been upgraded.
 -- Engineers can leave comments. We use a TEXT type that has no limit on char length


/*Join tables to water source table */
SELECT
		location.address,
		location.town_name,
		location.province_name,
		water_source.source_id,
		water_source.type_of_water_source,
		well_pollution.results
FROM
		water_source
LEFT JOIN
		well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
		visits ON water_source.source_id = visits.source_id
INNER JOIN
		location ON location.location_id = visits.location_id
        
/*1. Only records with visit_count = 1 are allowed.
2. Any of the following rows can be included:
a. Where shared taps have queue times over 30 min.
b. Only wells that are contaminated are allowed -- So we exclude wells that are Clean
c. Include any river and tap_in_home_broken sources.*/ -- ADDED THE SUBQUERY TO COUNT NUMBER OF ROWS
SELECT COUNT(*) AS row_count
FROM
	(SELECT
		location.address,
		location.town_name,
		location.province_name,
		water_source.source_id,
		water_source.type_of_water_source,
		well_pollution.results
FROM
		water_source
LEFT JOIN
		well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
		visits ON water_source.source_id = visits.source_id
INNER JOIN
		location ON location.location_id = visits.location_id
WHERE
		visits.visit_count = 1
        AND ( 
			(well_pollution.results != 'Clean')
			OR water_source.type_of_water_source IN ('river','tap_in_home_broken')
            OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
        )
) AS subquery;   


/*Insert into project_progress table*/
INSERT INTO 
		project_progress
        (
        Address,
        Town,
        Province,
        source_id,
        Source_type,
        Improvement    
        )
	SELECT
		location.address,
		location.town_name,
		location.province_name,
		water_source.source_id,
		water_source.type_of_water_source,
		well_pollution.results
FROM
		water_source
LEFT JOIN
		well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
		visits ON water_source.source_id = visits.source_id
INNER JOIN
		location ON location.location_id = visits.location_id
WHERE
		visits.visit_count = 1
        AND ( 
			(well_pollution.results != 'Clean')
			OR water_source.type_of_water_source IN ('river','tap_in_home_broken')
            OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
        );
        

-- A PRACTICAL PLAN
-- Step 1
/*Add control functions to add to improvement column to change contaminated to install etc*/
SELECT 
	CASE Improvement
		WHEN 'Contaminated: Biological' THEN 'Install RO filter'
        WHEN 'Contaminated: Chemical' THEN 'Install UV filter'
        ELSE NULL 
	END AS improvements

FROM
	project_progress;
    /*to change the column */
  SET SQL_SAFE_UPDATES=0;
	UPDATE project_progress
	SET Improvement = 
		CASE Improvement
			WHEN 'Contaminated: Biological' THEN 'Install RO filter'
			WHEN 'Contaminated: Chemical' THEN 'Install UV filter'
			ELSE NULL 
		END  


-- Step 2,3 & 4
/*update  river data to drill well for improvements column*/
SELECT 
    p.source_id,
    CASE
        WHEN source_type = 'well' AND improvement = 'Contaminated: Biological' THEN 'Install RO filter'
        WHEN source_type = 'well' AND improvement = 'Contaminated: Chemical' THEN 'Install UV filter'
        WHEN source_type = 'river' THEN 'Drill well'
        WHEN source_type = 'shared_tap' AND v.time_in_queue IS NOT NULL THEN 
            CONCAT('Install ', FLOOR(v.time_in_queue), ' taps nearby')
        WHEN source_type = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE improvement -- If no condition is met, keep the original value
    END AS updated_improvement
FROM project_progress AS p           -- left table
LEFT JOIN visits AS v                -- join to the right table
ON p.source_id = v.source_id;

-- Adding to the project_progress table
SET SQL_SAFE_UPDATES=0;
UPDATE project_progress AS p
JOIN (
    SELECT 
        p.source_id,
        CASE
            WHEN source_type = 'well' AND improvement = 'Contaminated: Biological' THEN 'Install RO filter'
            WHEN source_type = 'well' AND improvement = 'Contaminated: Chemical' THEN 'Install UV filter'
            WHEN source_type = 'river' THEN 'Drill well'
            WHEN source_type = 'shared_tap' AND v.time_in_queue IS NOT NULL THEN 
                CONCAT('Install ', FLOOR(v.time_in_queue), ' taps nearby')
            WHEN source_type = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
            ELSE improvement -- If no condition is met, keep the original value
        END AS updated_improvement
    FROM project_progress p
    LEFT JOIN visits v ON p.source_id = v.source_id
) AS subquery
ON p.source_id = subquery.source_id
SET p.improvement = subquery.updated_improvement;
 