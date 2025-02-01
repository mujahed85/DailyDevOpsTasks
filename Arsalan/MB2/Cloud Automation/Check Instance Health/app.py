import boto3

# Initialize AWS session with a specific profile (change profile if needed)
session = boto3.Session(profile_name="arsalan")
ec2_client = session.client('ec2', region_name='us-east-1')

def check_ec2_health():
    # Get the status of all running instances
    response = ec2_client.describe_instance_status(IncludeAllInstances=True)

    print("\nEC2 Instance Health Status:\n")
    for instance in response['InstanceStatuses']:
        instance_id = instance['InstanceId']
        state = instance['InstanceState']['Name']
        system_status = instance['SystemStatus']['Status']
        instance_status = instance['InstanceStatus']['Status']

        print(f"Instance ID: {instance_id}")
        print(f"  - State: {state}")
        print(f"  - System Status: {system_status}")
        print(f"  - Instance Status: {instance_status}")
        print("-" * 40)

if __name__ == "__main__":
    check_ec2_health()
