resource "aws_ecrpublic_repository" "active-ecr" {
  repository_name = "active-image"
  
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}


resource "aws_iam_policy" "ecr_push_policy" {
  name        = "ECR_Push_Policy"
  description = "IAM policy for pushing images to ECR"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
         "Sid":"GetAuthorizationToken",
         "Effect":"Allow",
         "Action":[
            "ecr-public:GetAuthorizationToken"
         ],
         "Resource":"*"
      },
      {
         "Sid":"ManageRepositoryContents",
         "Effect":"Allow",
         "Action":[
                "ecr-public:BatchCheckLayerAvailability",
                "ecr-public:GetRepositoryPolicy",
                "ecr-public:DescribeRepositories",
                "ecr-public:DescribeImages",
                "ecr-public:InitiateLayerUpload",
                "ecr-public:UploadLayerPart",
                "ecr-public:CompleteLayerUpload",
                "ecr-public:PutImage"
         ],
         "Resource":"*"
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
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:GetRepositoryPolicy",
      "ecr-public:DescribeRepositories",
      "ecr-public:DescribeRegistries",
      "ecr-public:DescribeImages",
      "ecr-public:DescribeImageTags",
      "ecr-public:GetRepositoryCatalogData",
      "ecr-public:GetRegistryCatalogData"
    ]
    
  }
}

resource "aws_ecrpublic_repository_policy" "ecr-policy" {
  repository_name = aws_ecrpublic_repository.active-ecr.repository_name
  policy     = data.aws_iam_policy_document.ecr-policy.json
  
}

resource "aws_iam_role" "ecr-active-role" {
  name = "ecr-active-role"

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