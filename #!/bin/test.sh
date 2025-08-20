#!/bin/bash

CLONE_DIR="dashy-src";REPO="https://github.com/Lissy93/dashy.git";TAR_FILE="dashy.tar"

docker stop dashy 2>/dev/null || true; docker rm dashy 2>/dev/null || true

if ! systemctl is-active --quiet docker; then
    echo "Докер не запущен для просмотра необходимо просмотреть systemctl status docker"
    systemctl status docker
    exit 1
fi
if ! ping -c 4 -q 8.8.8.8 >/dev/null 2>&1; then
        echo -e "\e[0;31mНет сети"
        exit 1
else
        echo -e "\e[1;32mПодключение к сети есть"
fi
if ! timeout 30s git ls-remote "$REPO" >/dev/null 2>&1; then
        echo -e "\e[1;31mДоступ к репозиторию ограничен"
        exit 1
else
        echo -e "\e[0;32mРепозиторий доступен"
fi

[ -d "$CLONE_DIR" ] && rm -rf "$CLONE_DIR"
git clone --depth 1 --branch master "$REPO" "$CLONE_DIR" || exit 1

cd "$CLONE_DIR" || exit 1

if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
    echo -e "\e[33mУстановка Node.js и npm...\e[0m"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

echo -e "\e[32mВерсия Node.js: $(node -v)\e[0m"
echo -e "\e[32mВерсия npm: $(npm -v)\e[0m"

if [ ! -f "package-lock.json" ]; then
    echo -e "\e[33mГенерация package-lock.json...\e[0m"
    npm install --package-lock-only --silent || {
        echo -e "\e[31mОШИБКА: Не удалось создать package-lock.json\e[0m"
        exit 1
    }
fi  

cat > Dockerfile <<'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --silent
COPY . .
RUN npm run build
RUN npx browserslist@latest --update-db

FROM nginx:1.23-alpine
RUN rm -f /docker-entrypoint.d/30-tune-worker-processes.sh && \
    rm -f /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/docker/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
EOF

echo -e "\e[33mСборка Docker\e[0m" && docker build -t dashy_app . || {
        echo -e "\e[31mПроизошла ошибка сборки\e[0m"
        exit 1
}
echo -e "\e[33mСохранение образа началось\e[0m" && docker save -o "$TAR_FILE" dashy_app || exit 1

cd .. || exit 1 
if ! -e *.tar; then
    echo -e "\e[31mОшибка не обнаружен dashy.tar\e[0m"
    exit 1
else
    echo -e "\e[33mВыполняется очистка\e[0m" && docker system prune -a -f
fi

echo -e "\e[33mЗагрузка Docker\e[0m" && docker load -i "$TAR_FILE" || exit 1

CONFIG_DIR="$HOME/dashy-config";CONFIG_FILE="$CONFIG_DIR/conf.yml"
mkdir -p "$CONFIG_DIR"
[ ! -f "$CONFIG_FILE" ] && curl -sL "$REPO/raw/master/public/conf.yml" -o "$CONFIG_FILE"

cat > docker-compose.yml <<EOF
version: '3.8'
services:
  dashy:
    container_name: dashy
    image: dashy_app
    ports:
      - "8080:80"
    volumes:
      - "$CONFIG_FILE:/app/public/conf.yml"
    restart: unless-stopped
EOF

echo -e "\e[33mЗапуск контейнера\e[0m" && docker compose up -d || exit 1
echo -e "\e[33mПроверка работы\e[0m" && sleep 10
if curl -sI http://localhost:8080 | grep -q "200 OK"; then
    echo -e "\e[32mУСПЕХ: Приложение доступно на \e[4mhttp://localhost:8080\e[0m"
    echo -e "Конфиг: \e[35m$CONFIG_FILE\e[0m"
else
    echo -e "\e[31mОШИБКА: Приложение не запустилось\e[0m"
    docker logs dashy
    exit 1
fi
