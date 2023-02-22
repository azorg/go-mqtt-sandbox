#!/bin/sh

DAYS="3653"

echo "Generate a client key pair"
mkdir -p client
#openssl genrsa -des3 -out client/client.key 2048
openssl genrsa -des3 -out client/client.key 2048

echo "Generate a certificate signing request (CSR) to send to the CA"
openssl req -out client/client.csr -key client/client.key -new

echo "Send the CSR to the CA, or sign it with your CA key"
openssl x509 -req -in client/client.csr -CA ca/ca.crt -CAkey ca/ca.key \
        -CAcreateserial -out client/client.crt -days $DAYS

