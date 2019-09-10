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
 
 # Lets encrypt a string using ansible vault
 use command  **ansible-vault encrypt_string** and copy the output
```
   ansible-vault encrypt_string --vault-password-file ~/.password 'Test123456!2'
   !vault |
             $ANSIBLE_VAULT;1.1;AES256
             31373566396333386562396266623435643664326462626334656236343130643330653861363935
             3461616539313034663430393331323736633864386562350a393937333837643938323365636439
             30366338376663663566646564636239356338356532323935306364613230633130386434383834
             3637646265356462300a633362623266656433646436663231633961626232376163396631323965
             3964
   Encryption successful
   
```

# Lets create a folder structure as mentioned below (or clone the []git-repo )

