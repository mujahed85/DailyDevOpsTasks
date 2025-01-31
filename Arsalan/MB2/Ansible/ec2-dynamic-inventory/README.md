
# Ansible Setup with AWS EC2 Integration

This guide will help you set up Ansible to manage EC2 instances on AWS, including configuration and playbook creation.

## Prerequisites

Before setting up Ansible with AWS EC2 integration, ensure that you have the following:

- **A Fresh Machine Setup**:
  - A Linux-based system (e.g., Ubuntu).
  - SSH access to the system.

- **AWS Access**:
  - AWS credentials (Access Key and Secret Key).
  - An EC2 instance with public IP addresses.
  - An EC2 key pair to authenticate the SSH connections.

## Installation

### Step 1: Install Ansible
To install Ansible on a fresh Ubuntu system, run the following commands:

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

### Step 2: Install AWS Dependencies for Ansible
Ansible uses a plugin to communicate with AWS EC2 instances. You need to install the AWS collection.

Run the following to install it:

```bash
ansible-galaxy collection install amazon.aws
```

### Step 3: Configure AWS Access
Make sure your AWS credentials are set up properly. You can configure AWS CLI if it's not done yet:

```bash
aws configure
```

This command will ask for your AWS Access Key, Secret Key, region, and output format. Ensure your AWS Access Key and Secret Key are correct.

### Step 4: Setup the Ansible Configuration File

Create the Ansible configuration file (`ansible.cfg`) in your project directory:

```ini
[defaults]
# Set the default private key for all SSH connections
private_key_file = ~/.ssh/mujahed.pem
```

This will ensure that your private key is used for SSH connections.

### Step 5: Setup the AWS EC2 Inventory File

Create a file called `aws_ec2.yml` for the dynamic inventory configuration.

```yaml
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
hostnames:
  - instance-id
filters:
  instance-state-name: running
keyed_groups:
  - key: tags.Group
    prefix: "group_"
  - key: instance_type
    prefix: "type_"
  - key: vpc_id
    prefix: "vpc_"
compose:
  ansible_user: ubuntu
  ansible_host: public_ip_address
  ansible_ssh_private_key_file: /home/ubuntu/.ssh/mujahed.pem
  ansible_ssh_common_args: '-o IdentitiesOnly=yes'  # Force SSH to use ONLY this key
```

Make sure to replace `/home/ubuntu/.ssh/mujahed.pem` with the correct path to your private key.

### Step 6: Write the Playbook

Create a playbook file called `playbook.yml` to ping the running EC2 instances:

```yaml
---
- name: Ping all running EC2 instances
  hosts: all
  gather_facts: no
  tasks:
    - name: Ping instances
      ansible.builtin.ping:
```

### Step 7: Running the Playbook

Finally, run your playbook to ping the EC2 instances:

```bash
ansible-playbook -i aws_ec2.yml playbook.yml
```

This command will use the `aws_ec2.yml` dynamic inventory to find all running EC2 instances and then run the `ping` task on them.

## Conclusion

Now, you have Ansible set up to manage your AWS EC2 instances. You can extend this setup by adding more tasks to manage your EC2 instances, deploy applications, or perform other administrative actions.
