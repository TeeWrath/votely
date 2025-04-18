from flask import Flask, request
from flask_cors import CORS
import socket

app = Flask(__name__)
CORS(app)  # <-- allow all origins for development

UDP_IP = "127.0.0.1"
UDP_PORT = 9999

@app.route('/vote', methods=['POST'])
def vote():
    candidate = request.json.get('candidate')
    if not candidate:
        return {"status": "error", "message": "Candidate not provided"}, 400

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(candidate.encode(), (UDP_IP, UDP_PORT))
    return {"status": "success", "message": f"Voted for {candidate}"}

if __name__ == '__main__':
    app.run(port=5000, debug=True)
