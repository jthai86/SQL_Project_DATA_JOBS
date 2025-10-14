SELECT 
        job_schedule_type,
        AVG(salary_year_avg) AS year_avg,
        AVG(salary_hour_avg) AS hour_avg
FROM job_postings_fact
WHERE job_posted_date > '2023-06-01'
GROUP BY job_schedule_type
ORDER BY job_schedule_type;

SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM
    job_postings_fact
WHERE
    job_posted_date::date > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    job_schedule_type;

SELECT
    EXTRACT(MONTH FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST')) AS MONTH,
    COUNT(*)
FROM job_postings_fact
GROUP BY MONTH
ORDER BY MONTH;

SELECT *
FROM job_postings_fact;

SELECT
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS job_postings_count
FROM
    job_postings_fact
	INNER JOIN
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2 
GROUP BY
    company_dim.name 
HAVING
    COUNT(job_postings_fact.job_id) > 0
ORDER BY
	job_postings_count DESC; 


WITH remote_job_skills AS ( 
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job        
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = TRUE AND
        job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)

SELECT 
    skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5    


SELECT skills_dim.skills
FROM skills_dim
INNER JOIN (
    SELECT 
        skill_id,
        COUNT(job_id) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY COUNT(job_id) DESC
    LIMIT 5
) AS top_skills ON skills_dim.skill_id = top_skills.skill_id
ORDER BY top_skills.skill_count DESC;

SELECT
   company_id,
   name,
   -- Categorize companies
   CASE
       WHEN job_count < 10 THEN 'Small'
       WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
       ELSE 'Large'
   END AS company_size
FROM (
   -- Subquery to calculate number of job postings per company 
   SELECT
       company_dim.company_id,
       company_dim.name,
       COUNT(job_postings_fact.job_id) AS job_count
   FROM company_dim
   INNER JOIN job_postings_fact 
       ON company_dim.company_id = job_postings_fact.company_id
   GROUP BY
       company_dim.company_id,
       company_dim.name
) AS company_job_count;

SELECT 
    company_dim.name
FROM 
    company_dim
INNER JOIN (
    -- Subquery to calculate average salary per company
    SELECT 
        company_id, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY company_id
    ) AS company_salaries ON company_dim.company_id = company_salaries.company_id
-- Filter for companies with an average salary greater than the overall average
WHERE company_salaries.avg_salary > (
    -- Subquery to calculate the overall average salary
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact
);

-- Define a CTE named title_diversity to calculate unique job titles per company
WITH title_diversity AS (
    SELECT
        company_id,
        COUNT(DISTINCT job_title) AS unique_titles  
    FROM job_postings_fact
    GROUP BY company_id  
)
-- Get company name and count of how many unique titles each company has
SELECT
    company_dim.name,  
    title_diversity.unique_titles  
FROM title_diversity
	INNER JOIN company_dim ON title_diversity.company_id = company_dim.company_id  
ORDER BY 
	unique_titles DESC  
LIMIT 10;  

-- gets average job salary for each country
WITH avg_salaries AS (
    SELECT 
        job_country, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY job_country
)
SELECT
    -- Gets basic job info
    job_postings.job_id,
    job_postings.job_title,
    companies.name AS company_name,
    job_postings.salary_year_avg AS salary_rate,
    -- categorizes the salary as above or below average the average salary for the country
    CASE
        WHEN job_postings.salary_year_avg > avg_salaries.avg_salary
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_category,
    -- gets the month and year of the job posting date
    EXTRACT(MONTH FROM job_postings.job_posted_date) AS posting_month
FROM
    job_postings_fact as job_postings
INNER JOIN
    company_dim as companies ON job_postings.company_id = companies.company_id
INNER JOIN
    avg_salaries ON job_postings.job_country = avg_salaries.job_country
ORDER BY
    -- Sorts it by the most recent job postings
    posting_month desc;



-- Counts the distinct skills required for each company's job posting
WITH required_skills AS (
    SELECT
        companies.company_id,
        COUNT(DISTINCT skills_to_job.skill_id) AS unique_skills_required
    FROM
        company_dim AS companies 
    LEFT JOIN job_postings_fact as job_postings ON companies.company_id = job_postings.company_id
    LEFT JOIN skills_job_dim as skills_to_job ON job_postings.job_id = skills_to_job.job_id
    GROUP BY
        companies.company_id
),
-- Gets the highest average yearly salary from the jobs that require at least one skills 
max_salary AS (
    SELECT
        job_postings.company_id,
        MAX(job_postings.salary_year_avg) AS highest_average_salary
    FROM
        job_postings_fact AS job_postings
    WHERE
        job_postings.job_id IN (SELECT job_id FROM skills_job_dim)
    GROUP BY
        job_postings.company_id
)
-- Joins 2 CTEs with table to get the query
SELECT
    companies.name,
    required_skills.unique_skills_required as unique_skills_required, --handle companies w/o any skills required
    max_salary.highest_average_salary
FROM
    company_dim AS companies
LEFT JOIN required_skills ON companies.company_id = required_skills.company_id
LEFT JOIN max_salary ON companies.company_id = max_salary.company_id
ORDER BY
    companies.name;


SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs   

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs      

SELECT 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::DATE,
    quarter1_job_postings.salary_year_avg
FROM (
SELECT *
FROM january_jobs
UNION ALL
SELECT *
FROM february_jobs
UNION ALL
SELECT *
FROM march_jobs
) AS quarter1_job_postings     
WHERE
    quarter1_job_postings.salary_year_avg > 70000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
        quarter1_job_postings.salary_year_avg DESC;

-- Select job postings with salary information
(
SELECT 
    job_id, 
    job_title, 
    'With Salary Info' AS salary_info  -- Custom field indicating salary info presence
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL  
)
UNION ALL
 -- Select job postings without salary information
(
SELECT 
    job_id, 
    job_title, 
    'Without Salary Info' AS salary_info  -- Custom field indicating absence of salary info
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NULL AND salary_hour_avg IS NULL 
)
ORDER BY 
    salary_info DESC, 
    job_id; 

SELECT
    job_postings_q1.job_id,
    job_postings_q1.job_title_short,
    job_postings_q1.job_location,
    job_postings_q1.job_via,
    job_postings_q1.salary_year_avg,
    skills_dim.skills,
    skills_dim.type
FROM
-- Get job postings from the first quarter of 2023
    (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
    ) as job_postings_q1
LEFT JOIN skills_job_dim ON job_postings_q1.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_q1.salary_year_avg > 70000
ORDER BY
    job_postings_q1.job_id;

-- CTE for combining job postings from January, February, and March
WITH combined_job_postings AS (
    SELECT job_id, job_posted_date
    FROM january_jobs
    UNION ALL
    SELECT job_id, job_posted_date
    FROM february_jobs
    UNION ALL
    SELECT job_id, job_posted_date
    FROM march_jobs
),
-- CTE for calculating monthly skill demand based on the combined postings
monthly_skill_demand AS (
    SELECT
        skills_dim.skills,  
        EXTRACT(YEAR FROM combined_job_postings.job_posted_date) AS year,  
        EXTRACT(MONTH FROM combined_job_postings.job_posted_date) AS month,  
        COUNT(combined_job_postings.job_id) AS postings_count 
    FROM
        combined_job_postings
    INNER JOIN skills_job_dim ON combined_job_postings.job_id = skills_job_dim.job_id  
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id  
    GROUP BY
        skills_dim.skills, 
        year, 
        month
)
-- Main query to display the demand for each skill during the first quarter
SELECT
    skills,  
    year,  
    month,  
    postings_count 
FROM
    monthly_skill_demand
ORDER BY
    skills, 
    year,
    month;  