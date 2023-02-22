Порядок установки (для Debian 11)
=================================

## 0. Установка Golang
```bash
sudo apt install golang
```
У меня установилась версия go1.15.15.
Как узнать? - Запустить `go version`

## 1. Установка MQTT брокера (сервера)
```bash
sudo apt install mosquitto mosquitto-clients mosquitto-dev
```
У меня установилась версия 2.0.11.

По умолчанию сервер (брокер) слушает TCP порт 1883.

## 2. Настройка MQTT брокера на локальном ПК и его проверка

По умолчанию должно работать:

* Как принять сообщение (с помощью mosquitto-clients):
```bash
mosquitto_sub -h localhost -t "topic/subtopic"
```

* Как отправить сообщение (с помощью mosquitto-clients):
```bash
mosquitto_pub -h localhost -t "topic/subtopic" -m "meaasge"
```
Для подробностей смотрите `man` или запустите клиент с ключом `--help`.

## 3. Установка клиентской библиотеки Go для работы с MQTT
Переходим в браузере на https://github.com/eclipse/paho.mqtt.golang
и читаем инструкцию (RAEDME.md).

Выполяем инструкцию:
```bash
go get github.com/eclipse/paho.mqtt.golang

go get github.com/gorilla/websocket
go get golang.org/x/net/proxy
```
Если все прошло без ошибок, то весь репозиторий проекта MQTT
клонируется в $GOPATH/src/github.com/eclipse/paho.mqtt.golang/.
Посмотеть GOPATH можно так: `go env | grep GOPATH`, т.к.
в переменных окружения оболочки он у меня не задан.
В моём случае GOPATH="/home/user/go".

В каталоге cmd репозитория есть много примеров.
Для сборки примеров нужно перейти в данный каталог и
запустить ./build.sh следующего триывиального содерджания:
```bash
#!/bin/sh

for dir in `ls -d */ | cut -f1 -d'/'`
do
    echo "Compiling $dir ...\c"
    cd $dir
    go clean
    go build
    cd ..
    echo " done."
done
```
Занятно, что в коде присутсвует "Copyright (c) 2021 IBM Corp and others".
Код распространяется под лицензией "Eclipse Public License - v 2.0 (EPL-2.0)".


