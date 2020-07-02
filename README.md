# Spinnaker Operator config files

This repo stores the actual config files being by the Armory sales engineering team for their demo instance of Spinnaker. 

We're taking advantage of several features that were built (recently) by the community and Armory: 

* Spinnaker Operator
* Kustomize bake 
* Git triggers (with secrets)

The pipeline is relatively straightforward containing two stages: 
1. Bake (manifest) with Kustomize
2. Deploy (manifest)

## Goal
the goal is for us to be able to manage multiple instances of spinnaker by utilizing kustomize
tweaks to each instance will be done in their own respective folders (e.g. vincent or julius)

## Directory structure

base/ - contains all the common configuration for spinnaker
vincent/ - contains any patches specific to vincent 
julius/ - *TODO* add configuration for other spinnaker instance