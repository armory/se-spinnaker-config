# Armory Agent (kubesvc)

The agent is installed on the target cluster.

Manifests currently can be found in artifactory.

https://armory.jfrog.io/artifactory/manifests/kubesvc/

The corresponding plugin manifests can be found here (which is added to the spinnaker configuration): 
https://armory.jfrog.io/artifactory/manifests/kubesvc-plugins/

## MISC NOTES:
Armory Agent required a LB that could forward GRPC (in AWS this required the use of a NLB)