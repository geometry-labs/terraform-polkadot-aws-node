variable "create" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

variable "network_settings" {
  description = "Map of network settings to apply. Use either this or set individual variables."
  type = map(object({
    name                = string
    shortname           = string
    api_health          = string
    polkadot_prometheus = string
    json_rpc            = string
    json_envoy          = string
    ws_rpc              = string
    ws_envoy            = string
  }))
  default = null
}

// If the network map is not supplied, fall back to running on supplied ports which
// default to polkadot.
locals {
  network_settings = var.network_settings == null ? { network = {
    name                = var.network_name
    shortname           = var.network_stub
    api_health          = var.health_check_port
    polkadot_prometheus = var.polkadot_prometheus_port
    json_rpc            = var.rpc_api_port
    json_envoy          = var.rpc_envoy_port
    ws_rpc              = var.wss_api_port
    ws_envoy            = var.wss_envoy_port
  } } : var.network_settings
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

variable "rpc_envoy_port" {
  description = "Port number for the JSON RPC Envoy proxy"
  type        = string
  default     = "21000"
}

variable "wss_envoy_port" {
  description = "Port number for the Websockets Envoy proxy"
  type        = string
  default     = "21001"
}

variable "polkadot_prometheus_port" {
  description = "Port number for the Prometheus Metrics exporter built into the Polkadot client"
  type        = string
  default     = "9610"
}

variable "health_check_port" {
  description = "Port number for the health check"
  type        = string
  default     = "5500"
}

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

