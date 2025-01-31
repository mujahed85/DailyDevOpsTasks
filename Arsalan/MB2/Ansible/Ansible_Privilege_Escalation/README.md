# Privilege Escalation in Ansible

# Privilege Escalation

## Overview

Privilege escalation is a security vulnerability that allows an attacker to gain higher access rights or privileges than they are authorized to have. It typically involves exploiting weaknesses in a system, application, or service to obtain unauthorized access to sensitive resources or perform actions that would normally be restricted.

There are two main types of privilege escalation:

## Types of Privilege Escalation

### 1. **Vertical Privilege Escalation**
Vertical privilege escalation occurs when a user or attacker elevates their privileges from a lower level to a higher level. For example, a normal user account gaining administrative or root privileges.

### 2. **Horizontal Privilege Escalation**
Horizontal privilege escalation involves gaining access to resources or actions that belong to other users at the same privilege level. For example, an attacker might access another user's data or settings without permission.

## Common Methods of Privilege Escalation

Privilege escalation can be achieved through various techniques, including:

- **Exploiting system vulnerabilities**: Attackers may exploit bugs or flaws in the operating system or software.
- **Weak or misconfigured access control**: Improperly set permissions on files, services, or user accounts.
- **Social engineering**: Tricking users or administrators into revealing credentials or executing malicious code.

## Risks and Impact

Privilege escalation poses several risks to systems, including:

- **Data Theft**: Attackers may access sensitive data they shouldn’t be able to see.
- **System Manipulation**: Unauthorized users may change configurations or system settings.
- **Malicious Activity**: Attackers can use elevated privileges to compromise the integrity of the system or network.

## Prevention

To prevent privilege escalation, it’s important to follow security best practices, including:

- **Principle of Least Privilege (PoLP)**: Users and processes should only be given the minimum privileges necessary to perform their tasks.
- **Regular patching and updates**: Keeping systems updated to fix known vulnerabilities.
- **Proper access controls**: Implementing strong authentication, authorization mechanisms, and role-based access control (RBAC).
- **Audit and monitor activity**: Regularly check logs and monitor unusual access patterns.

## Conclusion

Privilege escalation is a serious security threat that can have far-reaching consequences. It is important to recognize the types of privilege escalation and implement strong security measures to mitigate the risk.


## **Lab Setup**
We will set up an Ansible control node and a target node where we will execute privileged tasks using `become`.

### **1. Setup Environment**
- **Control Node:** Your Ansible machine
- **Target Node:** A remote Linux machine (Ubuntu/Debian/CentOS)


### **2. Configure Ansible Inventory**
Create an inventory file (`hosts.ini`):
```ini
[target]
target-node ansible_host=192.168.1.100 ansible_user=user ansible_become=True ansible_become_method=sudo
```

### **3. Create a Playbook with Privilege Escalation**
Create `privilege_escalation.yml`:
```yaml
---
- name: Privilege Escalation in Ansible
  hosts: target
  become: true
  tasks:
    - name: Update Package List
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Install Apache (Debian)
      apt:
        name: apache2
        state: present
      when: ansible_os_family == "Debian"

    - name: Install Apache (RHEL-based)
      yum:
        name: httpd
        state: present
      when: ansible_os_family == "RedHat"

    - name: Enable and Start Apache Service
      service:
        name: "{{ 'apache2' if ansible_os_family == 'Debian' else 'httpd' }}"
        state: started
        enabled: true
```

### **4. Execute the Playbook**
Run the playbook with:
```sh
ansible-playbook -i hosts.ini privilege_escalation.yml --ask-become-pass
```
You will be prompted for the sudo password.

---

## **Key Takeaways**
1. `become: true` enables privilege escalation.
2. `ansible_become=True` in the inventory file allows automatic elevation.
3. `ansible_become_method=sudo` specifies using `sudo` for privilege escalation.
4. The `--ask-become-pass` flag prompts for the sudo password during execution.

This setup ensures that Ansible can perform administrative tasks securely on remote machines. 🚀
