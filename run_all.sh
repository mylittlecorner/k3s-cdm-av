#!/bin/bash

# Uruchomienie force_update_services.sh
echo "Running force_update_services.sh..."
./force_update_services.sh

# Uruchomienie ingress.sh
echo "Running ingress.sh..."
./ingress.sh

# Uruchomienie simple_tests.sh
echo "Running simple_tests.sh..."
./simple_tests.sh

echo "All scripts executed successfully!"
