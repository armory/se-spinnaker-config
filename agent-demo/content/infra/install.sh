#!/bin/bash

for i in {0..49}
do
	echo -n .
	kustomize build agent-deployment | sed "s/account_name_replace/agent-infra-${i}/g" | kubectl apply --kubeconfig kubecfgs/kubecfg-demo-$i.yaml -f - &
done

wait < <(jobs -p)
echo "All done"