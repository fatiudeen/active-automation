output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = "${module.eks.cluster_endpoint}"
}

output "ecr_repository_url" {
  description = "ECR repository url."
  value = aws_ecr_repository.active-ecr.repository_url
}