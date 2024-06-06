#!/bin/bash

# Параметры
LOCKFILE="/Users/admin/otus/13.BASH/web_report.lock"
LOG_FILE="/Users/admin/otus/13.BASH/access.log"
ERROR_LOG_FILE="/Users/admin/otus/13.BASH/error.log"
LAST_RUN_FILE="/Users/admin/otus/13.BASH/web_report_last_run"
TEMP_FILE="/Users/admin/otus/13.BASH/temp"
EMAIL="your-email@example.com"
SUBJECT="Hourly Web Server Report"

# Проверка блокировки
if [ -e $LOCKFILE ]; then
    echo "Script is already running."
    exit 1
fi

# Создание блокировки
touch $LOCKFILE

# Текущая дата и время
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
LAST_RUN_TIME=$(cat $LAST_RUN_FILE 2>/dev/null || date -d "1 hour ago" +"%Y-%m-%d %H:%M:%S")

# Обновление времени последнего запуска
echo $CURRENT_TIME > $LAST_RUN_FILE

# Анализ логов
TEMP_FILE=$(mktemp)

# Список IP адресов с наибольшим количеством запросов
echo "IP Addresses with Most Requests since $LAST_RUN_TIME:" >> $TEMP_FILE
awk -v last_run_time="$LAST_RUN_TIME" '$4" "$5 >= "["last_run_time' $LOG_FILE | awk '{print $1}' | sort | uniq -c | sort -nr | head -10 >> $TEMP_FILE
echo "" >> $TEMP_FILE

# Список запрашиваемых URL с наибольшим количеством запросов
echo "Most Requested URLs since $LAST_RUN_TIME:" >> $TEMP_FILE
awk -v last_run_time="$LAST_RUN_TIME" '$4" "$5 >= "["last_run_time' $LOG_FILE | awk '{print $7}' | sort | uniq -c | sort -nr | head -10 >> $TEMP_FILE
echo "" >> $TEMP_FILE

# Ошибки веб-сервера/приложения
echo "Web Server/Application Errors since $LAST_RUN_TIME:" >> $TEMP_FILE
awk -v last_run_time="$LAST_RUN_TIME" '$4" "$5 >= "["last_run_time' $ERROR_LOG_FILE | grep -i "error" >> $TEMP_FILE
echo "" >> $TEMP_FILE

# Список всех кодов HTTP ответа с указанием их количества
echo "HTTP Response Codes since $LAST_RUN_TIME:" >> $TEMP_FILE
awk -v last_run_time="$LAST_RUN_TIME" '$4" "$5 >= "["last_run_time' $LOG_FILE | awk '{print $9}' | sort | uniq -c | sort -nr >> $TEMP_FILE

# Отправка письма
mail -s "$SUBJECT" $EMAIL < $TEMP_FILE

# Удаление временных файлов
rm $TEMP_FILE
rm $LOCKFILE
