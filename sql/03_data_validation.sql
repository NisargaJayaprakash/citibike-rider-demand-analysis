-- Verify transformed fields in the cleaned dataset

SELECT
    ride_id,
    ride_duration_minutes,
    ride_date,
    ride_hour,
    day_of_week,
    day_type,
    member_casual,
    rideable_type
FROM citibike_trips_clean
LIMIT 10;
