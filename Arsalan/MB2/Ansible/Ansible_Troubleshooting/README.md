# Troubleshooting SSH Connection Issues in Ansible

## **Problem:**  
When running an Ansible playbook, you get the following error:

```bash
fatal: [server1]: UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Permission denied (publickey,password).",
    "unreachable": true
}
```

## **Cause:**  
This issue typically occurs when:
- SSH keys are not set up correctly.
- The user does not have permission to access the remote server.
- The `ansible_user` is incorrect.

## **Solution:**  

### **1. Verify SSH Access**  
Manually check SSH connectivity to the remote server:

```bash
ssh -i ~/.ssh/id_rsa ansible_user@server1
```

If it asks for a password or denies access, fix the SSH key setup.

### **2. Define Correct Ansible User**  
Update the inventory file (`inventory.ini`):

```ini
[servers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### **3. Test Connection with Ansible**  
Run a simple `ping` module test:

```bash
ansible -i inventory.ini servers -m ping
```

If successful, it should return:

```json
server1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### **4. Use Verbose Mode for Debugging**  
If the issue persists, use verbose mode (`-vvvv`) to get more details:

```bash
ansible -i inventory.ini servers -m ping -vvvv
```

### **5. Fix SSH Key Permissions**  
Ensure SSH keys have the correct permissions:

```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

## **Final Ansible Playbook for Testing Connection**  
Save the following as `test.yml`:

```yaml
---
- name: Test SSH Connection
  hosts: servers
  gather_facts: no
  tasks:
    - name: Ping the remote server
      ansible.builtin.ping:
```

Run the playbook:

```bash
ansible-playbook -i inventory.ini test.yml
```

## **Conclusion**  
By following these steps, you can troubleshoot and fix SSH connectivity issues in Ansible, ensuring smooth playbook execution.

