# terraform-polkadot-aws-node

![](https://github.com/geometry-labs/terraform-polkadot-aws-node/actions/workflows/integration.yaml/badge.svg)


This module sets up a single node for the Polkadot blockchain and it's associated parachains on AWS. It uses Ansible to configure the node depending on its `node_purpose` which can be one of,

- `validator` - Requires manual unsealing 
- `library` - Archive node running on a configurable set of parachains 
- `source` of truth - Same a library but with an agent to push copies of the chain to S3 for autoscaling fast scale and sync operations 

The module is intended to be flexible in its configuration parameters allowing users specify networks and securtiy groups while also providing sane defaults for one click deployments. Users then have the option of attaching their own DNS record or with additional configuration, joining to a consul cluster and monitoring with prometheus.

## Requirements

- Terraform v.14+ tested 
- Ansible 2.9 - `pip install ansible`
- SSH Keys - `ssh-keygen -b 4096` (Only public required)

## Ansible Modules 

| Name | Version | 
| :--- | :--- | 
| [polkadot_base]() | ![](https://img.shields.io/github/v/release/geometry-labs/ansible-role-polkadot-base) | 
| [polkadot_library](https://github.com/geometry-labs/ansible-role-polkadot-library) | ![](https://img.shields.io/github/v/release/geometry-labs/ansible-role-polkadot-library) | 
| [polkadot_truth](https://github.com/geometry-labs/ansible-role-polkadot-truth) | ![](https://img.shields.io/github/v/release/geometry-labs/ansible-role-polkadot-truth) | 
| [polkadot_validator](https://github.com/geometry-labs/ansible-role-polkadot-validator) | ![](https://img.shields.io/github/v/release/geometry-labs/ansible-role-polkadot-validator) |
| [cloud_helper](https://github.com/geometry-labs/ansible-role-cloud-helper) |  ![](https://img.shields.io/github/v/release/geometry-labs/ansible-role-cloud-helper) | 

## Usage



Steps for running terraform:

1. Install the above [requirements](#requirements)
   
2. Get AWS API keys into environment variables
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

3. Create SSH keys and make note of the path (public_key_path variable) or copy the key material. 

```shell
ssh-keygen -b 4096 -f $HOME/.ssh/<your key name>
cat $HOME/.ssh/<your key name>.pub # this is the `public_key` variable
# $HOME/.ssh/<your key name> # This is the `private_key_path`
```

4. Use this module in your own terraform or modify one of the examples directory. Possible configurations are:

#### Defaults

Minimal defaults example for polkadot.  To run other parachains reference the other example. 

```hcl
module "default" {
  source           = "github.com/geometry-labs/terraform-polkadot-aws-node"
  name             = "default-${random_pet.this.id}"
  public_key       = var.public_key
  private_key_path = var.private_key_path
  node_purpose     = "library"
}
```
Deploys in default vpc and creates security group.  For public deployments 

#### External Network with Parachains 

To run additional parachains, complete the below map for `network_settings` to map ports to the associated chain. Ports will then be exposed over the load balancer. 

```hcl
locals {
  network_settings = {
    polkadot = {
      name                = "polkadot"
      shortname           = "polkadot"
      api_health          = "5000"
      polkadot_prometheus = "9610"
      json_rpc            = "9933"
      json_envoy          = "21000"
      ws_rpc              = "9944"
      ws_envoy            = "21001"
    }
    kusama = {
      name                = "kusama"
      shortname           = "ksmcc3"
      api_health          = "5001"
      polkadot_prometheus = "9611"
      json_rpc            = "9934"
      json_envoy          = "21002"
      ws_rpc              = "9945"
      ws_envoy            = "21003"
    }
  }
}

module "default" {
  source           = "github.com/geometry-labs/terraform-polkadot-aws-node.git?ref=v0.1.0"
  name             = "default-${random_pet.this.id}"
  public_key       = var.public_key
  private_key_path = var.private_key_path
  node_purpose     = "library"
  network_settings = local.network_settings
}
```

## Known issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible"></a> [ansible](#module\_ansible) | github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.15.0 |  |
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | github.com/insight-infrastructure/terraform-polkadot-user-data.git?ref=master |  |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.consul](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sot_host_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.consul](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sot_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.consul_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.consul](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sot_host_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet_ids.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ports"></a> [additional\_security\_group\_ports](#input\_additional\_security\_group\_ports) | Additional ports to add to security group. | `list(string)` | <pre>[<br>  "22"<br>]</pre> | no |
| <a name="input_base_path"></a> [base\_path](#input\_base\_path) | Alternate base path for Polkadot client | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the kubernetes cluster (if used) | `string` | `""` | no |
| <a name="input_consul_acl_datacenter"></a> [consul\_acl\_datacenter](#input\_consul\_acl\_datacenter) | Authoritative Consul ACL datacenter | `string` | `""` | no |
| <a name="input_consul_acl_enable"></a> [consul\_acl\_enable](#input\_consul\_acl\_enable) | Bool to enable Consul ACLs | `bool` | `false` | no |
| <a name="input_consul_acl_token"></a> [consul\_acl\_token](#input\_consul\_acl\_token) | Consul ACL token | `string` | `""` | no |
| <a name="input_consul_auto_encrypt_enabled"></a> [consul\_auto\_encrypt\_enabled](#input\_consul\_auto\_encrypt\_enabled) | Bool to enable Consul auto-encrypt | `bool` | `false` | no |
| <a name="input_consul_connect_enabled"></a> [consul\_connect\_enabled](#input\_consul\_connect\_enabled) | Bool to enable Consul Connect | `bool` | `false` | no |
| <a name="input_consul_enabled"></a> [consul\_enabled](#input\_consul\_enabled) | Bool to enable Consul | `bool` | `false` | no |
| <a name="input_consul_gossip_key"></a> [consul\_gossip\_key](#input\_consul\_gossip\_key) | Consul gossip encryption key | `string` | `""` | no |
| <a name="input_consul_security_group"></a> [consul\_security\_group](#input\_consul\_security\_group) | ID of security group to containing Consul | `string` | `null` | no |
| <a name="input_consul_tls_ca_filename"></a> [consul\_tls\_ca\_filename](#input\_consul\_tls\_ca\_filename) | Filename for Consul TLS CA certificate | `string` | `"ca.crt"` | no |
| <a name="input_consul_tls_source_dir"></a> [consul\_tls\_source\_dir](#input\_consul\_tls\_source\_dir) | Path to directory containing Consul TLS certs | `string` | `null` | no |
| <a name="input_consul_version"></a> [consul\_version](#input\_consul\_version) | Consul version number to install | `string` | `"1.9.4"` | no |
| <a name="input_create"></a> [create](#input\_create) | Boolean to make module or not | `bool` | `true` | no |
| <a name="input_create_ansible"></a> [create\_ansible](#input\_create\_ansible) | Boolean to make module or not | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Bool to create SG | `bool` | `true` | no |
| <a name="input_default_telemetry_enabled"></a> [default\_telemetry\_enabled](#input\_default\_telemetry\_enabled) | Bool to enable telemetry submission to telemetry.polkadot.io | `bool` | `false` | no |
| <a name="input_hardening_enabled"></a> [hardening\_enabled](#input\_hardening\_enabled) | Runs a series of linux hardening playbooks - ansible-collection-hardening | `bool` | `false` | no |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Bool to enable client health check agent | `bool` | `false` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Port number for the health check | `string` | `"5500"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM instance profile name, overrides source of truth IAM. | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Iteration number for this instance | `string` | `"0"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type | `string` | `"t3a.small"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the preexisting key to be used instead of the local public\_key\_path | `string` | `""` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | String for polkadot logging filter | `string` | `"sync=trace,afg=trace,babe=debug"` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Boolean for cloudwatch | `bool` | `false` | no |
| <a name="input_mount_volumes"></a> [mount\_volumes](#input\_mount\_volumes) | Bool to enable non-root volume mounting | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the deployment | `string` | `"polkadot-api"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The network name, ie kusama / polkadot | `string` | `"polkadot"` | no |
| <a name="input_network_settings"></a> [network\_settings](#input\_network\_settings) | Map of network settings to apply. Use either this or set individual variables. | <pre>map(object({<br>    name                = string<br>    shortname           = string<br>    api_health          = string<br>    polkadot_prometheus = string<br>    json_rpc            = string<br>    json_envoy          = string<br>    ws_rpc              = string<br>    ws_envoy            = string<br>  }))</pre> | `null` | no |
| <a name="input_network_stub"></a> [network\_stub](#input\_network\_stub) | The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3) | `string` | `"ksmcc3"` | no |
| <a name="input_node_exporter_enabled"></a> [node\_exporter\_enabled](#input\_node\_exporter\_enabled) | Bool to enable node exporter | `bool` | `false` | no |
| <a name="input_node_exporter_hash"></a> [node\_exporter\_hash](#input\_node\_exporter\_hash) | SHA256 hash of Node Exporter binary | `string` | `"b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"` | no |
| <a name="input_node_exporter_password"></a> [node\_exporter\_password](#input\_node\_exporter\_password) | Password for node exporter | `string` | `"node_exporter_password"` | no |
| <a name="input_node_exporter_url"></a> [node\_exporter\_url](#input\_node\_exporter\_url) | URL to Node Exporter binary | `string` | `"https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"` | no |
| <a name="input_node_exporter_user"></a> [node\_exporter\_user](#input\_node\_exporter\_user) | User for node exporter | `string` | `"node_exporter_user"` | no |
| <a name="input_node_purpose"></a> [node\_purpose](#input\_node\_purpose) | What type of node are you deploying? (validator/library/truth) | `string` | `"library"` | no |
| <a name="input_polkadot_additional_common_flags"></a> [polkadot\_additional\_common\_flags](#input\_polkadot\_additional\_common\_flags) | Optional common flags for Polkadot client | `string` | `""` | no |
| <a name="input_polkadot_additional_validator_flags"></a> [polkadot\_additional\_validator\_flags](#input\_polkadot\_additional\_validator\_flags) | Optional validator flags for Polkadot client | `string` | `""` | no |
| <a name="input_polkadot_client_hash"></a> [polkadot\_client\_hash](#input\_polkadot\_client\_hash) | SHA256 hash of Polkadot client binary | `string` | `"0b27d0cb99ca60c08c78102a9d2f513d89dfec8dbd6fdeba8b952a420cdc9fd2"` | no |
| <a name="input_polkadot_client_url"></a> [polkadot\_client\_url](#input\_polkadot\_client\_url) | URL to Polkadot client binary | `string` | `"https://github.com/paritytech/polkadot/releases/download/v0.8.29/polkadot"` | no |
| <a name="input_polkadot_prometheus_port"></a> [polkadot\_prometheus\_port](#input\_polkadot\_prometheus\_port) | Port number for the Prometheus Metrics exporter built into the Polkadot client | `string` | `"9610"` | no |
| <a name="input_polkadot_restart_day"></a> [polkadot\_restart\_day](#input\_polkadot\_restart\_day) | Client cron restart day | `string` | `""` | no |
| <a name="input_polkadot_restart_enabled"></a> [polkadot\_restart\_enabled](#input\_polkadot\_restart\_enabled) | Bool to enable client restart cron job | `bool` | `false` | no |
| <a name="input_polkadot_restart_hour"></a> [polkadot\_restart\_hour](#input\_polkadot\_restart\_hour) | Client cron restart hour | `string` | `""` | no |
| <a name="input_polkadot_restart_minute"></a> [polkadot\_restart\_minute](#input\_polkadot\_restart\_minute) | Client cron restart minute | `string` | `""` | no |
| <a name="input_polkadot_restart_month"></a> [polkadot\_restart\_month](#input\_polkadot\_restart\_month) | Client cron restart month | `string` | `""` | no |
| <a name="input_polkadot_restart_weekday"></a> [polkadot\_restart\_weekday](#input\_polkadot\_restart\_weekday) | Client cron restart weekday | `string` | `""` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Path to private key | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Name of the project for node name | `string` | `"project"` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Bool to use when Prometheus is enabled | `bool` | `false` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The public ssh key. key\_name takes precidence | `string` | `""` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume size | `string` | `0` | no |
| <a name="input_rpc_api_port"></a> [rpc\_api\_port](#input\_rpc\_api\_port) | Port number for the JSON RPC API | `string` | `"9933"` | no |
| <a name="input_rpc_envoy_port"></a> [rpc\_envoy\_port](#input\_rpc\_envoy\_port) | Port number for the JSON RPC Envoy proxy | `string` | `"21000"` | no |
| <a name="input_security_group_cidr_blocks"></a> [security\_group\_cidr\_blocks](#input\_security\_group\_cidr\_blocks) | If create\_security\_group enabled, incoming cidr blocks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The ids of the security group to run in | `list(string)` | `[]` | no |
| <a name="input_skip_health_check"></a> [skip\_health\_check](#input\_skip\_health\_check) | Bool to skip client health check when agent installed | `bool` | `true` | no |
| <a name="input_source_of_truth_enabled"></a> [source\_of\_truth\_enabled](#input\_source\_of\_truth\_enabled) | Bool to enable SoT sync (for use with library nodes) | `bool` | `false` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Username for SSH | `string` | `"ubuntu"` | no |
| <a name="input_storage_driver_type"></a> [storage\_driver\_type](#input\_storage\_driver\_type) | Type of EBS storage the instance is using (nitro/standard) | `string` | `"standard"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The id of the subnet. | `string` | `""` | no |
| <a name="input_sync_bucket_uri"></a> [sync\_bucket\_uri](#input\_sync\_bucket\_uri) | S3 bucket URI for SoT sync | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to associate with resources. | `map(string)` | `{}` | no |
| <a name="input_telemetry_url"></a> [telemetry\_url](#input\_telemetry\_url) | WSS URL for telemetry | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID to run inside. | `string` | `""` | no |
| <a name="input_wss_api_port"></a> [wss\_api\_port](#input\_wss\_api\_port) | Port number for the Websockets API | `string` | `"9944"` | no |
| <a name="input_wss_envoy_port"></a> [wss\_envoy\_port](#input\_wss\_envoy\_port) | Port number for the Websockets Envoy proxy | `string` | `"21001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
| <a name="output_sync_bucket_name"></a> [sync\_bucket\_name](#output\_sync\_bucket\_name) | n/a |
| <a name="output_sync_bucket_uri"></a> [sync\_bucket\_uri](#output\_sync\_bucket\_uri) | n/a |
| <a name="output_this_security_group_id"></a> [this\_security\_group\_id](#output\_this\_security\_group\_id) | n/a |
| <a name="output_this_security_group_ids"></a> [this\_security\_group\_ids](#output\_this\_security\_group\_ids) | n/a |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [robc-io](github.com/robc-io)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.