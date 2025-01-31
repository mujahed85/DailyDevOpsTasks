# Deploy Node.js Application on Ubuntu using Ansible

## Prerequisites
- An Ubuntu server with SSH access
- Ansible installed on your local machine
- A public repository: `https://github.com/ItsArsalanMD/nodejs.git`
- Node.js and npm

## Steps

### 1️⃣ Create an Inventory File (`inventory.ini`)
Create an inventory file that includes your server details:

```ini
[servers]
your_server_ip ansible_user=your_user ansible_ssh_private_key_file=your_ssh_key.pem
```

### 2️⃣ Create an Ansible Playbook (`deploy_nodejs.yml`)
This playbook installs dependencies, clones the repo, installs packages, and runs the app.

```yaml
- name: Deploy Node.js App
  hosts: servers
  become: yes
  tasks:

    - name: Install required dependencies
      apt:
        name:
          - nodejs
          - npm
          - git
        state: present
        update_cache: yes

    - name: Clone the Node.js repository
      git:
        repo: "https://github.com/ItsArsalanMD/nodejs.git"
        dest: "/home/{{ ansible_user }}/nodejs_app"
        version: main
        force: yes

    - name: Install Node.js dependencies
      npm:
        path: "/home/{{ ansible_user }}/nodejs_app"
        state: present

    - name: Start the Node.js application
      command: "node src/index.js"
      args:
        chdir: "/home/{{ ansible_user }}/nodejs_app"
      async: 1000
      poll: 0
      register: app_status

    - name: Display application status
      debug:
        msg: "Node.js app is running in the background"
```

### 3️⃣ Run the Ansible Playbook
Execute the following command:

```bash
ansible-playbook -i inventory.ini deploy_nodejs.yml
```

## 🎯 Access the Application
To see the result, visit `http://<your-server-node-ip>:3000`

