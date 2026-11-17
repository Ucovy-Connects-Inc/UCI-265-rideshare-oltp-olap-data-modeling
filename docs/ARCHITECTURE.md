# Architecture

## OLTP
Normalized PostgreSQL schema for high-integrity transactional operations.

## Bronze
Raw source replication with ingestion metadata.

## Silver
Cleansing, standardization, deduplication, validation and integration.

## Gold
Dimensional Star Schema for BI and analytics.

## SCD
- Type 1 for non-historical corrections/current-state attributes.
- Type 2 for full history of selected rider/driver attributes.
