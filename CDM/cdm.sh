#!/bin/bash
docker build -t your-docker-registry/cdm-image:latest .
kubectl apply -f cdm-deplyoment.yaml
kubectl apply -f cdm-service.yaml
