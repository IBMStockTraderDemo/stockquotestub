#!/bin/bash

#
# Deactivate the stock quote service stb
# delete the stub from the cluster
#
kubectl apply -f stock-quote-svc.yaml
kubectl delete deploy quote-stub
