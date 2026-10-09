-- QUERY 1: RIDES BY DAY OF WEEK

SELECT
    day_of_week,
    COUNT(*) AS total_rides
FROM citibike_trips_clean
GROUP BY day_of_week
ORDER BY total_rides DESC;


-- QUERY 2: HOURLY RIDER DEMAND

SELECT
    ride_hour,
    COUNT(*) AS total_rides
FROM citibike_trips_clean
GROUP BY ride_hour
ORDER BY total_rides DESC;


-- QUERY 3: WEEKDAY VS WEEKEND DEMAND

SELECT
    day_type,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_rides
FROM citibike_trips_clean
GROUP BY day_type
ORDER BY total_rides DESC;


-- QUERY 4: MEMBER VS CASUAL RIDER ANALYSIS

SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_rides,
    ROUND(AVG(ride_duration_minutes), 2)
        AS avg_ride_duration_minutes
FROM citibike_trips_clean
GROUP BY member_casual
ORDER BY total_rides DESC;


-- QUERY 5: MEMBERSHIP USAGE BY WEEKDAY/WEEKEND

SELECT
    member_casual,
    day_type,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_duration_minutes), 2)
        AS avg_duration_minutes
FROM citibike_trips_clean
GROUP BY member_casual, day_type
ORDER BY member_casual, total_rides DESC;


-- QUERY 6: MEMBERSHIP USAGE BY HOUR

SELECT
    member_casual,
    ride_hour,
    COUNT(*) AS total_rides
FROM citibike_trips_clean
GROUP BY member_casual, ride_hour
ORDER BY member_casual, total_rides DESC;


-- QUERY 7: TOP 10 DEPARTURE STATIONS

SELECT
    start_station_name,
    COUNT(*) AS total_departures
FROM citibike_trips_clean
WHERE start_station_name IS NOT NULL
GROUP BY start_station_name
ORDER BY total_departures DESC
LIMIT 10;


-- QUERY 8: TOP 10 DESTINATION STATIONS

SELECT
    end_station_name,
    COUNT(*) AS total_arrivals
FROM citibike_trips_clean
WHERE end_station_name IS NOT NULL
GROUP BY end_station_name
ORDER BY total_arrivals DESC
LIMIT 10;


-- QUERY 9: BIKE TYPE USAGE ANALYSIS

SELECT
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_rides,
    ROUND(AVG(ride_duration_minutes), 2)
        AS avg_ride_duration_minutes
FROM citibike_trips_clean
GROUP BY rideable_type
ORDER BY total_rides DESC;
