from pyspark.sql import functions as F

SOURCE_ROOT = "/Volumes/rideshare/landing/raw"
BRONZE_CATALOG = "rideshare_bronze"

DATASETS = [
    "riders",
    "drivers",
    "vehicles",
    "pricing_zones",
    "surge_pricing",
    "rides",
    "driver_locations",
    "payments",
    "ratings",
]

def ingest_dataset(dataset: str):
    source_path = f"{SOURCE_ROOT}/{dataset}"
    target_table = f"{BRONZE_CATALOG}.{dataset}"

    (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("header", "true")
        .option("cloudFiles.inferColumnTypes", "true")
        .load(source_path)
        .withColumn("_ingest_ts", F.current_timestamp())
        .withColumn("_source_file", F.col("_metadata.file_path"))
        .writeStream
        .option("checkpointLocation", f"/Volumes/rideshare/checkpoints/{dataset}")
        .trigger(availableNow=True)
        .toTable(target_table)
    )

for dataset in DATASETS:
    ingest_dataset(dataset)
