from flask import Flask, request, jsonify
import logging
from apscheduler.schedulers.background import BackgroundScheduler

app = Flask(__name__)

# Konfiguracja logowania
logging.basicConfig(filename='unauthorized_ips.log', level=logging.WARNING)

# Stała lista dozwolonych adresów IP dla celów testowych
allowed_ips = {
    "192.168.0.1",   # Przykładowy dozwolony adres IP
    "10.0.0.1",      # Inny przykładowy dozwolony adres IP
    "192.168.223.128",
    "127.0.0.1",
    "10.42.0.7"
}

# Lista zaktualizowanych adresów IP
updated_ips = allowed_ips.copy()

# Funkcja do odświeżania adresów IP raz na dobę
def refresh_ips():
    global updated_ips
    updated_ips = allowed_ips.copy()
    logging.info("IP addresses refreshed")

# Scheduler do odświeżania adresów IP raz na dobę
scheduler = BackgroundScheduler()
scheduler.add_job(func=refresh_ips, trigger="interval", hours=24)
scheduler.start()

# Endpoint do ręcznego odświeżania adresów IP (symulacja)
@app.route('/refresh', methods=['POST'])
def manual_refresh_ips():
    refresh_ips()
    return jsonify({'message': 'IP addresses refreshed manually', 'updated_ips': list(updated_ips)}), 200

# Endpoint do dodawania nowego adresu IP
@app.route('/add_ip', methods=['POST'])
def add_ip():
    new_ip = request.json.get('ip')
    if new_ip:
        allowed_ips.add(new_ip)
        refresh_ips()  # Aktualizacja listy updated_ips
        return jsonify({'message': f'IP address {new_ip} added', 'updated_ips': list(updated_ips)}), 200
    return jsonify({'error': 'No IP address provided'}), 400

# Endpoint do sprawdzania adresów IP
@app.route('/verify', methods=['POST'])
def verify_access():
    headers = dict(request.headers)  # Pobieranie nagłówków HTTP jako słownik
    logging.warning(f"Received headers: {headers}")  # Logowanie otrzymanych nagłówków

    client_ip = headers.get('X-Forwarded-For')
    if client_ip:
        # Pobieramy pierwszy adres IP z listy
        client_ip = client_ip.split(',')[0].strip()
        if client_ip in updated_ips:
            return "OK", 200

    # Logowanie nieautoryzowanych adresów IP
    logging.warning(f"Unauthorized access attempt from IP: {client_ip}")
    return "Unauthorized", 401

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001)
