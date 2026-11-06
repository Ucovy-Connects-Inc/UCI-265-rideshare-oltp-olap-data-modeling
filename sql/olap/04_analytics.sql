-- Ride volume by month
SELECT
    d.year_number,
    d.month_number,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN f.ride_status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_rides
FROM rideshare_dw.fact_rides f
JOIN rideshare_dw.dim_date d ON f.date_sk = d.date_sk
GROUP BY d.year_number, d.month_number
ORDER BY d.year_number, d.month_number;

-- Revenue by zone
SELECT
    z.zone_name,
    COUNT(*) AS rides,
    ROUND(SUM(f.final_fare), 2) AS total_revenue,
    ROUND(AVG(f.final_fare), 2) AS avg_fare
FROM rideshare_dw.fact_rides f
JOIN rideshare_dw.dim_zone z ON f.zone_sk = z.zone_sk
WHERE f.ride_status = 'COMPLETED'
GROUP BY z.zone_name
ORDER BY total_revenue DESC;

-- Driver performance
SELECT
    d.driver_id,
    d.driver_name,
    COUNT(*) AS completed_rides,
    ROUND(AVG(f.final_fare), 2) AS avg_fare,
    ROUND(AVG(f.driver_rating), 2) AS avg_driver_rating
FROM rideshare_dw.fact_rides f
JOIN rideshare_dw.dim_driver d ON f.driver_sk = d.driver_sk AND d.is_current = TRUE
WHERE f.ride_status = 'COMPLETED'
GROUP BY d.driver_id, d.driver_name
ORDER BY completed_rides DESC;

-- Rider activity
SELECT
    r.rider_id,
    r.rider_name,
    COUNT(*) AS ride_count,
    ROUND(SUM(f.final_fare), 2) AS lifetime_value
FROM rideshare_dw.fact_rides f
JOIN rideshare_dw.dim_rider r ON f.rider_sk = r.rider_sk AND r.is_current = TRUE
GROUP BY r.rider_id, r.rider_name
ORDER BY lifetime_value DESC;

-- Surge pricing
SELECT
    z.zone_name,
    ROUND(AVG(f.surge_multiplier), 2) AS avg_surge_multiplier,
    ROUND(SUM(f.final_fare), 2) AS revenue
FROM rideshare_dw.fact_rides f
JOIN rideshare_dw.dim_zone z ON f.zone_sk = z.zone_sk
GROUP BY z.zone_name
ORDER BY avg_surge_multiplier DESC;

-- Payment trends
SELECT
    p.payment_method,
    COUNT(*) AS ride_count,
    ROUND(SUM(f.payment_amount), 2) AS payment_amount
FROM rideshare_dw.fact_rides f
JOIN rideshare_dw.dim_payment_method p
  ON f.payment_method_sk = p.payment_method_sk
GROUP BY p.payment_method
ORDER BY payment_amount DESC;
