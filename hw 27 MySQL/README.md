## Домашее задание № 27 Репликация mysql

### 44.MySQL: Backup + Репликация

#### Цель

Поработать с реаликацией MySQL.

#### Описание домашнего задания

Для выполнения домашнего задания используйте методичку

Что нужно сделать?
В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp
Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:
```
| bookmaker          |
| competition        |
 market              |
| odds               |
| outcome
```
Настроить GTID репликацию

#### Ход работы

Запускаем виртуалки master и slave с помощью Vagrant.


#### Установка Percona-Server

Предварительно отключаем модуль mysql
```
sudo yum module disable mysql
```

1. Установка репозитория Percona-Server
```
$ sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
```

2. Включаем Percona-Server репозиторий:
```
$ sudo percona-release setup ps57
```

3. Установка пакетов Percona-Server

```
$ yum install Percona-Server-server-57
```
#### Настройка Percona-Server

По умолчаниĀ Percona хранит файлý в таком виде:
● Основной конфиг в /etc/my.cnf
● Так же инклудитсā директориā /etc/my.cnf.d/ - куда мý и будем
складýватþ наши конфиги.
● Дата файлý в /var/lib/mysql

Копируем конфиги из /vagrant/conf.d в /etc/my.cnf.d/
```
[root@otuslinux ~] cp /vagrant/conf/conf.d/* /etc/my.cnf.d/
```
После этого можно запустить службу:
```
[root@otuslinux ~] systemctl start mysql
```
При установке Percona автоматически генерирует паролþ длā пользователя root и кладет его в
файл /var/log/mysqld.log:
```
[root@otuslinux ~] cat /var/log/mysqld.log | grep 'root@localhost:' | awk '{print $11}'
*mulP>&68v/A
```
Подключаемся к mysql и меняем пароль для доступа к полному функционалу:
```
[root@otuslinux ~] mysql -uroot -p'*mulP>&68v/A'
mysql > ALTER USER USER() IDENTIFIED BY 'YourStrongPassword';
```
Репликацию будем настраивать с использованием GTID. 

Следует обратить внимание, что атрибут server-id на мастер-сервере должен обязательно
отличаться от server-id слейв-сервера.

Убеждаемся что GTID включен:
```
mysql> SHOW VARIABLES LIKE 'gtid_mode';
+-----------------------+---+
| Variable_name | Value |
+-----------------------+---+
| gtid_mode     | ON    |
+-----------------------+---+
```

Создадим тестовую базу bet и загрузим в нее дамп и проверим:
```
mysql> CREATE DATABASE bet;
Query OK, 1 row affected (0.00 sec)
[root@otuslinux ~] mysql -uroot -p -D bet < /vagrant/bet.dmp
mysql> USE bet;
mysql> SHOW TABLES;
+------------------+
| Tables_in_bet    |
+------------------+
| bookmaker        |
| competition      |
| events_on_demand |
| market           |
| odds             |
| outcome          |
| v_same_event     |
+------------------+
```

Создадим пользователя для репликации и даем ему права на эту самую репликацию:
```
mysql> CREATE USER 'repl'@'%' IDENTIFIED BY '!OtusLinux2018';
mysql> SELECT user,host FROM mysql.user where user='repl';
+------+------+
| user | host |
+------+------+
| repl | %    |
+------+------+
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '!OtusLinux2018';
```

Дампим базу для последующего залива на слейв и игнорируем таблицý по заданию:
```
[root@otuslinux ~] mysqldump --all-databases --triggers --routines --master-data
--ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event -uroot -p > master.sql
```
На этом настройка Master-а завершена. Файл дампа нужно залить на слейв.


#### Настройка Percona-Server Slave


Так же точно копируем конфиги из /vagrant/conf.d в /etc/my.cnf.d/
```
[root@slave ~] cp /vagrant/conf/conf.d/* /etc/my.cnf.d/
```
Правим в /etc/my.cnf.d/01-basics.cnf директиву server-id = 2
```
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
| 2           |
+-------------+
```
Раскомментируем в /etc/my.cnf.d/05-binlog.cnf строки:
```
#replicate-ignore-table=bet.events_on_demand
#replicate-ignore-table=bet.v_same_event
```
Таким образом указываем таблицы которые будут игнорироваться при репликации

Заливаем дамп мастера и убеждаемсā что база естþ и она без лишних таблиц:
```
mysql> SOURCE /mnt/master.sql
mysql> SHOW DATABASES LIKE 'bet';
+----------------+
| Database (bet) |
+----------------+
| bet            |
+----------------+
mysql> USE bet;
mysql> SHOW TABLES;
+---------------+
| Tables_in_bet |
+---------------+
| bookmaker     |
| competition   |
| market        |
| odds          |
| outcome       |
+---------------+ 
```
видим что таблиц v_same_event и events_on_demand нет
Ну и собственно подклĀчаем и запускаем слейв:
```
mysql> CHANGE MASTER TO MASTER_HOST = "192.168.11.150", MASTER_PORT = 3306,
MASTER_USER = "repl", MASTER_PASSWORD = "!OtusLinux2018", MASTER_AUTO_POSITION = 1;
mysql> START SLAVE;
mysql> SHOW SLAVE STATUS\G

mysql> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.56.150
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 788
               Relay_Log_File: slave-relay-bin.000002
                Relay_Log_Pos: 414
        Relay_Master_Log_File: mysql-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: No
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 1007
                   Last_Error: Error 'Can't create database 'bet'; database exists' on query. Default database: 'bet'. Query: 'CREATE DATABASE bet'
                 Skip_Counter: 0
```
Видим ошибку. Репликация не работает.

Поиск в интернете: https://medium.com/@brianlie/mysql-replication-skipped-gtid-and-how-to-fix-it-a2d836452724

Следуем рекомендациям в статье.

Проверяем
Видно что репликациā работает, gtid работает и игнорятся таблички по задани.:

```
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.56.150
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 788
               Relay_Log_File: slave-relay-bin.000005
                Relay_Log_Pos: 454
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event

```

Проверим репликацию в действии. На мастере:
mysql> USE bet;
mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');

На слейве:

```
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
|  2 | winline        |
+----+----------------+
6 rows in set (0.00 sec)

mysql> 

```

На этом настройка репликации завершена!




