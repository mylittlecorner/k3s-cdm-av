#!/bin/bash

# Funkcja testująca endpoint
test_endpoint() {
    url=$1
    expected_status=$2
    method=$3
    headers=$4
    data=$5

    # Wysyłanie żądania HTTP
    response=$(curl -s -o /dev/null -w "%{http_code}" -X $method $url -H "Content-Type: $headers" -d "$data")

    # Sprawdzanie statusu odpowiedzi
    if [ "$response" -eq "$expected_status" ]; then
        echo "Test $url OK"
    else
        echo "Test $url FAILED - Status code: $response"
    fi
}

# Testowanie Client Data Manager

echo "Dodawanie klienta - powinno zwrócić 201 Created"
test_endpoint "http://localhost/customers" 201 "POST" "application/json" "{\"id\":\"123\", \"name\":\"John Doe\", \"email\":\"john.doe@example.com\"}"

echo "Pobieranie listy klientów - powinno zwrócić 200 OK"
test_endpoint "http://localhost/customers" 200 "GET" "application/json" ""

echo "Usuwanie klienta - powinno zwrócić 200 OK"
test_endpoint "http://localhost/customers/123" 200 "DELETE" "application/json" ""

echo "Wszystkie testy jednostkowe zakończone."

# Instalacja curl, pobieranie logów nieautoryzowanych adresów IP i pozostanie w podzie
#kubectl exec -it $(kubectl get pod -l app=access-verifier -o jsonpath="{.items[0].metadata.name}") -n default -- sh -c "apt-get update && apt-get install -y curl && cat unauthorized_ips.log && exec sh"
# curl -X POST http://localhost:3001/add_ip -H "Content-Type: application/json" -d '{"ip": "10.42.0.66"}'