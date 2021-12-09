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
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ansible | github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.15.0 |  |
| user_data | github.com/insight-infrastructure/terraform-polkadot-user-data.git?ref=master |  |

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) |
| [aws_eip_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) |
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) |
| [aws_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_group\_ports | Additional ports to add to security group. | `list(string)` | <pre>[<br>  "22"<br>]</pre> | no |
| base\_path | Alternate base path for Polkadot client | `string` | `""` | no |
| cluster\_name | Name of the kubernetes cluster (if used) | `string` | `""` | no |
| consul\_acl\_datacenter | Authoritative Consul ACL datacenter | `string` | `""` | no |
| consul\_acl\_enable | Bool to enable Consul ACLs | `bool` | `false` | no |
| consul\_acl\_token | Consul ACL token | `string` | `""` | no |
| consul\_auto\_encrypt\_enabled | Bool to enable Consul auto-encrypt | `bool` | `false` | no |
| consul\_connect\_enabled | Bool to enable Consul Connect | `bool` | `false` | no |
| consul\_enabled | Bool to enable Consul | `bool` | `false` | no |
| consul\_gossip\_key | Consul gossip encryption key | `string` | `""` | no |
| consul\_security\_group | ID of security group to containing Consul | `string` | `null` | no |
| consul\_tls\_ca\_filename | Filename for Consul TLS CA certificate | `string` | `"ca.crt"` | no |
| consul\_tls\_source\_dir | Path to directory containing Consul TLS certs | `string` | `null` | no |
| consul\_version | Consul version number to install | `string` | `"1.9.4"` | no |
| create | Boolean to make module or not | `bool` | `true` | no |
| create\_ansible | Boolean to make module or not | `bool` | `true` | no |
| create\_security\_group | Bool to create SG | `bool` | `true` | no |
| default\_telemetry\_enabled | Bool to enable telemetry submission to telemetry.polkadot.io | `bool` | `false` | no |
| enable\_kms | n/a | `bool` | `false` | no |
| hardening\_enabled | Runs a series of linux hardening playbooks - ansible-collection-hardening | `bool` | `false` | no |
| health\_check\_enabled | Bool to enable client health check agent | `bool` | `false` | no |
| health\_check\_port | Port number for the health check | `string` | `"5500"` | no |
| iam\_instance\_profile | IAM instance profile name, overrides source of truth IAM. | `string` | `""` | no |
| instance\_count | Iteration number for this instance | `string` | `"0"` | no |
| instance\_type | Instance type | `string` | `"t3a.small"` | no |
| key\_name | The name of the preexisting key to be used instead of the local public\_key\_path | `string` | `""` | no |
| logging\_filter | String for polkadot logging filter | `string` | `"sync=trace,afg=trace,babe=debug"` | no |
| monitoring | Boolean for cloudwatch | `bool` | `false` | no |
| mount\_volumes | Bool to enable non-root volume mounting | `bool` | `false` | no |
| name | The name of the deployment | `string` | `"polkadot-api"` | no |
| network\_name | The network name, ie kusama / polkadot | `string` | `"polkadot"` | no |
| network\_settings | Map of network settings to apply. Use either this or set individual variables. | <pre>map(object({<br>    name                = string<br>    shortname           = string<br>    api_health          = string<br>    polkadot_prometheus = string<br>    json_rpc            = string<br>    json_envoy          = string<br>    ws_rpc              = string<br>    ws_envoy            = string<br>  }))</pre> | `null` | no |
| network\_stub | The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3) | `string` | `"ksmcc3"` | no |
| node\_exporter\_enabled | Bool to enable node exporter | `bool` | `false` | no |
| node\_exporter\_hash | SHA256 hash of Node Exporter binary | `string` | `"b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"` | no |
| node\_exporter\_password | Password for node exporter | `string` | `"node_exporter_password"` | no |
| node\_exporter\_url | URL to Node Exporter binary | `string` | `"https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"` | no |
| node\_exporter\_user | User for node exporter | `string` | `"node_exporter_user"` | no |
| node\_purpose | What type of node are you deploying? (validator/library/truth) | `string` | `"library"` | no |
| polkadot\_additional\_common\_flags | Optional common flags for Polkadot client | `string` | `""` | no |
| polkadot\_additional\_validator\_flags | Optional validator flags for Polkadot client | `string` | `""` | no |
| polkadot\_client\_hash | SHA256 hash of Polkadot client binary | `string` | `"0b27d0cb99ca60c08c78102a9d2f513d89dfec8dbd6fdeba8b952a420cdc9fd2"` | no |
| polkadot\_client\_url | URL to Polkadot client binary | `string` | `"https://github.com/paritytech/polkadot/releases/download/v0.8.29/polkadot"` | no |
| polkadot\_prometheus\_port | Port number for the Prometheus Metrics exporter built into the Polkadot client | `string` | `"9610"` | no |
| polkadot\_restart\_day | Client cron restart day | `string` | `""` | no |
| polkadot\_restart\_enabled | Bool to enable client restart cron job | `bool` | `false` | no |
| polkadot\_restart\_hour | Client cron restart hour | `string` | `""` | no |
| polkadot\_restart\_minute | Client cron restart minute | `string` | `""` | no |
| polkadot\_restart\_month | Client cron restart month | `string` | `""` | no |
| polkadot\_restart\_weekday | Client cron restart weekday | `string` | `""` | no |
| private\_key\_path | Path to private key | `string` | n/a | yes |
| project | Name of the project for node name | `string` | `"project"` | no |
| prometheus\_enabled | Bool to use when Prometheus is enabled | `bool` | `false` | no |
| public\_key | The public ssh key. key\_name takes precidence | `string` | `""` | no |
| root\_volume\_size | Root volume size | `string` | `0` | no |
| rpc\_api\_port | Port number for the JSON RPC API | `string` | `"9933"` | no |
| rpc\_envoy\_port | Port number for the JSON RPC Envoy proxy | `string` | `"21000"` | no |
| security\_group\_cidr\_blocks | If create\_security\_group enabled, incoming cidr blocks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| security\_group\_ids | The ids of the security group to run in | `list(string)` | `[]` | no |
| skip\_health\_check | Bool to skip client health check when agent installed | `bool` | `true` | no |
| source\_of\_truth\_enabled | Bool to enable SoT sync (for use with library nodes) | `bool` | `false` | no |
| ssh\_user | Username for SSH | `string` | `"ubuntu"` | no |
| storage\_driver\_type | Type of EBS storage the instance is using (nitro/standard) | `string` | `"standard"` | no |
| subnet\_id | The id of the subnet. | `string` | `""` | no |
| sync\_bucket\_name | S3 bucket name for SoT sync | `string` | `null` | no |
| tags | Tags to associate with resources. | `map(string)` | `{}` | no |
| telemetry\_url | WSS URL for telemetry | `string` | `""` | no |
| vpc\_id | The VPC ID to run inside. | `string` | `""` | no |
| wss\_api\_port | Port number for the Websockets API | `string` | `"9944"` | no |
| wss\_envoy\_port | Port number for the Websockets Envoy proxy | `string` | `"21001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | n/a |
| kms\_key\_arn | n/a |
| private\_ip | n/a |
| public\_ip | n/a |
| security\_group\_id | n/a |
| subnet\_id | n/a |
| sync\_bucket\_arn | n/a |
| sync\_bucket\_domain\_name | n/a |
| sync\_bucket\_name | n/a |
| this\_security\_group\_id | n/a |
| this\_security\_group\_ids | n/a |
| user\_data | n/a |
| vpc\_id | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [robc-io](github.com/robc-io)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.