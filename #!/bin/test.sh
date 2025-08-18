#!/bin/bash

if ! systemctl is-active --quiet docker; then
    echo "Докер не запущен для просмотра необходимо просмотреть systemctl status docker"
    systemctl status docker
    exit 1
fi
if ! ping -c 4 -q 8.8.8.8; then
        echo "Нет сети"
else
        echo "Подключение к сети есть"
fi
if timeout 30s git ls-remote https://github.com/Lissy93/dashy > /dev/null 2>&1; then
        echo "Репозиторий доступен"
else
        echo "Доступ к репозиторию ограничен"
        exit 1
fi

docker build https://github.com/Lissy93/dashy


