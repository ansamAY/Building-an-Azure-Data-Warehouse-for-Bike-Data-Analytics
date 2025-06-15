-- Create the fact_payment table optimized for Dedicated SQL Pool
CREATE TABLE fact_payment (
    payment_id varchar(50) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount varchar(50) NOT NULL,
    account_number varchar(50) NOT NULL
)
WITH (
    DISTRIBUTION = HASH(payment_id),  -- Optimize for query and loading on account_number
    CLUSTERED COLUMNSTORE INDEX           -- Best for large fact tables
);

-- Insert data from staging with safe conversion
INSERT INTO fact_payment (payment_id, payment_date, payment_amount, account_number)
SELECT
    payment_id,
    TRY_CAST(LEFT(payment_date, 10) AS DATE) AS payment_date,
    payment_amount,
    rider_id AS account_number
FROM
    dbo.PAYMENT
WHERE
    TRY_CAST(LEFT(payment_date, 10) AS DATE) IS NOT NULL;

-- Sample query to verify data
SELECT TOP 100 * FROM fact_payment;
