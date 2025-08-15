#!/bin/test
#докер
if ! docker info >/dev/null 2>&1; then 
    echo "Error {TypeERROR}"
fi

#инет
echo -e "GET http://google.com HTTPS/1.0\n\n" | google.com 80 > dev/null 2>&1

if [$? -eq 0]; then
    echo 'Online'
else
    echo 'Offline'
#гит
if timeout 30s git ls-remote --tags > /dev/null 2>&1; then
    echo "git-sever доступен"
else 
    echo "git-server недоступен"
fi
#создание файла докера
docker build 


