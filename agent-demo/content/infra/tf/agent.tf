resource "null_resource" "install-agent" {
  count = 50
  provisioner "local-exec" {
    command = <<-EOT
      kustomize build ../agent-deployment \
        | sed "s/account_name_replace/agent-infra-${count.index}/g" \
        | kubectl apply --kubeconfig ../kubecfgs/kubecfg-demo-${count.index}.yaml -f -
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    null_resource.get-credentials,
  ]
}