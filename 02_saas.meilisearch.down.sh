#!/usr/bin/env bash
set -e

source 99_config.sh

###############################################
# This script DELETES a SAAS                  #
# Usage: $0 <tenant-name>                     #
###############################################

NAME="ns-${1:-$NAME_TENANT}"

kubectl delete -f $WORK_DIR/manifests/product/meilisearch/meilisearch.yaml --namespace=$NAME

#TODO: delete service
#TODO: delete namespace itself
#TODO: delete ingress and everything else

kubectl wait --for=delete namespace $NAME