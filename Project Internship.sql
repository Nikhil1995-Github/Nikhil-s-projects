
CREATE TABLE project.career_tracks 
(internship_id int ,skills_learned text,networking_opportunities text, equity text,
						   future_salary integer,future_id integer);
INSERT INTO project.career_tracks (internship_id  ,skills_learned ,networking_opportunities , equity ,
						   future_salary ,future_id )
SELECT internship_id  ,skills_learned ,networking_opportunities , equity ,
						   future_salary ,future_id FROM  project.future_track;
CREATE TABLE project.internship_details (position text, internship_id int,intenrship_location text,salary_per_hour_in_dollars money ,company_id int);
INSERT INTO project.internship_details(position , internship_id ,intenrship_location ,salary_per_hour_in_dollars ,company_id )
SELECT position , internship_id ,internship_location ,salary_per_hour ,company_id FROM project.internship;

CREATE TABLE project.skills_required (internship_id int,sql text, python text, tableau text, adobe_xd text, google_analytics text, excel text, skill_id int);
INSERT INTO  project.skills_required (internship_id ,sql , python , tableau , adobe_xd , google_analytics , excel , skill_id )
SELECT  internship_id ,sql , python , tableau , adobe_xd , google_analytics , excel , skill_id  
		 FROM project.skill_level_required;	
CREATE TABLE project.homework_solutions (questions text, queries text);
CREATE TABLE project.homework_description ( description text);
INSERT INTO  project.homework_description ( description)(VALUES 
( 'This project gives in-depth information about the various internships I have applied to and about the companies that offer them'));

ALTER TABLE project.career_tracks
ADD CONSTRAINT career_id_fkey 
FOREIGN KEY (internship_id)
REFERENCES  project.internship_details (internship_id)
ON UPDATE CASCADE 
ON DELETE CASCADE;

ALTER TABLE project.locations
ADD CONSTRAINT location_id_fkey 
FOREIGN KEY (company_id)
REFERENCES project.company_details  (company_id)
ON UPDATE CASCADE 
ON DELETE CASCADE;

ALTER TABLE project.skills_required
ADD CONSTRAINT skills_id_fkey 
FOREIGN KEY (internship_id)
REFERENCES  project.internship_details (internship_id)
ON UPDATE CASCADE 
ON DELETE CASCADE;
---------
---Which internship will enable me to make the highest salary in the future?
CREATE VIEW internship_with_highest_future_salaries AS
SELECT company_name,position,sector,future_salary
FROM career_tracks t 
INNER JOIN  internship_details i
ON i.internship_id=t.internship_id
INNER JOIN  company_details c
ON c.company_id = i.company_id
ORDER BY future_salary DESC
limit 3;

---Which internship will offer me equity in the company and good networking opportunities for the future?

SELECT company_name,position,sector,future_salary
FROM project.career_tracks t 
INNER JOIN  project.internship_details i
ON i.internship_id=t.internship_id
INNER JOIN  project.company_details c
ON c.company_id = i.company_id
WHERE equity='yes' AND networking_opportunities ='high'
ORDER BY future_salary DESC
limit 3;

----Which  internships pay above the average pay of all interships?

SELECT company_name,position,internship_location,salary_per_hour_in_dollars
FROM internship_details i
INNER JOIN company_details c ON (c.company_id=i.company_id)
WHERE salary_per_hour_in_dollars > (SELECT AVG  (salary_per_hour_in_dollars)								
FROM internship_details)
ORDER BY salary_per_hour_in_dollars DESC
;
--Which locations have above average pay and what is the highest pay for each location?
SELECT internship_location,salary_per_hour_in_dollars
FROM internship_details i
INNER JOIN company_details c ON (c.company_id=i.company_id)
WHERE salary_per_hour_in_dollars > (SELECT AVG  (salary_per_hour_in_dollars)								
FROM internship_details)
GROUP BY internship_location,salary_per_hour_in_dollars
ORDER BY salary_per_hour_in_dollars DESC
;


---Which internships have the lowest and the highest pay, respectively?
SELECT 'Minimum paying position,company:' AS payscale,position,company_name
FROM internship_details i
INNER JOIN company_details c 
ON (c.company_id=i.company_id)
WHERE salary_per_hour_in_dollars=
(SELECT MIN (salary_per_hour_in_dollars) FROM internship_details)
UNION 
SELECT 'Maximum paying position,company:' AS payscale,position,company_name
FROM internship_details i
INNER JOIN company_details c 
ON (c.company_id=i.company_id)
WHERE salary_per_hour_in_dollars=
(SELECT MAX (salary_per_hour_in_dollars) FROM internship_details);

---A skill matrix of all the companies, their positions and the skill level required at those companies
SELECT company_name, position,excel,sql,tableau,adobe_xd,python,google_analytics
FROM internship_details i
INNER JOIN skills_required s ON (s.internship_id=i.internship_id)
INNER JOIN company_details c ON (c.company_id=i.company_id);


CREATE SERVER server2 FOREIGN DATA WRAPPER ogr_fdw OPTIONS (datasource 'C:\FTP\npatil\ans1.xlsx', format 'XLSX', config_options 'OGR_XLSX_HEADERS=FORCE'); 
IMPORT FOREIGN SCHEMA ogr_all  FROM SERVER server2 INTO project;
INSERT INTO project.homework_solutions(questions,queries) SELECT doubts,answers
FROM project.sheet1;
-----
ALTER TABLE project.internship_details ADD CONSTRAINT salary_per_hour 
CHECK (salary_per_hour_in_dollars > 0);
ALTER TABLE project.company_details ADD CONSTRAINT company 
CHECK (company_name IS NOT NULL);
SET search_path TO project,public;
------
WITH cte_intern AS  (
    SELECT excel,python
        RANK() OVER (
            PARTITION BY sql
            ORDER BY sql ) 
        sql
    FROM 
     project.skills_required   
)
SELECT *
FROM project.skills_required;




























						   
						   
						   
						   
	