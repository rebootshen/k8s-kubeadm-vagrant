#! /bin/bash

set -x

KUBERNETES_VERSION="1.23.6-0"

whoami

#Aliyun mirrors

#curl -sS -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# Step 2: add repo
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum-config-manager --disable docker-ce-edge
sudo yum-config-manager --disable docker-ce-test


cat <<EOF > /etc/yum.repos.d/kubernetes2.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# k8s repo
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


yum install -y net-tools tree telnet vim wget bind-utils

# Step 3: Docker-CE
yum makecache fast
#sudo yum -y install docker-ce

# docker 
yum install --nogpgcheck -y yum-utils device-mapper-persistent-data lvm2
yum install --nogpgcheck -y docker-ce

# kubelet kubeadm
yum install -y  install -y kubelet-$KUBERNETES_VERSION kubectl-$KUBERNETES_VERSION kubeadm-$KUBERNETES_VERSION --disableexcludes=kubernetes
#yum install -y  --nogpgcheck kubelet kubeadm kubectl


# disable SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# disable swap
swapoff -a
sed -i '/swap/s/^/#/g' /etc/fstab

# bridge IPv4 to iptables 
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# disable firewalld
systemctl stop firewalld
systemctl disable firewalld


# Step 5: cgroup driver
sudo mkdir -p /etc/docker
sudo bash -c ' cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF'



if [ ! $(getent group docker) ];
then 
    sudo groupadd docker;
else
    echo "docker user group already exists"
fi

sudo gpasswd -a $USER docker
sudo gpasswd -a vagrant docker

sudo systemctl  daemon-reload

# Step 4: enable Docker
#sudo service docker start
#sudo systemctl restart docker

systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

echo "[TASK 10] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 11] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc