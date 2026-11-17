CREATE SCHEMA IF NOT EXISTS rideshare_dw;
SET search_path TO rideshare_dw;

CREATE TABLE IF NOT EXISTS dim_rider (
    rider_sk BIGSERIAL PRIMARY KEY,
    rider_id BIGINT NOT NULL,
    email VARCHAR(255),
    phone_number VARCHAR(30),
    rider_name VARCHAR(150),
    city VARCHAR(100),
    state VARCHAR(50),
    is_active BOOLEAN,
    effective_start_date DATE NOT NULL,
    effective_end_date DATE NOT NULL DEFAULT DATE '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS dim_driver (
    driver_sk BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL,
    driver_name VARCHAR(150),
    license_number VARCHAR(100),
    rating NUMERIC(3,2),
    city VARCHAR(100),
    state VARCHAR(50),
    is_active BOOLEAN,
    effective_start_date DATE NOT NULL,
    effective_end_date DATE NOT NULL DEFAULT DATE '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS dim_vehicle (
    vehicle_sk BIGSERIAL PRIMARY KEY,
    vehicle_id BIGINT NOT NULL UNIQUE,
    license_plate VARCHAR(30),
    company VARCHAR(100),
    model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_type VARCHAR(50),
    number_of_seats INTEGER,
    is_active BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_zone (
    zone_sk BIGSERIAL PRIMARY KEY,
    zone_id BIGINT NOT NULL UNIQUE,
    zone_name VARCHAR(150),
    base_rate_per_km NUMERIC(10,2),
    base_rate_per_min NUMERIC(10,2),
    minimum_fare NUMERIC(10,2),
    is_active BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_sk INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    month_number INTEGER,
    month_name VARCHAR(20),
    quarter_number INTEGER,
    year_number INTEGER,
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_payment_method (
    payment_method_sk BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS fact_rides (
    ride_fact_sk BIGSERIAL PRIMARY KEY,
    ride_id BIGINT NOT NULL UNIQUE,
    rider_sk BIGINT REFERENCES dim_rider(rider_sk),
    driver_sk BIGINT REFERENCES dim_driver(driver_sk),
    vehicle_sk BIGINT REFERENCES dim_vehicle(vehicle_sk),
    zone_sk BIGINT REFERENCES dim_zone(zone_sk),
    date_sk INTEGER REFERENCES dim_date(date_sk),
    payment_method_sk BIGINT REFERENCES dim_payment_method(payment_method_sk),
    ride_status VARCHAR(30),
    estimated_fare NUMERIC(10,2),
    final_fare NUMERIC(10,2),
    distance_km NUMERIC(10,2),
    duration_min INTEGER,
    surge_multiplier NUMERIC(5,2),
    payment_amount NUMERIC(10,2),
    driver_rating INTEGER,
    rider_rating INTEGER,
    requested_at TIMESTAMP,
    completed_at TIMESTAMP
);
