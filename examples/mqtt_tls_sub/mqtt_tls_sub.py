#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import paho.mqtt.client as mqtt
import time, ssl

BROKER ="localhost"
PORT = 8883
CONN_FLAG = False
TOPIC = "sample/TLS"

# the callback for when the client receives a CONNACK response from the server
def on_connect(client, userdata, flags, rc):
    global CONN_FLAG
    CONN_FLAG = True # FIXME: bad practics
    print("Connected =", CONN_FLAG, "result code =" + str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("$SYS/#")

def on_log(client, userdata, level, buf):
    print("Log: " + buf)

def on_disconnect(client, userdata, flags, rc=None):
    print("Disconnected OK")

# the callback for when a PUBLISH message is received from the server
def on_message(client, userdata, msg):
    print("TOPIC=" + msg.topic + \
          " TEXT=" + str(msg.payload.decode("utf-8")) +
          " QoS=" + str(msg.qos))

client = mqtt.Client("mqtt_client")

#client.on_log = on_log
client.on_connect = on_connect
client.on_disconnect = on_disconnect
client.on_message = on_message

client.tls_set(ca_certs="ca/ca.crt", tls_version=ssl.PROTOCOL_TLSv1_2)
client.tls_insecure_set(True) # FIXME

client.connect(BROKER, PORT, 60)

client.loop()

while not CONN_FLAG:
    time.sleep(1)
    print("waiting")
    client.loop()

print("Subscribing to topic", TOPIC)
client.subscribe(TOPIC)

#client.loop()

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
client.loop_forever()

client.disconnect()

