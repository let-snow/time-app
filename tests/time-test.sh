#!/bin/bash

set -e

# Запускаем приложение в фоне
python app.py &
APP_PID=$!

# Ждём, пока сервер запустится
sleep 3

# Тестируем роут /time
echo "Testing /time endpoint..."
response=$(curl -s http://localhost:3000/time)

# Проверяем, что ответ не пустой
if [ -z "$response" ]; then
  echo "FAIL: Empty response from /time"
  kill $APP_PID
  exit 1
fi

# Парсим JSON и проверяем, что time — целое число > 0
time_value=$(echo $response | grep -o '"time":[0-9]*' | cut -d: -f2)

if ! [[ "$time_value" =~ ^[0-9]+$ ]] || [ "$time_value" -eq 0 ]; then
  echo "FAIL: Invalid time value: $time_value"
  kill $APP_PID
  exit 1
fi

echo "PASS: /time returns valid Unix timestamp ($time_value)"

# Останавливаем приложение
kill $APP_PID
wait $APP_PID 2>/dev/null || true

echo "All tests passed!"
