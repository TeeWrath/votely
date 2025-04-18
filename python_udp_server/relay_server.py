from flask import Flask, request, jsonify
from flask_cors import CORS
import socket
import json

app = Flask(__name__)
CORS(app)  # Allow all origins for development

UDP_IP = "127.0.0.1"
UDP_PORT = 9999
TCP_IP = "127.0.0.1"
TCP_PORT = 9998

@app.route('/vote', methods=['POST'])
def vote():
    candidate = request.json.get('candidate')
    if not candidate:
        return {"status": "error", "message": "Candidate not provided"}, 400

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(candidate.encode(), (UDP_IP, UDP_PORT))
    return {"status": "success", "message": f"Voted for {candidate}"}

@app.route('/results', methods=['GET'])
def get_results():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((TCP_IP, TCP_PORT))
        sock.sendall("GET_VOTES".encode())
        data = sock.recv(1024).decode()
        votes = json.loads(data)
        sock.close()
        return jsonify({"status": "success", "results": votes})
    except Exception as e:
        print(f"Error fetching results: {e}")
        return jsonify({"status": "error", "message": "Failed to fetch results"}), 500

if __name__ == '__main__':
    app.run(port=5000, debug=True)