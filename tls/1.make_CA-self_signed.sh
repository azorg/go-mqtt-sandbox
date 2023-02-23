#!/bin/sh

DAYS="3653" # 10 years

NODES="-nodes"

echo "Generate a certificate authority (CA) certificate and key pair"
mkdir -p ca

# way #1 (as in man page)
#openssl req -new -x509 -days $DAYS -extensions v3_ca $NODES \
#        -subj "/CN=Fake root CA/O=localhost/OU=generate-CA/emailAddress=root@example.net" \
#        -keyout ca/ca.key -out ca/ca.crt

# way #2 (yet another way)
#openssl genrsa -des3 -out ca/ca.key 2048
#openssl req -new -x509 -days $DAYS \
#        -subj "/CN=Fake root CA/O=localhost/OU=generate-CA/emailAddress=root@example.net" \
#        -key ca/ca.key -out ca/ca.crt

# way #3
echo "Generate CA key pair (ca.key)"
#openssl genrsa -des3 -out ca/ca.key 2048
openssl genrsa -out ca/ca.key 2048

echo "Generate a certificate signing request (ca.csr)"
openssl req -new -sha256 \
        -subj "/CN=Fake root CA/O=localhost/OU=generate-CA/emailAddress=root@example.net" \
        -key ca/ca.key -out ca/ca.csr

echo "View ca.csr:"
openssl req -noout -text -in ca/ca.csr

echo "Create the fake CA's root SELF SIGNED certificate (ca.crt)"
openssl x509 -req -days $DAYS -sha256 \
        -in ca/ca.csr -signkey ca/ca.key -out ca/ca.crt

echo "View ca.crt:"
#openssl x509 -noout -text -in ca/ca.crt | less
openssl x509 -in ca/ca.crt -nameopt multiline -subject -noout


