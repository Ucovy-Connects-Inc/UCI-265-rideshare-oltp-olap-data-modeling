from pyspark.sql import functions as F
from pyspark.sql.window import Window

BRONZE = "rideshare_bronze"
SILVER = "rideshare_silver"

def latest_by_key(df, key_col, ts_col):
    window = Window.partitionBy(key_col).orderBy(F.col(ts_col).desc_nulls_last())
    return (
        df.withColumn("_rn", F.row_number().over(window))
          .filter(F.col("_rn") == 1)
          .drop("_rn")
    )

riders = (
    spark.table(f"{BRONZE}.riders")
    .filter(F.col("rider_id").isNotNull())
    .withColumn("email", F.lower(F.trim("email")))
    .withColumn("phone_number", F.trim("phone_number"))
    .withColumn("rider_name", F.initcap(F.trim("rider_name")))
    .withColumn("city", F.initcap(F.trim("city")))
    .withColumn("state", F.upper(F.trim("state")))
    .dropDuplicates(["rider_id"])
)

drivers = (
    spark.table(f"{BRONZE}.drivers")
    .filter(F.col("driver_id").isNotNull())
    .withColumn("email", F.lower(F.trim("email")))
    .withColumn("driver_name", F.initcap(F.trim("driver_name")))
    .withColumn("city", F.initcap(F.trim("city")))
    .withColumn("state", F.upper(F.trim("state")))
    .dropDuplicates(["driver_id"])
)

vehicles = (
    spark.table(f"{BRONZE}.vehicles")
    .filter(F.col("vehicle_id").isNotNull())
    .dropDuplicates(["vehicle_id"])
)

zones = (
    spark.table(f"{BRONZE}.pricing_zones")
    .filter(F.col("zone_id").isNotNull())
    .dropDuplicates(["zone_id"])
)

rides = (
    spark.table(f"{BRONZE}.rides")
    .filter(F.col("ride_id").isNotNull())
    .withColumn("status", F.upper(F.trim("status")))
    .filter(F.col("status").isin(
        "REQUESTED","MATCHED","ARRIVED","IN_PROGRESS","COMPLETED","CANCELLED"
    ))
    .filter(F.coalesce(F.col("estimated_fare"), F.lit(0)) >= 0)
    .filter(F.coalesce(F.col("distance_km"), F.lit(0)) >= 0)
    .dropDuplicates(["ride_id"])
)

payments = latest_by_key(
    spark.table(f"{BRONZE}.payments")
         .filter(F.col("payment_id").isNotNull()),
    "ride_id",
    "created_at",
)

ratings = (
    spark.table(f"{BRONZE}.ratings")
    .filter(F.col("stars").between(1, 5))
)

riders.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.riders")
drivers.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.drivers")
vehicles.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.vehicles")
zones.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.pricing_zones")
rides.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.rides")
payments.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.payments")
ratings.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{SILVER}.ratings")
