# resource "null_resource" "build_and_push_to_ecr" {

#   depends_on = [module.eks, module.vpc]

#     provisioner "local-exec" {
#     working_dir = "${path.module}/../scripts"
#     command     = "chmod u+x  ./build_and_push.sh"
#   }

#   provisioner "local-exec" {
#     working_dir = "${path.module}/../scripts"
#     command = "./build_and_push.sh"
#     interpreter = ["/bin/sh", "-c"]


#     environment  = {
#         AWS_REGION= local.region
#         ECR_REPOSITORY_URL= aws_ecrpublic_repository.active-ecr.repository_uri
#         DOCKERFILE_PATH= "${path.module}/../server/"
#     }
#   }
# }