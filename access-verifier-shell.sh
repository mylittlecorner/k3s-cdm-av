#!/bin/bash

# Pobieranie nazwy poda access-verifier
access_verifier_pod=$(kubectl get pod -l app=access-verifier -o jsonpath="{.items[0].metadata.name}" -n default)

# Wejście do powłoki poda access-verifier
kubectl exec -it $access_verifier_pod -n default -- /bin/sh
