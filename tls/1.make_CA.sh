#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a certificate authority (CA) certificate and key pair"
mkdir -p ca
openssl req -new -x509 -days $DAYS -extensions v3_ca -keyout ca/ca.key -out ca/ca.crt



