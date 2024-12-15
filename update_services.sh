#!/bin/bash

# Funkcja sprawdzająca, czy Deployment istnieje
function restart_deployment_if_exists {
  local deployment_name=$1
  if kubectl get deployment $deployment_name > /dev/null 2>&1; then
    kubectl rollout restart deployment/$deployment_name
  else
    echo "Deployment $deployment_name nie istnieje, pomijanie restartu."
  fi
}

# Aktualizacja mikroserwisu Access Verifier (AV)
echo "Aktualizacja Access Verifier..."
cd ./AV || exit
sudo docker build -t local-access-verifier:latest .
sudo docker tag local-access-verifier:latest localhost:5000/access-verifier:latest
sudo docker push localhost:5000/access-verifier:latest
restart_deployment_if_exists "access-verifier"

# Aktualizacja mikroserwisu Client Data Manager (CDM)
echo "Aktualizacja Client Data Manager..."
cd ../CDM || exit
sudo docker build -t local-cdm-image:latest .
sudo docker tag local-cdm-image:latest localhost:5000/cdm-image:latest
sudo docker push localhost:5000/cdm-image:latest
restart_deployment_if_exists "cdm-service"

echo "Aktualizacja mikroserwisów zakończona."
