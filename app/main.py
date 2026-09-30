from flask import Flask, jsonify

app = Flask(__name__)

def compute_square(n):
    return n * n

@app.route("/")
def hello():
    return jsonify({"message": "Hello, World!"})

@app.route("/healthz")
def healthz():
    return jsonify({"status": "OK"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
