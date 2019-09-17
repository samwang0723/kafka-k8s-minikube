#!/bin/bash

kubectl apply -f deployment/kafka-namespace.yml
kubectl apply -f deployment/zookeeper-deployment.yml
kubectl apply -f deployment/zookeeper-service.yml
kubectl apply -f deployment/kafka-broker.yml

# Make sure to update /etc/hosts for your minikube load balancer
# e.g. 192.168.99.107 kafka-0.kafka.kafka.svc.cluster.local
