#!/bin/sh
set -x

cd ../argocd
kubectl create namespace argocd
kubectl config set-context --current --namespace argocd
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f install.yaml 
kubectl get all

#curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
#chmod +x /usr/local/bin/argocd

kubectl apply -f argocd-ingress.yml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# MevetUP3kABoprtV
