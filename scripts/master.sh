#! /bin/bash

set -x

whoami 

MASTER_IP="192.168.100.2"
NODENAME=$(hostname -s)
POD_NW_CIDR="10.244.0.0/16"
KUBETOKEN="b029ee.968a33e8d8e6bb0d"

echo 'y' | sudo kubeadm reset
# --image-repository registry.aliyuncs.com/google_containers：kubernetes 组件阿里云镜像，国内无法直接从 google 拉取
kubeadm init --image-repository registry.aliyuncs.com/google_containers --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=$POD_NW_CIDR --token $KUBETOKEN --token-ttl 0
#kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_NW_CIDR --node-name $NODENAME  --token $KUBETOKEN --token-ttl 0
#--image-repository registry.aliyuncs.com/google_containers


# Save Configs to shared /Vagrant location
# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.
config_path="/vagrant/configs"

if [ -d $config_path ]; then
   rm -f $config_path/*
else
   mkdir -p /vagrant/configs
fi


mkdir -p /root/.kube
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

cp -i /etc/kubernetes/admin.conf /vagrant/configs/config
touch /vagrant/configs/join.sh
touch /home/vagrant/.kube/join.sh
chmod +x /vagrant/configs/join.sh  
chmod +x /home/vagrant/.kube/join.sh     

echo "[TASK 4] Generate and save cluster join command to /join.sh"
#kubeadm token create --print-join-command > /root/joincluster.sh #2>/dev/null
kubeadm token create --print-join-command > /vagrant/configs/join.sh
sudo cp -f /vagrant/configs/join.sh /home/vagrant/.kube/join.sh

sudo -i -u vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
sudo rm -f /home/vagrant/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown 1000:1000 /home/vagrant/.kube/config
echo "alias k='kubectl'" >> ~/.bashrc

echo "added user to docker group: " + $USER
sudo usermod -aG docker $USER

kubectl taint nodes --all node-role.kubernetes.io/master-
#kubectl apply -f /vagrant/calico.yaml
kubectl get pods -A

EOF


# for flannel with multiple network card, DNS may not resolve
#kubectl apply -f /vagrant/kube-flannel.yml

#sed -i 's@# - name: CALICO_IPV4POOL_CIDR@- name: CALICO_IPV4POOL_CIDR@g; s@#   value: "192.168.0.0/16"@  value: '"${POD_CIDR}"'@g' /root/calico.yaml
#kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f /root/calico.yaml >/dev/null 2>&1


# Install Calico Network Plugin

#curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f /vagrant/k8s/calico.yaml

# Install Metrics Server
#deprecated kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml
# https://github.com/zuozewei/blog-example/tree/master/Kubernetes/k8s-metrics-server

kubectl apply -f /vagrant/k8s/metrics/metrics-rbac.yaml -n kube-system
kubectl apply -f /vagrant/k8s/metrics/metrics-api-service.yaml -n kube-system
kubectl apply -f /vagrant/k8s/metrics/metrics-server-deploy.yaml -n kube-system

# Install Kubernetes Dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# Create Dashboard User

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" >> /vagrant/configs/token

