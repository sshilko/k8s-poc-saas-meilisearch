#!/usr/bin/env bash
set -e

###############################################
# This script CONFIGURE cluster               #
###############################################

hash jq mkdir docker curl sha256sum basename hostnamectl date envsubst || echo "At least one dependency is missing"

WORK_DIR=$(readlink -f $0 | xargs dirname)

mkdir -p tmp
SAVE_DIR="$WORK_DIR/tmp"

# SaaS Tenant prefix
NAME_TENANT='tenant0'

# K8S Cluster prefix
NAME_CLUSTER='cluster0'

# DNS Domain
DNS='frb.io'

#######################
# Vendor dependencies #
#######################

#https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager
if [ ! -f "$SAVE_DIR/kind" ]; then
    curl -C - -Lo $SAVE_DIR/kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64 && chmod +x $SAVE_DIR/kind
fi

#https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
if [ ! -f "$SAVE_DIR/kubectl" ] || [ ! -f "$SAVE_DIR/kubectl.sha256" ]; then
    curl -Lo $SAVE_DIR/kubectl        "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -Lo $SAVE_DIR/kubectl.sha256 "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    chmod +x $SAVE_DIR/kubectl
fi

echo "$(cat $SAVE_DIR/kubectl.sha256) $SAVE_DIR/kubectl" | sha256sum --check --status || (rm $SAVE_DIR/kubectl $SAVE_DIR/kubectl.sha256 && exit 1)

if [ "$?" != "0" ];then echo $? && exit $?; fi

#####################
# Use vendored deps #
#####################

kubectl() {
    $SAVE_DIR/kubectl "$@"
}

kind() {
    $SAVE_DIR/kind "$@"
}

