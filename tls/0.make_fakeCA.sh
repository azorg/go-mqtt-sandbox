#!/bin/sh

DAYS="3653" # 10 years

echo "Generate the fake certificate authority's (CA) signing key (ca-fake.key)"
mkdir -p ca-fake
#openssl genrsa -des3 -out ca-fake/ca-fake.key 2048
openssl genrsa -out ca-fake/ca-fake.key 2048

echo "Generate a certificate signing request for the fake CA (ca-fake.csr)"
openssl req -new -sha256 \
        -subj "/CN=Fake root CA/O=localhost/OU=generate-CA/emailAddress=root@example.net" \
        -key ca-fake/ca-fake.key -out ca-fake/ca-fake.csr

echo "View ca-fake.csr:"
openssl req -noout -text -in ca-fake/ca-fake.csr

echo "Create the fake CA's root SELF SIGNED certificate (ca-fake.crt)"
openssl x509 -req -days $DAYS -sha256 \
        -in ca-fake/ca-fake.csr \
        -signkey ca-fake/ca-fake.key \
        -out ca-fake/ca-fake.crt 

echo "View ca-fake.crt:"
#openssl x509 -noout -text -in ca-fake/ca-fake.crt
openssl x509 -in ca-fake/ca-fake.crt -nameopt multiline -subject -noout


