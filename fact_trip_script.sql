-- Create fact_trip table optimized for Dedicated SQL Pool
CREATE TABLE fact_trip (
    trip_id VARCHAR(50) NOT NULL,
    trip_type VARCHAR(75),
    started_at DATETIME2 NOT NULL,
    ended_at DATETIME2 NOT NULL,
    start_station_id VARCHAR(50),
    end_station_id VARCHAR(50),
    rider_id INT NOT NULL,
    duration_trip FLOAT      -- Duration in minutes
)
WITH (
    DISTRIBUTION = HASH(trip_id),         -- Distribute by trip_id for better load & join performance
    CLUSTERED COLUMNSTORE INDEX           -- Best for large fact tables, analytical queries
);

-- Insert data with proper conversions and join
INSERT INTO fact_trip (trip_id, trip_type, started_at, ended_at, start_station_id, end_station_id, rider_id, duration_trip)
SELECT
    trip.trip_id,
    trip.trip_type,
    TRY_CAST(trip.started_at AS DATETIME2) AS started_at,
    TRY_CAST(trip.ended_at AS DATETIME2) AS ended_at,
    trip.start_station_id,
    trip.end_station_id,
    trip.rider_id ,
    DATEDIFF(MINUTE, TRY_CAST(trip.started_at AS DATETIME2), TRY_CAST(trip.ended_at AS DATETIME2)) AS duration_trip
FROM
    dbo.trip trip
WHERE
    TRY_CAST(trip.started_at AS DATETIME2) IS NOT NULL
    AND TRY_CAST(trip.ended_at AS DATETIME2) IS NOT NULL
;

-- Sample data check
SELECT TOP 100 * FROM fact_trip;
