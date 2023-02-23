#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a certificate authority (CA) certificate and key pair"
mkdir -p ca

# way #1 (as in man page - bad way)
#openssl req -new -x509 -days $DAYS -extensions v3_ca -keyout ca/ca.key -out ca/ca.crt

# way #2 (yet another bad way)
#openssl genrsa -des3 -out ca/ca.key 2048
#openssl req -new -x509 -days $DAYS -key ca/ca.key -out ca/ca.crt

# way #3
echo "Generate CA key pair"
openssl genrsa -des3 -out ca/ca.key 2048

echo "Generate a certificate signing request"
openssl req -new -sha256 -key ca/ca.key -out ca/ca.csr

echo "View ca.csr:"
openssl req -noout -text -in ca/ca.csr | less

echo "Create the fake CA's root certificate (SELF SIGNED)"
openssl x509 -req -days $DAYS -sha256 -in ca/ca.csr \
        -signkey ca/ca.key -out ca/ca.crt 

echo "Copy ca.crt to /etc/ssl/certs/ca-fake.pem"
sudo cp ca/ca.crt /etc/ssl/certs/ca-fake.pem

echo "Run update-ca-certificates --fresh"
sudo update-ca-certificates --fresh

echo "View ca.crt:"
openssl x509 -noout -text -in ca/ca.crt | less


