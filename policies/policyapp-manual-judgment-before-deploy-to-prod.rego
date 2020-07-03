# manual judgment before deploy to prod based on namespace only for "policyapp"

package opa.pipelines

# check for policyapp
policyApp { input.pipeline.application == "policyapp" }

# get prodDeployStages by namespaceOverride field == 'prod'
prodDeployStages[{"stageId": deployStagesRefId, "reqStageIds": deployStagesRequisiteStageId, "stageName": deployStageName}] {
  deployStages := [s | s = input.pipeline.stages[_]; (s.type == "deployManifest"); (s.namespaceOverride == "prod")]
  deployStagesRefId := deployStages[_].refId
  deployStagesRequisiteStageId := deployStages[_].requisiteStageRefIds
  deployStageName := deployStages[_].name
}

# get prodDeployStages by namespace in manifest == 'prod'
prodDeployStages2[{"stageId": deployStagesRefId, "reqStageIds": deployStagesRequisiteStageId, "stageName": deployStageName}]{
  deployStages := [s | s = input.pipeline.stages[_]; (s.type == "deployManifest"); (s.manifests[_].metadata.namespace == "prod")]
  deployStagesRefId := deployStages[_].refId
  deployStagesRequisiteStageId := deployStages[_].requisiteStageRefIds
  deployStageName := deployStages[_].name
}

# merge the two prodDeployStages
allProdDeployStages [{"results": results}] {
  results := prodDeployStages | prodDeployStages2
}

# deny when deploy stage has no requisiteStage (aka its the first stage)
deny[msg] {
  policyApp
  r = [y | y = allProdDeployStages[_].results[_]; count(y.reqStageIds) == 0]
  count(r) > 0
  msg = sprintf("Deployment to namespace `prod` requires stage '%v' to depend on a manual judgment stage before it.", [r[_].stageName])
}

# deny when deploy stage does not depend on a manual judgment stage
deny[msg] {
  policyApp
  some x
  r = [y | y = allProdDeployStages[_].results[_]; count(y.reqStageIds) > 0]
  requisiteStages := r[x].reqStageIds
  mjStages := [mj | mj = input.pipeline.stages[_]; mj.type == "manualJudgment"] 
  noMJb4Deploy := mjStages[_].refId != requisiteStages[_]
  noMJb4Deploy
  msg = sprintf("Deployment to namespace `prod` requires stage '%v' to depend on a manual judgment stage before it.", [r[x].stageName])
}