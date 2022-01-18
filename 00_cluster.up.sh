#!/usr/bin/env bash
set -e

source 99_config.sh

#################################
# This script CREATES a cluster #
# Usage: $0 <cluster-name>      #
#################################

cat <<EOF
Now is `$(which date)`

`$(which hostnamectl)`
EOF

kubectl version --client

NAME=${1:-$NAME_CLUSTER}

kind create cluster --name $NAME --wait 90s --config $WORK_DIR/kind/config.yaml >/dev/null

echo "Cluster created ..."

#Calico CNI - namespace network isolation, zero trust network model for security
#TODO: calico doesnt work locally, figure out network isolation solution for kind/local cluster
#kubectl create -f manifests/platform/calico/tigera-operator.yaml
#kubectl apply -f  manifests/platform/calico/calico-config.yaml

#K8S Dashboard
kubectl apply   -f manifests/platform/k8s-dashboard/k8s-dashboard.yaml
kubectl apply   -f manifests/platform/k8s-dashboard/k8s-dashboard-sa-admin.yaml

echo "K8S Dashboard available with 'kubectl proxy' at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login"

#TODO: check kubectl invocation points to KIND cluster and not system-default
MYTOKEN=$(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}")
MYSECRET=$(kubectl -n kubernetes-dashboard get secret $MYTOKEN -o go-template="{{.data.token | base64decode}}")

echo "K8S Dashboard ServiceAccount: $MYTOKEN"
echo "K8S Dashboard Secret: $MYSECRET"

kubectl cluster-info
kubectl get namespaces

# https://kind.sigs.k8s.io/docs/user/ingress/#using-ingress
# Kind does not support ingressClass, cant deploy namespaced ingress controllers
# > We don't support namespaced ingressClass yet
# > So a ClusterRole and a ClusterRoleBinding is required
# > The manifests contains kind specific patches to forward the hostPorts to the ingress controller, 
#   set taint tolerations and schedule it to the custom labelled node.
kubectl apply -f manifests/platform/ingress-nginx/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "K8S Cluster up"

