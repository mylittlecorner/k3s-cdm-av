sudo kubectl apply -f ingress.yaml
sudo kubectl apply -f nginx-ingress-controller.yaml
sudo kubectl apply -f nginx-configuration.yaml
sudo kubectl create namespace ingress-nginx
