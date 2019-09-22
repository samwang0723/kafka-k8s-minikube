#!/bin/bash
echo "Deleting all resources"
kubectl delete --all services,deployments,pods,statefulsets,rc,poddisruptionbudget,secrets --namespace=kafka
kubectl delete namespaces kafka
echo "Done"
