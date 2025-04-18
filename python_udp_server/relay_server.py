from flask import Flask, request, jsonify
from flask_cors import CORS
import socket
import json
import time

app = Flask(__name__)
CORS(app)  # Allow all origins for development

UDP_IP = "192.168.29.80"  # Your machine's IP
UDP_PORT = 9999
TCP_IP = "192.168.29.80"  # Your machine's IP
TCP_PORT = 9998
MAX_RETRIES = 3
RETRY_DELAY = 1  # seconds

def try_tcp_connect(command):
    """Attempt TCP connection with retries"""
    for attempt in range(MAX_RETRIES):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((TCP_IP, TCP_PORT))
            sock.sendall(command.encode())
            response = sock.recv(1024).decode()
            sock.close()
            return response, None
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt < MAX_RETRIES - 1:
                time.sleep(RETRY_DELAY)
            else:
                return None, str(e)
    return None, "Max retries reached"

@app.route('/vote', methods=['POST'])
def vote():
    candidate = request.json.get('candidate')
    if not candidate:
        return {"status": "error", "message": "Candidate not provided"}, 400

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(candidate.encode(), (UDP_IP, UDP_PORT))
        sock.close()
        return {"status": "success", "message": f"Voted for {candidate}"}
    except Exception as e:
        print(f"Error sending vote: {e}")
        return {"status": "error", "message": "Failed to send vote"}, 500

@app.route('/results', methods=['GET'])
def get_results():
    response, error = try_tcp_connect("GET_VOTES")
    if response:
        try:
            votes = json.loads(response)
            return jsonify({"status": "success", "results": votes})
        except Exception as e:
            print(f"Error parsing results: {e}")
            return jsonify({"status": "error", "message": "Failed to parse results"}), 500
    else:
        print(f"Error fetching results: {error}")
        return jsonify({"status": "error", "message": f"Failed to fetch results: {error}"}), 500

@app.route('/add_candidate', methods=['POST'])
def add_candidate():
    candidate = request.json.get('candidate')
    if not candidate:
        return {"status": "error", "message": "Candidate not provided"}, 400

    response, error = try_tcp_connect(f"ADD_CANDIDATE:{candidate}")
    if response:
        if response == "OK":
            return {"status": "success", "message": f"Added candidate {candidate}"}
        else:
            return {"status": "error", "message": response}, 400
    else:
        print(f"Error adding candidate: {error}")
        return jsonify({"status": "error", "message": f"Failed to add candidate: {error}"}), 500

@app.route('/shutdown', methods=['POST'])
def shutdown():
    response, error = try_tcp_connect("SHUTDOWN")
    if response:
        if response == "OK":
            return {"status": "success", "message": "Server shutting down"}
        else:
            return {"status": "error", "message": "Failed to shutdown server"}, 500
    else:
        print(f"Error shutting down server: {error}")
        return jsonify({"status": "error", "message": f"Failed to shutdown server: {error}"}), 500

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)