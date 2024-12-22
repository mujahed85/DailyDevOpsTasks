import boto3
import json

# Initialize AWS services
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Specify your DynamoDB table name
DYNAMODB_TABLE_NAME = "tbl-timestamp"  # Replace with your table name

def lambda_handler(event, context):
    """
    Lambda function to process S3 events and upload data to DynamoDB.
    """
    try:
        # Extract bucket name and object key from the event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        object_key = event['Records'][0]['s3']['object']['key']
        
        print(f"Bucket: {bucket_name}, Object: {object_key}")
        
        # Get the file content directly from S3
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        file_content = response['Body'].read().decode('utf-8').strip()
        
        print(f"File content: {file_content}")
        
        # Parse the file content (assumes the format "Random Timestamp: <timestamp>")
        if "Random Timestamp" in file_content:
            _, timestamp_value = file_content.split(": ")
            print(f"Timestamp extracted: {timestamp_value}")
        else:
            raise ValueError("Unexpected file format")
        
        # Upload the data to DynamoDB
        table = dynamodb.Table(DYNAMODB_TABLE_NAME)
        table.put_item(Item={
            "PK01": object_key,  # Use the S3 object key as the unique ID
            "timestamp": timestamp_value
        })
        
        print(f"Data uploaded to DynamoDB table: {DYNAMODB_TABLE_NAME}")
        return {
            "statusCode": 200,
            "body": json.dumps("Data successfully processed and uploaded to DynamoDB")
        }
    
    except Exception as e:
        print(f"Error processing the event: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error processing the file: {str(e)}")
        }

