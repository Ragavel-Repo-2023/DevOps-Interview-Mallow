data "aws_iam_policy_document" "irsa_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:rails-app-sa"]
    }
  }
}

resource "aws_iam_role" "irsa_s3" {
  name               = "${var.cluster_name}-irsa-s3-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_role.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.app_bucket.arn,
      "${aws_s3_bucket.app_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "irsa_s3" {
  name   = "${var.cluster_name}-irsa-s3-policy"
  role   = aws_iam_role.irsa_s3.id
  policy = data.aws_iam_policy_document.s3_access.json
}