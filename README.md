# Azure Data Warehouse Pipeline: Bike Share Analytics Project

This project demonstrates the complete pipeline of designing and building a modern cloud-based data warehouse using Azure services. It includes data ingestion from PostgreSQL, transformation via SQL, and loading into a star schema structure on Azure Synapse Analytics.

---

##  Project Overview

### Business Case
A bike share company wants to analyze ride, payment, and station data for better customer insight and operations. This pipeline ingests operational data and transforms it into a star schema to support reporting and business intelligence.

---

##  Technologies Used

- **Azure PostgreSQL** – Operational (OLTP) database source
- **Azure Synapse Analytics** – Data warehouse (OLAP) with Serverless and Dedicated SQL Pools
- **Azure Blob Storage / Data Lake Gen2** – Raw data and staging area
- **Azure Data Lake / Ingest Wizard** – Data movement
- **SQL (T-SQL)** – Transformation logic
- **Python** – Data population via script
- **dbeaver** – PostgreSQL UI for verification

##  Pipeline Steps

### Task 1: Create Azure Resources
- Create Azure PostgreSQL Database
- Create Azure Synapse Workspace
- Use built-in **Serverless SQL Pool**

### Task 2: Design Star Schema
Design based on business requirements:
- **Fact Tables:** `fact_trip`, `fact_payment`
- **Dimension Tables:** `dim_rider`, `dim_station`, `dim_date`

### Task 3: Load PostgreSQL
- Run `ProjectDataToPostgres.py` to insert data into PostgreSQL tables:
  - `trip.csv`
  - `payment.csv`
  - `station.csv`
  - `rider.csv`
- Verify using `pgAdmin`

###  Task 4: Extract to Azure Data Lake
- Use Synapse **Ingest Wizard** to extract data from PostgreSQL to Azure Data Lake (Blob Storage as `.csv` files)

###  Task 5: Load into External Tables
- Create external tables in **Serverless SQL Pool** pointing to `.csv` in Data Lake
- Use `EXTERNAL TABLE` + `EXTERNAL DATA SOURCE` + `FILE FORMAT`

### Task 6: Transform to Star Schema
- Create tables in **Dedicated SQL Pool**
- Use SQL scripts to `INSERT INTO` final fact/dim tables from external staging

---

##  Star Schema Overview

**Fact Tables**
- `fact_payment(payment_id, payment_date, payment_amount, rider_id)`
- `fact_trip(trip_id, ride_type, started_at, ended_at, start_station_id, end_station_id, duration, rider_id)`

**Dimension Tables**
- `dim_rider(rider_id, name, birthdate, is_member, account_start, account_end,rider_age)`
- `dim_station(station_id, address, lat, lon)`
- `dim_date(date_key, full_date, year, month, week, weekday,...so on)`

---

## Final Outcome

By the end of this project, you'll have:
- Designed and implemented a star schema
- Built a full ETL/ELT pipeline using Azure tools
- Gained experience working with external tables, serverless/dedicated SQL pools
- Produced a clean, scalable cloud data warehouse ready for BI/reporting


---

## 📚 Resources

- [Azure Synapse Documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/)
- [PostgreSQL Official Docs](https://www.postgresql.org/docs/)
- [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/)

---

##  Author

**Ansam Ali**  
Data Engineer | Technical writer

---

## 📝 License

This project is for educational purposes. Please cite if used.




