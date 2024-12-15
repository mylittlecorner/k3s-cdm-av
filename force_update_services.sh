#!/bin/bash

# Usunięcie starych zasobów Kubernetes
echo "Usuwanie starych zasobów Kubernetes..."
sudo kubectl delete deployment access-verifier --ignore-not-found
sudo kubectl delete deployment cdm-service --ignore-not-found
sudo kubectl delete service access-verifier --ignore-not-found
sudo kubectl delete service cdm-service --ignore-not-found
sudo kubectl delete ingress my-ingress --ignore-not-found

# Usunięcie starych obrazów Docker
echo "Usuwanie starych obrazów Docker..."
sudo docker rmi local-access-verifier:latest --force
sudo docker rmi local-cdm-image:latest --force
sudo docker rmi your-docker-registry/access-verifier:latest --force
sudo docker rmi your-docker-registry/cdm-image:latest --force

# Uruchomienie lokalnego repozytorium Docker
echo "Uruchomienie lokalnego repozytorium Docker..."
sudo docker stop registry
sudo docker rm registry
sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Budowanie i wypychanie nowych obrazów Docker
echo "Budowanie i wypychanie nowych obrazów Docker..."
cd ./AV || exit
sudo docker build -t local-access-verifier:latest .
sudo docker tag local-access-verifier:latest localhost:5000/access-verifier:latest
sudo docker push localhost:5000/access-verifier:latest

cd ../CDM || exit
sudo docker build -t local-cdm-image:latest .
sudo docker tag local-cdm-image:latest localhost:5000/cdm-image:latest
sudo docker push localhost:5000/cdm-image:latest

# Zastosowanie zaktualizowanych plików deployment.yaml
echo "Zastosowanie zaktualizowanych plików deployment.yaml..."
kubectl apply -f ../AV/av-deployment.yaml
kubectl apply -f ../CDM/cdm-deployment.yaml
kubectl apply -f ../AV/av-service.yaml
kubectl apply -f ../CDM/cdm-service.yaml


# Sprawdzenie stanu podów
echo "Sprawdzanie stanu podów..."
kubectl get pods

echo "Aktualizacja mikroserwisów zakończona."
