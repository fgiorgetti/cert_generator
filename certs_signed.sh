#!/bin/bash

# Generate certificates signed by an existing CA

. `dirname $0`/read_var.sh

if [[ -z $CA_KEY || -z $CA_PEM ]]; then
    . `dirname $0`/certs_ca.sh
fi

# Reading private key to use
echo "- Generating or using existing private key to produce CSR and signed Certificates"
read_var CERT_KEY "Enter the Certificate private key file name" true ''
read_var CERT_KEY_PASS "Enter the Certificate private key password"
if [[ -f $CERT_KEY ]]; then
    echo Certificate private key already exists, using it.
else
    echo Generating new private key certificate
    if [[ ${CERT_KEY_PASS} != "" ]]; then
        openssl genrsa -aes128 -passout "pass:${CERT_KEY_PASS}" -out $CERT_KEY 3072
    else
        openssl genrsa -out $CERT_KEY 2048
    fi
fi
echo

# Reading the CSR info
read_var CERT_CSR "Enter the CSR (certificate signing request) file name for the previous key" true ''
read_var CERT_CN  "Enter the subject common name (CN) that will be used to identify this CSR" true ''
EXTRA_DNS=""
if [[ -f $CERT_CSR ]]; then
    echo Certificate signing request already exists, using it.
else
    while true; do
        read_var DNS "Enter additional subject alternative name (or empty to ignore)" false ''
        [[ -z "${DNS}" ]] && break
        EXTRA_DNS+=", DNS:${DNS}"
    done

    echo Generating certificate signing request...
    openssl req -new -batch -subj "/CN=$CERT_CN" -addext "subjectAltName = DNS:${CERT_CN}${EXTRA_DNS}" -key $CERT_KEY -out $CERT_CSR
fi
echo

# Creating a signed ceritifcate based on CSR for the related Cert Key
valid_cert=false
while [[ $valid_cert == false ]]; do
    read_var CERT_PEM "Enter the signed certificate pem file name" true ''
    [[ -f $CERT_PEM ]] && echo "Public certificate already exists (press ENTER to try again)." || valid_cert=true
done

echo "- Generating new public certificate using $CERT_CSR and signed by $CA_PEM with $CA_KEY"
cat << EOF > cert.ext
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:TRUE
keyUsage               = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign
subjectAltName         = DNS:${CERT_CN}${EXTRA_DNS}
issuerAltName          = issuer:copy
EOF

openssl x509 -req -in $CERT_CSR -CA $CA_PEM -CAkey $CA_KEY -CAcreateserial -out $CERT_PEM -days 1825 -sha256 -extfile cert.ext
echo

echo "- Validating generated PEM ceriticate ($CERT_PEM) using CA PEM ($CA_PEM)"
openssl verify -CAfile $CA_PEM $CERT_PEM

