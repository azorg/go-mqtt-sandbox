#!/bin/sh

DAYS="3653" # 10 years

rm -rf ca
rm -rf server
rm -rf client

NODES="-nodes"

echo "*** Generate the fake root sertificate authority's (CA) SELF SIGNED (ca.key, ca.crt)"
mkdir -p ca
openssl req -new -x509 -days $DAYS -extensions v3_ca $NODES \
        -subj "/CN=Fake root CA/O=localhost/OU=generate-CA/emailAddress=root@example.net" \
        -keyout ca/ca.key -out ca/ca.crt

chmod 400 ca/ca.key
chmod 444 ca/ca.crt

echo "*** View CA certificate (ca.crt):"
openssl x509 -in ca/ca.crt -nameopt multiline -subject -noout

echo "*** Create the server / mqtt broker's keypair (server.key)"
mkdir -p server
openssl genrsa -out server/server.key 2048

echo "*** Generate a certificate signing request (CSR) to send to the CA (server.csr)"
openssl req -new \
        -subj "/CN=An MQTT broker/O=localhost/OU=mqtt-CA/emailAddress=broker@mqtt.net" \
        -key server/server.key \
        -out server/server.csr

echo "*** 'Send' the server CSR to the CA, or sign it with your CA key (server.crt)"
openssl x509 -req -days $DAYS \
        -CAcreateserial \
        -CA ca/ca.crt -CAkey ca/ca.key \
        -in  server/server.csr \
        -out server/server.crt

echo "*** View server.crt:"
openssl x509 -in server/server.crt -nameopt multiline -subject -noout

echo "*** Generate a client key pair"
mkdir -p client
openssl genrsa -out client/client.key 2048

echo "*** Generate a certificate signing request (CSR) to send to the CA (client.csr)"
openssl req -new \
        -subj "/CN=An MQTT client/O=localhost/OU=mqtt-cert/emailAddress=client@mqtt.net" \
        -key client/client.key \
        -out client/client.csr

echo "*** 'Send' the client CSR to the CA, or sign it with your CA key (client.crt)"
openssl x509 -req -days $DAYS \
        -CAcreateserial \
        -CA ca/ca.crt -CAkey ca/ca.key \
        -in  client/client.csr \
        -out client/client.crt

echo "*** View client.crt:"
openssl x509 -in client/client.crt -nameopt multiline -subject -noout


