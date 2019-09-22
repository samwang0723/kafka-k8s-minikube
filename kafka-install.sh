#!/bin/bash

echo "Create namespace \"kafka\""
kubectl apply -f deployment/00-namespace.yml

echo "Generate secrets from key-stores folder..."
kubectl create secret generic kafka-ssl --namespace=kafka \
	--from-file=./key-stores/certs

echo "Deploying zookeeper cluster..."
kubectl apply -f deployment/10-zookeeper-service.yml
kubectl apply -f deployment/11-zookeeper-service-headless.yml
kubectl apply -f deployment/12-zookeeper-statefulset.yml
kubectl apply -f deployment/13-zookeeper-disruptionbudget.yml

i=1
sp="/-\|"

echo "Wait until zookeeper cluster setup completed..."
while [[ $(kubectl get pods -l app=kafka-zookeeper --namespace=kafka -o 'jsonpath={.items[*].status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; 
do printf "\b${sp:i++%${#sp}:1}" && sleep 1; done

echo "Deploying kafka brokers..."
kubectl apply -f deployment/20-kafka-service.yml
kubectl apply -f deployment/21-kafka-headless.yml
kubectl apply -f deployment/22-kafka-statefulset.yml
kubectl apply -f deployment/23-kafka-load-balancer.yml

echo "Wait until broker pods and loadbalancer setup completed..."
while [[ $(kubectl get pods -l app=kafka --namespace=kafka -o 'jsonpath={.items[*].status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; 
do printf "\b${sp:i++%${#sp}:1}" && sleep 1; done

echo "Wait until test-client setup completed..."
kubectl apply -f deployment/30-kafka-test-client.yml

echo "Done"

# Make sure to update /etc/hosts for your minikube load balancer
# e.g. 192.168.99.107 kafka-broker-0.kafka.kafka.svc.cluster.local
