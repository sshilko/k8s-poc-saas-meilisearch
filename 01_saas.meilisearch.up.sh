#!/usr/bin/env bash
set -e

source 99_config.sh

###################################################
# This script CREATES Meilisearch SAAS per tenant #
# Usage: $0 <tenant-name>                         #
###################################################

NAME="ns-${1:-$NAME_TENANT}"

#Create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAME
  labels:
    network: $NAME
EOF

#Deploy Meilisearch
kubectl apply -f $WORK_DIR/manifests/product/meilisearch/meilisearch.yaml --namespace=$NAME

#Expose Meilisearch (could have used HEML instead)
NAME=$NAME DNS=$DNS envsubst < $WORK_DIR/manifests/product/meilisearch/meilisearch-service.yaml.tmpl | kubectl apply --namespace=$NAME -f -

#https://kind.sigs.k8s.io/docs/user/ingress/
echo "K8S Waiting for Ingress ..."

########### DOES NOT WORK IN KIND LOCAL SETUP
#Deploy ingress controller
#By default, deploying multiple Ingress controllers (e.g., ingress-nginx & gce) will result in all controllers simultaneously racing to update Ingress status fields in confusing ways.
#To fix this problem, use IngressClasses, the kubernetes.io/ingress.class annotation is deprecated from kubernetes v1.22+.
#https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class
#https://kubernetes.github.io/ingress-nginx/user-guide/multiple-ingress/
#https://kubernetes.github.io/ingress-nginx/#how-to-easily-install-multiple-instances-of-the-ingress-nginx-controller-in-the-same-cluster
#helm install ingress-nginx-$NAME ingress-nginx/ingress-nginx  \
#--namespace $NAME \
#--set controller.ingressClassResource.name=nginx-$NAME \
#--set controller.ingressClassResource.controllerValue="$DNS/ingress-nginx-controller-$NAME" \
#--set controller.ingressClassResource.enabled=true \
#--set controller.ingressClassByName=true \
#--set controller.setAsDefaultIngress=true
########### DOES NOT WORK IN KIND LOCAL SETUP
#kubectl --namespace $NAME get services -o wide -w ingress-nginx-$NAME-controller
kubectl --namespace $NAME get services -o wide

#https://kubernetes.github.io/ingress-nginx/user-guide/basic-usage/
#https://kubernetes.io/docs/concepts/services-networking/ingress/
#ingressClassName is predefined value 'nginx' for auto-discovery by ingress-controller
#https://kind.sigs.k8s.io/docs/user/ingress/
# cat <<EOF | kubectl apply --namespace $NAME -f -
#   apiVersion: networking.k8s.io/v1
#   kind: Ingress
#   metadata:
#     name: $NAME-ingress-meilisearch
#   spec:
#     ingressClassName: nginx-$NAME
#     rules:
#       - http:
#           paths:
#             - path: "/"
#               pathType: Prefix
#               backend:
#                 service:
#                   name: $NAME-meilisearch-service
#                   port:
#                     number: 80
# EOF


# cat <<EOF | kubectl apply --namespace $NAME -f -
#   apiVersion: networking.k8s.io/v1
#   kind: Ingress
#   metadata:
#     name: $NAME-ingress-meilisearch
#   spec:
#     defaultBackend:
#       service:
#         name: $NAME-meilisearch-service
#         port:
#           number: 80
# EOF


#Cant use namespaced ingresses because Kind does not support exposing them easily, locally must to use shared, single ingress, for demo-purposes only
cat <<EOF | kubectl apply --namespace $NAME -f -
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: ingress-meilisearch-$NAME
  spec:
    rules:
    - host: $NAME.meilisearch.$DNS
      http:
        paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: $NAME-meilisearch-service
              port:
                number: 80
EOF

#INGRESS-CONTROLLER => INGRESS => SERVICE => ENDPOINT => POD

#kubectl delete ingress --namespace $NAME $NAME-ingress-meilisearch
kubectl get ingress -n $NAME && kubectl describe ingress ingress-meilisearch-$NAME -n $NAME

kubectl describe ingressclasses

kubectl wait --for=condition=Ready pods --all --namespace=$NAME

#Did pods boot up?
kubectl get pods --namespace $NAME -o wide

#Did Meilisearch boot up in pod
kubectl exec --stdin --tty meilisearch-0 --namespace $NAME -- curl -v http://127.0.0.1:7700/health

#Does service exists?
kubectl get services --namespace $NAME -o wide

#Does the service have any endpoints?
kubectl get endpoints -n $NAME

#Debug info
#kubectl get pod --all-namespaces -o json | jq '.items[] | .metadata.name + " " +.status.podIP + " " + .metadata.namespace' |grep meilisearch

#Only allow networking from/to the same namespace
# cat <<EOF | kubectl apply -f -
# apiVersion: crd.projectcalico.org/v1
# kind: GlobalNetworkPolicy
# metadata:
#   name: isolate-namespace-tenants
# spec:
#   namespaceSelector: network == '$NAME'
#   ingress:
#   - action: Allow
#     protocol: TCP
#     source:
#       namespaceSelector: network == '$NAME'
# EOF
