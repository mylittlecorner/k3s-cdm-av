#!/bin/bash

# Pobieranie nazwy poda cdm-service
cdm_pod=$(kubectl get pod -l app=cdm -o jsonpath="{.items[0].metadata.name}" -n default)

# Wejście do powłoki poda cdm-service
kubectl exec -it $cdm_pod -n default -- /bin/sh
