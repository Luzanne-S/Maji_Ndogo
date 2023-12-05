---- Task 1: INTEGRATING THE REPORT
/*joining tables - code from slides*/
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id;

-- my version with additional columns
SELECT
	visits.record_id, 
    visits.location_id AS visit_location,
    water_quality.subjective_quality_score, 
    auditor_report.true_water_source_score,
    auditor_report.location_id AS audit_location
FROM 
	visits
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN auditor_report ON visits.location_id = auditor_report.location_id;

-- change names and remove a duplicate (location)
SELECT
	visits.record_id, 
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score, 
    auditor_report.true_water_source_score AS auditor_score
    
FROM 
	visits
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN auditor_report ON visits.location_id = auditor_report.location_id;

-- checking if the scores are the same for the auditor and surveyor
SELECT
	visits.record_id, 
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score, 
    auditor_report.true_water_source_score AS auditor_score
    
FROM 
	visits
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN auditor_report ON visits.location_id = auditor_report.location_id

WHERE  subjective_quality_score <> true_water_source_score   -- to see if they are the same
AND visits.visit_count = 1;

/* to count the number of rows without the duplicates use a subquery = 1518 BUT with duplicates (remove visit_count=1) equals to 2505*/
SELECT COUNT(*) AS row_count
FROM (
    SELECT
        visits.record_id, 
        visits.location_id,
        water_quality.subjective_quality_score AS surveyor_score, 
        auditor_report.true_water_source_score AS auditor_score
    FROM 
        visits
    JOIN water_quality ON visits.record_id = water_quality.record_id
    JOIN auditor_report ON visits.location_id = auditor_report.location_id
    WHERE  subjective_quality_score = true_water_source_score                -- IF change (= to <>) then incorrect records count to 102
    AND visits.visit_count = 1       
) AS subquery;


-- finding the source of the different issues
SELECT
	visits.record_id, 
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score, 
    auditor_report.true_water_source_score AS auditor_score,
    water_source.type_of_water_source AS survey_source,
    auditor_report.type_of_water_source AS auditor_source
    
FROM 
	visits
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN auditor_report ON visits.location_id = auditor_report.location_id
JOIN water_source ON water_source.type_of_water_source = auditor_report.type_of_water_source

WHERE  subjective_quality_score <> true_water_source_score
AND visits.visit_count = 1;



---- Task 2: LINKING RECORDS
/* join assigned employee id  from visits table to query*/
SELECT
	visits.record_id, 
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score, 
    auditor_report.true_water_source_score AS auditor_score,
    visits.assigned_employee_id           -- to see which employees added incorrect information
    
FROM 
	visits
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN auditor_report ON visits.location_id = auditor_report.location_id

WHERE  subjective_quality_score <> true_water_source_score
AND visits.visit_count = 1;

/* change ID to employee names */
SELECT
	visits.record_id, 
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score, 
    auditor_report.true_water_source_score AS auditor_score,
    employee.employee_name
    
FROM 
	visits
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN auditor_report ON visits.location_id = auditor_report.location_id
JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id

WHERE  subjective_quality_score <> true_water_source_score
AND visits.visit_count = 1;

/*Create CTE*/
WITH 
	Incorrect_records AS(

					SELECT
						visits.record_id, 
						visits.location_id,
						water_quality.subjective_quality_score AS surveyor_score, 
						auditor_report.true_water_source_score AS auditor_score,
						employee.employee_name
						
					FROM 
						visits
					JOIN water_quality ON visits.record_id = water_quality.record_id
					JOIN auditor_report ON visits.location_id = auditor_report.location_id
					JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id

					WHERE  subjective_quality_score <> true_water_source_score
					AND visits.visit_count = 1
)
SELECT 
	*
FROM 
	Incorrect_records;
    
/*Query it by looking for distinct list of employees and counting how many there are */
WITH 
	Incorrect_records AS(

					SELECT
						visits.record_id, 
						visits.location_id,
						water_quality.subjective_quality_score AS surveyor_score, 
						auditor_report.true_water_source_score AS auditor_score,
						employee.employee_name
						
					FROM 
						visits
					JOIN water_quality ON visits.record_id = water_quality.record_id
					JOIN auditor_report ON visits.location_id = auditor_report.location_id
					JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id

					WHERE  subjective_quality_score <> true_water_source_score
					AND visits.visit_count = 1
)
SELECT 
	COUNT(DISTINCT (employee_name))
FROM 
	Incorrect_records;
/*Query it by looking for distinct list of employees and adding up how many mistakes they each made */
WITH 
	Incorrect_records AS(

					SELECT
						visits.record_id, 
						visits.location_id,
						water_quality.subjective_quality_score AS surveyor_score, 
						auditor_report.true_water_source_score AS auditor_score,
						employee.employee_name
						
					FROM 
						visits
					JOIN water_quality ON visits.record_id = water_quality.record_id
					JOIN auditor_report ON visits.location_id = auditor_report.location_id
					JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id

					WHERE  subjective_quality_score <> true_water_source_score
					AND visits.visit_count = 1
)
SELECT 
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM 
	Incorrect_records
GROUP BY employee_name;



-- -- Task 3: GATHERING EVIDENCE
/* Create view so that the code is less messy*/
CREATE VIEW
	Incorrect_records AS(

					SELECT
						visits.record_id, 
						visits.location_id,
						water_quality.subjective_quality_score AS surveyor_score, 
						auditor_report.true_water_source_score AS auditor_score,
						employee.employee_name
						
					FROM 
						visits
					JOIN water_quality ON visits.record_id = water_quality.record_id
					JOIN auditor_report ON visits.location_id = auditor_report.location_id
					JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id

					WHERE  subjective_quality_score <> true_water_source_score
					AND visits.visit_count = 1
);    -- use it as a reference when refering back to it 

/*counts how many mistakes each employee made*/
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
			SELECT
				employee_name,
				COUNT(employee_name) AS number_of_mistakes
			FROM
				Incorrect_records
				/*
				Incorrect_records is a view that joins the audit report to the database
				for records where the auditor and
				employees scores are different*/

			GROUP BY
				employee_name)
				-- Query
			SELECT * FROM error_count;

/*calculate the average number of mistakes*/
WITH error_count AS (
			SELECT
				employee_name,
				COUNT(employee_name) AS number_of_mistakes
			FROM
				Incorrect_records

			GROUP BY
				employee_name)
				-- Query
				SELECT AVG(number_of_mistakes) FROM error_count;
                
/*employees with mistakes > 6*/
WITH error_count AS (
			SELECT
				employee_name,
				COUNT(employee_name) AS number_of_mistakes
			FROM
				Incorrect_records

			GROUP BY
				employee_name)
				-- Query
			SELECT 
                employee_name,
                number_of_mistakes
			FROM error_count
                WHERE
					number_of_mistakes > (SELECT AVG(number_of_mistakes) 
										FROM error_count);    -- Filter within the where part
/*suspect list with mistake count*/
WITH
	suspect_list AS(
				SELECT 
					employee_name,
                    COUNT(employee_name) AS number_of_mistakes
				FROM
					Incorrect_records
				GROUP BY
					employee_name
)
	SELECT 	
		employee_name as suspect,
        number_of_mistakes
	FROM 
		suspect_list
        WHERE employee_name LIKE 'Bello Azibo'
			OR employee_name LIKE 'Zuriel Matembo'
			or employee_name LIKE 'Malachi Mavuso'
			or employee_name LIKE 'Lalitha Kaburi';
            
/*Add statements to incorrect_records view*/
CREATE VIEW                  -- had to delete previous view in order to have it be the same name
	Incorrect_records AS(

					SELECT
						visits.record_id, 
						visits.location_id,
						water_quality.subjective_quality_score AS surveyor_score, 
						auditor_report.true_water_source_score AS auditor_score,
						employee.employee_name,
                        auditor_report.statements
						
					FROM 
						visits
					JOIN water_quality ON visits.record_id = water_quality.record_id
					JOIN auditor_report ON visits.location_id = auditor_report.location_id
					JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id

					WHERE  subjective_quality_score <> true_water_source_score
					AND visits.visit_count = 1
);

/*get statements from suspects*/
SELECT
	employee_name,
    location_id,
    statements
FROM
	Incorrect_records
WHERE
	employee_name IN (SELECT employee_name 
						FROM incorrect_records
                        WHERE employee_name LIKE 'Bello Azibo'
						OR employee_name LIKE 'Zuriel Matembo'
						OR employee_name LIKE 'Malachi Mavuso'
						OR employee_name LIKE 'Lalitha Kaburi');
                        
/*filter statements to see if cash was involved*/
SELECT
	employee_name,
    location_id,
    statements
FROM
	Incorrect_records
WHERE
	statements IN (SELECT statements
						FROM incorrect_records
                        WHERE  statements LIKE '%cash%');  -- records show only suspects used the word cash


/*We found that employees:Zuriel Matembo, Malachi Mavuso, Bello Azibo and Lalitha Kaburi
    1. Captured more mistakes then their peers
    2. The evidence against them show that potential fraud may have taken place and further investigation needs to take place */


