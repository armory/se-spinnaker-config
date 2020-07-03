# How to add policies 
This assumes you are running OPA with kube-mgmt, which auto loads policies based on the configmap in the namespace opa.

## Example: add a policy as a configmap

kubectl create configmap policyapp-mj-b4-deploy2prod --from-file=policyapp-manual-judgment-before-deploy-to-prod.rego -n opa

kubectl create configmap policyapp-trusted-image-source --from-file=policyapp-trusted-image-source.rego -n opa

