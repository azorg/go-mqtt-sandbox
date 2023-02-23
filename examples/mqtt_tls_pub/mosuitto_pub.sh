#!/bin/sh

#mosquitto_pub --cafile ca/ca.crt --cert client/client.crt --key client/client.key -p 8883 \
#              -q 2 -h localhost -d -i CONSOLE \
#              -t "sample/TLS" -m "Hello from mosquitto_pub!"

mosquitto_pub --cafile ca/ca.crt --cert client/client.crt --key client/client.key -p 8883 \
              -q 2 -h localhost --insecure -d -i CONSOLE \
              -t "sample/TLS" -m "Hello from mosquitto_pub!"

