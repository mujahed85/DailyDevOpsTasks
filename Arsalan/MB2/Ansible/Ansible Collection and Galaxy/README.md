# Ansible Collections & Galaxy Labs

## Ansible Collections
Ansible collections are a distribution format for Ansible content, including roles, modules, and plugins. They allow users to package, share, and reuse automation code efficiently.

### Installing a Collection
To install an Ansible collection from Ansible Galaxy, use the following command:

```bash
ansible-galaxy collection install <namespace>.<collection_name>
```

Example:

```bash
ansible-galaxy collection install ansible.builtin
```

### Searching for Collections
To search for a specific collection on Ansible Galaxy, use:

```bash
ansible-galaxy collection search <collection_name>
```

### Listing Installed Collections
To view the installed collections on your system:

```bash
ansible-galaxy collection list
```

## Ansible Galaxy Labs
Ansible Galaxy Labs is a section within Ansible Galaxy that hosts experimental content, including community-contributed roles and collections.

### Browsing Galaxy Labs
Visit the [Ansible Galaxy website](https://galaxy.ansible.com/) to explore collections and roles.

### Contributing to Galaxy Labs
1. Create an Ansible role or collection.
2. Publish it to Galaxy using:

```bash
ansible-galaxy role publish <tar_file>
```

or for collections:

```bash
ansible-galaxy collection publish <tar_file>
```

3. Share the content with the Ansible community.

## Useful Links
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Ansible Galaxy Collections](https://galaxy.ansible.com/search?type=collection)
