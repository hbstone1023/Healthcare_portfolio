WITH cohort_sizes AS (
    -- Define the denominator: How many users joined in each month?
    SELECT 
        DATE_TRUNC('month', join_date) AS cohort_month,
        COUNT(patient_id) AS cohort_size
    FROM patients
    GROUP BY 1
),

retention_events AS (
    -- Identify the follow-up events and associate them with the user's cohort month
    SELECT 
        DATE_TRUNC('month', p.join_date) AS cohort_month,
        e.patient_id,
        CASE 
            WHEN e.event_name = 'Visit_Month_1' THEN 1
            WHEN e.event_name = 'Visit_Month_2' THEN 2
            WHEN e.event_name = 'Visit_Month_3' THEN 3
            ELSE 0 
        END AS months_retained
    FROM patients p
    JOIN events e 
        ON p.patient_id = e.patient_id
    WHERE e.event_name LIKE 'Visit_Month_%'
),

retention_counts AS (
    -- Count how many unique patients showed up in month N for each cohort
    SELECT 
        cohort_month,
        months_retained,
        COUNT(DISTINCT patient_id) AS retained_patients
    FROM retention_events
    GROUP BY 1, 2
)

SELECT 
    rc.cohort_month,
    cs.cohort_size,
    rc.months_retained,
    rc.retained_patients,
    ROUND(rc.retained_patients * 100.0 / cs.cohort_size, 1) AS retention_rate_pct
FROM retention_counts rc
JOIN cohort_sizes cs 
    ON rc.cohort_month = cs.cohort_month
ORDER BY rc.cohort_month, rc.months_retained;
