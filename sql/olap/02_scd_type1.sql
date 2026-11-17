-- SCD Type 1 example: overwrite non-historical vehicle attributes.
UPDATE rideshare_dw.dim_vehicle target
SET
    company = source.company,
    model = source.model,
    vehicle_year = source.vehicle_year,
    vehicle_type = source.vehicle_type,
    number_of_seats = source.number_of_seats,
    is_active = source.is_active
FROM rideshare.vehicles source
WHERE target.vehicle_id = source.vehicle_id;
