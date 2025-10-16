/*
Question: **What are the top skills based on salary?** 
- Look at the average salary associated with each skill for Data Analyst positions.
- Focuses on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the most financially rewarding skills to acquire or improve.
*/

SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = TRUE 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;

/*
Here's a breakdown of the results for the top paying skills
1. Big Data & Cloud Ecosystem Dominate

Top earners are tied to big data processing and cloud integration tools:

PySpark (#1 at ~$208K) and Databricks (~$142K) are both central to large-scale data engineering pipelines.

GCP and Kubernetes also appear, showing that analysts who can deploy scalable data infrastructure command high pay.
Trend: The analyst role is blending with data engineering and MLOps.

2. MLOps and AI Platforms Are Lucrative

DataRobot, Watson, and scikit-learn all appear — these are used for automated machine learning and AI model deployment.

These roles are shifting toward modeling + automation expertise, not just reporting.
Trend: Analysts with ML operationalization skills are rare and therefore well-paid.

3. Developer Collaboration & DevOps Tools Rising

Bitbucket, GitLab, Atlassian, and Jenkins — all DevOps or collaboration tools — appear with salaries in the ~$125K–$190K range.
Trend: Organizations increasingly value analysts who work seamlessly within engineering-style workflows (version control, CI/CD, agile tools).

4. Advanced Programming & Analytical Stack

Python ecosystem skills dominate: Pandas, NumPy, Jupyter, scikit-learn, PySpark, Databricks, Airflow.

These are the core stack for data science and data engineering.
Trend: Analysts who can code efficiently and build data pipelines are much more valuable than dashboard-only analysts.

5. Multi-language Advantage

Swift, Scala, Golang, and SQL/PostgreSQL — indicate that high-paying analysts often work in multi-language environments or hybrid roles.
Trend: Cross-language fluency (e.g., Python + Scala for Spark) is tied to premium compensation.

6. Hybrid Business-Technical Tools

MicroStrategy, Notion, Twilio — these represent BI, documentation, and communication integrations.
Trend: Analysts with both data pipeline and communication/platform integration skills bridge business and tech, increasing their strategic value.

[
  {
    "skills": "pyspark",
    "avg_salary": "208172.25"
  },
  {
    "skills": "bitbucket",
    "avg_salary": "189154.50"
  },
  {
    "skills": "couchbase",
    "avg_salary": "160515.00"
  },
  {
    "skills": "watson",
    "avg_salary": "160515.00"
  },
  {
    "skills": "datarobot",
    "avg_salary": "155485.50"
  },
  {
    "skills": "gitlab",
    "avg_salary": "154500.00"
  },
  {
    "skills": "swift",
    "avg_salary": "153750.00"
  },
  {
    "skills": "jupyter",
    "avg_salary": "152776.50"
  },
  {
    "skills": "pandas",
    "avg_salary": "151821.33"
  },
  {
    "skills": "elasticsearch",
    "avg_salary": "145000.00"
  },
  {
    "skills": "golang",
    "avg_salary": "145000.00"
  },
  {
    "skills": "numpy",
    "avg_salary": "143512.50"
  },
  {
    "skills": "databricks",
    "avg_salary": "141906.60"
  },
  {
    "skills": "linux",
    "avg_salary": "136507.50"
  },
  {
    "skills": "kubernetes",
    "avg_salary": "132500.00"
  },
  {
    "skills": "atlassian",
    "avg_salary": "131161.80"
  },
  {
    "skills": "twilio",
    "avg_salary": "127000.00"
  },
  {
    "skills": "airflow",
    "avg_salary": "126103.00"
  },
  {
    "skills": "scikit-learn",
    "avg_salary": "125781.25"
  },
  {
    "skills": "jenkins",
    "avg_salary": "125436.33"
  },
  {
    "skills": "notion",
    "avg_salary": "125000.00"
  },
  {
    "skills": "scala",
    "avg_salary": "124903.00"
  },
  {
    "skills": "postgresql",
    "avg_salary": "123878.75"
  },
  {
    "skills": "gcp",
    "avg_salary": "122500.00"
  },
  {
    "skills": "microstrategy",
    "avg_salary": "121619.25"
  }
]

*/