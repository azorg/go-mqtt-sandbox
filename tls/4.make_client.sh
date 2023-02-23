#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a client key pair"
mkdir -p client
#openssl genrsa -des3 -out client/client.key 2048
openssl genrsa -out client/client.key 2048

echo "Generate a certificate signing request (CSR) to send to the CA"
openssl req -new -key client/client.key -out client/client.csr

echo "View client.csr:"
openssl req -noout -text -in client/client.csr | less

echo "Send the CSR to the CA, or sign it with your CA key"
openssl x509 -req -days $DAYS -in client/client.csr \
        -CA ca/ca.crt -CAkey ca/ca.key \
        -CAcreateserial -out client/client.crt

echo "View client.crt:"
openssl x509 -noout -text -in client/client.crt | less


