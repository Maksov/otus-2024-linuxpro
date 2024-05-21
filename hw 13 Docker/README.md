## Домашее задание № 12 SELinux

### Занятие 19. Docker

#### Цель

Разобраться с основами docker, с образом, эко системой docker в целом;

#### Описание домашнего задания

1. Установите Docker на хост машину
https://docs.docker.com/engine/install/ubuntu/
2. Установите Docker Compose - как плагин, или как отдельное приложение
3. Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
4. Определите разницу между контейнером и образом
5. Вывод опишите в домашнем задании.
6. Ответьте на вопрос: Можно ли в контейнере собрать ядро?
7. Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.


#### Ход работы

1. Установка docker на CentOS 8 в соответствии с документацией
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

2. Запуск docker

```
[maksim@centos8 ~]$ sudo systemctl start docker
[maksim@centos8 ~]$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor pre>
   Active: active (running) since Tue 2024-05-21 20:13:10 +05; 12s ago
     Docs: https://docs.docker.com
 Main PID: 7992 (dockerd)
    Tasks: 10
   Memory: 40.3M
   CGroup: /system.slice/docker.service
           └─7992 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/contai>

мая 21 20:13:08 centos8 systemd[1]: Starting Docker Application Container Engin>

```
3. Сборка образа
```
[maksim@centos8 docker]$ ls
Dockerfile  index.html  nginx.conf

[maksim@centos8 docker]$ sudo docker build -t maksov/otusng:v1.0 .
[sudo] пароль для maksim: 
[+] Building 45.7s (11/11) FINISHED                              docker:default
 => [internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 949B                                       0.0s
 => [internal] load metadata for docker.io/library/alpine:latest          20.8s
 => [internal] load .dockerignore                                          0.0s
 => => transferring context: 2B                                            0.0s
 => [1/6] FROM docker.io/library/alpine:latest@sha256:c5b1261d6d3e4307162  7.5s
 => => resolve docker.io/library/alpine:latest@sha256:c5b1261d6d3e4307162  0.0s
 => => sha256:05455a08881ea9cf0e752bc48e61bbd71a34c029bb1 1.47kB / 1.47kB  0.0s
 => => sha256:4abcf20661432fb2d719aaf90656f55c287f8ca915d 3.41MB / 3.41MB  7.2s
 => => sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8e 1.64kB / 1.64kB  0.0s
 => => sha256:6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c0 528B / 528B  0.0s
 => => extracting sha256:4abcf20661432fb2d719aaf90656f55c287f8ca915dc1c92  0.2s
 => [internal] load build context                                          0.0s
 => => transferring context: 1.48kB                                        0.0s
 => [2/6] RUN apk update && apk add nginx && rm -rf /var/cache/apk/*      16.0s
 => [3/6] RUN adduser -D -g 'www' www && mkdir /www && chown -R www:www /  0.6s 
 => [4/6] RUN mkdir -p /run/nginx                                          0.5s 
 => [5/6] COPY index.html /www                                             0.1s 
 => [6/6] COPY nginx.conf /etc/nginx/nginx.conf                            0.0s 
 => exporting to image                                                     0.1s 
 => => exporting layers                                                    0.0s 
 => => writing image sha256:07a296c2fb5ebb55258ded996772da4a09982bf884700  0.0s
 => => naming to docker.io/maksov/otusng:v1.0                              0.0s

 [maksim@centos8 docker]$ sudo docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
maksov/otusng   v1.0      07a296c2fb5e   About a minute ago   8.84MB
[maksim@centos8 docker]$ 

```

4. Запуск контйенера

```
[maksim@centos8 docker]$ sudo docker run -p 80:80 -t maksov/otusng:v1.0
maksim@centos8 ~]$ sudo docker ps
[sudo] пароль для maksim: 
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                               NAMES
daeac1d0a3c7   maksov/otusng:v1.0   "nginx -g 'daemon of…"   25 seconds ago   Up 25 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp   epic_banach

```

5. Проверяю работу nginx в контейнере

```
[maksim@centos8 ~]$ curl localhost
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="utf-8" />
    <title>Домашняя работа Docker по курсу Администрирование Linux Pro в OTUS (Овчинников М)</title>
</head>
<body>
    Server is online
</body>
</html>
[maksim@centos8 ~]$ 

```
6. Загрузка образа в репозиторий Docker Hub
```
[maksim@centos8 ~]$ sudo docker push maksov/otusng:v1.0
The push refers to repository [docker.io/maksov/otusng]
cfb46d856e8c: Pushed 
f0e82f5f3b80: Pushed 
072fec7271d4: Pushed 
190022338b30: Pushed 
1b8d87548b66: Pushed 
d4fc045c9e3a: Waiting d4fc045c9e3a: Mounted from library/alpine 
v1.0: digest: sha256:a9b4403c54933e74dff86ea8e0778bbb78e5d7db2fb0cd7f001b3ec5fecbc718 size: 1566
[maksim@centos8 ~]$ 

```
Ссылка на репозиторий
```
https://hub.docker.com/repository/docker/maksov/otusng/general
```

#### Ответы на вопросы

##### 1. Разница между контейнером и образом. 
Образ является шаблоном для контейнера.

Образы
Docker-образ — это read-only шаблон. Например, образ может содержать операционку Ubuntu c Apache и приложением на ней. Образы используются для создания контейнеров. Docker позволяет легко создавать новые образы, обновлять существующие, или вы можете скачать образы созданные другими людьми. Образы — это компонента сборки docker-а.

Контейнеры
Контейнеры похожи на директории. В контейнерах содержится все, что нужно для работы приложения. Каждый контейнер создается из образа. Контейнеры могут быть созданы, запущены, остановлены, перенесены или удалены. Каждый контейнер изолирован и является безопасной платформой для приложения. Контейнеры — это компонента работы.

##### 2. Можно ли в контейнере собрать ядро?
В принципе, возможно, установив компилятор, необходимые для него библиотеки, сделав доступными исходные тексты. Но запустить это ядро в контейнере не получится, т.к. контейнер использует ядро хостовой системы.