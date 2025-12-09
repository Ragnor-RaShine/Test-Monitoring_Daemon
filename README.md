# Скрипт-демон Test-Monitoring.sh

Описание:  
Осуществляет мониториг процесса test. Запускается при запуске ОС, используя систему инициализации и автозапуска Systemd. Отрабатывает каждую минуту, если процесс запущен, то отправляет запрос по адресу https://test.com/monitoring/test/api  . Если процесс был перезапущен, то делает запись в /var/log/Monitoring.log , а если процесс не запущен, то ничего не делает. Также записи в лог делаются, если сервер мониторинга недоступен.
  
  
Скрипт выполнен в рамках задания от компании Effective Mobile.  
  
  
  
  
Установка и настройка скрипта мониторинга Test-Monitoring:  
  
1. Разместить файл скрипта Test-Monitoring.sh в /opt/Scripts/  
  
2. Дать скрипту права на выполнение как программы с помощью команды:  
    sudo chmod +x /opt/Scripts/Test-Monitoring.sh  
      
3. Разместить файл Test-Monitoring.Service для системы автозапуска и инициализации в /etc/systemd/system/  
  
4. Перечитать список сервисов Systemd:  
    sudo systemctl daemon-reload  
      
5. Добавить новый сервис в автозапуск:  
    sudo systemctl enable Test-Monitoring.Service  
      
6. Запустить сервис мониторинга:  
    sudo systemctl start Test-Monitoring.Service
