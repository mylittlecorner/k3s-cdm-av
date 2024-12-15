import requests
import logging
from flask import Flask, request, jsonify

app = Flask(__name__)

ACCESS_VERIFIER_URL = 'http://access-verifier:3001/verify'

# Konfiguracja logowania
logging.basicConfig(filename='client_data_manager.log', level=logging.INFO)

customers = {}

def forward_request_to_verifier(headers):
    headers_dict = dict(headers)
    client_ip = request.remote_addr  # Rzeczywisty adres IP klienta
    if 'X-Forwarded-For' in headers_dict:
        headers_dict['X-Forwarded-For'] = f"{headers_dict['X-Forwarded-For']}, {client_ip}"
    else:
        headers_dict['X-Forwarded-For'] = client_ip  # Dodajemy nagłówek X-Forwarded-For

    logging.info(f"Forwarding client IP: {client_ip}")  # Logowanie przesyłanego adresu IP
    logging.info(f"Headers sent to Access Verifier: {headers_dict}")  # Logowanie wszystkich nagłówków

    # Przesyłanie nagłówków jako text/plain z dodaniem tekstu EXAMPLE do zawartości
    response = requests.post(ACCESS_VERIFIER_URL, data=str(headers_dict) + "EXAMPLE", headers={**headers_dict, 'Content-Type': 'text/plain'})
    return response.status_code == 200

@app.route('/customers', methods=['POST'])
def add_customer():
    if not forward_request_to_verifier(request.headers):
        return "Unauthorized", 401
    
    try:
        customer_id = request.json.get('id')
        name = request.json.get('name')
        email = request.json.get('email')
        if customer_id in customers:
            return jsonify({'error': 'Customer already exists'}), 400
        customers[customer_id] = {'name': name, 'email': email}
        return jsonify({'message': 'Customer added successfully'}), 201
    except Exception as e:
        logging.error(f"Error adding customer: {str(e)}")
        return "Internal Server Error", 500

@app.route('/customers', methods=['GET'])
def get_customers():
    if not forward_request_to_verifier(request.headers):
        return "Unauthorized", 401

    try:
        return jsonify(customers)
    except Exception as e:
        logging.error(f"Error fetching customers: {str(e)}")
        return "Internal Server Error", 500

@app.route('/customers/<customer_id>', methods=['DELETE'])
def delete_customer(customer_id):
    if not forward_request_to_verifier(request.headers):
        return "Unauthorized", 401

    try:
        if customer_id not in customers:
            return jsonify({'error': 'Customer not found'}), 404
        del customers[customer_id]
        return jsonify({'message': 'Customer deleted successfully'}), 200
    except Exception as e:
        logging.error(f"Error deleting customer: {str(e)}")
        return "Internal Server Error", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3002)
