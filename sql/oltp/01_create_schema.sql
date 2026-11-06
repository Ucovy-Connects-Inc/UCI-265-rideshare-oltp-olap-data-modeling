CREATE SCHEMA IF NOT EXISTS rideshare;
SET search_path TO rideshare;

CREATE TABLE IF NOT EXISTS riders (
    rider_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    rider_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS drivers (
    driver_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    driver_name VARCHAR(150) NOT NULL,
    license_number VARCHAR(100) NOT NULL UNIQUE,
    rating NUMERIC(3,2) CHECK (rating BETWEEN 0 AND 5),
    total_rides INTEGER NOT NULL DEFAULT 0 CHECK (total_rides >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    city VARCHAR(100),
    state VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL REFERENCES drivers(driver_id),
    license_plate VARCHAR(30) NOT NULL UNIQUE,
    company VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    vehicle_year INTEGER CHECK (vehicle_year BETWEEN 1990 AND 2100),
    color VARCHAR(50),
    vehicle_type VARCHAR(50) NOT NULL,
    number_of_seats INTEGER CHECK (number_of_seats > 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS pricing_zones (
    zone_id BIGSERIAL PRIMARY KEY,
    zone_name VARCHAR(150) NOT NULL UNIQUE,
    base_rate_per_km NUMERIC(10,2) NOT NULL CHECK (base_rate_per_km >= 0),
    base_rate_per_min NUMERIC(10,2) NOT NULL CHECK (base_rate_per_min >= 0),
    minimum_fare NUMERIC(10,2) NOT NULL CHECK (minimum_fare >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS surge_pricing (
    surge_id BIGSERIAL PRIMARY KEY,
    zone_id BIGINT NOT NULL REFERENCES pricing_zones(zone_id),
    multiplier NUMERIC(5,2) NOT NULL CHECK (multiplier >= 1),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    CHECK (end_time IS NULL OR end_time > start_time)
);

CREATE TABLE IF NOT EXISTS rides (
    ride_id BIGSERIAL PRIMARY KEY,
    rider_id BIGINT NOT NULL REFERENCES riders(rider_id),
    driver_id BIGINT REFERENCES drivers(driver_id),
    vehicle_id BIGINT REFERENCES vehicles(vehicle_id),
    zone_id BIGINT REFERENCES pricing_zones(zone_id),
    status VARCHAR(30) NOT NULL CHECK (
        status IN ('REQUESTED','MATCHED','ARRIVED','IN_PROGRESS','COMPLETED','CANCELLED')
    ),
    pickup_latitude NUMERIC(9,6),
    pickup_longitude NUMERIC(9,6),
    pickup_address VARCHAR(500),
    destination_latitude NUMERIC(9,6),
    destination_longitude NUMERIC(9,6),
    destination_address VARCHAR(500),
    estimated_fare NUMERIC(10,2) CHECK (estimated_fare >= 0),
    final_fare NUMERIC(10,2) CHECK (final_fare >= 0),
    distance_km NUMERIC(10,2) CHECK (distance_km >= 0),
    duration_min INTEGER CHECK (duration_min >= 0),
    requested_at TIMESTAMP NOT NULL,
    matched_at TIMESTAMP,
    pickup_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS driver_locations (
    location_id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL REFERENCES drivers(driver_id),
    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,
    heading INTEGER CHECK (heading BETWEEN 0 AND 359),
    speed_kph NUMERIC(8,2) CHECK (speed_kph >= 0),
    accuracy_meters NUMERIC(8,2) CHECK (accuracy_meters >= 0),
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id BIGSERIAL PRIMARY KEY,
    ride_id BIGINT NOT NULL REFERENCES rides(ride_id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL CHECK (
        status IN ('PENDING','AUTHORIZED','PAID','FAILED','REFUNDED')
    ),
    gateway_transaction_id VARCHAR(150) UNIQUE,
    failure_reason VARCHAR(500),
    processed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ratings (
    rating_id BIGSERIAL PRIMARY KEY,
    ride_id BIGINT NOT NULL REFERENCES rides(ride_id),
    rater_type VARCHAR(20) NOT NULL CHECK (rater_type IN ('RIDER','DRIVER')),
    rater_id BIGINT NOT NULL,
    ratee_type VARCHAR(20) NOT NULL CHECK (ratee_type IN ('RIDER','DRIVER')),
    ratee_id BIGINT NOT NULL,
    stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (ride_id, rater_type, rater_id, ratee_type, ratee_id)
);

CREATE INDEX IF NOT EXISTS idx_rides_rider_id ON rides(rider_id);
CREATE INDEX IF NOT EXISTS idx_rides_driver_id ON rides(driver_id);
CREATE INDEX IF NOT EXISTS idx_rides_requested_at ON rides(requested_at);
CREATE INDEX IF NOT EXISTS idx_locations_driver_time ON driver_locations(driver_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_payments_ride_id ON payments(ride_id);
