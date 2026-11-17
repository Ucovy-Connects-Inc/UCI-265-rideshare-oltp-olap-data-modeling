-- SCD Type 2 example for riders.
-- Step 1: expire changed current rows.
UPDATE rideshare_dw.dim_rider target
SET
    effective_end_date = CURRENT_DATE - INTERVAL '1 day',
    is_current = FALSE
FROM rideshare.riders source
WHERE target.rider_id = source.rider_id
  AND target.is_current = TRUE
  AND (
      COALESCE(target.email, '') <> COALESCE(source.email, '') OR
      COALESCE(target.phone_number, '') <> COALESCE(source.phone_number, '') OR
      COALESCE(target.rider_name, '') <> COALESCE(source.rider_name, '') OR
      COALESCE(target.city, '') <> COALESCE(source.city, '') OR
      COALESCE(target.state, '') <> COALESCE(source.state, '') OR
      target.is_active IS DISTINCT FROM source.is_active
  );

-- Step 2: insert new or changed current rows.
INSERT INTO rideshare_dw.dim_rider (
    rider_id, email, phone_number, rider_name, city, state,
    is_active, effective_start_date, effective_end_date, is_current
)
SELECT
    source.rider_id, source.email, source.phone_number, source.rider_name,
    source.city, source.state, source.is_active,
    CURRENT_DATE, DATE '9999-12-31', TRUE
FROM rideshare.riders source
LEFT JOIN rideshare_dw.dim_rider target
  ON source.rider_id = target.rider_id
 AND target.is_current = TRUE
WHERE target.rider_id IS NULL;
