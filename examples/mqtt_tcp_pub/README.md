Пример простого MQTT издателя на Golang
=======================================

## Как проверить?
1. Запустить сервер mosquitto `sudo systemctl start mosquitto.service` (если не запущен)

2. Запустить в отдельном терминале MQTT подписчик (один или несколько):
```bash
mosquitto_sub -q 2 -h localhost -t "sample/TCP"
```

3. Запустить `go run mqtt_pub_tcp.go` и проверить доставку сообщений подписчиками...





