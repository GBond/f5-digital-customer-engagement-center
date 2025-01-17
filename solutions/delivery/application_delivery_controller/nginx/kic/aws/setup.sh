#!/bin/bash
terraform init -upgrade
terraform fmt
terraform validate
terraform plan
# apply
read -p "Press enter to continue"
terraform apply --auto-approve
#export KUBECONFIG=$KUBECONFIG:$(echo -n "$(cat ./cluster-config)")
mkdir -p ~/.kube/
\cp ./cluster-config ~/.kube/cluster-config
export KUBECONFIG=$KUBECONFIG:~/.kube/cluster-config
