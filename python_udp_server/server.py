import socket
from collections import defaultdict

votes = defaultdict(int)
HOST = "0.0.0.0"
PORT = 9999

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((HOST, PORT))
print(f"UDP server started on {HOST}:{PORT}")

while True:
    data, addr = sock.recvfrom(1024)
    candidate = data.decode().strip()
    votes[candidate] += 1
    print(f"Received vote for: {candidate} from {addr}")
    print(f"Current Results: {dict(votes)}")
