# Armory Sales Dev Cluster

## purpose
the purpose of this cluster is create a deployment target for our spinnaker instances
we also want to integrate kubesvc (kubeagent?) to communicate with this cluster

Using EKSCTL to create Armory-Sales-Dev Cluster
`eksctl create cluster -f eksctl-salesdevcluster.yml --profile armory-sales-dev`

PreReqs: 
- `sharedsekey.pub` (download from 1password) 

Get kubeconfig:

`aws sts get-caller-identity --profile armory-sales-dev`

`aws eks --region us-west-2 update-kubeconfig --name armory-sales-dev-cluster --kubeconfig ~/.kube/base.yaml --profile armory-sales-dev`