#!/bin/bash

#
# Deploy and actovate the stock quote virtual service stub
#
kubectl apply -f quote-stub-pod.yaml
kubectl apply -f quote-stub-svc.yaml