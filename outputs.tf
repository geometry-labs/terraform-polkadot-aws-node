output "subnet_id" {
  value = var.subnet_id
}

output "security_group_id" {
  value = var.security_group_id
}

output "instance_id" {
  value = join("", aws_instance.this.*.id)
}

output "public_ip" {
  value = join("", aws_eip.this.*.public_ip)
}

output "private_ip" {
  value = join("", aws_instance.this.*.private_ip)
}

output "user_data" {
  value = join("", aws_instance.this.*.user_data)
}

output "sync_bucket_uri" {
  value = join("", aws_s3_bucket.sync.*.bucket_domain_name)
}

output "sync_bucket_name" {
  value = join("", aws_s3_bucket.sync.*.bucket)
}
