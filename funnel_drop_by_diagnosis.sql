WITH patient_funnel AS (
    SELECT 
        p.patient_id,
        p.primary_diagnosis,
        -- Using MAX with CASE to create binary flags for whether a patient reached a step
        MAX(CASE WHEN e.event_name = '1_Account_Created' THEN 1 ELSE 0 END) AS step_1_acct,
        MAX(CASE WHEN e.event_name = '2_Intake_Completed' THEN 1 ELSE 0 END) AS step_2_intake,
        MAX(CASE WHEN e.event_name = '3_Provider_Matched' THEN 1 ELSE 0 END) AS step_3_match,
        MAX(CASE WHEN e.event_name = '4_First_Visit' THEN 1 ELSE 0 END) AS step_4_visit
    FROM patients p
    LEFT JOIN events e 
        ON p.patient_id = e.patient_id
    GROUP BY 1, 2
),

funnel_aggregates AS (
    SELECT 
        primary_diagnosis,
        COUNT(patient_id) AS total_patients,
        SUM(step_1_acct) AS total_acct_created,
        SUM(step_2_intake) AS total_intake_completed,
        SUM(step_3_match) AS total_provider_matched,
        SUM(step_4_visit) AS total_first_visit
    FROM patient_funnel
    GROUP BY 1
)

SELECT 
    primary_diagnosis,
    total_acct_created,
    total_intake_completed,
    total_provider_matched,
    total_first_visit,
    -- Calculate Step-to-Step Drop-off
    ROUND(total_intake_completed * 100.0 / NULLIF(total_acct_created, 0), 1) AS pct_acct_to_intake,
    ROUND(total_provider_matched * 100.0 / NULLIF(total_intake_completed, 0), 1) AS pct_intake_to_match,
    ROUND(total_first_visit * 100.0 / NULLIF(total_provider_matched, 0), 1) AS pct_match_to_visit,
    -- Calculate Overall Funnel Conversion
    ROUND(total_first_visit * 100.0 / NULLIF(total_acct_created, 0), 1) AS overall_conversion_rate
FROM funnel_aggregates
ORDER BY total_patients DESC;
