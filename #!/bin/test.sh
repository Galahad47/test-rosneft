#!/bin/bash

if ! systemctl is-active --quiet docker; then
    echo "Докер не запущен для просмотра необходимо просмотреть systemctl status docker"
    systemctl status docker
    exit 1
fi
if ! ping -c 4 -q 8.8.8.8; then
        echo -e "\e[0;31mНет сети"
else
        echo -e "\e[1;32mПодключение к сети есть"
fi
if timeout 30s git ls-remote https://github.com/Lissy93/dashy.git > /dev/null 2>&1; then
        echo -e "\e[0;32mРепозиторий доступен"
else
        echo -e "\e[1;31mДоступ к репозиторию ограничен"
        exit 1
fi

clone https://github.com/Lissy93/dashy.git
mkdir -p ~/dashy && cd ~/dashy && curl -o config.yml https://raw.githubusercontent.com/Lissy93/dashy/main/config.yml
docker run  -d --name dashy -p 8080:80 -v ~/dashy/config.yml:/app/config.yml lissy93/dashy.git
docker save -o dashy.tar dashy

docker stop $(docker ps -qa) && docker rm $(docker ps -qa)

docker load -i dashy.tar && docker images | grep dashy


cat > docker-compose.yml <<EOF
version: '3'
services:
    dashy:
        image: dashy-app
        container_name: dashy
        ports: '8080:80'
        restart: unleess-stopped
EOF

docker-compose up -d && curl -I http://localhost:8080

