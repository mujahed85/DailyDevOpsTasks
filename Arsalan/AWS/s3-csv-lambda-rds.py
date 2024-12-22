import json
import boto3
import pymysql
import csv
from io import StringIO

# RDS MySQL configurations
RDS_HOST = "rds-mysql.czokoiy2urvv.us-east-1.rds.amazonaws.com"  # Replace with your RDS endpoint
RDS_PORT = 3306  # Default MySQL port
RDS_USER = "admin"  # Replace with your DB username
RDS_PASSWORD = "Admin123"  # Replace with your DB password
RDS_DB_NAME = "company"  # Replace with your database name

# S3 client
s3_client = boto3.client('s3')

# Function to insert data into MySQL
def insert_data_to_rds(csv_data):
    # Connect to RDS MySQL database
    connection = pymysql.connect(
        host=RDS_HOST,
        user=RDS_USER,
        password=RDS_PASSWORD,
        database=RDS_DB_NAME,
        port=RDS_PORT
    )
    
    try:
        with connection.cursor() as cursor:
            # Prepare SQL query - adjust this based on your table structure
            insert_query = """
                INSERT INTO employees (id, name, department)
                VALUES (%s, %s, %s)
            """
            for row in csv_data:
                cursor.execute(insert_query, (row[0], row[1], row[2]))  # Adjust row indexing as needed
            connection.commit()  # Commit the transaction
    finally:
        connection.close()  # Always close the connection

# Lambda handler function
def lambda_handler(event, context):
    # Extract bucket and file name from S3 event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']
    
    # Log the event for debugging
    print(f"Received S3 event. Bucket: {bucket_name}, File: {file_name}")
    
    # Download the CSV file from S3
    s3_object = s3_client.get_object(Bucket=bucket_name, Key=file_name)
    file_content = s3_object['Body'].read().decode('utf-8')
    
    # Read the CSV content
    csv_reader = csv.reader(StringIO(file_content))

    print(f"readed content : {file_content}")
    
    # Convert CSV rows into a list of tuples (skip the header row if necessary)
    csv_data = []
    for row in csv_reader:
        if row:  # Skip empty rows
            csv_data.append(row)
    
    # Insert data into RDS MySQL
    if csv_data:
        insert_data_to_rds(csv_data)
        print(f"Successfully inserted {len(csv_data)} rows into RDS.")
    else:
        print("No data to insert into RDS.")
    
    return {
        'statusCode': 200,
        'body': json.dumps('CSV processing complete.')
    }
