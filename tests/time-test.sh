#!/bin/bash

set -e

# Функция очистки: убивает процесс и ждёт его завершения
cleanup() {
    echo "Cleaning up..."
    if [ -n "$APP_PID" ] && kill -0 $APP_PID 2>/dev/null; then
        kill $APP_PID || true
        wait $APP_PID 2>/dev/null || true
    fi
}

# Обработчик прерываний
trap cleanup EXIT

# Проверяем, свободен ли порт 3000
if nc -z localhost 3000; then
    echo "FAIL: Port 3000 is already in use"
    exit 1
fi

# Запускаем приложение в фоне
python app.py &
APP_PID=$!

# Ждём, пока сервер запустится
sleep 5

# Тестируем роут /time
echo "Testing /time endpoint..."
response=$(curl -s http://localhost:3000/time)

# Проверяем, что ответ не пустой
if [ -z "$response" ]; then
    echo "FAIL: Empty response from /time"
    exit 1
fi

# Парсим JSON с помощью jq (более надёжный способ)
if ! command -v jq &> /dev/null; then
    echo "FAIL: jq is not installed. Please install jq for JSON parsing."
    exit 1
fi

time_value=$(echo "$response" | jq -r '.time')

# Проверяем, что time — целое число > 0
if ! [[ "$time_value" =~ ^[0-9]+$ ]] || [ "$time_value" -eq 0 ]; then
    echo "FAIL: Invalid time value: $time_value"
    exit 1
fi

echo "PASS: /time returns valid Unix timestamp ($time_value)"
