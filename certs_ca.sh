#!/bin/bash

. `dirname $0`/read_var.sh

# Create or use existing CA KEY
echo "- First we need to create a CA key file - The private key for your Certificate Authority"
read_var CA_KEY 'Enter CA key file name' true 'ca.key'
if [[ -f $CA_KEY ]]; then
    echo CA key file already exists, using it.
else
    echo Generating CA key file...
    openssl genrsa -out $CA_KEY 2048
fi
echo

# Create or use existing CA PEM file
echo "- Next we need a public X509 certificate from your CA key file"
read_var CA_PEM 'Enter CA pem file name' true 'ca.pem'
if [[ -f $CA_PEM ]]; then
    echo CA pem file already exists, using it.
else
    echo Generating CA pem file...
    openssl req -x509 -new -batch -nodes -key $CA_KEY -sha256 -days 1825 -out $CA_PEM
fi
echo

