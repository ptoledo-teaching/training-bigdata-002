from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder.getOrCreate()

# Create a list of numbers
numbers = range(0, 1000000)

# Parallelize the list to create an RDD (Resilient Distributed Dataset)
rdd = spark.sparkContext.parallelize(numbers, numSlices=4)

# Perform a distributed calculation - sum of squares
sum_of_squares = rdd.map(lambda x: x*x).reduce(lambda x, y: x + y)

# Print the result
print("Sum of squares:", sum_of_squares)

# Stop Spark session
spark.stop()