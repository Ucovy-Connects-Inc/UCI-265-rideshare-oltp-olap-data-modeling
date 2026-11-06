from pathlib import Path
import ast, csv

ROOT = Path(__file__).resolve().parents[1]

required = [
    "README.md",
    "sql/oltp/01_create_schema.sql",
    "sql/oltp/02_validation.sql",
    "sql/olap/01_create_star_schema.sql",
    "sql/olap/02_scd_type1.sql",
    "sql/olap/03_scd_type2.sql",
    "sql/olap/04_analytics.sql",
    "src/bronze/bronze_ingestion.py",
    "src/silver/build_silver.py",
    "src/gold/build_gold.py",
    "docs/BUSINESS_REQUIREMENTS.md",
    "docs/CONCEPTUAL_MODEL.md",
    "docs/NORMALIZATION.md",
    "docs/ARCHITECTURE.md",
    "docs/DATA_DICTIONARY.md",
    "diagrams/oltp_er_diagram.mmd",
    "diagrams/olap_star_schema.mmd",
]

missing = [p for p in required if not (ROOT / p).exists()]
if missing:
    raise SystemExit(f"Missing required files: {missing}")

for p in [
    "src/bronze/bronze_ingestion.py",
    "src/silver/build_silver.py",
    "src/gold/build_gold.py",
    "tests/test_sample_data.py",
]:
    ast.parse((ROOT / p).read_text(encoding="utf-8"))

print("Static repository validation passed.")
