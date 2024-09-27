#!/bin/bash

CA_PEM=$1
CERT_PEM=$2

openssl verify -CAfile "$CA_PEM" "$CERT_PEM"
