resource "random_pet" "this" {}

module "user_data" {
  source         = "github.com/insight-infrastructure/terraform-polkadot-user-data.git?ref=master"
  type           = var.node_purpose
  cloud_provider = "aws"
  driver_type    = var.storage_driver_type
  mount_volumes  = var.mount_volumes
}

resource "aws_key_pair" "this" {
  count      = var.key_name == "" && var.create ? 1 : 0
  public_key = var.public_key
}

resource "aws_eip" "this" {
  count = var.create ? 1 : 0

  vpc = true

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

resource "aws_eip_association" "this" {
  count = var.create ? 1 : 0

  allocation_id = aws_eip.this.*.id[count.index]
  instance_id   = join("", aws_instance.this.*.id)
}


resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  user_data              = module.user_data.user_data
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  monitoring             = var.monitoring
  key_name               = concat(aws_key_pair.this.*.key_name, [var.key_name])[0]
  iam_instance_profile   = var.iam_instance_profile == "" && local.create_source_of_truth ? join("", aws_iam_instance_profile.sot_host.*.name) : var.iam_instance_profile

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = merge({ Name : var.node_name }, var.tags)
}

module "ansible" {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.12.0"
  create = var.create_ansible && var.create

  ip                     = join("", aws_eip_association.this.*.public_ip)
  user                   = "ubuntu"
  private_key_path       = var.private_key_path
  playbook_file_path     = "${path.module}/ansible/${var.node_purpose}.yml"
  requirements_file_path = "${path.module}/ansible/requirements.yml"
  forks                  = 1

  playbook_vars = {
    id       = var.name
    ssh_user = var.ssh_user

    # enable flags
    node_exporter_enabled = var.node_exporter_enabled
    health_check_enabled  = var.health_check_enabled
    consul_enabled        = var.consul_enabled
    use_source_of_truth   = var.source_of_truth_enabled

    # node exporter
    node_exporter_user            = var.node_exporter_user
    node_exporter_password        = var.node_exporter_password
    node_exporter_binary_url      = var.node_exporter_url
    node_exporter_binary_checksum = "sha256:${var.node_exporter_hash}"

    # polkadot client
    polkadot_binary_url      = var.polkadot_client_url
    polkadot_binary_checksum = "sha256:${var.polkadot_client_hash}"

    polkadot_restart_enabled = var.polkadot_restart_enabled
    polkadot_restart_minute  = var.polkadot_restart_minute
    polkadot_restart_hour    = var.polkadot_restart_hour
    polkadot_restart_day     = var.polkadot_restart_day
    polkadot_restart_month   = var.polkadot_restart_month
    polkadot_restart_weekday = var.polkadot_restart_weekday

    network_settings = jsonencode(local.network_settings)

    project                   = var.project
    instance_count            = var.instance_count
    loggingFilter             = var.logging_filter
    telemetryUrl              = var.telemetry_url
    default_telemetry_enabled = var.default_telemetry_enabled
    base_path                 = var.base_path

    # Validator
    polkadot_additional_common_flags    = var.polkadot_additional_common_flags
    polkadot_additional_validator_flags = var.polkadot_additional_validator_flags

    # SOT
    region          = data.aws_region.this.name
    sync_bucket_uri = local.create_source_of_truth ? aws_s3_bucket.sync[0].bucket_domain_name : var.sync_bucket_uri
  }

  module_depends_on = aws_instance.this
}
