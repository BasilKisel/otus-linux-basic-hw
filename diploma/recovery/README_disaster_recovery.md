# Восстановление работоспособности при отказе инфраструктуры

* Ты же добавил запись с картинкой в блог WP для демонстрации?
* Ты же сделал полный бакап БД?
* Ты же продемострировал лодержимое полного и инкрементного бакапов?
* Ты же отключил внешний диск от nfs перед демонстрацией?
* Ты же удалил старые ВМ что бы хватило место для новых?

## Шпаргалка
* Скрипты восстановления в каталоге "recovery";
* Адреса узлов:
    * 192.168.1.11 - bootstrap
    * 192.168.1.12 - nfs server
    * 192.168.1.13 - mysql source
    * 192.168.1.14 - mysql replica
    * 192.168.1.15 - web-app-nd1
    * 192.168.1.16 - web-app-nd2
    * 192.168.1.17 - nginx reverse proxy
    * 192.168.1.18 - Prometheus + Graphana
    * 192.168.1.19 - ELK stack
* Скрипты бакапа/восстановления MySql из nfs (192.168.1.12):
    * `/usr/sbin/dump-mysql-tablewise.sh`
    * `/usr/sbin/dump-mysql-serverwise.sh`
    * `/usr/sbin/restore-mysql-serverwise.sh`

## 1. NFS server
1. Подготовить boostrap к роли nfs сервера:
    1. Импортировать образ ВМ "bootstrap";
    2. Переименовать в "nfs";
    3. Подключить внешний диск к SCSI шине 1;
    4. Запустить ВМ.
2. Преобразовать boostrap в nfs сервер:
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "nfs"
    3. Зайти в каталог на ВМ;
    4. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-nfs-server.sh && sudo ./01.install-nfs-server.sh ) >> ./install.log `;
    5. Оборвать ssh соединение с "bootstrap".
3. При утрате файлов веб-приложения:
    1. Подключиться по ssh к "nfs" (192.168.1.12);
    3. Зайти в каталог "nfs";
    2. Выполнить ` sudo ./02.unpack-wordpress.sh `.

## 2. MySQL - source
1. Подготовить boostrap к роли "mysql-source":
    1. Импортировать образ ВМ "bootstrap";
    2. Переименовать в "mysql-source";
    3. Запустить ВМ.
2. Преобразовать boostrap в "mysql-source":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "mysql-source";
    3. Зайти в каталог на ВМ;
    4. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-mysql-source.sh && sudo ./01.install-mysql-source.sh ) >> ./install.log `;
    5. Оборвать ssh соединение с "bootstrap".
3. При наличии бакапов БД:
    1. Подключиться по ssh к "nfs" (192.168.1.12);
    2. Выполнить `/usr/sbin/restore-mysql-serverwise.sh` (при ошибке подключения к mysql: подождать 10 секунд и повторить).

## 3. web-app-nd1
1. Подготовить boostrap к роли "web-app-nd1":
    1. Импортировать образ ВМ bootstrap";
    2. Переименовать в "web-app-nd1";
    3. Запустить ВМ.
2. Преобразовать boostrap в "web-app-nd1":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "web-app";
    3. Зайти в каталог на ВМ;
    4. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-web-app-nd1.sh && sudo ./01.install-web-app.sh ) >> ./install.log `;
    5. Оборвать ssh соединение с "bootstrap".

## 4. Nginx - reverse proxy
1. Подготовить boostrap к роли "nginx-rev-proxy":
    1. Импортировать образ ВМ "bootstrap";
    2. Переименовать в "nginx-rev-proxy";
    3. Запустить ВМ.
2. Преобразовать boostrap в "nginx-rev-proxy":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "web-app"
    3. Зайти в каталог на ВМ;
    4. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-web-app-nd1.sh && sudo ./01.install-web-app.sh ) >> ./install.log `;
    5. Оборвать ssh соединение с "bootstrap".
3. Проверить работу веб-приложения:
    1. Зайти в браузере на адрес http://192.168.1.17 - веб приложение должно отобразить начальную страницу;
    2. Зайти в браузере на адрес http://192.168.1.17/hello.php - должна отобразиться тестовая страница докер-контейнера.

## 5. web-app-nd2
1. Подготовить boostrap к роли "web-app-nd2":
    1. Импортировать образ ВМ "bootstrap";
    2. Переименовать в "web-app-nd2";
    3. Запустить ВМ.
2. Преобразовать boostrap в "web-app-nd2":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "web-app"
    3. Зайти в каталог на ВМ;
    4. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-web-app-nd2.sh && sudo ./01.install-web-app.sh ) >> ./install.log `;
    5. Оборвать ssh соединение с "bootstrap".

## 6. MySQL - replica
1. Подготовить boostrap к роли "mysql-replica":
    1. Импортировать образ ВМ "bootstrap";
    2. Переименовать в "mysql-replica";
    3. Запустить ВМ.
2. Преобразовать boostrap в "mysql-replica":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "mysql-replica"
    3. Зайти в каталог на ВМ;
    4. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-mysql-replica.sh && sudo ./01.install-mysql-replica.sh ) >> ./install.log `;
    5. Оборвать ssh соединение с "bootstrap".

## 7. Prometheus + Grafana
1. Подготовить boostrap к роли "prometheus-grafana":
    1. Импортировать образ ВМ "bootstrap";
    2. Переименовать в "prometheus-grafana";
    3. Запустить ВМ.
2. Преобразовать boostrap в "prometheus-grafana":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "prometheus-grafana"
    3. Зайти в каталог на ВМ;
    4. Скопировать пакеты установки grafana в подкаталог "grafana";
    5. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-prometheus-grafana.sh && sudo ./01.install-prometheus-grafana.sh ) >> ./install.log `;
    6. Оборвать ssh соединение с "bootstrap".
3. Проверить сбор метрик в Prometheus:
    1. Зайти в браузере на адрес "http://192.168.1.18:9090";
    2. Перейти в "Status" -> "Targets";
    3. Убедиться, что следующие узлы в статусе "UP":
        * http://192.168.1.12:9100/metrics
        * http://192.168.1.13:9100/metrics
        * http://192.168.1.14:9100/metrics
        * http://192.168.1.15:9100/metrics
        * http://192.168.1.16:9100/metrics
        * http://192.168.1.17:9100/metrics
        * http://localhost:9100/metrics
    4. Убедиться, что экспортер метрик nginx в статусе "UP" с адресом
        * http://192.168.1.17:9113/metrics
4. Настроить подключение к Prometheus в Grafana:
    1. Зайти в браузере на адрес "http://192.168.1.18:3000";
    2. Перейти в "Menu" -> "Connections" -> "Data Sources";
    3. Выбрать "Add new data souce", "Prometheus", указать адрес "http://localhost:9090", "Save & text".
5. Настроить дашборды в Grafana:
    1. Зайти в браузере на адрес "http://192.168.1.18:3000" (admin, admin);
    2. Перейти в "Menu" -> "Dashboards", "New" -> "Import";
    3. Скопировать содержимое файла "prometheus-grafana/grafana-node-dashboard-id-1860-rev33.json" в поле для JSON;
    4. Выбрать настроенное подключение к Prometheus, "Import";
    5. Повторить шаги 5.1-3.4 для файла "prometheus-grafana/grafana-nginx-prometheus-exporter-dashboard.json".

## 8. ELK stack
1. Подготовить boostrap-elk к роли "elk":
    1. Импортировать образ ВМ "bootstrap-elk" (ELK, а не обычный образ ВМ);
    2. Переименовать в "elk";
    3. Запустить ВМ.
2. Преобразовать boostrap-elk в "elk":
    1. Подключиться по ssh к "bootstrap";
    2. Скопировать каталог скриптов "elk";
    3. Зайти в каталог на ВМ;
    4. Скопировать пакеты установки elk в подкаталог "elk";
    5. Выполнить ` . __make_executable.sh; ( sudo ./00.prepare-vm-elk.sh && sudo ./01.install-elk.sh ) >> ./install.log `;
    6. Оборвать ssh соединение с "bootstrap".

## 9. nginx-filebeat
1. Подключиться по ssh к "nginx-rev-proxy" (192.168.1.17);
2. Скопировать каталог "nginx-reverse-proxy-filebeat";
3. Перейти в каталог на ВМ;
4. Скопировать пакеты установки filebeat в подкаталог "filebeat";
5. Выполнить ` . __make_executable.sh; sudo ./01.install-nginx-filebeat.sh >> ./install.log `.

## 10. apache-filebeat
1. Подключиться по ssh к "web-app-nd1"/"web-app-nd2" (192.168.1.15-16);
2. Скопировать каталог "apache-filebeat";
3. Перейти в каталог на ВМ;
4. Скопировать пакеты установки filebeat в подкаталог "filebeat";
5. Выполнить ` . __make_executable.sh; sudo ./01.install-apache-filebeat.sh >> ./install.log `.

## 11. Настройка дашборда в Kibana
1. Зайти в браузер на адрес "http://192.168.1.19:5601";
2. Перейти в "Menu" -> "Management" -> "Stack Management", "Kibana" -> "Saved Objects";
3. "Import", "Import", указать файл "elk/kibana\_admin\_dashboard.ndjson"

