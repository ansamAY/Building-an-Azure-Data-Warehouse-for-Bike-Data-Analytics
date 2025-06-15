CREATE TABLE dim_rider (
    account_number INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    birthdate DATE,
    rider_age INT,
    is_member BIT NOT NULL,
    account_start_date DATE,
    account_end_date DATE
)
WITH (
    DISTRIBUTION = HASH(account_number),
    HEAP
);

INSERT INTO dim_rider (account_number, first_name, last_name, address, birthdate, rider_age, is_member, account_start_date, account_end_date)
SELECT
    rider_id AS account_number,
    first_name,
    last_name,
    address,
    TRY_CAST(LEFT(birthdate, 10) AS DATE) AS birthdate,
    CASE 
        WHEN TRY_CAST(LEFT(birthdate, 10) AS DATE) IS NOT NULL THEN
            DATEDIFF(YEAR, TRY_CAST(LEFT(birthdate, 10) AS DATE), GETDATE())
            - CASE 
                WHEN DATEADD(YEAR, DATEDIFF(YEAR, TRY_CAST(LEFT(birthdate, 10) AS DATE), GETDATE()), TRY_CAST(LEFT(birthdate, 10) AS DATE)) > GETDATE() THEN 1
                ELSE 0
              END
        ELSE NULL
    END AS rider_age,
    is_member,
    TRY_CAST(LEFT(account_start, 10) AS DATE) AS account_start_date,
    TRY_CAST(LEFT(account_end, 10) AS DATE) AS account_end_date
FROM
    dbo.rider
WHERE
    TRY_CAST(LEFT(birthdate, 10) AS DATE) IS NOT NULL;



-- Sample query to verify data
SELECT TOP 100 * FROM dim_rider;
