#!/bin/sh
set -x

cd ../gitlab
kubectl create namespace kube-ops
kubectl config set-context --current --namespace kube-ops
kubectl apply -f gitlab-redis.yml 
kubectl apply -f gitlab-postgresql.yml
kubectl apply -f gitlab.yml

kubectl apply -f gitlab-ingress.yml
kubectl get all

#http://gitlab.rebootshen.com/
#http://gitlab.rebootshen.com/users/sign_in

#root:admin321

#http://gitlab.rebootshen.com/admin/application_settings/general#js-signup-settings
#http://gitlab.rebootshen.com/admin/runners
# Register an instance runner
#  TxCi463xtuyagyezDssQ

# http://gitlab.rebootshen.com/
