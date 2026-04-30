from flask import Flask, jsonify
import time

app = Flask(__name__)

# Счётчик запросов к /time
request_count = 0

@app.route('/time')
def get_time():
    global request_count
    request_count += 1
    current_time = int(time.time())
    return jsonify({"time": current_time})

@app.route('/metrics')
def get_metrics():
    return jsonify({"count": request_count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
