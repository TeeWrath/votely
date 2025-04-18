import socket
from collections import defaultdict
import threading
import json
import os
import signal
import sys

votes = defaultdict(int)
HOST = "0.0.0.0"
UDP_PORT = 9999
TCP_PORT = 9998
running = True  # Flag to control server shutdown

def save_votes():
    """Thread-safe saving of votes to totalvotes.json"""
    with threading.Lock():
        with open("totalvotes.json", "w") as f:
            json.dump(dict(votes), f, indent=4)

def udp_server():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind((HOST, UDP_PORT))
        print(f"UDP server started on {HOST}:{UDP_PORT}")
        while running:
            try:
                sock.settimeout(1.0)  # Timeout to check running flag
                data, addr = sock.recvfrom(1024)
                candidate = data.decode().strip()
                votes[candidate] += 1
                print(f"Received vote for: {candidate} from {addr}")
                print(f"Current Results: {dict(votes)}")
                save_votes()  # Save votes after each vote
            except socket.timeout:
                continue
            except Exception as e:
                print(f"UDP server error: {e}")
    except Exception as e:
        print(f"Failed to start UDP server: {e}")
    finally:
        sock.close()
        print("UDP server stopped")

def tcp_server():
    global running  # Declare global at the start of the function
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((HOST, TCP_PORT))
        sock.listen(5)  # Increased queue size for multiple clients
        print(f"TCP server started on {HOST}:{TCP_PORT}")
        while running:
            try:
                sock.settimeout(1.0)  # Timeout to check running flag
                conn, addr = sock.accept()
                with conn:
                    data = conn.recv(1024).decode().strip()
                    if data == "GET_VOTES":
                        conn.sendall(json.dumps(dict(votes)).encode())
                    elif data.startswith("ADD_CANDIDATE:"):
                        candidate = data.split(":", 1)[1].strip()
                        if candidate and candidate not in votes:
                            votes[candidate] = 0  # Initialize vote count
                            save_votes()
                            conn.sendall(b"OK")
                        else:
                            conn.sendall(b"ERROR: Candidate exists or invalid")
                    elif data == "SHUTDOWN":
                        running = False
                        conn.sendall(b"OK")
                        print("Shutdown signal received")
                    print(f"Served request to {addr}")
            except socket.timeout:
                continue
            except Exception as e:
                print(f"TCP server error: {e}")
    except Exception as e:
        print(f"Failed to start TCP server: {e}")
    finally:
        sock.close()
        print("TCP server stopped")

if __name__ == "__main__":
    # Initialize totalvotes.json if it doesn't exist
    if not os.path.exists("totalvotes.json"):
        save_votes()
    
    udp_thread = threading.Thread(target=udp_server)
    tcp_thread = threading.Thread(target=tcp_server)
    udp_thread.daemon = True
    tcp_thread.daemon = True
    udp_thread.start()
    tcp_thread.start()
    
    try:
        udp_thread.join()  # Keep main thread running
    except KeyboardInterrupt:
        print("Shutting down server...")
        running = False
        sys.exit(0)