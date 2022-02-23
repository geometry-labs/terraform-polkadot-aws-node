//Source of truth nodes are run to back up the chain to S3 to allow fast
//scale and sync for autoscaling groups.  This creates an s3 bucket and
//gives the node permission to push data to it.

variable "enable_kms" {
  type    = bool
  default = false
}

locals {
  create_source_of_truth = var.node_purpose == "truth" && var.sync_bucket_name == null
}

resource "aws_s3_bucket" "sync" {
  count         = local.create_source_of_truth ? 1 : 0
  bucket_prefix = "${var.name}-truth"

  tags = merge(var.tags)
}

resource "aws_s3_bucket_acl" "this" {
  count  = local.create_source_of_truth ? 1 : 0
  bucket = join("", aws_s3_bucket.sync.*.bucket)
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = local.create_source_of_truth && var.enable_kms ? 1 : 0
  bucket = join("", aws_s3_bucket.sync.*.bucket)

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = join("", aws_kms_key.key.*.id)
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "key" {
  count = var.enable_kms && local.create_source_of_truth ? 1 : 0
  tags  = merge(var.tags, { Name = var.name })
}

resource "aws_kms_alias" "alias" {
  count         = var.enable_kms && local.create_source_of_truth ? 1 : 0
  name          = "alias/${join("", aws_s3_bucket.sync.*.bucket)}"
  target_key_id = join("", aws_kms_key.key.*.arn)
}

output "sync_bucket_domain_name" {
  value = join("", aws_s3_bucket.sync.*.bucket_domain_name)
}

output "sync_bucket_name" {
  value = join("", aws_s3_bucket.sync.*.bucket)
}

output "kms_key_arn" {
  value = join("", aws_kms_key.key.*.arn)
}

output "sync_bucket_arn" {
  value = join("", aws_s3_bucket.sync.*.arn)
}