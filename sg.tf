
locals {
  security_group_open_ports = concat(distinct(flatten([for net in local.network_settings : [net["api_health"], net["json_rpc"], net["ws_rpc"]]])), var.additional_security_group_ports)
}

variable "additional_security_group_ports" {
  description = "Additional ports to add to security group."
  type        = list(string)
  default     = ["22"]
}

variable "create_security_group" {
  description = "Bool to create SG"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The VPC ID to run inside."
  type        = string
  default     = ""
}

data "aws_vpc" "this" {
  default = true
}

data "aws_subnet_ids" "this" {
  vpc_id = data.aws_vpc.this.id
}

data "aws_subnet" "this" {
  id = var.subnet_id == "" ? tolist(data.aws_subnet_ids.this.ids)[0] : var.subnet_id
}

resource "aws_security_group" "this" {
  count       = var.create && var.create_security_group ? 1 : 0
  description = "Polkadot API Node Ingress."
  name        = "${var.name}-sg"
  vpc_id      = data.aws_subnet.this.vpc_id
  tags        = merge(var.tags, { Name = var.name })
}

variable "security_group_cidr_blocks" {
  description = "If create_security_group enabled, incoming cidr blocks."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create && var.create_security_group ? length(local.security_group_open_ports) : 0
  from_port         = local.security_group_open_ports[count.index]
  to_port           = local.security_group_open_ports[count.index]
  protocol          = "tcp"
  security_group_id = join("", aws_security_group.this.*.id)
  cidr_blocks       = var.security_group_cidr_blocks
  type              = "ingress"
}

resource "aws_security_group_rule" "egress" {
  count             = var.create && var.create_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this.*.id)
}

output "this_security_group_id" {
  value = join("", aws_security_group.this.*.id)
}

output "this_security_group_ids" {
  value = concat(var.security_group_ids, aws_security_group.this.*.id)
}

