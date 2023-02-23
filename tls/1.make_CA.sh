#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a certificate authority (CA) key pair (ca.key)"
mkdir -p ca
#openssl genrsa -des3 -out ca/ca.key 2048
openssl genrsa -out ca/ca.key 2048

echo "Generate a certificate signing request (CSR) to send to the fake CA (ca.csr)"
openssl req -new -new -sha256 \
        -subj "/CN=MQTT root CA/O=localhost/OU=mqtt-CA/emailAddress=root@mqtt.net" \
        -key ca/ca.key -out ca/ca.csr

echo "View ca.csr:"
openssl req -noout -text -in ca/ca.csr

echo "Send the CSR to the fake CA, or sign it with your CA key"
openssl x509 -req -days $DAYS \
        -CAcreateserial \
        -CA ca-fake/ca-fake.crt -CAkey ca-fake/ca-fake.key \
        -in ca/ca.csr \
        -out ca/ca.crt

echo "View ca.crt:"
#openssl x509 -noout -text -in ca/ca.crt
openssl x509 -in ca/ca.crt -nameopt multiline -subject -noout


