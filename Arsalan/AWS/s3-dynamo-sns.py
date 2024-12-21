import boto3
import random
import datetime
import os
import time

# Function to generate a random timestamp
def generate_random_timestamp():
    start_date = datetime.datetime(2020, 1, 1)
    end_date = datetime.datetime.now()
    random_date = start_date + (end_date - start_date) * random.random()
    return random_date.strftime("%Y-%m-%d %H:%M:%S")

# Function to upload a file to an S3 bucket
def upload_to_s3(file_name, bucket_name, object_name=None):
    s3_client = boto3.client('s3')
    try:
        if object_name is None:
            object_name = os.path.basename(file_name)
        s3_client.upload_file(file_name, bucket_name, object_name)
        print(f"File uploaded to S3: s3://{bucket_name}/{object_name}")
    except Exception as e:
        print(f"Error uploading to S3: {e}")

# Main function
def main():
    bucket_name = "bkt-csv-dynamo"  # Replace with your S3 bucket name
    file_name = "random_timestamp.txt"
    
    try:
        while True:
            # Generate a random timestamp
            random_timestamp = generate_random_timestamp()
            
            # Write the timestamp to a file
            with open(file_name, "w") as file:
                file.write(f"Random Timestamp: {random_timestamp}\n")
            
            # Upload the file to the S3 bucket
            upload_to_s3(file_name, bucket_name)
            
            # Wait for 5 seconds before generating the next timestamp
            time.sleep(5)
    except KeyboardInterrupt:
        print("\nProcess interrupted by user. Exiting...")
    finally:
        # Clean up the local file
        if os.path.exists(file_name):
            os.remove(file_name)
            print("Local file deleted.")

if __name__ == "__main__":
    main()
