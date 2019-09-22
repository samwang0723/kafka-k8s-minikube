#!/bin/bash
echo "Detection of VMX support"
sysctl -a | grep -E --color 'machdep.cpu.features|VMX' 

echo "Install kubernetes-cli through Homebrew"
brew install kubernetes-cli
kubectl version

echo "Plesae have VirtualBox installed. https://download.virtualbox.org/virtualbox/6.0.12/VirtualBox-6.0.12-133076-OSX.dmg "

echo "Installing minikube ..."
brew cask install minikube

echo "Starting minikube"
minikube start --memory=6144 --cpus=4
minikube addons enable ingress
# minikube delete

echo "Install kafkacat for testing ..."
brew install kafkacat
