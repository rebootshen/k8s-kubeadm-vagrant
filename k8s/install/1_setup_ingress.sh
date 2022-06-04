#!/bin/sh
set -x

# enlarge memory of macbook docker desktop to 10G
# kind delete cluster
# kind get clusters
cd ../ingress
kubectl label nodes master ingress-ready=true

kubectl apply -f ingress-nginx-deploy-DaemonSet-best.yaml
kubectl apply -f coredns.yaml
kubectl apply -f dnsutils.yaml

kubectl apply -f demo-deploy.yaml
kubectl apply -f demo-service.yaml
kubectl apply -f demo-ingress.yaml

kubectl apply -f example-deploy-service.yaml
kubectl apply -f example-ingress.yaml
 
cat /etc/hosts
#192.168.8.121 gitlab.rebootshen.com
#192.168.8.121 rancher.rebootshen.com
