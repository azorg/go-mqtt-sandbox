Пример MQTT подписчика на Golang с использованием TLS
=====================================================

## Как проверить?
0. Настроить mosquito для работы на порте 8883 с TLS (см. пример tls/etc/mosquitto/conf.d/tls.conf)
 * создать ключевую пару CA и изготовить само подписанный сертификат CA
 * создать ключевую пару сервера и подписать её своим же ключаем CA
 * создать ключевую пару для клиента (клиентов) и подписать её ключам CA
 * самопо дписанный сертификат CA `ca.crt` поместить в `/etc/mosquitto/ca_certificates/`
 * ключ сервера `server.key` и сертификат `server.crt` поместить в `/etc/mosuitto/certs/` 
 * настроить (по образцу) `/etc/mosquitto/conf.d/tls.conf`
 * в _каталог_ клиента положить ключ `client.key`, сертификат клиента `client.crt`
   и само подписанный сертификат CA `ca.crt`

1. Запустить сервер mosquitto `sudo systemctl start mosquitto.service` (если не запущен)
Посмотреть статус с использованием Systemd можно так: `systemctl status mosquitto.service`

2. Проверить TLS/SSL соединение с сервером (посомтреть чего выдает mosquitto)
```bash
openssl s_client -showcerts -connect localhost:8883 < /dev/null \
        -CAfile ca/ca.crt -key client/client.key -cert client/client.crt \
        -status -debug
```
 
3. Запустить `go run mqtt_sub_tls.go` для проверки приёма сообщений от издателя

4. Запустить в отдельном терминале MQTT издатель:
```bash
mosquitto_sub --cafile ca/ca.crt --cert client/client.crt --key client/client.key -p 8883 \
              -q 2 -h localhost -q 2 -d --insecure \
              -t "sample/TLS"  "Hello Go!"
```




