## Updated Ansible Playbook for Docker CI/CD Pipeline

### **Overview**
This Ansible playbook clones a GitHub repository, builds a Docker image, pushes it to Docker Hub, and runs a container on a remote EC2 instance.

---

### **Updated Playbook**
```yaml
---
- name: Clone repo, build, push, and run Docker container on remote EC2 instance
  hosts: docker_host
  become: true
  vars:
    github_repo: "https://github.com/ItsArsalanMD/nodejs.git"  # Change to your repo
    clone_path: "/home/ubuntu/nodejs"  # Where repo will be cloned
    image_name: arsalan94/nodejs
    image_tag: latest
    container_name: nodejs
    dockerhub_username: "docker-username"
    dockerhub_password: "docker-password"  # Use Ansible Vault instead for security!
  tasks:

    - name: Install Git (if not installed)
      package:
        name: git
        state: present

    - name: Clone GitHub repository
      git:
        repo: "{{ github_repo }}"
        dest: "{{ clone_path }}"
        version: main  # Change branch if necessary
        force: yes  # Overwrites existing content

    - name: Log in to Docker Hub
      docker_login:
        username: "{{ dockerhub_username }}"
        password: "{{ dockerhub_password }}"

    - name: Build Docker image from cloned repository
      docker_image:
        source: build
        build:
          path: "{{ clone_path }}"
        name: "{{ image_name }}"
        tag: "{{ image_tag }}"
        push: no
      register: build_result

    - name: Tag the image
      command: docker tag {{ image_name }}:{{ image_tag }} {{ dockerhub_username }}/{{ image_name }}:{{ image_tag }}
      when: build_result.changed

    - name: Push Docker image to Docker Hub
      command: docker push {{ dockerhub_username }}/{{ image_name }}:{{ image_tag }}
      when: build_result.changed

    - name: Stop existing container (if any)
      docker_container:
        name: "{{ container_name }}"
        state: stopped
        force_kill: true
      ignore_errors: yes

    - name: Remove existing container (if any)
      docker_container:
        name: "{{ container_name }}"
        state: absent
      ignore_errors: yes

    - name: Run the container from the new image
      docker_container:
        name: "{{ container_name }}"
        image: "{{ dockerhub_username }}/{{ image_name }}:{{ image_tag }}"
        state: started
        restart_policy: always
        ports:
          - "3000:3000"
```

---

### **Jenkinsfile for CI/CD Pipeline**
```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                // Check out code from GitHub
                checkout scm
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'jenkins',
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
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
```

---

### **Changes & Fixes**
- **Clones GitHub repository** before building Docker image.
- **Fixed `docker_image` push issue:** Now using `command: docker push` instead.
- **Ensured correct image tagging** before pushing.
- **Stops and removes existing container before redeployment.**
- **Added Jenkinsfile for CI/CD automation**

### **Execution Instructions**
1. **Run the playbook:**
   ```bash
   ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml -u ubuntu --private-key $SSH_KEY
   ```
2. **Verify the image on Docker Hub** by checking `https://hub.docker.com/`.
3. **Check running containers on EC2:**
   ```bash
   docker ps
   ```

This updated playbook should now work without issues! 🚀

