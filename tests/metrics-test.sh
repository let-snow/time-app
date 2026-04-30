#!/bin/bash

# Убиваем процесс на порту 3000, если есть
kill $(lsof -ti:3000) 2>/dev/null || true
sleep 2

# Запускаем приложение в фоне
python app.py &
APP_PID=$!

# Ждём запуска сервера
sleep 5

# Сначала получаем начальные метрики
initial_metrics=$(curl -s http://localhost:3000/metrics)
initial_count=$(echo $initial_metrics | grep -o '"count":[0-9]*' | cut -d: -f2)

# Отправляем 3 запроса к /time для увеличения счётчика
for i in {1..3}; do
    curl -s http://localhost:3000/time > /dev/null
done

# Получаем обновлённые метрики
updated_metrics=$(curl -s http://localhost:3000/metrics)
updated_count=$(echo $updated_metrics | grep -o '"count":[0-9]*' | cut -d: -f2)

# Проверяем, что счётчик увеличился на 3
expected_count=$((initial_count + 3))

if [ "$updated_count" -eq "$expected_count" ]; then
    echo "PASS: /metrics returns correct count ($updated_count)"
else
    echo "FAIL: /metrics count mismatch. Expected $expected_count, got $updated_count"
    kill $APP_PID 2>/dev/null
    exit 1
fi

# Останавливаем приложение
kill $APP_PID 2>/dev/null
