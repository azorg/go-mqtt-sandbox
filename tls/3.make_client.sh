#!/bin/sh

DAYS="3653" # 10 years

echo "Generate a client key pair (client.key)"
mkdir -p client
#openssl genrsa -des3 -out client/client.key 2048
openssl genrsa -out client/client.key 2048

echo "Generate a certificate signing request (CSR) to send to the CA (client.csr)"
openssl req -new -sha256 \
        -subj "/CN=An MQTT client/O=localhost/OU=mqtt-cert/emailAddress=client@mqtt.net" \
        -key client/client.key -out client/client.csr

echo "View client.csr:"
openssl req -noout -text -in client/client.csr

echo "Send the CSR to the CA, or sign it with your CA key (make client.crt)"
openssl x509 -req -days $DAYS \
        -CAcreateserial \
        -CA ca/ca.crt -CAkey ca/ca.key \
        -in client/client.csr \
        -out client/client.crt

echo "View client.crt:"
#openssl x509 -noout -text -in client/client.crt
openssl x509 -in client/client.crt -nameopt multiline -subject -noout


