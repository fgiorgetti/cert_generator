#!/bin/bash

. `dirname $0`/read_var.sh
. `dirname $0`/certs_ca.sh

# Validating if user wants to create new certs and signed certs
read_var CREATE_NEW "Do you want to create signed certificates using the given CA?" true yes yes no
echo

# If user is done, exit
[[ ${CREATE_NEW,,} != 'yes' ]] && exit 0

. `dirname $0`/certs_signed.sh
