
//Source of truth nodes are run to back up the chain to S3 to allow fast
//scale and sync for autoscaling groups.  This creates an s3 bucket and
//gives the node permission to push data to it.

locals {
  create_source_of_truth = var.node_purpose == "truth" && var.sync_bucket_uri != null
}

resource "aws_s3_bucket" "sync" {
  count         = local.create_source_of_truth ? 1 : 0
  bucket_prefix = "${var.name}-substrate-truth"
  acl           = "private"

  region = var.sync_region # TODO: RM?

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = join("", aws_kms_key.key.*.id)
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(var.tags)
}

resource "aws_kms_key" "key" {
  count = local.create_source_of_truth ? 1 : 0
  tags  = merge(var.tags, { Name = var.name })
}

resource "aws_kms_alias" "alias" {
  count         = local.create_source_of_truth ? 1 : 0
  name          = "alias/${join("", aws_s3_bucket.sync.*.bucket)}"
  target_key_id = join("", aws_kms_key.key.*.arn)
}

data "aws_iam_policy_document" "assume_policy_document" {
  count = local.create_source_of_truth ? 1 : 0
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

resource "aws_iam_role" "sot_host_role" {
  count = local.create_source_of_truth ? 1 : 0

  path               = "/"
  assume_role_policy = join("", data.aws_iam_policy_document.assume_policy_document.*.json)
}

data "aws_iam_policy_document" "sot_host_policy_document" {
  count = local.create_source_of_truth ? 1 : 0

  # TODO: Are all objects at /?
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${join("", aws_s3_bucket.sync.*.arn)}/*"]
  }

  # TODO: RM?
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${join("", aws_s3_bucket.sync.*.arn)}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [join("", aws_s3_bucket.sync.*.arn)]

    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["public-keys/"]
      variable = "s3:prefix"
    }
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
  count = local.create_source_of_truth ? 1 : 0

  policy_arn = join("", aws_iam_policy.sot_host_policy.*.arn)
  role       = join("", aws_iam_role.sot_host_role.*.name)
}

resource "aws_iam_instance_profile" "sot_host" {
  count = local.create_source_of_truth ? 1 : 0
  name  = "test_profile"
  role  = join("", aws_iam_role.sot_host_role.*.name)
}
