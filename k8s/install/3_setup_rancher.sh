#!/bin/sh
set -x

cd ../rancher

# install cert-manager
kubectl create namespace cert-manager
kubectl apply -f cert-manager.crds.yaml 

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.1
#if faiil
#helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.1

# install rancher
kubectl create namespace cattle-system
kubectl -n cattle-system create secret generic tls-ca --from-file=cacerts.pem

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm install rancher rancher-latest/rancher   --namespace cattle-system   --set hostname=rancher.rebootshen.com  --set bootstrapPassword=admin --set ingress.tls.source=secret --version 2.6.5  --create-namespace -f values.rancher.yaml

kubectl -n cattle-system rollout status deploy/rancher

kubectl config set-context --current --namespace cattle-system
kubectl get all

echo https://rancher.rebootshen.com/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
#https://rancher.rebootshen.com/dashboard/?setup=admin

# admin:admin
# install istio