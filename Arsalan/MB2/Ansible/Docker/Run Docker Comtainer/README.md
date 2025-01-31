# Generate a markdown file for the playbook

playbook_markdown = """
# Ansible Playbook: Setup Docker and Run Node.js Project

This playbook installs Docker, clones a Node.js project from GitHub, builds a Docker image, and runs the container.

## Steps:

1. Install Docker and Git
2. Clone the Node.js project from GitHub
3. Build the Docker image using the Dockerfile
4. Run the Docker container from the built image


```init
[servers]
your_target_node_ip ansible_ssh_user=your_user
```

```yaml
---
- name: Setup Docker and run Node.js project
  hosts: all
  become: true
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install required packages
      apt:
        name:
          - docker.io
          - git
        state: present

    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes

    - name: Clone the Node.js project from GitHub
      git:
        repo: "https://github.com/ItsArsalanMD/nodejs.git"
        dest: "/opt/nodejs_project"
        version: main

    - name: Build Docker image for Node.js project
      docker_image:
        name: "nodejs_image"
        source: build  # Corrected source parameter
        build:
          path: "/opt/nodejs_project"  # Directory containing Dockerfile
        state: present

    - name: Run Docker container from built image
      docker_container:
        name: nodejs_container
        image: "nodejs_image"
        state: started
        restart_policy: always
        ports:
          - "3000:3000"
