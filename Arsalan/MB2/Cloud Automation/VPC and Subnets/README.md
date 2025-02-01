# **Lab: Automate Creating a VPC and Subnets with Boto3**

## **Objective**  
By the end of this lab, you will be able to:  
✅ Create a VPC using Boto3  
✅ Create public and private subnets  
✅ Associate an internet gateway  
✅ Attach a route table for the public subnet  

---

## **Prerequisites**
✔ AWS CLI installed and configured with appropriate IAM permissions  
✔ Python installed (`pip install boto3`)  
✔ Basic understanding of AWS networking  

---

## **Step 1: Install Required Dependencies**  
Run the following command in your terminal if Boto3 is not installed:  

```bash
pip install boto3
```

---

## **Step 2: Python Script to Create VPC and Subnets**  
Create a Python script (`create_vpc.py`) with the following content:

```python
import boto3

# Initialize AWS session
ec2 = boto3.client('ec2', region_name='us-east-1')  # Change region if needed

def create_vpc():
    response = ec2.create_vpc(CidrBlock='10.0.0.0/16')
    vpc_id = response['Vpc']['VpcId']
    print(f"VPC Created: {vpc_id}")

    # Tagging the VPC
    ec2.create_tags(Resources=[vpc_id], Tags=[{"Key": "Name", "Value": "MyVPC"}])
    
    return vpc_id

def create_subnet(vpc_id, cidr_block, availability_zone, subnet_type):
    response = ec2.create_subnet(
        VpcId=vpc_id,
        CidrBlock=cidr_block,
        AvailabilityZone=availability_zone
    )
    subnet_id = response['Subnet']['SubnetId']
    print(f"{subnet_type} Subnet Created: {subnet_id}")

    # Tagging the subnet
    ec2.create_tags(Resources=[subnet_id], Tags=[{"Key": "Name", "Value": f"My{subnet_type}Subnet"}])

    return subnet_id

def create_internet_gateway(vpc_id):
    response = ec2.create_internet_gateway()
    igw_id = response['InternetGateway']['InternetGatewayId']
    print(f"Internet Gateway Created: {igw_id}")

    # Attach IGW to VPC
    ec2.attach_internet_gateway(InternetGatewayId=igw_id, VpcId=vpc_id)

    return igw_id

def create_route_table(vpc_id, igw_id):
    response = ec2.create_route_table(VpcId=vpc_id)
    route_table_id = response['RouteTable']['RouteTableId']
    print(f"Route Table Created: {route_table_id}")

    # Create route to IGW
    ec2.create_route(RouteTableId=route_table_id, DestinationCidrBlock="0.0.0.0/0", GatewayId=igw_id)

    return route_table_id

def associate_route_table(route_table_id, subnet_id):
    ec2.associate_route_table(RouteTableId=route_table_id, SubnetId=subnet_id)
    print(f"Route Table {route_table_id} associated with Subnet {subnet_id}")

def main():
    vpc_id = create_vpc()
    public_subnet_id = create_subnet(vpc_id, '10.0.1.0/24', 'us-east-1a', 'Public')
    private_subnet_id = create_subnet(vpc_id, '10.0.2.0/24', 'us-east-1b', 'Private')

    igw_id = create_internet_gateway(vpc_id)
    route_table_id = create_route_table(vpc_id, igw_id)
    associate_route_table(route_table_id, public_subnet_id)

if __name__ == "__main__":
    main()
```

---

## **Step 3: Run the Script**  
Execute the script using:  

```bash
python create_vpc.py
```

---

## **Expected Output**  
```
VPC Created: vpc-0abcdef1234567890
Public Subnet Created: subnet-0abcdef1234567890
Private Subnet Created: subnet-0abcdef1234567891
Internet Gateway Created: igw-0abcdef1234567890
Route Table Created: rtb-0abcdef1234567890
Route Table rtb-0abcdef1234567890 associated with Subnet subnet-0abcdef1234567890
```

---

## **Cleanup (Optional)**  
To delete the resources, use:  

```python
ec2.delete_vpc(VpcId='vpc-xxxxxxxxxxxxxxxxx')
```

---

### 🎯 **What You Learned**  
✅ How to create a VPC with Boto3  
✅ How to add public and private subnets  
✅ How to associate an Internet Gateway  
✅ How to set up a route table  

Would you like to extend this with NAT Gateway, security groups, or anything else? 🚀
