from pyspark.sql import SparkSession
from pyspark.sql.functions import unix_timestamp, monotonically_increasing_id, split, col 
from pyspark.sql.types import StructType, StructField, StringType, LongType, IntegerType, DoubleType

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

# Read the CSV file
df = spark.read.csv("s3a://utfsm-datasets-inf356/vlt_observations/vlt_observations_000.csv", header=False, schema=schema)

# Numbering columns
df = df.withColumn("oid", monotonically_increasing_id())

# Parse columns - simple types
df = df.withColumn("exposition_time", col("exposition_time").cast("float")) 
df = df.withColumn("filter_lambda_min", col("filter_lambda_min").cast("float")) 
df = df.withColumn("filter_lambda_max", col("filter_lambda_max").cast("float")) 
df = df.withColumn("obs_mjd", col("obs_mjd").cast("float")) 
df = df.withColumn("airmass", col("airmass").cast("float")) 
df = df.withColumn("seeing", col("seeing").cast("float"))

# Store the data
# You must create an s3 bucket in your aws account with the name XXXXXXXXXX-inf356 where
# XXXXXXXXXX is your student number without dots or dashes. E.G. 123.456.789-0 => 1234567890.
# You must replace the XXXXXXXXXX in the following line
df.write.mode("overwrite").csv("s3a://XXXXXXXXXX-inf356/vlt_observations_000.csv")