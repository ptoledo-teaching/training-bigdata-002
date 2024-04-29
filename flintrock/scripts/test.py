from pyspark.sql import SparkSession
from pyspark.sql.functions import unix_timestamp, monotonically_increasing_id, split, col 
from pyspark.sql.types import StructType, StructField, StringType, LongType, IntegerType, DoubleType

# Create a SparkSession
spark = SparkSession \
    .builder \
    .config("spark.executor.instances", "4") \
    .getOrCreate()

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
df = spark.read.csv("/data/vlt_observations.csv", header=False, schema=schema)
#df = df.withColumn("oid", monotonically_increasing_id())

# Parse columns
df = df.withColumn("obs_timestamp", unix_timestamp(df["obs_timestamp"], "yyyy MMM d HH:mm:ss").cast(LongType())) \
    .withColumn("release_date", unix_timestamp(df["release_date"], "MMM d yyyy").cast(LongType())) \
    .withColumn("template_start", unix_timestamp(split(df["template_start"], "\\.")[0], "yyyy-MM-dd'T'HH:mm:ss").cast(LongType())) \
    .withColumn("exposition_time", col("exposition_time").cast("float")) \
    .withColumn("filter_lambda_min", col("filter_lambda_min").cast("float")) \
    .withColumn("filter_lambda_max", col("filter_lambda_max").cast("float")) \
    .withColumn("obs_mjd", col("obs_mjd").cast("float")) \
    .withColumn("airmass", col("airmass").cast("float")) \
    .withColumn("seeing", col("seeing").cast("float"))

# Show the DataFrame
#selected_df = df.select("release_date", "template_start", "airmass")
#selected_df.show()

# Store the data
#df.write.mode("overwrite").parquet("/data/vlt_observations.parquet")
object_counts = df.groupBy("object").count()
object_counts.show()