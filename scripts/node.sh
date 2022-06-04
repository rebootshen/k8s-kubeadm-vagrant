#! /bin/bash
MASTER_IP="192.168.100.2"

set -x

whoami

#/bin/bash /vagrant/configs/join.sh -v

#echo "[TASK 1] Join node to Kubernetes Cluster"

mkdir -p /home/vagrant/.kube
sudo yum install -y sshpass #>/dev/null 2>&1
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MASTER_IP:/home/vagrant/.kube/join.sh /home/vagrant/.kube/join.sh #2>/dev/null
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MASTER_IP:/home/vagrant/.kube/config /home/vagrant/.kube/config #2>/dev/null


#sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MASTER_IP:/home/vagrant/.kube/join.sh /home/vagrant/.kube/join.sh #2>/dev/null

#sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no apiserver.endpoint:/root/joincluster.sh /root/joincluster.sh #2>/dev/null

sudo bash /home/vagrant/.kube/join.sh #>/dev/null 2>&1



sudo -i -u vagrant bash << EOF
whoami
set -x
#mkdir -p /home/vagrant/.kube
#sudo cp -i /vagrant/configs/config /home/vagrant/.kube/
#sudo cp -i /vagrant/configs/join.sh /home/vagrant/.kube/
sudo chown -R 1000:1000 /home/vagrant/.kube/
echo "alias k='kubectl'" >> ~/.bashrc

echo "added user to docker group: " + $USER
sudo usermod -aG docker $USER

NODENAME=$(hostname -s)
kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker

kubectl get nodes
EOF

#kubeadm join 192.168.56.10:6443 --token b029ee.968a33e8d8e6bb0d \
#    master:     --discovery-token-ca-cert-hash sha256:3b60230c407352106d820339abf706d086b6242f5b06e536440f4136798e12c2



