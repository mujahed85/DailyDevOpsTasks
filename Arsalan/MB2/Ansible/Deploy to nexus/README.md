# Deploying an Application to Nexus Using Ansible

## Prerequisites
- **Nexus Repository Manager** is already installed and running.
- **Ansible** is installed on the machine you will use for automation.
- **Nexus credentials** (username, password, etc.).
- A **project package** (JAR, WAR, or any artifact) ready to be deployed to Nexus.
- The necessary **configuration for the repository** in Nexus (like the repository URL).

## Steps to Deploy the App to Nexus using Ansible

### 1. Set up Ansible Inventory and Variables
Create an inventory file (`inventory.ini`) where you define the host machine (or your Nexus server) and Ansible variables like Nexus credentials.

#### Example `inventory.ini`:
```ini
[nexus]
nexus_host=your_nexus_host

[nexus:vars]
nexus_username=your_username
nexus_password=your_password
nexus_repo_url=http://your_nexus_host/repository/your_repo_name/
artifact_path=/path/to/your/artifact/your_app.jar
```

### 2. Create Ansible Playbook
The playbook will include tasks to authenticate with Nexus and upload the artifact.

#### Example `deploy_to_nexus.yml`:
```yaml
---
- name: Deploy app to Nexus
  hosts: nexus
  gather_facts: false
  tasks:
    - name: Upload artifact to Nexus repository
      uri:
        url: "{{ nexus_repo_url }}"
        method: POST
        user: "{{ nexus_username }}"
        password: "{{ nexus_password }}"
        headers:
          Content-Type: "multipart/form-data"
        body_format: form-multipart
        body:
          file: "{{ lookup('file', artifact_path) }}"
          repository: "your_repo_name"
          version: "1.0.0"
          groupId: "com.example"
          artifactId: "your-app"
        status_code: 201
      register: response

    - name: Print upload result
      debug:
        var: response
```

### 3. Run the Ansible Playbook
Execute the Ansible playbook to deploy the artifact to Nexus.

```bash
ansible-playbook -i inventory.ini deploy_to_nexus.yml
```

### 4. Verify Deployment
- Check the output from the playbook. If it was successful, Nexus should now contain your artifact.
- You can also log in to Nexus and manually verify that the artifact was uploaded to the specified repository.

### 5. Troubleshooting
- If you encounter issues, ensure the Nexus credentials are correct and that the repository is accessible from the Ansible machine.
- Check Nexus logs for any errors related to authentication or permissions.
