#!/bin/sh

#sudo cp ca-fake/ca-fake.crt /etc/ssl/certs/ca-fake.pem
sudo cp ca/ca.crt /etc/ssl/certs/ca-fake.pem

sudo update-ca-certificates --fresh

sudo cp ca/ca.crt /etc/mosquitto/ca_certificates/

sudo cp server/server.crt /etc/mosquitto/certs/
sudo cp server/server.key /etc/mosquitto/certs/

sudo chown mosquitto:mosquitto /etc/mosquitto/certs/server.key
sudo chmod 0600                /etc/mosquitto/certs/server.key

