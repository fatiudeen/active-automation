resource "null_resource" "helm_charts" {
  depends_on = [null_resource.build_and_push_to_ecr]

  triggers = {
    cluster_endpoint = "${module.eks.cluster_endpoint}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"
    command     = "chmod u+x  ../scripts/install.sh"
  }


  provisioner "local-exec" {
    working_dir = "${path.module}"
    command     = "../scripts/install.sh"
    interpreter = ["/bin/sh", "-c"]

    environment  = {
        DEPL_PATH      = "${path.module}/k8s/"
        CLUSTER_NAME = local.name
        AWS_REGION = local.region
        AWS_ACCESS_KEY_ID = var.aws_access_key
        AWS_SECRET_ACCESS_KEY = var.aws_secret_key
        EKS_ARN = module.eks.cluster_arn
    }
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"
    command     = "helm upgrade --install --debug active-depl -f ${path.module}/k8s --set image ${aws_ecrpublic_repository.active-ecr.repository_uri}/:latest"
    # interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"
    when        = destroy
    command     = "chmod u+x  ../scripts/uninstall.sh"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"
    when        = destroy

    command     = "./scripts/uninstall.sh"
    interpreter = ["/bin/sh", "-c"]

  }


}