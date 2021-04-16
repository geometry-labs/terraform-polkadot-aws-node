variable "create" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

variable "create_ansible" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

########
# Label
########

variable "name" {
  description = "The name of the deployment"
  type        = string
  default     = "polkadot-api"
}

variable "tags" {
  description = "Tags to associate with resources."
  type        = map(string)
  default     = {}
}

variable "node_purpose" {
  description = "What type of node are you deploying? (validator/library/truth)"
  type        = string
  default     = "library"

  //  validation {
  //    condition     = var.node_purpose == "validator" || var.node_purpose == "validator" || var.node_purpose == "truth"
  //    error_message = "The node_purpose value must be one of \"validator\", \"validator\", or \"truth\"."
  //  }
}

#########
# Network
#########
variable "subnet_id" {
  description = "The id of the subnet."
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "The id of the security group to run in"
  type        = string
}

#####
# ec2
#####
variable "node_name" {
  description = "Name of the node"
  type        = string
  default     = ""
}

variable "monitoring" {
  description = "Boolean for cloudwatch"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root volume size"
  type        = string
  default     = 0
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "The public ssh key. key_name takes precidence"
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to private key"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The name of the preexisting key to be used instead of the local public_key_path"
  type        = string
  default     = ""
}

variable "storage_driver_type" {
  description = "Type of EBS storage the instance is using (nitro/standard)"
  type        = string
  default     = "standard"
}

variable "mount_volumes" {
  description = "Bool to enable non-root volume mounting"
  type        = bool
  default     = false
}

#########
# Ansible
#########

variable "ssh_user" {
  description = "Username for SSH"
  type        = string
  default     = "ubuntu"
}

## Enable flags
variable "node_exporter_enabled" {
  description = "Bool to enable node exporter"
  type        = bool
  default     = true
}

variable "health_check_enabled" {
  description = "Bool to enable client health check agent"
  type        = bool
  default     = true
}

variable "consul_enabled" {
  description = "Bool to enable Consul"
  type        = bool
  default     = true
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

# Client
//variable "network_settings" {
//  description = "Map of network settings to apply. Use either this or set individual variables."
//  type        = map(map(string))
//  default     = null
//}

variable "network_settings" {
  description = "Map of network settings to apply. Use either this or set individual variables."
  type = map(object({
    name                = string
    shortname           = string
    api_health          = string
    polkadot_prometheus = string
    json_rpc            = string
    ws_rpc              = string
  }))
  //  default     = {
  //    polkadot = {
  //      name                = "polkadot"
  //      shortname           = "polkadot"
  //      api_health          = "5000"
  //      polkadot_prometheus = "9610"
  //      json_rpc            = "9933"
  //      ws_rpc              = "9944"
  //    }
  //  }
  default = null
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
  default     = "https://github.com/w3f/polkadot/releases/download/v0.8.23/polkadot"
}

variable "polkadot_client_hash" {
  description = "SHA256 hash of Polkadot client binary"
  type        = string
  default     = "cdf31d39ed54e66489d1afe74ed7549d5bcdf8ff479759e8fc476d17d069901e"
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

variable "rpc_api_port" {
  description = "Port number for the JSON RPC API"
  type        = string
  default     = "9933"
}

variable "wss_api_port" {
  description = "Port number for the Websockets API"
  type        = string
  default     = "9944"
}

variable "health_check_port" {
  description = "Port number for the health check"
  type        = string
  default     = "5500"
}

variable "polkadot_prometheus_port" {
  description = "Port number for the Prometheus Metrics exporter built into the Polkadot client"
  type        = string
  default     = "9610"
}