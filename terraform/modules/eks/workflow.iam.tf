resource "aws_iam_role_policy" "github_eks_policy" {
  name = "github-terraform-eks-policy"
  role = "arn:aws:iam::624602074403:role/github-workflow-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:TagResource",
          "eks:CreateNodegroup",
          "eks:DescribeNodegroup",
          "eks:DeleteNodegroup",
          "eks:DeleteCluster"
        ]
        Resource = "*"
      }
    ]
  })
}