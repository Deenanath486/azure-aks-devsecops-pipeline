from flask import Flask, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import os
import socket

app = Flask(__name__)

REQUEST_COUNT = Counter('app_requests_total', 'Total HTTP Requests', ['endpoint'])

@app.route('/')
def home():
    REQUEST_COUNT.labels(endpoint='/').inc()
    return jsonify({
        "status": "online",
        "service": "azure-aks-devsecops-demo",
        "hostname": socket.gethostname(),
        "environment": os.getenv("ENVIRONMENT", "production"),
        "version": "1.0.0"
    }), 200

@app.route('/healthz')
def healthz():
    REQUEST_COUNT.labels(endpoint='/healthz').inc()
    return jsonify({"status": "healthy"}), 200

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
