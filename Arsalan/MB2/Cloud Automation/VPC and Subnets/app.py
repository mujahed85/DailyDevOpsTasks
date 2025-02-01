import boto3

# Initialize AWS session with profile "arsalan"
session = boto3.Session(profile_name="arsalan")
ec2 = session.client('ec2', region_name='ap-south-1')  # Change region if needed

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
    public_subnet_id = create_subnet(vpc_id, '10.0.1.0/24', 'ap-south-1a', 'Public')
    private_subnet_id = create_subnet(vpc_id, '10.0.2.0/24', 'ap-south-1b', 'Private')

    igw_id = create_internet_gateway(vpc_id)
    route_table_id = create_route_table(vpc_id, igw_id)
    associate_route_table(route_table_id, public_subnet_id)

if __name__ == "__main__":
    main()
