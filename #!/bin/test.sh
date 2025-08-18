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

mkdir -p ~/dashy && cd ~/dashy && curl -o config.yml https://raw.githubusercontent.com/Lissy93/dashy/main/config.yml
docker run  -d --name dashy -p 8080:80 -v ~/dashy/config.yml:/app/config.yml lissy93/dashy
timeout 10s
docker save -o test_rosneft.tar dashy
timeout 5s
docker stop $(docker ps -qa) && docker rm $(docker ps -qa)
timeout 10s
docker load -i test_rosneft.tar --build && docker images

cat > docker-compose.yml <<EOF
version: '3'
services:
    dashy:
        image: dashy-app
        container_name: dashy
        ports: '8080:80'
        restart: unleess-stopped
EOF

docker-compose up -d --build && curl -I http://localhost:8080

