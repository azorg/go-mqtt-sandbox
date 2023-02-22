Пример простого MQTT подписчика на Golang
=========================================

## Как проверить?
1. Запустить сервер mosquitto `sudo systemctl start mosquitto.service` (если не запущен)

2. Запустить `go run mqtt_sub_tcp.go` (один или несколько в отдельных терминалах)

3. Отправить сообщения всем подписчикам
```bash
mosquitto_pub -q 2 -h localhost -t "sample/TCP" -m "Hello MQTT!"
```

