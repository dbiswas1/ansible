# Managing Secrets in Ansible using the AWS secret Manager

## Description
We will be using ansible vault to encrypt he sensitive feild of the application properties
and store the ansible vault password in AWS secret manager. 
  We wil be achieving the following:-
  
  * Ansible will store encrypt the feild in the application properties jinja template
  * while building the property file contact AWS secrets manager for vault key
  * Retrieve the key from AWS secrets manger
  * Build the property file and place the file (with decrypted value)in the target host
  
 ## Steps
 
 ### Lets encrypt a string using ansible vault
 use command  **ansible-vault encrypt_string** and copy the output
```
   ansible-vault encrypt_string --vault-password-file ~/.password 'Test123456!2'
   !vault |
             $ANSIBLE_VAULT;1.1;AES256
             34363133323661303339643130643037386134616239613063323436336263636662383533633337
             6336313932653138613465303030313039663933653663370a316235653534313230363139626332
             65383437326662356337663130613862363366623765616461663838356439313934383261366662
             3866613533643236390a646462613237346235316461346366353931336161363531373532633832
             6133
   Encryption successful
   
```

### Lets create a folder structure as mentioned below or clone the [git-repo](https://github.com/dbiswas1/ansible.git )

```
roles
    └── secrets_management # main Playbook Name
        ├── group_vars # Keep all the variable per service
        │   └── vars.yml
        ├── retrive-secrets.sh # retrive the vault password
        ├── secrets.yml # actual playbook
        └── templates # Jinja templates of all the property files
            └── app.properties.j2
```

### Create a Jinja template with above encrypted value

Already this is present in the template folder folder with following content

```
port = 7000
Host  = db_host
username = appdb
password = {{ secrets_management.db_passwd }}
```

secrets_management.db_passwd is retrived from the vars.yml file placed in group_vars

```
secrets_management:
  db_passwd: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          34363133323661303339643130643037386134616239613063323436336263636662383533633337
          6336313932653138613465303030313039663933653663370a316235653534313230363139626332
          65383437326662356337663130613862363366623765616461663838356439313934383261366662
          3866613533643236390a646462613237346235316461346366353931336161363531373532633832
          6133
```

### Create a script for passing vault password
Following script will fetch the password from AWS secrets manager and pass to Ansible vault for
decrypting the password used in property file

1) To make sure we communicate to AWS Secrets manger we should be using IAM roles 
and not the AWS access key and secrets for better security

Following is how we create a role and assign the role to instance
```
``` 

### Lets Run the playbook to create a application properties file

