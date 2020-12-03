package spinnaker.execution.stages.before.deployManifest

deny[msg] {
    msg := "LoadBalancer Services must not have port 22 open."
    manifests := input.stage.context.manifests
    manifest := manifests[_]

    manifest.kind == "Service"

    port := manifest.spec.ports[_]
    port.port == 22
}