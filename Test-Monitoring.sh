#!/bin/bash

# Переменные:

PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/Monitoring.log"
PID_FILE="/var/run/test.pid"
DAEMON_PID_FILE="/var/run/Test-Monitoring.pid"
SLEEP_INT=60


# Функции:

# 1. Функция записи в лог
log_message() {
    echo "[$(date '+%d-%m-%Y %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 2. Функция для завершения работы демона
daemon_down() {
    log_message "Демон мониторинга завершает работу"
    rm -f "$DAEMON_PID_FILE"
    exit 0
}


# Перехват сигналов завершения (обработка сигналов завершения)
trap daemon_down SIGTERM SIGINT

# Создание PID файл демона
echo $$ > "$DAEMON_PID_FILE"

log_message "Демон мониторинга запущен"



# Основной цикл демона
while true; do
    # Проверяем, запущен ли процесс
    if pgrep -x "$PROCESS_NAME" > /dev/null; then
        CURRENT_PID=$(pgrep -x "$PROCESS_NAME" | head -n1)

        # Проверяем, был ли процесс перезапущен
        if [ -f "$PID_FILE" ]; then
            OLD_PID=$(cat "$PID_FILE")
            if [ "$OLD_PID" != "$CURRENT_PID" ] && [ "$OLD_PID" != "" ]; then
                log_message "Процесс $PROCESS_NAME перезапущен. Старый PID: $OLD_PID, Новый PID: $CURRENT_PID"
            fi
        else
            # Первый запуск после старта демона ($PID_FILE ещё не был создан)
            log_message "Процесс $PROCESS_NAME запущен. PID: $CURRENT_PID"
        fi

        # Сохраняем текущий PID
        echo "$CURRENT_PID" > "$PID_FILE"

        # Отправляем запрос на сервер мониторинга
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
                   --connect-timeout 10 \
                   --max-time 30 \
                   --retry 0 \
                   "$MONITORING_URL" 2>/dev/null)

        # Проверяем ответ от сервера
        if [ -z "$RESPONSE" ] || [ "$RESPONSE" != "200" ]; then
            log_message "Сервер мониторинга недоступен. Код ответа: $RESPONSE"
        fi
    else
        # Процесс не запущен - очищаем PID файл
        if [ -f "$PID_FILE" ]; then
            rm -f "$PID_FILE"
        fi
    fi

    # Ждем заданный интервал
    sleep $SLEEP_INT
done
