from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType
from pyspark.sql.functions import monotonically_increasing_id, col 

# Bucket
# You must create an s3 bucket in your aws account with the name XXXXXXXXXX-inf356 where
# XXXXXXXXXX is your student number without dots or dashes. E.G. 123.456.789-0 => 1234567890.
# You must replace the XXXXXXXXXX in the following line
bucket = "XXXXXXXXXX-inf356"
filename = "vlt_observations_000"

# Create a SparkSession
spark = SparkSession.builder.getOrCreate()

# Create the data schema
schema = StructType([
    StructField("object", StringType(), True),
    StructField("right_ascension", StringType(), True),
    StructField("declination", StringType(), True),
    StructField("obs_timestamp", StringType(), True),
    StructField("program_id", StringType(), True),
    StructField("investigators", StringType(), True),
    StructField("obs_mode", StringType(), True),
    StructField("title", StringType(), True),
    StructField("program_type", StringType(), True),
    StructField("instrument", StringType(), True),
    StructField("category", StringType(), True),
    StructField("obs_type", StringType(), True),
    StructField("obs_nature", StringType(), True),
    StructField("dataset_id", StringType(), True),
    StructField("obs_file", StringType(), True),
    StructField("release_date", StringType(), True),
    StructField("obs_name", StringType(), True),
    StructField("obs_id", StringType(), True),
    StructField("template_id", StringType(), True),
    StructField("template_start", StringType(), True),
    StructField("exposition_time", StringType(), True),
    StructField("filter_lambda_min", StringType(), True),
    StructField("filter_lambda_max", StringType(), True),
    StructField("filter", StringType(), True),
    StructField("grism", StringType(), True),
    StructField("grating", StringType(), True),
    StructField("slit", StringType(), True),
    StructField("obs_mjd", StringType(), True),
    StructField("airmass", StringType(), True),
    StructField("seeing", StringType(), True),
    StructField("distance", StringType(), True),
    StructField("position", StringType(), True)
])

# Read the CSV file and number the rows
print(f"Reading file {filename}.csv from utfsm-inf356-datasets bucket")
df_0 = spark.read.csv(f"s3a://utfsm-inf356-datasets/vlt_observations/{filename}.csv", header=False, schema=schema)
print(f"    - {df_0.count()} rows read")
print(f"    - Creating row number column")
df_0 = df_0.withColumn("oid", monotonically_increasing_id())

print(f"Writting file as {filename}.parquet into {bucket} bucket")
# Store the data in user bucket
df_0.write.mode("overwrite").parquet(f"s3a://{bucket}/{filename}.parquet")

# Read the data and parse floats
print(f"Reading file {filename}.parquet from {bucket} bucket")
df_1 = spark.read.parquet(f"s3a://{bucket}/{filename}.parquet")
print(f"    - {df_1.count()} rows read")
print(f"    - Parsing float columns")
df_1 = df_1.withColumn("exposition_time", col("exposition_time").cast("float")) 
df_1 = df_1.withColumn("filter_lambda_min", col("filter_lambda_min").cast("float")) 
df_1 = df_1.withColumn("filter_lambda_max", col("filter_lambda_max").cast("float")) 
df_1 = df_1.withColumn("obs_mjd", col("obs_mjd").cast("float")) 
df_1 = df_1.withColumn("airmass", col("airmass").cast("float")) 
df_1 = df_1.withColumn("seeing", col("seeing").cast("float"))

# Store the data in user bucket
print(f"Writting file as {filename}.parsed.csv into {bucket} bucket")
df_1.write.mode("overwrite").csv(f"s3a://{bucket}/{filename}.parsed.csv")
print(f"Writting file as {filename}.parsed.parquet into {bucket} bucket")
df_1.write.mode("overwrite").parquet(f"s3a://{bucket}/{filename}.parsed.parquet")

# Stop Spark session
spark.stop()
