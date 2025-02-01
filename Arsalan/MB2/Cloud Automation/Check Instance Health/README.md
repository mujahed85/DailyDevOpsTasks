# **EC2 Health Check Using Boto3**

## **Prerequisites**
✔ Ensure AWS CLI is installed and configured (`aws configure`).  
✔ Install Boto3 (`pip install boto3`).  
✔ Make sure your IAM role has permissions:

- `ec2:DescribeInstanceStatus`
- `ec2:DescribeInstances`

---

## **Python Script to Check EC2 Instance Health**
Create a Python file (`ec2_health_check.py`) with the following content:

```python
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
```

---

## **How It Works**
✅ Fetches all EC2 instance statuses.  
✅ Displays instance **State** (running, stopped, terminated, etc.).  
✅ Shows **System Status** (ok, impaired, initializing, etc.).  
✅ Shows **Instance Status** (ok, impaired, initializing, etc.).  

---

## **Run the Script**
Execute the script using:

```bash
python ec2_health_check.py
```

---

## **Expected Output**
```
EC2 Instance Health Status:

Instance ID: i-0abcdef1234567890
  - State: running
  - System Status: ok
  - Instance Status: ok
----------------------------------------
Instance ID: i-0xyz987654321abcd
  - State: stopped
  - System Status: impaired
  - Instance Status: initializing
----------------------------------------
```

---

## **Next Steps**
🔹 Automate this check using **AWS Lambda + CloudWatch Events**.  
🔹 Send alerts to **Slack, Email, or SNS** if an instance is unhealthy.  

Would you like to extend this script to **restart unhealthy instances automatically**? 🚀
