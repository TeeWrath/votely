import socket
from collections import defaultdict
import threading
import json

votes = defaultdict(int)
HOST = "0.0.0.0"
UDP_PORT = 9999
TCP_PORT = 9998  # New TCP port for sharing votes

def udp_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((HOST, UDP_PORT))
    print(f"UDP server started on {HOST}:{UDP_PORT}")
    while True:
        data, addr = sock.recvfrom(1024)
        candidate = data.decode().strip()
        votes[candidate] += 1
        print(f"Received vote for: {candidate} from {addr}")
        print(f"Current Results: {dict(votes)}")

def tcp_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((HOST, TCP_PORT))
    sock.listen(1)
    print(f"TCP server started on {HOST}:{TCP_PORT}")
    while True:
        conn, addr = sock.accept()
        with conn:
            data = conn.recv(1024).decode().strip()
            if data == "GET_VOTES":
                conn.sendall(json.dumps(dict(votes)).encode())
            print(f"Served vote results to {addr}")

if __name__ == "__main__":
    udp_thread = threading.Thread(target=udp_server)
    tcp_thread = threading.Thread(target=tcp_server)
    udp_thread.daemon = True
    tcp_thread.daemon = True
    udp_thread.start()
    tcp_thread.start()
    udp_thread.join()  # Keep the main thread running