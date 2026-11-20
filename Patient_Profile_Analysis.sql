USE Patient_Profile_Analysis;
GO
SELECT COUNT(*) AS total_rows
FROM dbo.patient_visits;

SELECT TOP 10
    icd_code,
    COUNT(*) AS diagnosis_count
FROM dbo.patient_visits
GROUP BY icd_code
ORDER BY diagnosis_count DESC, icd_code;

SELECT TOP 10
    cpt_code,
    COUNT(*) AS procedure_count
FROM dbo.patient_visits
GROUP BY cpt_code
ORDER BY procedure_count DESC, cpt_code;

SELECT
    patient_id,
    COUNT(DISTINCT visit_date) AS visit_days
FROM dbo.patient_visits
GROUP BY patient_id
ORDER BY visit_days DESC, patient_id;


SELECT
    patient_id,
    COUNT(DISTINCT visit_date) AS visit_days
FROM dbo.patient_visits
GROUP BY patient_id
HAVING COUNT(DISTINCT visit_date) >= 4
ORDER BY visit_days DESC, patient_id;

SELECT AVG(visit_days * 1.0) AS average_visit_days
FROM (
    SELECT
        patient_id,
        COUNT(DISTINCT visit_date) AS visit_days
    FROM dbo.patient_visits
    GROUP BY patient_id
) AS patient_totals;

SELECT
    patient_id,
    COUNT(DISTINCT date_of_birth) AS birth_date_count
FROM dbo.patient_visits
GROUP BY patient_id
HAVING COUNT(DISTINCT date_of_birth) > 1;

SELECT
    patient_id,
    CASE
        WHEN COUNT(DISTINCT date_of_birth) = 1
        THEN MIN(date_of_birth)
        ELSE NULL
    END AS clean_birth_date
FROM dbo.patient_visits
GROUP BY patient_id;

USE Patient_Profile_Analysis;
GO

SELECT TOP 5 *
FROM dbo.patient_visits;

WITH patients AS (
    SELECT
        patient_id,
        CASE
            WHEN COUNT(DISTINCT date_of_birth) = 1
            THEN MIN(date_of_birth)
            ELSE NULL
        END AS clean_birth_date
    FROM dbo.patient_visits
    GROUP BY patient_id
),
patient_ages AS (
    SELECT
        patient_id,
        DATEDIFF(YEAR, clean_birth_date, '20241218')
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, clean_birth_date, '20241218'),
                clean_birth_date
            ) > '20241218'
            THEN 1
            ELSE 0
          END AS age
    FROM patients
)
SELECT
    patient_id,
    age,
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 18 THEN '0–17'
        WHEN age < 40 THEN '18–39'
        WHEN age < 65 THEN '40–64'
        ELSE '65+'
    END AS age_group
FROM patient_ages
ORDER BY patient_id;

USE Patient_Profile_Analysis;
GO

WITH patients AS (
    SELECT
        patient_id,
        CASE
            WHEN COUNT(DISTINCT date_of_birth) = 1
            THEN MIN(date_of_birth)
            ELSE NULL
        END AS clean_birth_date
    FROM dbo.patient_visits
    GROUP BY patient_id
),
patient_ages AS (
    SELECT
        patient_id,
        DATEDIFF(YEAR, clean_birth_date, '20241218')
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, clean_birth_date, '20241218'),
                clean_birth_date
            ) > '20241218'
            THEN 1
            ELSE 0
          END AS age
    FROM patients
)
SELECT
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 18 THEN '0–17'
        WHEN age < 40 THEN '18–39'
        WHEN age < 65 THEN '40–64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS patient_count
FROM patient_ages
GROUP BY
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 18 THEN '0–17'
        WHEN age < 40 THEN '18–39'
        WHEN age < 65 THEN '40–64'
        ELSE '65+'
    END
ORDER BY age_group;

SELECT
    patient_id,
    COUNT(DISTINCT patient_sex) AS sex_count
FROM dbo.patient_visits
GROUP BY patient_id
HAVING COUNT(DISTINCT patient_sex) > 1;

SELECT
    patient_id,
    CASE
        WHEN COUNT(DISTINCT patient_sex) = 1
        THEN MIN(patient_sex)
        ELSE 'Unknown'
    END AS clean_sex
FROM dbo.patient_visits
GROUP BY patient_id;

WITH patients AS (
    SELECT
        patient_id,
        CASE
            WHEN COUNT(DISTINCT patient_sex) = 1
            THEN MIN(patient_sex)
            ELSE 'Unknown'
        END AS clean_sex
    FROM dbo.patient_visits
    GROUP BY patient_id
)
SELECT
    visits.icd_code,
    patients.clean_sex, 
    COUNT(*) AS diagnosis_count
FROM dbo.patient_visits AS visits
JOIN patients
    ON visits.patient_id = patients.patient_id
GROUP BY
    visits.icd_code,
    patients.clean_sex
ORDER BY
    visits.icd_code,
    diagnosis_count DESC;


   WITH patients AS (
    SELECT
        patient_id,
        CASE
            WHEN COUNT(DISTINCT date_of_birth) = 1
            THEN MIN(date_of_birth)
            ELSE NULL
        END AS clean_birth_date
    FROM dbo.patient_visits
    GROUP BY patient_id
),
patient_ages AS (
    SELECT
        patient_id,
        DATEDIFF(YEAR, clean_birth_date, '20241218')
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, clean_birth_date, '20241218'),
                clean_birth_date
            ) > '20241218'
            THEN 1
            ELSE 0
          END AS age
    FROM patients
),
patient_groups AS (
    SELECT
        patient_id,
        CASE
            WHEN age IS NULL THEN 'Unknown'
            WHEN age < 18 THEN '0–17'
            WHEN age < 40 THEN '18–39'
            WHEN age < 65 THEN '40–64'
            ELSE '65+'
        END AS age_group
    FROM patient_ages
)
SELECT
    visits.icd_code,
    patient_groups.age_group,
    COUNT(*) AS diagnosis_count
FROM dbo.patient_visits AS visits
JOIN patient_groups
    ON visits.patient_id = patient_groups.patient_id
GROUP BY
    visits.icd_code,
    patient_groups.age_group
ORDER BY
    visits.icd_code,
    patient_groups.age_group;