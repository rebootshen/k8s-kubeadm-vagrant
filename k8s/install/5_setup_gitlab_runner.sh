#!/bin/sh
set -x

# net update token from admin


cd ../gitlab

helm repo add gitlab https://charts.gitlab.io
helm repo list
helm list
helm search repo -l gitlab/gitlab-runner
## !! need get token from gitlab admin
helm install --namespace kube-ops gitlab-runner -f values.gitlab-runner.yml gitlab/gitlab-runner

kubectl config set-context --current --namespace kube-ops
kubectl get all

# register user and approve by admin
# http://gitlab.rebootshen.com/users/sign_in#login-pane
# http://gitlab.rebootshen.com/admin/users?filter=blocked_pending_approval
# root:admin321


# sprint template: spring-demo
# git clone http://gitlab.rebootshen.com/samshen/spring-demo
# git commit -m "add .gitlab-ci.yml"

#http://gitlab.rebootshen.com/samshen/spring-demo/-/settings/ci_cd
# CI/CD configuration file: .gitlab-ci.yml

# http://gitlab.rebootshen.com/admin/runners/1/edit
# Restrict projects for this runner
# Enable :Sam Shen / spring-demo
# Run untagged jobs;  remove all tags

# 
# fluentd  efk
# nexus-iq/nexus-repo/sonarqube

# install all kind of debug tools : dnsutils etc