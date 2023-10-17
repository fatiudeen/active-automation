output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = "${module.eks.cluster_endpoint}"
}

output "ecr_repository_url" {
  description = "ECR repository url."
  value = aws_ecrpublic_repository.active-ecr.repository_uri
}

output "cluster_name" {
  description = "local cluster name."
  value = local.name
}

output "eks_arn" {
  description = "EKS ARN"
  value = module.eks.cluster_arn
}