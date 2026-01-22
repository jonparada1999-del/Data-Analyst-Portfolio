-- PROJECT: Hospitality Demand & Revenue Analysis -- ANALYST: Jonathan Parada -- TOOLS: Google BigQuery (SQL) -- DATASET: 119,000 Hotel Booking Records

-- I am calculating the monthly cancellation rate to identify 
-- seasonal periods with the highest revenue risk.
SELECT 
    arrival_date_month,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(AVG(is_canceled) * 100, 2) AS cancellation_rate_percentage
FROM `Hospitality_Project.hotel_bookings`
GROUP BY arrival_date_month
ORDER BY cancellation_rate_percentage DESC;

-- I am comparing cancellation rates by market segment 
-- to evaluate the reliability of different revenue streams.
SELECT 
    market_segment,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(AVG(is_canceled) * 100, 2) AS cancellation_rate
FROM `Hospitality_Project.hotel_bookings`
GROUP BY market_segment
ORDER BY total_bookings DESC;

-- I am manually calculating stay and revenue features to ensure
-- the dataset is complete for the final Tableau dashboard.
SELECT 
    hotel,
    is_canceled,
    lead_time,
    arrival_date_year,
    arrival_date_month,
    market_segment,
    distribution_channel,
    reserved_room_type,
    deposit_type,
    customer_type,
    adr,
    country,
    -- Manually re-calculating the features from Python to bypass the naming error
    (stays_in_weekend_nights + stays_in_week_nights) AS total_stay,
    ((stays_in_weekend_nights + stays_in_week_nights) * adr) AS revenue
FROM `Hospitality_Project.hotel_bookings`;
