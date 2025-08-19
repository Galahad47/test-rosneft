#!/bin/bash
CLONE_DIR = "dashy-src";REPO = "https://github.com/Lissy93/dashy.git";TAR_FILE="../dashy.tar"
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
if timeout 30s git ls-remote "$REPO" > /dev/null 2>&1; then
        echo -e "\e[0;32mРепозиторий доступен"
else
        echo -e "\e[1;31mДоступ к репозиторию ограничен"
        exit 1
fi

##Тут я слонирую репозитоорий и проверяю .json
[ -d "$CLONE_DIR" ] && rm -rf "$CLONE_DIR"
git clone --depth 1 --branch master "$REPO" "$CLONE_DIR" || exit 1

cd "$CLONE_DIR" || exit 1

if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
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

FROM nginx:1.23-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EOF

echo -e "\e[33mСборка Docker   \e[0m" && docker build -t dashy-app . || {
        echo -e "\e[31mПроизошла ошибка сборки\e[0m"
        exit 1
}
echo -e "\e[33mСохранение образа началось\e[0m" && docker save -o "$TAR_FILE" dashy-app || exit 1

cd .. || exit 1 
echo -e "\e[33mВыполняется очистка\e[0m" && docker system prune -a -f



