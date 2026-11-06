from pyspark.sql import functions as F

SILVER = "rideshare_silver"
GOLD = "rideshare_gold"

riders = spark.table(f"{SILVER}.riders")
drivers = spark.table(f"{SILVER}.drivers")
vehicles = spark.table(f"{SILVER}.vehicles")
zones = spark.table(f"{SILVER}.pricing_zones")
rides = spark.table(f"{SILVER}.rides")
payments = spark.table(f"{SILVER}.payments")
ratings = spark.table(f"{SILVER}.ratings")

dim_vehicle = vehicles.select(
    F.monotonically_increasing_id().alias("vehicle_sk"),
    "vehicle_id","license_plate","company","model","vehicle_year",
    "vehicle_type","number_of_seats","is_active"
)

dim_zone = zones.select(
    F.monotonically_increasing_id().alias("zone_sk"),
    "zone_id","zone_name","base_rate_per_km","base_rate_per_min",
    "minimum_fare","is_active"
)

dim_payment_method = (
    payments.select("payment_method").where(F.col("payment_method").isNotNull()).distinct()
    .withColumn("payment_method_sk", F.monotonically_increasing_id())
    .select("payment_method_sk","payment_method")
)

dim_date = (
    rides.select(F.to_date("requested_at").alias("full_date"))
    .where(F.col("full_date").isNotNull())
    .distinct()
    .withColumn("date_sk", F.date_format("full_date","yyyyMMdd").cast("int"))
    .withColumn("day_of_week", F.dayofweek("full_date"))
    .withColumn("day_name", F.date_format("full_date","EEEE"))
    .withColumn("month_number", F.month("full_date"))
    .withColumn("month_name", F.date_format("full_date","MMMM"))
    .withColumn("quarter_number", F.quarter("full_date"))
    .withColumn("year_number", F.year("full_date"))
    .withColumn("is_weekend", F.dayofweek("full_date").isin(1,7))
)

driver_ratings = (
    ratings.filter(F.col("ratee_type") == "DRIVER")
    .groupBy("ride_id")
    .agg(F.max("stars").alias("driver_rating"))
)

rider_ratings = (
    ratings.filter(F.col("ratee_type") == "RIDER")
    .groupBy("ride_id")
    .agg(F.max("stars").alias("rider_rating"))
)

fact_rides = (
    rides.alias("r")
    .join(dim_vehicle.alias("v"), F.col("r.vehicle_id") == F.col("v.vehicle_id"), "left")
    .join(dim_zone.alias("z"), F.col("r.zone_id") == F.col("z.zone_id"), "left")
    .join(payments.alias("p"), F.col("r.ride_id") == F.col("p.ride_id"), "left")
    .join(dim_payment_method.alias("pm"), F.col("p.payment_method") == F.col("pm.payment_method"), "left")
    .join(driver_ratings.alias("dr"), "ride_id", "left")
    .join(rider_ratings.alias("rr"), "ride_id", "left")
    .withColumn("date_sk", F.date_format(F.to_date("requested_at"),"yyyyMMdd").cast("int"))
    .withColumn("surge_multiplier", F.lit(1.0))
    .select(
        F.monotonically_increasing_id().alias("ride_fact_sk"),
        "ride_id",
        F.col("r.rider_id").alias("rider_id"),
        F.col("r.driver_id").alias("driver_id"),
        F.col("v.vehicle_sk"),
        F.col("z.zone_sk"),
        "date_sk",
        F.col("pm.payment_method_sk"),
        F.col("r.status").alias("ride_status"),
        "estimated_fare","final_fare","distance_km","duration_min",
        "surge_multiplier",
        F.col("p.amount").alias("payment_amount"),
        "driver_rating","rider_rating",
        "requested_at","completed_at"
    )
)

dim_vehicle.write.mode("overwrite").option("overwriteSchema","true").saveAsTable(f"{GOLD}.dim_vehicle")
dim_zone.write.mode("overwrite").option("overwriteSchema","true").saveAsTable(f"{GOLD}.dim_zone")
dim_payment_method.write.mode("overwrite").option("overwriteSchema","true").saveAsTable(f"{GOLD}.dim_payment_method")
dim_date.write.mode("overwrite").option("overwriteSchema","true").saveAsTable(f"{GOLD}.dim_date")
fact_rides.write.mode("overwrite").option("overwriteSchema","true").saveAsTable(f"{GOLD}.fact_rides")
