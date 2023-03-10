/*
 * Пример простого MQTT издателя на Golang
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
	PUB_TIMEOUT     = 5 * time.Second

	TOPIC = "sample/TCP"
	TEXT  = "Hello MQTT Go!"

	QOS = 2 // 0 - отправил забыл, 1 - минимум одно, 2 - ровно одно
)

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
	opts.SetPingTimeout(PING_TIMEOUT)

	// иницировать подключение к брокеру
	c := mqtt.NewClient(opts)
	t := c.Connect()

	// ждать подключения к брокеру (вместо t.Wait())
	if !wait_ch(t.Done(), CONNECT_TIMEOUT) {
		panic("Cnnect timeout")
	} else if t.Error() != nil {
		panic(t.Error())
	}

	// инициировать отправку сообщения брокеру
	fmt.Println("publish TOPIC='" + TOPIC + "' TEXT='" + TEXT + "'")
	t = c.Publish(TOPIC, QOS, false, TEXT)

	// ждать завершения отправки сообщения (вместо t.Wait())
	if !wait_ch(t.Done(), PUB_TIMEOUT) {
		fmt.Println("Publish timeout")
	}

	if t.Error() != nil {
		panic(t.Error())
	}

	// разорвать соединение с брокером
	c.Disconnect(250)

	// FIXME: ждать еще секунду! С хуя?!
	time.Sleep(1 * time.Second)
}

/*** end of "mqtt_tcp_pub.go" file ***/
