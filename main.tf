variable "create" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
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

