kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo

kubectl create ingress demo-localhost --class=nginx \
  --rule=demo.rebootshen.com/*=demo:80


kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80

#DaemonSet, no need port-forward
# http://demo.rebootshen.com/
# It works!

#NP
# http://demo.rebootshen.com:8080/
# It works!