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

##### Create a IAM Role and policy and attach the instances to have access for aws secrets manager

Ref: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html

##### setup aws secret manager
create a file as secret.json with following content

```
{
  "ansible_dev_vault_passwd": "test123"
}
```

Run the following commands after we have assigned the IAM roles to the instance 

```
aws secretsmanager create-secret --name ansible/DevVaultPassword \
--description "Test Secrets" \
--secret-string file://secret.json

{
    "VersionId": "74d43e92-1302-4ae3-821f-c422c6095495",
    "Name": "ansible/DevVaultPassword",
    "ARN": "arn:aws:secretsmanager:******:********:secret:ansible/DevVaultPassword-nX1LA5"
}
```

### Lets Run the playbook to create a application properties file

```
ansible-playbook secrets.yml --vault-password-file ./retrive-secrets.sh

PLAY [127.0.0.1] ***************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************************************
ok: [127.0.0.1]

TASK [Create a directory for property file] ************************************************************************************************************************************************************************************************
changed: [127.0.0.1]

TASK [Basic Templating] ********************************************************************************************************************************************************************************************************************
changed: [127.0.0.1]

PLAY RECAP *********************************************************************************************************************************************************************************************************************************
127.0.0.1                  : ok=3    changed=2    unreachable=0    failed=0

```

### View the Application Properties file

Output of the file is the decrypted field at rest in the target host

```
cat /tmp/secrets_management/app.properties                                                                                                                                            ip-172-31-44-201: Tue Sep 10 06:20:41 2019

port = 7000
Host  = db_host
username = appdb
password = Test123456!2
```