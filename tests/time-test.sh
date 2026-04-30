#!/bin/bash

# Пытаемся убить процесс на порту 3000, если он есть
kill $(lsof -ti:3000) 2>/dev/null || true
sleep 2

# Запускаем приложение в фоне
python app.py &
APP_PID=$!

# Ждём немного, чтобы сервер запустился
sleep 5

# Отправляем запрос и сохраняем ответ
response=$(curl -s http://localhost:3000/time)

# Проверяем, что ответ не пустой
if [ -z "$response" ]; then
  echo "FAIL: No response from server"
  kill $APP_PID 2>/dev/null
  exit 1
fi

# Извлекаем число после "time": ищем цифры
time_value=$(echo $response | grep -o '[0-9]\+' | head -1)

# Если не нашли число или оно равно 0 — ошибка
if [ -z "$time_value" ] || [ "$time_value" -eq 0 ]; then
  echo "FAIL: Invalid time value"
  kill $APP_PID 2>/dev/null
  exit 1
fi

echo "PASS: Got time $time_value"

# Останавливаем приложение
kill $APP_PID 2>/dev/null
