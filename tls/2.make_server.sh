#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a server key pair"
mkdir -p server
#openssl genrsa -des3 -out server/server.key 2048
openssl genrsa -out server/server.key 2048

echo "Generate a certificate signing request (CSR) to send to the CA"
echo "Note: When prompted for the CN (Common Name), please enter either"
echo "      your server (or broker) hostname or domain name."
openssl req -out server/server.csr -key server/server.key -new

echo "Send the CSR to the CA, or sign it with your CA key"
openssl x509 -req -in server/server.csr -CA ca/ca.crt -CAkey ca/ca.key \
        -CAcreateserial -out server/server.crt -days $DAYS




