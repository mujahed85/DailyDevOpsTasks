# Jenkins Pipeline with Ansible Deployment Lab Guide

This lab demonstrates how to integrate an Ansible playbook into a Jenkins Pipeline for deploying or configuring your target servers. In this example, Jenkins checks out a repository that contains your Ansible playbooks and inventory file, then runs the playbook using SSH credentials.

## Prerequisites

- **Jenkins Installation:**  
  Ensure Jenkins is installed and running. Configure your Jenkins instance to allow pipeline jobs.

- **SSH Credentials:**  
  Store your SSH private key as a credential in Jenkins. In this example, the credential ID is `nverginia`.

- **Ansible Installed:**  
  Ansible must be installed on the Jenkins host or on the agent where the pipeline is executed.

- **Inventory and Playbook:**  
  The repository should contain your Ansible playbook (`playbook.yml`) and inventory file (`inventory.ini`). In this lab, the inventory file specifies a target web server.

## Repository Contents

Your repository (in this example, hosted at [https://github.com/ItsArsalanMD/Ansible.git](https://github.com/ItsArsalanMD/Ansible.git)) should include at least the following files:

### `playbook.yml`

*Your Ansible playbook file (example content not shown here; ensure it is configured to deploy or configure as needed).*

### `inventory.ini`

```ini
[web_servers]
server1 ansible_host=3.109.184.81
```

This inventory file defines a group called `web_servers` with a single host (`server1`) that has the IP address `3.109.184.81`.

## Jenkins Pipeline Configuration

Below is the Jenkinsfile used in this lab. It includes two main stages: checking out the code and running the Ansible playbook.

### `Jenkinsfile`

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout repository containing Ansible playbooks
                git url: 'https://github.com/ItsArsalanMD/Ansible.git', branch: 'main'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: '<YOUR_PRIVATEKEY_ID>',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh '''
                        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml \
                          -u ubuntu --private-key $SSH_KEY
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Ansible playbook executed successfully!"
        }
        failure {
            echo "Ansible playbook execution failed."
        }
    }
}
```

#### Explanation:

- **Checkout Code:**  
  The pipeline checks out the repository from GitHub which contains the Ansible playbooks and inventory file.

- **Run Ansible Playbook:**  
  The pipeline stage uses the `withCredentials` block to securely inject the SSH private key into the environment variable `SSH_KEY`. Then, it executes the Ansible playbook using the `ansible-playbook` command.  
  - `-i inventory.ini` specifies the inventory file.  
  - `-u ubuntu` indicates that Ansible should connect as the `ubuntu` user.  
  - `--private-key $SSH_KEY` uses the injected private key for SSH authentication.

- **Post Actions:**  
  After the pipeline runs, a message is echoed to indicate success or failure.

## Running the Lab

1. **Set Up the Credential:**  
   In Jenkins, add your SSH private key under the ID `nverginia`.

2. **Create the Pipeline Job:**  
   - Create a new Pipeline job in Jenkins.
   - Use the provided Jenkinsfile (either directly pasted into the Pipeline script area or stored in SCM).

3. **Trigger the Pipeline:**  
   Run the pipeline manually or via SCM triggers. Monitor the console output to see the progress and results.

4. **Verify the Deployment:**  
   Once the pipeline completes, verify that your playbook has been executed successfully on the target server (`3.109.184.81`).

## Conclusion

This lab guide outlines a simple approach to integrate Ansible into your Jenkins Pipeline. By following these steps, you can automate deployments and configuration tasks with Ansible while managing your CI/CD flow in Jenkins. Feel free to extend this lab with additional stages, error handling, or integration with other tools as needed.