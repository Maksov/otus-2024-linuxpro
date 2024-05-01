## Домашее задание № 10 Bash

### Занятие 13. Bash

#### Цель

- Научиться писать Bash-скрипты;

#### Описание домашнего задания

Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.

Необходимая информация в письме:

- Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Ошибки веб-сервера/приложения c момента последнего запуска;
- Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
- Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.

В письме должен быть прописан обрабатываемый временной диапазон.

#### Ход работы

Начнем реализовывать скрипт по порядку. 
Для начала рассмотрим структуру файла access.log
access.log — это текстовый файл, использующийся веб-серверами для записи обращений к сайту. В каждой строке этого файла записывается одно обращение к серверу.
Пример содержимого файла access.log:
```
207.46.13.73 - - [21/May/2019:03:08:12 +0300] "GET /catalog/mototekhnika/pitbayki/?display=table HTTP/1.0" 200 32236 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
178.154.244.16 - - [21/May/2019:03:16:45 +0300] "POST /bitrix/tools/conversion/ajax_counter.php HTTP/1.0" 200 22 "https://nomoto.ru/company/news/novaya/" "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)"
200.33.155.30 - - [14/Aug/2019:04:12:10 +0300] "GET / HTTP/1.1" 200 3698 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7"rt=0.000 uct="-" uht="-" urt="-"
165.22.19.102 - - [14/Aug/2019:04:38:36 +0300] "POST /wp-login.php HTTP/1.1" 200 1721 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0"rt=0.255 uct="0.000" uht="0.193" urt="0.193"
```
Более наглядное представление файла access.log:
+----------------+------------------------------+--------------------------------------------------------------+-----+-------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------+
|       A        |   Время запроса к серверу    |          Тип запроса, его содержимое и версия                |  D  |   E   |          URL-источник запроса            |               HTTP-заголовок, содержащий информацию о запросе (клиентское приложение, язык и т. д.)                    |
+----------------+------------------------------+--------------------------------------------------------------+-----+-------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------+
| 207.46.13.73   | [21/May/2019:03:08:12 +0300] | "GET /catalog/mototekhnika/pitbayki/?display=table HTTP/1.0" | 200 | 32236 | "-"                                      | "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"                                              |
| 178.154.244.16 | [21/May/2019:03:16:45 +0300] | "POST /bitrix/tools/conversion/ajax_counter.php HTTP/1.0"    | 200 | 22    | "https://nomoto.ru/company/news/novaya/" | "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)"                                                     |
| 200.33.155.30  | [14/Aug/2019:04:12:10 +0300] | "GET / HTTP/1.1"                                             | 200 | 3698  | "-"                                      | "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7" |
| 165.22.19.102  | [14/Aug/2019:04:38:36 +0300] | "POST /wp-login.php HTTP/1.1"                                | 200 | 1721  | "-"                                      | "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0"                                         |
+----------------+------------------------------+--------------------------------------------------------------+-----+-------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------+
Где:
A — хост/IP-адрес, с которого произведён запрос к серверу;
D — код состояния HTTP;
E — количество отданных сервером байт.


Покамандно соберем необходимые данные.

Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов 

```
cat access.log | awk '{print $1}'  | sort | uniq -c | sort -rn | head -n 10
```
Получаем список ip адресов с количеством запросов
	``` 
	 45 93.158.167.130
     39 109.236.252.130
     37 212.57.117.19
     33 188.43.241.106
     31 87.250.233.68
     24 62.75.198.172
     22 148.251.223.21
     20 185.6.8.9
     17 217.118.66.161
     16 95.165.18.146
	```
Приводим это в человекочитаемы вид с табличкой)
```
cat access.log | awk '{print $1}'  | sort | uniq -c | sort -rn | head | awk '
        BEGIN {
            print "+=====+=================+=================+"
            print "|  X  |    IP-адрес     | Кол-во запросов |"
            print "+-----+-----------------+-----------------+"
            i = 0
        }
		{   # Меняем столбцы местами
            printf "| %3d | %-15s |      %6d     |\n", ++i, $2, $1
        }
		END {print "+-----+-----------------+-----------------+\n"}'
```
Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов	
```
cat access.log | awk '{print $7}'  | sort | uniq -c | sort -rn | head -n 10
	157 /
    120 /wp-login.php
     57 /xmlrpc.php
     26 /robots.txt
     12 /favicon.ico
     11 400
      9 /wp-includes/js/wp-embed.min.js?ver=5.0.4
      7 /wp-admin/admin-post.php?page=301bulkoptions
      7 /1
      6 /wp-content/uploads/2016/10/robo5.jpg

```
Читаемый вид
```
cat access.log | awk '{print $7}'  | sort | uniq -c | sort -rn | head | awk '
 BEGIN {
            print "+=====+=================+==================================="
            print "|  Y  | Кол-во запросов |             Адрес                 "
            print "+-----+-----------------+-----------------------------------"
            i = 0
        }
	    { printf "| %3d | %15d | %-s\n", ++i, $1, $2 }
        END {
            print "+-----+-----------------+-----------------------------------\n"}'
```
Ошибки веб-сервера/приложения
```
 cat access.log | awk '
        BEGIN {
            i = 0

            print "+=====+====================================================="
            print "|                        ОШИБКИ                             "
            print "+-----+--------------+--------------------------------------"
            print "|  №  |  Код ошибки  |           HTTP запрос                "
            print "+-----+--------------+--------------------------------------"
        }
        {
            if (match($9,/^5.*/))
                {printf "| %3d | %-12d |%s\n", ++i, $9, $7}
            else
                {}
        }'
```
Список всех кодов HTTP ответа с указанием их кол-ва
Сразу читаемый вид:
```
cat access.log | awk '{print $9}'  | sort | uniq -c | sort -rn | awk '
        BEGIN {
            return_codes[100]="Continue"
            return_codes[101]="Switching Protocols"
            return_codes[102]="Processing"
            return_codes[200]="OK"
            return_codes[201]="Created"
            return_codes[202]="Accepted"
            return_codes[203]="Non-Authoritative Information"
            return_codes[204]="No Content"
            return_codes[205]="Reset Content"
            return_codes[206]="Partial Content"
            return_codes[207]="Multi-Status"
            return_codes[208]="Already Reported"
            return_codes[226]="IM Used"
            return_codes[300]="Multiple Choices"
            return_codes[301]="Moved Permanently"
            return_codes[302]="Moved Temporarily"
            return_codes[302]="Found"
            return_codes[303]="See Other"
            return_codes[304]="Not Modified"
            return_codes[305]="Use Proxy"
            return_codes[307]="Temporary Redirect"
            return_codes[308]="Permanent Redirect"
            return_codes[400]="Bad Request"
            return_codes[401]="Unauthorized"
            return_codes[402]="Payment Required"
            return_codes[403]="Forbidden"
            return_codes[404]="Not Found"
            return_codes[405]="Method Not Allowed"
            return_codes[406]="Not Acceptable"
            return_codes[407]="Proxy Authentication Required"
            return_codes[408]="Request Timeout"
            return_codes[409]="Conflict"
            return_codes[410]="Gone"
            return_codes[411]="Length Required"
            return_codes[412]="Precondition Failed"
            return_codes[413]="Payload Too Large"
            return_codes[414]="URI Too Long"
            return_codes[415]="Unsupported Media Type"
            return_codes[416]="Not Satisfiable"
            return_codes[417]="Expectation Failed"
            return_codes[418]="Im a teapot"
            return_codes[419]="Authentication Timeout"
            return_codes[421]="Misdirected Request"
            return_codes[422]="Unprocessable Entity"
            return_codes[423]="Locked"
            return_codes[424]="Failed Dependency"
            return_codes[426]="Upgrade Required"
            return_codes[428]="Required"
            return_codes[429]="Too Many Requests"
            return_codes[431]="Request Header Fields Too Large"
            return_codes[449]="Retry With"
            return_codes[451]="Unavailable For Legal Reasons"
            return_codes[452]="Bad sended request"
            return_codes[499]="Client Closed Request"
            return_codes[500]="Internal Server Error"
            return_codes[501]="Not Implemented"
            return_codes[502]="Bad Gateway"
            return_codes[503]="Service Unavailable"
            return_codes[504]="Gateway Timeout"
            return_codes[505]="HTTP Version Not Supported"
            return_codes[506]="Variant Also Negotiates"
            return_codes[507]="Insufficient Storage"
            return_codes[508]="Loop Detected"
            return_codes[509]="Bandwidth Limit Exceeded"
            return_codes[510]="Not Extended"
            return_codes[511]="Network Authentication Required"
            return_codes[520]="Unknown Error"
            return_codes[521]="Web Server Is Down"
            return_codes[522]="Connection Timed Out"
            return_codes[523]="Origin Is Unreachable"
            return_codes[524]="A Timeout Occurred"
            return_codes[525]="SSL Handshake Failed"
            return_codes[526]="Invalid SSL Certificate"

            i = 0


            print "+=====+=================================+========+"
            print "|  №  |         Код возврата HTTP       | Кол-во |"
			print "+=====+=====+===========================+========+"
        }
		{
		    printf "|%4d | %3d | %-25s | %6d |\n", \
                ++i, $2, return_codes[$2], $1		
		}'
```

Соберем теперь это все в рабоий скрипт с функцией и отправкой почты
>> analayzer_weblog.sh

По результату выполнения скрипт отправляет отчет на локальный почтовый ящик

```
[vagrant@otus-hw10-Bash ~]$ ./analayzer_weblog.sh
/home/vagrant
[vagrant@otus-hw10-Bash ~]$ mail
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/vagrant": 1 message 1 new
>N  1 vagrant@otus-hw10-Ba  Wed May  1 23:26  76/3591  "REPORT"
& 1
Message  1:
From vagrant@otus-hw10-Bash.localdomain  Wed May  1 23:26:09 2024
Return-Path: <vagrant@otus-hw10-Bash.localdomain>
X-Original-To: vagrant@localhost
Delivered-To: vagrant@localhost
Date: Wed, 01 May 2024 23:26:09 +0000
To: vagrant@localhost
Subject: REPORT
User-Agent: Heirloom mailx 12.5 7/5/10
Content-Type: text/plain; charset=utf-8
From: vagrant@otus-hw10-Bash.localdomain
Status: R

+=====+=================+=================+
|  X  |    IP-адрес     | Кол-во запросов |
+-----+-----------------+-----------------+
|   1 | 93.158.167.130  |          45     |
|   2 | 109.236.252.130 |          39     |
|   3 | 212.57.117.19   |          37     |
|   4 | 188.43.241.106  |          33     |
|   5 | 87.250.233.68   |          31     |
|   6 | 62.75.198.172   |          24     |
|   7 | 148.251.223.21  |          22     |
|   8 | 185.6.8.9       |          20     |
|   9 | 217.118.66.161  |          17     |
|  10 | 95.165.18.146   |          16     |
+-----+-----------------+-----------------+

+=====+=================+===================================
|  Y  | Кол-во запросов |             Адрес
+-----+-----------------+-----------------------------------
|   1 |             157 | /
|   2 |             120 | /wp-login.php
|   3 |              57 | /xmlrpc.php
|   4 |              26 | /robots.txt
|   5 |              12 | /favicon.ico
|   6 |              11 | 400
|   7 |               9 | /wp-includes/js/wp-embed.min.js?ver=5.0.4
|   8 |               7 | /wp-admin/admin-post.php?page=301bulkoptions
|   9 |               7 | /1
|  10 |               6 | /wp-content/uploads/2016/10/robo5.jpg
|  11 |               6 | /wp-content/uploads/2016/10/robo4.jpg
|  12 |               6 | /wp-content/uploads/2016/10/robo3.jpg
|  13 |               6 | /wp-content/uploads/2016/10/robo2.jpg
|  14 |               6 | /wp-content/uploads/2016/10/robo1.jpg
|  15 |               6 | /wp-content/uploads/2016/10/aoc-1.jpg
+-----+-----------------+-----------------------------------

+=====+=====================================================
|                        ОШИБКИ
+-----+--------------+--------------------------------------
|  №  |  Код ошибки  |           HTTP запрос
+-----+--------------+--------------------------------------
|   1 | 500          |/wp-includes/ID3/comay.php
|   2 | 500          |/wp-content/plugins/uploadify/includes/check.php
|   3 | 500          |/wp-content/uploads/2018/08/seo_script.php
+-----+--------------+-----------------------------------

+=====+=================================+========+
|  №  |         Код возврата HTTP       | Кол-во |
+=====+=====+===========================+========+
|   1 | 200 | OK                        |    498 |
|   2 | 301 | Moved Permanently         |     95 |
|   3 | 404 | Not Found                 |     51 |
|   4 |   0 |                           |     11 |
|   5 | 400 | Bad Request               |      7 |
|   6 | 500 | Internal Server Error     |      3 |
|   7 | 499 | Client Closed Request     |      2 |
|   8 | 405 | Method Not Allowed        |      1 |
|   9 | 403 | Forbidden                 |      1 |
|  10 | 304 | Not Modified              |      1 |
+-----+-----+---------------------------+--------+

&  q
Held 1 message in /var/spool/mail/vagrant
You have mail in /var/spool/mail/vagrant

```