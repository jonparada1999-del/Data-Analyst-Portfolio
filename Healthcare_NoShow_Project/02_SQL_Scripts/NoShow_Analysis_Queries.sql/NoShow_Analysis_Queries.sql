/* PROJECT: Healthcare Appointment No-Show Analysis AUTHOR: Jonathan Parada TOOLS: Google BigQuery (SQL) OBJECTIVE: Identifying behavioral drivers for missed medical appointments.*/

-- STEP 1: DATA CLEANING & FEATURE ENGINEERING -- This query creates a cleaned view, standardizes dates, and calculates 'wait_time_days'.
CREATE OR REPLACE VIEW `healthcare_data.cleaned_appointments` AS
SELECT 
    PatientId,
    AppointmentID,
    Gender,
    -- Convert text to real dates so we can do math
    CAST(ScheduledDay AS DATE) AS scheduled_date,
    CAST(AppointmentDay AS DATE) AS appointment_date,
    -- Create a 'Wait Time' column: How long between booking and the appt
    DATE_DIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE), DAY) AS wait_time_days,
    Age,
    Neighbourhood,
    SMS_received,
    -- Using backticks to handle that hyphen in the name
    `No-show` AS missed_appt
FROM `healthcare_data.appointments`
WHERE Age >= 0; -- Professional touch: Filtering out impossible ages
-- STEP 2: WAIT TIME ANALYSIS -- This query categorizes appointments by how long the patient waited to see a trend.
SELECT 
    CASE 
        WHEN wait_time_days = 0 THEN '1. Same Day'
        WHEN wait_time_days <= 7 THEN '2. Within a Week'
        WHEN wait_time_days <= 30 THEN '3. Within a Month'
        ELSE '4. Long Wait (30+ Days)'
    END AS wait_category,
    COUNT(*) AS total_appointments,
    ROUND(COUNTIF(missed_appt = TRUE) * 100 / COUNT(*), 2) AS no_show_rate
FROM `healthcare_data.cleaned_appointments`
GROUP BY 1
ORDER BY 1;

-- STEP 3: AGE GROUP ANALYSIS -- This query identifies which generations have the highest no-show rates.
SELECT 
    CASE 
        WHEN Age <= 18 THEN '0-18 (Youth)'
        WHEN Age <= 35 THEN '19-35 (Young Adult)'
        WHEN Age <= 60 THEN '36-60 (Adult)'
        ELSE '61+ (Senior)'
    END AS age_group,
    COUNT(*) AS total_appointments,
    ROUND(COUNTIF(missed_appt = TRUE) * 100 / COUNT(*), 2) AS no_show_rate
FROM `healthcare_data.cleaned_appointments`
GROUP BY 1
ORDER BY 1;

-- STEP 4: NEIGHBORHOOD HOTSPOT ANALYSIS -- This query finds the top 10 neighborhoods with the highest no-show percentages.
SELECT 
    Neighbourhood,
    COUNT(*) AS total_appointments,
    ROUND(COUNTIF(missed_appt = TRUE) * 100 / COUNT(*), 2) AS no_show_rate
FROM `healthcare_data.cleaned_appointments`
GROUP BY Neighbourhood
HAVING total_appointments > 100 -- Only look at areas with enough data
ORDER BY no_show_rate DESC
LIMIT 10;
