SET search_path TO rideshare;

-- Orphan checks
SELECT r.ride_id
FROM rides r
LEFT JOIN riders rd ON r.rider_id = rd.rider_id
WHERE rd.rider_id IS NULL;

SELECT r.ride_id
FROM rides r
LEFT JOIN drivers d ON r.driver_id = d.driver_id
WHERE r.driver_id IS NOT NULL AND d.driver_id IS NULL;

SELECT p.payment_id
FROM payments p
LEFT JOIN rides r ON p.ride_id = r.ride_id
WHERE r.ride_id IS NULL;

-- Completed ride validation
SELECT ride_id
FROM rides
WHERE status = 'COMPLETED' AND completed_at IS NULL;

-- Invalid fares
SELECT ride_id
FROM rides
WHERE COALESCE(final_fare, 0) < 0 OR COALESCE(distance_km, 0) < 0;

-- Duplicate business keys
SELECT email, COUNT(*) FROM riders GROUP BY email HAVING COUNT(*) > 1;
SELECT license_number, COUNT(*) FROM drivers GROUP BY license_number HAVING COUNT(*) > 1;
SELECT license_plate, COUNT(*) FROM vehicles GROUP BY license_plate HAVING COUNT(*) > 1;
