#!/bin/sh

DAYS="3653" # 10 years

echo "Generate the fake certificate authority's (CA) signing key"
mkdir -p ca-fake
openssl genrsa -des3 -out ca-fake/ca-fake.key 2048

echo "Generate a certificate signing request for the fake CA"
echo 
echo "Note: Give the organization a name like 'Fake Authority' and"
echo "      do not enter a common name (since your fake CA does not"
echo "      actually live on a server with a name)"
openssl req -new -sha256 -key ca-fake/ca-fake.key -out ca-fake/ca-fake.csr

echo "View ca-fake.csr:"
openssl req -noout -text -in ca-fake/ca-fake.csr | less

echo "Create the fake CA's root certificate (self signed)"
openssl x509 -req -days $DAYS -sha256 -in ca-fake/ca-fake.csr \
        -signkey ca-fake/ca-fake.key -out ca-fake/ca-fake.crt 

echo "Copy ca-fake.crt to /etc/ssl/certs/ca-fake.pem"
sudo cp ca-fake/ca-fake.crt /etc/ssl/certs/ca-fake.pem

echo "Run update-ca-certificates --fresh"
sudo update-ca-certificates --fresh

echo "View ca-fake.crt:"
openssl x509 -noout -text -in ca-fake/ca-fake.crt | less



