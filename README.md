# Часть 1 - Основы

<H4>Если ВМ совсем новая, то нужно установить необходимые для работы библиотеки.Тут мы просто создали группу и добавили в нее юзера, у файла $test.sh предварительно заданы права на r+x (чтение и исполнение)</H4>

    sudo apt update -y && sudo apt upgrade -y

    sudo apt install openssh-server -y
    sudo apt install ufw -y
    sudo apt update -y && sudo apt upgrade -y

    sudo apt install curl -y
    sudo apt update -y && sudo apt upgrade -y

    sudo apt update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo docker run hello-world


<H4>Находясь в директории файла(хотя можно просто прописать путь в командах), необходимо прописать команды </H4>
    
    sudo addgrp dockers #создал новую группу
    sudo useradd lapenkoas
    sudo usermod -aG dockers lapenkoas
    sudo chgrp dockers test.sh
    sudo chmod  u=rwx,g=rx test.sh 
    
# Часть 2 - Закрепление. 
<H3>
    Далее я распишу подробно как работает скрипт описанный в папке bin
</H3>

<H5>
    1.  Необходимо было проверить установлен ли докер, работает ли он на ВМ и запущен ли демон.
    2.  Работает ли интернет и есть ли связь с репозиторием Lissy93/dashy (есть ли доступ на r)
    3.  Создание докер файла.
    4.  Работа с docker build
    5.  Выгрузить di в файл
    6.  rm для всех контенеров и reg очистка
    7.  Работа с полученным di
    8.  .yml - создаем расписываем
    9.  Запускаем с помощью .yml контейнер с приложением
    10. открыть localhost:8080 должен появится стартовый web. Можно в целом и сразу развернуть на своём домене, если белый ip
</H5>

# Часть 3 - Во все тяжкие

<H4>
    После описание выше, решил натсроить дашборд. 
</H4>



