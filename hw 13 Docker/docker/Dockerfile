# По услвию задания за основу взял Alpine Linux
FROM alpine:latest
# Ставлю необходимые пакеты и вычищаю за собой кеш установки
RUN apk update && apk add nginx && rm -rf /var/cache/apk/*
# добавляю пользователя от которого будет запускаться nginx
RUN adduser -D -g 'www' www && mkdir /www && chown -R www:www /var/lib/nginx && chown -R www:www /www
RUN mkdir -p /run/nginx
# Добавляю изменённую стартовую страницу и конфиг nginx
COPY index.html /www
COPY nginx.conf /etc/nginx/nginx.conf
# указываю какой порт будет транслировать контейнер
EXPOSE 80
# запуск nginx в режиме приложения
CMD ["nginx", "-g", "daemon off;"]