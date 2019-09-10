#!/usr/bin/env bash

# Get the secrets from AWS, Make sure you have the Jq installed

secret1=$(aws secretsmanager get-secret-value --secret-id ansible/DevVaultPassword | jq -r '.SecretString' | awk -F "\"" '{print $4}')
export ENV1=${secret1}
echo ${ENV1}