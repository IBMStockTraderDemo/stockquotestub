#!/bin/bash

#
# Deactivate the stock quote service stb
# delete the stub deom the cluster
#
kubectl apply -f stock-quote-svc-ocp.yaml
