/*
 * Пример подписчика MQTT издателя на Golang
 * File: "mqtt_tcp_pub.go"
 */

package main

import (
	"fmt"
	"log"
	"os"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

const (
	URI = "tcp://localhost:1883"
	ID  = "sample_tcp"

	DEBUG = false

	KEEP_ALIVE      = 1 * time.Second
	PING_TIMEOUT    = 2 * time.Second
	CONNECT_TIMEOUT = 5 * time.Second
	SUB_TIMEOUT     = 5 * time.Second

	TOPIC = "sample/TCP"
	TEXT  = "Hello MQTT Go!"

	QOS = 2 // 0 - отправил забыл, 1 - минимум одно, 2 - ровно одно
)

// функция хендлер подписчика
var mqtt_handler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	fmt.Println("receive TOPIC='" + msg.Topic() + "' TEXT='" + string(msg.Payload()) + "'")
}

// функция ожидания канала с таймаутом
func wait_ch(ch <-chan struct{}, timeout time.Duration) bool {
	select {
	case <-ch:
		return true
	case <-time.After(timeout):
		return false
	}
}

func main() {
	if DEBUG {
		mqtt.ERROR = log.New(os.Stdout, "ERR:", 0)
		mqtt.CRITICAL = log.New(os.Stdout, "CRIT:", 0)
		mqtt.WARN = log.New(os.Stdout, "WARN:", 0)
		mqtt.DEBUG = log.New(os.Stdout, "DBG:", 0)
	}

	// задать опции подключения к MQTT брокеру
	opts := mqtt.NewClientOptions().AddBroker(URI).SetClientID(ID)
	opts.SetKeepAlive(KEEP_ALIVE)
	opts.SetDefaultPublishHandler(mqtt_handler)
	opts.SetPingTimeout(PING_TIMEOUT)

	// иницировать подключение к брокеру
	c := mqtt.NewClient(opts)
	t := c.Connect()

	// ждать подключения к брокеру (вместо t.Wait())
	if !wait_ch(t.Done(), CONNECT_TIMEOUT) {
		panic("Connect timeout")
	} else if t.Error() != nil {
		panic(t.Error())
	}

	// запросить подписку у брокера на заданную тему
	t = c.Subscribe(TOPIC, QOS, nil)

	// ждать подтверждения/завершения подписки (вместо t.Wait())
	if !wait_ch(t.Done(), SUB_TIMEOUT) {
		fmt.Println("Subscribe timeout")
		os.Exit(1)
	} else if t.Error() != nil {
		panic(t.Error())
	}

	fmt.Println("Press Ctrl+C or Q+ENTER to exit")
	for {
		var str string
		fmt.Scanf("%s", &str)
		if str == "q" || str == "Q" {
			break
		}
	}

	// отказаться от подписки
	t = c.Unsubscribe(TOPIC)

	// ждать подтверждения/завершения отказа от подписки (вместо t.Wait())
	if !wait_ch(t.Done(), SUB_TIMEOUT) {
		fmt.Println("Unsubscribe timeout")
		os.Exit(1)
	} else if t.Error() != nil {
		panic(t.Error())
	}

	c.Disconnect(250)
}

/*** end of "mqtt_tcp_sub.go" file ***/
