resource "aws_ecr_repository" "active-ecr" {
  name = "active-container"
  force_delete = true
  
  
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}


resource "aws_iam_policy" "ecr_push_policy" {
  name        = "ECR-Push-Policy"
  description = "IAM policy for pushing images to ECR"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Resource": "*",

        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "ecr-policy" {
  statement {
    sid    = "AllowPushPull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [

      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
    
  }
}

resource "aws_ecr_repository_policy" "ecr-policy" {
  repository = aws_ecr_repository.active-ecr.name
  policy     = data.aws_iam_policy_document.ecr-policy.json
  
}

resource "aws_iam_role" "active-ecr-role" {
  name = "active-ecr-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": ["*"]},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}