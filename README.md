# Прописываем для начала следующее:
# Если система совсем новая 
    sudo groupadd dockers-user &&
        sudo chgrp dockers-user /test.sh &&
            sudo usermod -aG dockers-user lapenkoas

# Тут мы просто создали группу и добавили в нее юзера, у группы предварительно заданы права на -r+w (чтение и запись)
