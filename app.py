from flask import Flask, jsonify
import time

app = Flask(__name__)

@app.route('/time')
def get_time():
    current_time = int(time.time())
    return jsonify({"time": current_time})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
