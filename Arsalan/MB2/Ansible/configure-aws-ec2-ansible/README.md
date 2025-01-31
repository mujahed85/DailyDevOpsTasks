# AWS EC2 Provisioning with Ansible

Automates the deployment of an Ubuntu EC2 instance and configures Nginx with a sample webpage.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Customization](#customization)
- [FAQ](#faq)
- [License](#license)

## Prerequisites

- AWS account with IAM credentials
- Ansible installed on control node
- Existing AWS EC2:
  - SSH key pair
  - Security group with rules:
    - SSH (22) from your IP
    - HTTP (80) for web access
- Python packages: `boto3`, `botocore`

## Installation

1. Install required collections:
```bash
ansible-galaxy collection install amazon.aws
```

2. Configure AWS credentials:
```bash
aws configure
# Provide your AWS Access Key ID, Secret Access Key, and default region
```

## Usage

1. Edit the playbook variables in `ec2-provision.yml`:
```yaml
---
- name: Provision and Configure EC2 Instance
  hosts: localhost
  connection: local
  gather_facts: false
  vars:
    key_name: "your-existing-key-name"        # Existing SSH key pair name
    security_groups: ["your-existing-sg"]     # Existing security group name
    instance_type: "t2.micro"
    ami_id: "ami-0c55b159cbfafe1f0"           # Amazon Linux 2 (us-east-1)
    region: "us-east-1"
    ssh_user: "ec2-user"                      # SSH user for your AMI
    ssh_key_path: "/path/to/existing-key.pem" # Path to existing private key

  tasks:
    - name: Launch EC2 Instance
      community.aws.ec2_instance:
        key_name: "{{ key_name }}"
        instance_type: "{{ instance_type }}"
        image_id: "{{ ami_id }}"
        region: "{{ region }}"
        security_groups: "{{ security_groups }}"
        wait: yes
        tags:
          Name: "Ansible-Provisioned"
      register: ec2_instance

    - name: Wait for SSH to Start
      ansible.builtin.wait_for:
        host: "{{ ec2_instance.instances[0].public_ip_address }}"
        port: 22
        timeout: 300

    - name: Add Instance to Inventory
      ansible.builtin.add_host:
        name: "{{ ec2_instance.instances[0].public_ip_address }}"
        groups: "configured_instances"
        ansible_user: "{{ ssh_user }}"
        ansible_ssh_private_key_file: "{{ ssh_key_path }}"

- name: Configure Application
  hosts: configured_instances
  become: yes
  tasks:
    - name: Update Package Cache
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_os_family == 'Debian'

    - name: Install Nginx
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: yes
      when: ansible_os_family == 'Debian'

    - name: Start and Enable Nginx
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes

    - name: Deploy Sample Index Page
      ansible.builtin.copy:
        content: "Hello from Ansible-provisioned Ubuntu instance!"
        dest: /var/www/html/index.nginx-debian.html
      notify:
        - Reload Nginx

  handlers:
    - name: Reload Nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
```

2. Execute the playbook:
```bash
ansible-playbook ec2-provision.yml
```

3. Verify deployment:
```bash
# Get the public IP from AWS console or playbook output
curl http://<PUBLIC_IP>/
# Should return "Hello from Ansible-provisioned Ubuntu instance"
```

## File Structure
```
.
├── ec2-provision.yml    # Main Ansible playbook
├── README.md            # Documentation
└── your-key.pem         # SSH private key (DO NOT COMMIT TO VCS)
```

## Customization

### Instance Configuration
```yaml
instance_type: "t3.small"    # Change instance type
ami_id: "ami-12345678"       # Use different AMI
region: "us-west-2"          # Different AWS region
```

### Web Content
Modify the `content` parameter in the playbook:
```yaml
- name: Deploy Sample Index Page
  ansible.builtin.copy:
    content: "Your custom content here"
    dest: /var/www/html/index.nginx-debian.html
```

### Security
- Restrict SSH access to specific IP ranges
- Use different security group with minimal required ports
- Rotate SSH keys regularly

## FAQ

### How do I find the correct AMI ID for my region?
```bash
aws ec2 describe-images echo   --owners amazon echo   --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" echo   --query 'sort_by(Images, &CreationDate)[-1].ImageId'
```

### Getting permission denied errors?
- Ensure SSH key has proper permissions:
  ```bash
  chmod 600 your-key.pem
  ```
- Verify IAM user has EC2 full access permissions

### Connection timeout during SSH wait?
- Check security group inbound rules
- Verify instance is in a public subnet
- Ensure correct SSH user (ubuntu for Ubuntu AMIs)

## License
MIT License. See [LICENSE](LICENSE) for details.

---

> **Important**: Always terminate unused instances to avoid charges:
> ```bash
> aws ec2 terminate-instances --instance-ids <YOUR_INSTANCE_ID>
> ```
> Replace <YOUR_INSTANCE_ID> with your actual instance ID from AWS Console
