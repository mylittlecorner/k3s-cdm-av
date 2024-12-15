#!/bin/bash
docker build -t your-docker-registry/access-verifier:latest .
kubectl apply -f av-deployment.yaml
kubectl apply -f av-service.yaml
