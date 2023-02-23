#!/bin/sh

#mosquitto_sub --cafile ca/ca.crt --cert client/client.crt --key client/client.key -p 8883 \
#              -q 2 -h localhost -t "sample/TLS" -d

mosquitto_sub --cafile ca/ca.crt --cert client/client.crt --key client/client.key -p 8883 \
              -q 2 -h localhost -t "sample/TLS" --insecure 

