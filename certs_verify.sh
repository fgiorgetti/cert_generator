#!/bin/bash

# Simply verifies if provided CA has signed the PEM file

CA_PEM=$1
CERT_PEM=$2

openssl verify -CAfile $CA_PEM $CERT_PEM
