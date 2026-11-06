# UCI-265 - Ride-Sharing OLTP to OLAP Data Modeling

End-to-end Data Engineering and Data Modeling implementation for a Ride-Sharing platform.

## Scope

- Business requirements and conceptual model
- OLTP relational schema normalized to 3NF
- PostgreSQL DDL with PK/FK/unique/check constraints
- Sample Ride-Sharing datasets
- Bronze / Silver / Gold Medallion processing with PySpark
- OLAP Star Schema with surrogate keys
- SCD Type 1 and Type 2 examples
- Analytical SQL and validation queries
- ER and Star Schema diagrams in Mermaid Crow's Foot notation
- GitHub PR workflow

## Architecture

```text
Operational Ride-Sharing Data
        |
        v
PostgreSQL OLTP (3NF)
        |
        v
Bronze Raw Layer
        |
        v
Silver Cleansed / Integrated Layer
        |
        v
Gold Star Schema
        |
        +--> dimensions
        +--> fact_rides
        |
        v
Analytics SQL / BI
```

## Runtime Note

This repository contains the implementation artifacts. Actual PostgreSQL and Spark/Databricks runtime validation requires the corresponding runtime environment.

## Jira

UCI-265
