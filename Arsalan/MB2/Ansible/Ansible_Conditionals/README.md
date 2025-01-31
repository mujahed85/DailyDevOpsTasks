# Ansible Conditionals Lab

## **Prerequisites**
- Install Ansible on your control node.
- Have a managed node (Ubuntu, CentOS, or any Linux server).
- SSH access is set up for Ansible.

---

## **Step 1: Create an Inventory File**
Create an inventory file `hosts.ini` with the following content:

```ini
[servers]
node1 ansible_host=<YOUR_MANAGED_NODE_IP> ansible_user=<YOUR_USER> ansible_ssh_private_key_file=<YOUR_SSH_KEY>
```

Replace `<YOUR_MANAGED_NODE_IP>`, `<YOUR_USER>`, and `<YOUR_SSH_KEY>` with your actual values.

---

## **Step 2: Create an Ansible Playbook with Conditionals**
Create a file `conditional_playbook.yml` and add the following playbook:

```yaml
---
- name: Ansible Conditionals Lab
  hosts: servers
  gather_facts: yes
  tasks:

    - name: Check if a file exists
      stat:
        path: /tmp/testfile.txt
      register: file_stat

    - name: Create the file only if it doesn't exist
      file:
        path: /tmp/testfile.txt
        state: touch
      when: not file_stat.stat.exists

    - name: Install Nginx only on Ubuntu
      apt:
        name: nginx
        state: present
      when: ansible_facts['os_family'] == "Debian"

    - name: Install httpd only on CentOS
      yum:
        name: httpd
        state: present
      when: ansible_facts['os_family'] == "RedHat"

    - name: Set a variable based on a condition
      set_fact:
        package_name: "nginx"
      when: ansible_facts['os_family'] == "Debian"

    - name: Set a variable based on a different condition
      set_fact:
        package_name: "httpd"
      when: ansible_facts['os_family'] == "RedHat"

    - name: Print the selected package name
      debug:
        msg: "The package to be installed is {{ package_name }}"

    - name: Example of `failed_when`
      shell: "cat /tmp/testfile.txt"
      register: file_output
      failed_when: "'error' in file_output.stdout"

    - name: Example of `changed_when`
      shell: "echo 'Hello' >> /tmp/testfile.txt"
      register: append_output
      changed_when: "'Hello' in append_output.stdout"
```

---

## **Step 3: Run the Playbook**
Execute the playbook using the following command:

```sh
ansible-playbook -i hosts.ini conditional_playbook.yml
```

---

## **Expected Results**
- If `/tmp/testfile.txt` does not exist, it will be created.
- Nginx will be installed if the system is Ubuntu/Debian.
- HTTPD (Apache) will be installed if the system is CentOS/RedHat.
- The correct package name will be set and displayed.
- If the `/tmp/testfile.txt` file contains the word `error`, the task will fail.
- The `changed_when` condition will determine whether the `echo` command resulted in a change.

---

This lab provides a practical hands-on approach to understanding Ansible conditionals with `when`, `failed_when`, and `changed_when`.
