
variable "create_ansible" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

variable "ssh_user" {
  description = "Username for SSH"
  type        = string
  default     = "ubuntu"
}

## Enable flags
variable "node_exporter_enabled" {
  description = "Bool to enable node exporter"
  type        = bool
  default     = false
}

variable "health_check_enabled" {
  description = "Bool to enable client health check agent"
  type        = bool
  default     = false
}

variable "skip_health_check" {
  description = "Bool to skip client health check when agent installed"
  type        = bool
  default     = true
}

variable "consul_enabled" {
  description = "Bool to enable Consul"
  type        = bool
  default     = false
}

variable "source_of_truth_enabled" {
  description = "Bool to enable SoT sync (for use with library nodes)"
  type        = bool
  default     = false
}

# Node exporter
variable "node_exporter_user" {
  description = "User for node exporter"
  type        = string
  default     = "node_exporter_user"
}

variable "node_exporter_password" {
  description = "Password for node exporter"
  type        = string
  default     = "node_exporter_password"
}

variable "node_exporter_url" {
  description = "URL to Node Exporter binary"
  type        = string
  default     = "https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"
}

variable "node_exporter_hash" {
  description = "SHA256 hash of Node Exporter binary"
  type        = string
  default     = "b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"
}


variable "iam_instance_profile" {
  description = "IAM instance profile name, overrides source of truth IAM."
  type        = string
  default     = ""
}

variable "network_stub" {
  description = "The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3)"
  type        = string
  default     = "ksmcc3"
}

variable "network_name" {
  description = "The network name, ie kusama / polkadot"
  type        = string
  default     = "polkadot"
}

variable "polkadot_client_url" {
  description = "URL to Polkadot client binary"
  type        = string
  default     = "https://github.com/paritytech/polkadot/releases/download/v0.8.29/polkadot"
}

variable "polkadot_client_hash" {
  description = "SHA256 hash of Polkadot client binary"
  type        = string
  default     = "0b27d0cb99ca60c08c78102a9d2f513d89dfec8dbd6fdeba8b952a420cdc9fd2"
}

variable "polkadot_restart_enabled" {
  description = "Bool to enable client restart cron job"
  type        = bool
  default     = false
}

variable "polkadot_restart_minute" {
  description = "Client cron restart minute"
  type        = string
  default     = ""
}

variable "polkadot_restart_hour" {
  description = "Client cron restart hour"
  type        = string
  default     = ""
}

variable "polkadot_restart_day" {
  description = "Client cron restart day"
  type        = string
  default     = ""
}

variable "polkadot_restart_month" {
  description = "Client cron restart month"
  type        = string
  default     = ""
}

variable "polkadot_restart_weekday" {
  description = "Client cron restart weekday"
  type        = string
  default     = ""
}

variable "sync_bucket_uri" {
  description = "S3 bucket URI for SoT sync"
  type        = string
  default     = null
}

variable "project" {
  description = "Name of the project for node name"
  type        = string
  default     = "project"
}

variable "instance_count" {
  description = "Iteration number for this instance"
  type        = string
  default     = "0"
}

variable "logging_filter" {
  description = "String for polkadot logging filter"
  type        = string
  default     = "sync=trace,afg=trace,babe=debug"
}

variable "telemetry_url" {
  description = "WSS URL for telemetry"
  type        = string
  default     = ""
}

variable "default_telemetry_enabled" {
  description = "Bool to enable telemetry submission to telemetry.polkadot.io"
  type        = bool
  default     = false
}

variable "base_path" {
  description = "Alternate base path for Polkadot client"
  type        = string
  default     = ""
}

variable "polkadot_additional_common_flags" {
  description = "Optional common flags for Polkadot client"
  type        = string
  default     = ""
}

variable "polkadot_additional_validator_flags" {
  description = "Optional validator flags for Polkadot client"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster (if used)"
  type        = string
  default     = ""
}

variable "consul_version" {
  type        = string
  description = "Consul version number to install"
  default     = "1.9.4"
}

variable "consul_gossip_key" {
  type        = string
  description = "Consul gossip encryption key"
  default     = ""
}

variable "consul_auto_encrypt_enabled" {
  description = "Bool to enable Consul auto-encrypt"
  type        = bool
  default     = false
}

variable "consul_connect_enabled" {
  description = "Bool to enable Consul Connect"
  type        = bool
  default     = false
}

variable "consul_acl_enable" {
  description = "Bool to enable Consul ACLs"
  type        = bool
  default     = false
}

variable "consul_acl_datacenter" {
  description = "Authoritative Consul ACL datacenter"
  type        = string
  default     = ""
}

variable "consul_acl_token" {
  description = "Consul ACL token"
  type        = string
  default     = ""
}

variable "consul_tls_source_dir" {
  description = "Path to directory containing Consul TLS certs"
  type        = string
  default     = null
}

variable "consul_tls_ca_filename" {
  description = "Filename for Consul TLS CA certificate"
  type        = string
  default     = "ca.crt"
}

variable "prometheus_enabled" {
  description = "Bool to use when Prometheus is enabled"
  type        = bool
  default     = false
}

variable "hardening_enabled" {
  description = "Runs a series of linux hardening playbooks - ansible-collection-hardening"
  type        = bool
  default     = false
}

module "ansible" {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.15.0"
  create = var.create_ansible && var.create

  ip                     = join("", aws_eip_association.this.*.public_ip)
  user                   = "ubuntu"
  private_key_path       = var.private_key_path
  playbook_file_path     = "${path.module}/ansible/${var.node_purpose}.yml"
  requirements_file_path = "${path.module}/ansible/requirements.yml"
  forks                  = 1

  playbook_vars = {
    id                = var.name
    ssh_user          = var.ssh_user
    deployed_networks = join("\n", [for network in local.network_settings : network["shortname"]])
    instance_type     = "node"

    # enable flags
    node_exporter_enabled = var.node_exporter_enabled
    health_check_enabled  = var.health_check_enabled
    skip_health_check     = var.skip_health_check
    consul_enabled        = var.consul_enabled
    use_source_of_truth   = var.source_of_truth_enabled
    prometheus_enabled    = var.prometheus_enabled
    hardening_enabled     = var.hardening_enabled

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

    # Consul
    consul_datacenter           = data.aws_region.this.name
    consul_enabled              = var.consul_enabled
    consul_version              = var.consul_version
    retry_join_string           = "provider=aws tag_key=\"k8s.io/cluster/${var.cluster_name}\" tag_value=owned"
    consul_gossip_key           = var.consul_gossip_key
    consul_auto_encrypt_enabled = var.consul_auto_encrypt_enabled
    consul_tls_src_files        = var.consul_tls_source_dir
    consul_tls_ca_crt           = var.consul_tls_ca_filename
    consul_connect_enabled      = var.consul_connect_enabled
    consul_acl_enable           = var.consul_acl_enable
    consul_acl_datacenter       = var.consul_acl_datacenter
    consul_acl_token            = var.consul_acl_token
  }

  module_depends_on = aws_instance.this
}

