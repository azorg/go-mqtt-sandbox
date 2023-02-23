#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a certificate authority (CA) key pair"
mkdir -p ca
openssl genrsa -des3 -out ca/ca.key 2048

echo "Generate a certificate signing request (CSR) to send to the fake CA"
openssl req -new -key ca/ca.key -out ca/ca.csr

echo "View ca.csr:"
openssl req -noout -text -in ca/ca.csr | less

echo "Send the CSR to the fake CA, or sign it with your CA key"
openssl x509 -req -days $DAYS -in ca/ca.csr \
        -CA ca-fake/ca-fake.crt -CAkey ca-fake/ca-fake.key \
        -CAcreateserial -out ca/ca.crt #-extfile filename

echo "View ca.crt:"
openssl x509 -noout -text -in ca/ca.crt | less


