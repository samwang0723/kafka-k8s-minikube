## Getting Started

Make sure VirtualBox VM is installed https://download.virtualbox.org/virtualbox/6.0.12/VirtualBox-6.0.12-133076-OSX.dmg 
Execute the minikube install script (do note that tested with MacbookPro 2018 2.6 GHz 16GB mem, still requires the VM to set by default with 6144 memory and 4 cpus)
	
	./minikube-install.sh

## Generate SSL certificates

Under key-stores folder 

	./gen-ssl-certs.sh ca ca-cert kafka.example.com
	./gen-ssl-certs.sh -k server ca-cert kafka. kafka.example.com
	./gen-ssl-certs.sh -k client ca-cert kafka. kafka.example.com

## Install Kafka Cluster

In the development folder we already helped to configure 1 zookeeper and 2 broker pods, you can adjust them to fit your actual requirements.
Especially in the broker service configuration, we use LoadBalancer to pointing to each broker pod, in realworld you may not want to do this but use Ingress or NodePort instead.

	./kafka-install.sh

## Test Your Kafka

*kafkacat* has been installed when you execute the minikube script, we can use this cli to test if things are setup properly

	kafkacat -L -b kafka.example.com:9000

If using SSL

	kafkacat -L -b kafka.example.com:9000 -X security.protocol=SSL -X ssl.certificate.location=client_cert.pem -X ssl.key.location=client_key.pem -X ssl.key.password=test1234 -X ssl.ca.location=ca_cert.pem

### Create Topic in Cluster

	kubectl -n kafka exec kafka-test-client -- \
	/usr/bin/kafka-topics --zookeeper kafka-zookeeper:2181 --create --topic sample-test --partitions 1 --replication-factor 1

### List Topics in Cluster

	kubectl -n kafka exec kafka-test-client -- \
	/usr/bin/kafka-topics --zookeeper kafka-zookeeper:2181 --list

### Monitoring as Consumer

In Cluster

	kubectl -n kafka exec kafka-test-client -- \
	/usr/bin/kafka-console-consumer --bootstrap-server kafka:9093 --topic sample-test --from-beginning

Kafkacat

	kafkacat -b kafka.example.com:9000 -t {topic}

### Send as Producer

	cat {text-file} | kafkacat -b kafka.example.com:9000 -t {topic}

### DNS Configure

Make sure to modify your */etc/hosts* and add minikube exposed IP address with the hostname.
	
	{minikube_ip} kafka.example.com

## Uninstall 

You can simply remove all setup kubernetes instances by running

	./kafka-uninstall.sh

and if you want a fresh environment, please delete minikube and restart one

	minikube delete

## Installing with helm-chart

With better and easier configuration change we can have better control on the release 
and rollback using helm-chart, and because of the deployment will comes with sequence, 
we need to execute zookeeper to be ready first, then broker and client.

To have one script execution can simply apply

	./kafka-install-helm.sh

Or you can choose to manual install by using helm console, but make sure to create the 
namespace and secrets beforehand.

	helm install --name {release_name} --namespace kafka kafka/charts/kafka-broker

View the deployment status by using:
	
	helm status {release_name}

Remove the release

	helm delete --purge {release_name}

There are also a confluentinc version, please check https://github.com/confluentinc/cp-helm-charts

