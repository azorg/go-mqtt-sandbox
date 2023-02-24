/*
 * Пример MQTT издателя на Golang с использованием TLS
 * File: "mqtt_tls_pub.go"
 */

package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

const (
	URI = "ssl://localhost:8883"
	ID  = "sample_tls"

	DEBUG = false

	//KEEP_ALIVE      = 1 * time.Second
	//PING_TIMEOUT    = 2 * time.Second
	CONNECT_TIMEOUT = 5 * time.Second
	PUB_TIMEOUT     = 5 * time.Second

	TOPIC = "sample/TLS"
	TEXT  = "Hello MQTT/TLS Go!"

	QOS = 2 // 0 - отправил забыл, 1 - минимум одно, 2 - ровно одно
)

func NewTLSConfig() *tls.Config {
	// Import trusted certificates from CAfile.pem.
	// Alternatively, manually add CA certificates to
	// default openssl CA bundle.
	certpool := x509.NewCertPool()
	pemCerts, err := ioutil.ReadFile("ca/ca.crt")
	if err == nil {
		certpool.AppendCertsFromPEM(pemCerts)
	}

	// Import client certificate/key pair
	cert, err := tls.LoadX509KeyPair("client/client.crt", "client/client.key")
	if err != nil {
		panic(err)
	}

	// Just to print out the client certificate..
	cert.Leaf, err = x509.ParseCertificate(cert.Certificate[0])
	if err != nil {
		panic(err)
	}
	//fmt.Println(cert.Leaf)

	// Create tls.Config with desired tls properties
	return &tls.Config{
		// RootCAs = certs used to verify server cert.
		RootCAs: certpool,
		// ClientAuth = whether to request cert from server.
		// Since the server is set up for SSL, this happens
		// anyways.
		ClientAuth: tls.NoClientCert,
		// ClientCAs = certs used to validate client cert.
		ClientCAs: nil,
		// InsecureSkipVerify = verify that cert contents
		// match server. IP matches what is in cert etc.
		InsecureSkipVerify: true,
		// Certificates = list of certs client sends to server.
		Certificates: []tls.Certificate{cert},
	}
}

// функция хендлер подписчика
//var mqtt_handler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
//	fmt.Println("receive TOPIC='" + msg.Topic() + "' TEXT='" + string(msg.Payload()) + "'")
//}

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

	// создать конфигурацию TLS со всеми сертификатами/ключами
	tlsconfig := NewTLSConfig()

	// задать опции подключения к MQTT брокеру
	opts := mqtt.NewClientOptions()
	opts.AddBroker(URI)
	opts.SetClientID(ID)
	opts.SetTLSConfig(tlsconfig)
	//opts.SetDefaultPublishHandler(mqtt_handler)
	//opts.SetKeepAlive(KEEP_ALIVE)
	//opts.SetPingTimeout(PING_TIMEOUT)

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

/*** end of "mqtt_tls_pub.go" file ***/
