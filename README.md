Instalacja Docker i K3s:
Zainstaluj Docker:
```
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io && sudo systemctl start docker && sudo systemctl enable docker
```
Zainstaluj Kubernetes (kubeadm, kubelet, kubectl): // POPRAWKA k3s
```
sudo curl -sfL https://get.k3s.io | sudo sh - && sudo kubectl create deployment nginx --image=nginx && sudo kubectl expose deployment nginx --port=80 --type=NodePort && sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/k3s/deploy.yaml && sudo kubectl get nodes && sudo kubectl get pods --all-namespaces && sudo kubectl get svc -n ingress-nginx && sudo kubectl get pods && sudo kubectl get svc
```

Skonfiguruj kubectl
```
mkdir -p $HOME/.kube && sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Jak obsługiwać program i czego można oczekiwać
Opis programu
```
Program ten składa się z dwóch głównych komponentów: Client Data Manager (CDM) oraz Access Verifier (AV). CDM zarządza operacjami CRUD (Create, Read, Update, Delete) dla klientów, natomiast AV weryfikuje autoryzację żądań na podstawie adresów IP.
```
Funkcje i oczekiwane działanie
```
Dodawanie klienta (POST /customers):

Klient wysyła żądanie HTTP POST z danymi nowego klienta do CDM.

CDM przekazuje nagłówki HTTP do AV w celu weryfikacji autoryzacji.

Jeśli AV zwróci odpowiedź 200 OK, CDM dodaje nowego klienta do swojej bazy danych i zwraca odpowiedź 201 Created.

Jeśli AV zwróci odpowiedź 401 Unauthorized, CDM odrzuca żądanie i zwraca odpowiedź 401 Unauthorized.
```
Pobieranie listy klientów (GET /customers):
```
Klient wysyła żądanie HTTP GET do CDM.

CDM przekazuje nagłówki HTTP do AV w celu weryfikacji autoryzacji.

Jeśli AV zwróci odpowiedź 200 OK, CDM zwraca listę klientów.

Jeśli AV zwróci odpowiedź 401 Unauthorized, CDM odrzuca żądanie i zwraca odpowiedź 401 Unauthorized.
```
Usuwanie klienta (DELETE /customers/<customer_id>):
```
Klient wysyła żądanie HTTP DELETE z identyfikatorem klienta do CDM.

CDM przekazuje nagłówki HTTP do AV w celu weryfikacji autoryzacji.

Jeśli AV zwróci odpowiedź 200 OK, CDM usuwa klienta z bazy danych i zwraca odpowiedź 200 OK.

Jeśli AV zwróci odpowiedź 401 Unauthorized, CDM odrzuca żądanie i zwraca odpowiedź 401 Unauthorized.
```
Instrukcje obsługi programu
Uruchomienie aplikacji:
```
Upewnij się, że masz zainstalowane Docker i Kubernetes (k3s) zgodnie z instrukcjami w sekcji Instalacja w pliku README.md.

Skopiuj plik config do katalogu .kube, aby skonfigurować kubectl.

Uruchom aplikację przy użyciu skryptów shellowych (cdm-shell.sh, access-verifier-shell.sh, run_all.sh).
```
Testowanie:
```
Użyj skryptów simple_tests.sh do uruchomienia prostych testów funkcjonalnych i upewnij się, że aplikacja działa poprawnie.

Przeprowadź testy, wysyłając odpowiednie żądania HTTP do endpointów aplikacji (POST /customers, GET /customers, DELETE /customers/<customer_id>).
```
Monitorowanie i logowanie:
```
Sprawdzaj logi w plikach client_data_manager.log oraz unauthorized_ips.log, aby monitorować działanie aplikacji i weryfikację autoryzacji.

Upewnij się, że wszystkie operacje są rejestrowane i sprawdzaj ewentualne błędy w logach.

Aktualizacja i zarządzanie:

Używaj skryptu force_update_services.sh, aby wymusić aktualizację wszystkich usług.

Używaj skryptu ingress.sh, aby skonfigurować Ingress Controller i zarządzać ruchem do usług uruchomionych w klastrze Kubernetes.

Używaj skryptu run_all.sh, aby zautomatyzować procesy aktualizacji, konfiguracji i testowania za jednym razem.
```
Access Verifier (AV) - app.py
Opis: Plik app.py dla Access Verifiera zarządza weryfikacją adresów IP i autoryzacją żądań HTTP. Główne zadania obejmują odbieranie żądań weryfikacyjnych, sprawdzanie adresów IP i zarządzanie listą dozwolonych adresów IP.

Funkcje:

verify_access:

Odbiera żądania POST i sprawdza nagłówki HTTP, szczególnie X-Forwarded-For, aby zweryfikować adres IP.

Zwraca odpowiedź 200 OK, jeśli adres IP znajduje się na liście dozwolonych, lub 401 Unauthorized, jeśli nie.

refresh_ips:

Odświeża listę dozwolonych adresów IP, kopiując zawartość stałej listy allowed_ips do updated_ips.

Jest uruchamiana raz na dobę za pomocą planera zadań apscheduler.

manual_refresh_ips:

Endpoint POST umożliwiający ręczne odświeżanie listy dozwolonych adresów IP.

add_ip:

Endpoint POST umożliwiający dodawanie nowych adresów IP do listy dozwolonych.

Endpointy:

/verify: Weryfikacja autoryzacji żądań.

/refresh: Ręczne odświeżanie listy dozwolonych adresów IP.

/add_ip: Dodawanie nowych adresów IP do listy dozwolonych.

Client Data Manager (CDM) - app.py
Opis: Plik app.py dla Client Data Managera zarządza operacjami CRUD dla klientów. Przed wykonaniem operacji, CDM weryfikuje autoryzację żądania za pomocą Access Verifiera.

Funkcje:

forward_request_to_verifier:

Przekazuje nagłówki HTTP do Access Verifiera w celu weryfikacji autoryzacji.

Dodaje nagłówek X-Forwarded-For z adresem IP klienta.

add_customer:

Endpoint POST dodający nowego klienta do bazy danych.

Przed dodaniem klienta, CDM weryfikuje autoryzację żądania za pomocą Access Verifiera.

get_customers:

Endpoint GET zwracający listę klientów z bazy danych.

Przed zwróceniem listy klientów, CDM weryfikuje autoryzację żądania za pomocą Access Verifiera.

delete_customer:

Endpoint DELETE usuwający klienta z bazy danych na podstawie identyfikatora klienta.

Przed usunięciem klienta, CDM weryfikuje autoryzację żądania za pomocą Access Verifiera.

Endpointy:

/customers: Obsługuje dodawanie klientów (POST) oraz pobieranie listy klientów (GET).

/customers/<customer_id>: Obsługuje usuwanie klientów (DELETE).

Podsumowanie
Access Verifier (AV): Odpowiada za weryfikację adresów IP i autoryzację żądań HTTP. Zarządza listą dozwolonych adresów IP i obsługuje żądania weryfikacyjne.

Client Data Manager (CDM): Zarządza operacjami CRUD dla klientów. Przekazuje nagłówki HTTP do AV w celu weryfikacji autoryzacji przed wykonaniem operacji.
