-- 01. RAW DATA SCHEMA

CREATE TABLE IF NOT EXISTS public.citibike_trips_raw (
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


-- 02. RAW DATA QUALITY CHECKS

SELECT
    COUNT(*) AS total_raw_records,
    COUNT(DISTINCT ride_id) AS unique_ride_ids,
    COUNT(*) - COUNT(DISTINCT ride_id)
        AS duplicate_or_null_id_count
FROM public.citibike_trips_raw;


-- 03. MISSING VALUES & TIMESTAMP VALIDATION

SELECT
    COUNT(*) FILTER (
        WHERE ride_id IS NULL
    ) AS missing_ride_ids,

    COUNT(*) FILTER (
        WHERE member_casual IS NULL
    ) AS missing_rider_types,

    COUNT(*) FILTER (
        WHERE started_at IS NULL OR ended_at IS NULL
    ) AS missing_timestamps,

    COUNT(*) FILTER (
        WHERE start_station_name IS NULL
           OR end_station_name IS NULL
    ) AS missing_station_names,

    COUNT(*) FILTER (
        WHERE start_lat IS NULL OR start_lng IS NULL
           OR end_lat IS NULL OR end_lng IS NULL
    ) AS missing_coordinates,

    COUNT(*) FILTER (
        WHERE ended_at < started_at
    ) AS reversed_timestamps
FROM public.citibike_trips_raw;


-- 04. RIDE DURATION QUALITY CHECK

SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM
            (ended_at - started_at)) / 60.0)::numeric,
        2
    ) AS avg_duration_minutes,

    ROUND(
        MAX(EXTRACT(EPOCH FROM
            (ended_at - started_at)) / 60.0)::numeric,
        2
    ) AS max_duration_minutes,

    COUNT(*) FILTER (
        WHERE EXTRACT(EPOCH FROM
            (ended_at - started_at)) / 60.0 > 60
    ) AS rides_over_60_minutes

FROM public.citibike_trips_raw;


-- 05. JULY DATE FILTER VALIDATION

    COUNT(*) AS july_starting_trips
FROM public.citibike_trips_raw
WHERE started_at >= DATE '2026-07-01'
  AND started_at < DATE '2026-08-01';


-- 06. CREATE RECONSTRUCTED CLEANED TABLE
-- Uses a separate table name to preserve the existing
-- citibike_trips_clean table and Tableau data source.
--
-- Includes the 13 original fields plus five derived fields.

CREATE TABLE IF NOT EXISTS
    public.citibike_trips_clean_reconstructed AS

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
        (EXTRACT(EPOCH FROM
            (ended_at - started_at)) / 60.0)::numeric,
        2
    ) AS ride_duration_minutes,

    started_at::date AS ride_date,

    EXTRACT(HOUR FROM started_at)::integer
        AS ride_hour,

    TRIM(TO_CHAR(started_at, 'Day'))
        AS day_of_week,

    CASE
        WHEN EXTRACT(ISODOW FROM started_at) IN (6, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type

FROM public.citibike_trips_raw

WHERE started_at >= DATE '2026-07-01'
  AND started_at < DATE '2026-08-01'
  AND ended_at >= started_at;


-- 07. VALIDATE CLEANED RECORD COUNTS

SELECT
    (SELECT COUNT(*)
     FROM public.citibike_trips_raw)
        AS raw_records,

    (SELECT COUNT(*)
     FROM public.citibike_trips_clean)
        AS existing_clean_records,

    (SELECT COUNT(*)
     FROM public.citibike_trips_clean_reconstructed)
        AS reconstructed_records;


-- 08. VERIFY DERIVED FIELD COMPLETENESS

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE ride_duration_minutes IS NULL
    ) AS missing_duration,

    COUNT(*) FILTER (
        WHERE ride_date IS NULL
           OR ride_hour IS NULL
           OR day_of_week IS NULL
           OR day_type IS NULL
    ) AS missing_derived_fields

FROM public.citibike_trips_clean_reconstructed;


-- 09. COMPARE RECONSTRUCTED AND EXISTING CLEANED DATA

SELECT
    COUNT(*) FILTER (
        WHERE r.ride_id IS NULL
    ) AS missing_from_reconstructed,

    COUNT(*) FILTER (
        WHERE c.ride_id IS NULL
    ) AS missing_from_existing,

    COUNT(*) FILTER (
        WHERE r.ride_id IS NOT NULL
          AND c.ride_id IS NOT NULL
          AND (
              r.ride_duration_minutes
                  IS DISTINCT FROM c.ride_duration_minutes
              OR r.ride_date IS DISTINCT FROM c.ride_date
              OR r.ride_hour IS DISTINCT FROM c.ride_hour
              OR r.day_of_week IS DISTINCT FROM c.day_of_week
              OR r.day_type IS DISTINCT FROM c.day_type
          )
    ) AS transformation_mismatches

FROM public.citibike_trips_clean_reconstructed r
FULL OUTER JOIN public.citibike_trips_clean c
    ON r.ride_id = c.ride_id;


-- 10. FINAL DATASET SUMMARY

SELECT
    COUNT(*) AS total_cleaned_rides,
    COUNT(DISTINCT ride_id) AS unique_rides,
    MIN(ride_date) AS earliest_ride_date,
    MAX(ride_date) AS latest_ride_date,
    ROUND(AVG(ride_duration_minutes), 2)
        AS avg_ride_duration_minutes

FROM public.citibike_trips_clean;
