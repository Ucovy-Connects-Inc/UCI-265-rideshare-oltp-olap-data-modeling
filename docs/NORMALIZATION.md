# Normalization

## 1NF
All columns are atomic and each table has a primary key.

## 2NF
Attributes depend on the full business key. Independent entities are separated.

## 3NF
Transitive dependencies are removed:
- vehicle attributes live in `vehicles`
- pricing attributes live in `pricing_zones`
- driver attributes live in `drivers`
- payment attributes live in `payments`

## BCNF Review
Candidate business keys are enforced with UNIQUE constraints, including email, phone, license number, license plate and gateway transaction id.
