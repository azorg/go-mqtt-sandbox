#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import paho.mqtt.client as mqtt
import time

BROKER ="localhost"
PORT = 8883
CONN_FLAG = False

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


def on_disconnect(client, userdata, flags, rc):
    print("Disconnected OK")


# the callback for when a PUBLISH message is received from the server
def on_message(client, userdata, msg):
    print("TOPIC =" + msg.topic + " TEXT =" + str(msg.payload))


client = mqtt.Client("my_client")
client.on_log = on_log
client.tls_set(ca_certs="ca/ca.crt")
client.on_connect = on_connect
client.on_disconnect = on_disconnect
client.on_message = on_message

client.connect(BROKER, PORT, 60)

while not CONN_FLAG:
    time.sleep(1)
    print("waiting")
    client.loop()

time.sleep(3)

client.publish("sample/TLS", "Hello from Python!")

time.sleep(2)

client.loop()

time.sleep(2)

client.disconnect()

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
#client.loop_forever()






