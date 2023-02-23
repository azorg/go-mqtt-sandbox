#!/bin/sh

DAYS="3653" # 10 years

echo "1. Generate the fake certificate authority's (CA) signing key"
mkdir -p ca
openssl genrsa -des3 -out ca/ca.key 2048

echo "2. Generate a certificate signing request for the fake CA"
echo 
echo "Note: Give the organization a name like 'Fake Authority' and"
echo "      do not enter a common name (since your fake CA does not"
echo "      actually live on a server with a name)"
openssl req -new -sha256 -key ca/ca.key -out ca/ca.csr

echo "3. Create the fake CA's root certificate (SELF SIGNED)"
openssl x509 -req  -days $DAYS -sha256 \
        -in ca/ca.csr -signkey ca/ca.key -out ca/ca.crt

echo "Copy ca.crt to /etc/ssl/certs/ca-fake.pem"
sudo cp ca/ca.crt /etc/ssl/certs/ca-fake.pem

echo "Run update-ca-certificates --fresh"
sudo update-ca-certificates --fresh

echo "View ca.crt:"
openssl x509 -noout -text -in ca/ca.crt | less

echo "4. Create the server / mqtt broker's keypair"
mkdir -p server
openssl genrsa -out server/server.key 2048

echo "5. Create a certificate signing request using the server key "
echo "   to send to the fake CA for identity verification"
echo
echo "Note: Give the organization a name like 'Localhost MQTT Broker Inc.'"
echo "      and the common name should be localhost or the exact domain you use "
echo "      to connect to the mqtt broker"
openssl req -new -sha256 -key server/server.key -out server/server.csr

echo "6. Now acting as the fake CA, you receive the server's request"
echo "   for your signature. You have verified the server is who it says"
echo "   it is (an MQTT broker operating on localhost), so create a new"
echo "   certificate & sign it with all the power of your fake authority"
openssl x509 -req -days $DAYS -in server/server.csr \
        -CA ca/ca.crt -CAkey ca/ca.key \
        -CAcreateserial -out server/server.crt

echo "View server.crt:"
openssl x509 -noout -text -in server/server.crt | less

echo "7. Generate a client key pair"
mkdir -p client
#openssl genrsa -des3 -out client/client.key 2048
openssl genrsa -out client/client.key 2048

echo "8. Generate a certificate signing request (CSR) to send to the CA"
openssl req -new -key client/client.key -out client/client.csr

echo "9. Send the client CSR to the CA, or sign it with your CA key"
openssl x509 -req -days $DAYS -in client/client.csr \
        -CA ca/ca.crt -CAkey ca/ca.key \
        -CAcreateserial -out client/client.crt

echo "View client.crt:"
openssl x509 -noout -text -in client/client.crt | less


