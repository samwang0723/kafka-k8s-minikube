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
	
	192.168.99.107 kafka.example.com

## Uninstall 

You can simply remove all setup kubernetes instances by running

	./kafka-uninstall.sh

and if you want a fresh environment, please delete minikube and restart one

	minikube delete

