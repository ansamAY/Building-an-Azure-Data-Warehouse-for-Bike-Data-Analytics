-- Create dim_station table optimized for Dedicated SQL Pool
CREATE TABLE dim_station (
    station_id VARCHAR(100) NOT NULL,
    station_name VARCHAR(100) NOT NULL,
    station_latitude FLOAT NOT NULL,
    station_longitude FLOAT NOT NULL
)
WITH (
    DISTRIBUTION = HASH(station_id),         -- Distribute by station_id for performance on joins
    HEAP                                    -- Use HEAP, or consider CLUSTERED COLUMNSTORE if table grows large
);

-- Insert data from staging_station
INSERT INTO dim_station (station_id, station_name, station_latitude, station_longitude)
SELECT
    station_id,
    station_name,
    latitude,
    longitude
FROM
    dbo.station
WHERE
    station_id IS NOT NULL                    -- Filter out rows with null station_id
    AND latitude IS NOT NULL
    AND longitude IS NOT NULL
;

-- Sample select to verify data
SELECT TOP 100 * FROM dim_station;
