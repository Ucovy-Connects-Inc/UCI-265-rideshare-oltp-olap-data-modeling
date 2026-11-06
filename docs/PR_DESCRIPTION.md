## UCI-265 - Ride-Sharing OLTP to OLAP Data Modeling

### Summary
Implemented an end-to-end Ride-Sharing data architecture covering normalized OLTP modeling, Medallion processing, OLAP dimensional modeling, SCD patterns and analytical SQL.

### Changes Included
- Added Ride-Sharing business requirements and conceptual model.
- Added Crow's Foot OLTP ER diagram and Gold Star Schema diagram.
- Added PostgreSQL 3NF OLTP DDL for riders, drivers, vehicles, rides, locations, pricing, payments and ratings.
- Added PK, FK, unique, check constraints and indexes.
- Added sample Ride-Sharing datasets.
- Added Bronze Auto Loader ingestion example.
- Added Silver PySpark cleansing and integration logic.
- Added Gold Star Schema DDL and PySpark build logic.
- Added surrogate-key design.
- Added SCD Type 1 and SCD Type 2 SQL patterns.
- Added ride volume, revenue, driver, rider, surge and payment analytics SQL.
- Added data-quality and referential-integrity validation.
- Added architecture, normalization and data dictionary documentation.

### Jira
UCI-265

### Note
Runtime execution requires PostgreSQL and/or Spark/Databricks access. The repository contains the implementation artifacts and static validation.
