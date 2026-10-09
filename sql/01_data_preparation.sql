
-- ============================================================
-- PROJECT 2: CITI BIKE RIDER DEMAND & MEMBERSHIP ANALYSIS
-- 01_data_preparation.sql
-- Original PostgreSQL data preparation queries
-- ============================================================


-- QUERY 1: CREATE RAW DATA TABLE

CREATE TABLE citibike_trips_raw (
    ride_id TEXT,
    rideable_type TEXT,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    start_station_name TEXT,
    start_station_id TEXT,
    end_station_name TEXT,
    end_station_id TEXT,
    start_lat DOUBLE PRECISION,
    start_lng DOUBLE PRECISION,
    end_lat DOUBLE PRECISION,
    end_lng DOUBLE PRECISION,
    member_casual TEXT
);


-- QUERY 2: CLEANING AND TRANSFORMATION

CREATE TABLE citibike_trips_clean AS
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual,

    ROUND(
        (EXTRACT(EPOCH FROM (ended_at - started_at)) / 60)::numeric,
        2
    ) AS ride_duration_minutes,

    started_at::date AS ride_date,

    EXTRACT(HOUR FROM started_at)::int AS ride_hour,

    TRIM(TO_CHAR(started_at, 'Day')) AS day_of_week,

    CASE
        WHEN EXTRACT(ISODOW FROM started_at) IN (6, 7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type

FROM citibike_trips_raw

WHERE
    ended_at > started_at
    AND started_at >= '2026-07-01 00:00:00'
    AND started_at < '2026-08-01 00:00:00';
