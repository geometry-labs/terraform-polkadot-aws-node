resource "aws_iam_instance_profile" "this" {
  count       = var.consul_enabled || local.create_source_of_truth ? 1 : 0
  name_prefix = "${var.name}-"
  role        = join("", aws_iam_role.sot_host_role.*.name)
}

resource "aws_iam_role" "sot_host_role" {
  count              = local.create_source_of_truth ? 1 : 0
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_document.json
}

data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sot_host_policy_document" {
  count = local.create_source_of_truth ? 1 : 0

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]
    resources = ["${join("", aws_s3_bucket.sync.*.arn)}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [join("", aws_s3_bucket.sync.*.arn)]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [join("", aws_kms_key.key.*.arn)]
  }
}

resource "aws_iam_policy" "sot_host_policy" {
  count  = local.create_source_of_truth ? 1 : 0
  policy = join("", data.aws_iam_policy_document.sot_host_policy_document.*.json)
}

resource "aws_iam_role_policy_attachment" "sot_host" {
  count      = local.create_source_of_truth ? 1 : 0
  policy_arn = join("", aws_iam_policy.sot_host_policy.*.arn)
  role       = join("", aws_iam_role.sot_host_role.*.name)
}

data "aws_iam_policy_document" "consul" {
  count = var.consul_enabled ? 1 : 0
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "consul" {
  count  = var.consul_enabled ? 1 : 0
  policy = join("", data.aws_iam_policy_document.consul.*.json)
}

resource "aws_iam_role_policy_attachment" "consul" {
  count      = var.consul_enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.consul.*.arn)
  role       = join("", aws_iam_role.sot_host_role.*.name)
}
