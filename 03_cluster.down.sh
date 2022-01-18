#!/usr/bin/env bash
set -e

source 99_config.sh

###############################################
# This script DESTROY cluster                 #
# Usage: $0 <cluster-name>                    #
###############################################

NAME=${1:-$NAME_CLUSTER}

kind delete cluster -v 10 --name $NAME