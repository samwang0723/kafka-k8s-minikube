#!/bin/bash

echo "Create namespace \"kafka\""
kubectl create namespace kafka

echo "Generate secrets from key-stores folder..."
kubectl create secret generic kafka-ssl --namespace=kafka \
	--from-file=./key-stores/certs

echo "Deploy RBAC for tiller"
kubectl apply -f kafka/templates/01-rbac-config.yml

echo "Install tiller into k8s cluster"
helm init --service-account tiller --skip-refresh

echo "Check helm version"
helm version

echo "Update chart repo"
helm repo update


