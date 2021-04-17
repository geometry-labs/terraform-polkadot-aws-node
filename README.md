# terraform-polkadot-aws-node

This module sets up single node deployments for polkadot, but can also be used to deploy nodes in a multi-node configuration.
Options include validator, API, and source of truth nodes. 

## Usage

```hcl
module "network" {
  source = "github.com/insight-infrastructure/terraform-aws-polkadot-network.git?ref=master"
  sentry_enabled = true
  num_azs = 1
}

module "default" {
  source            = "../.."
  public_key        = var.public_key
  subnet_id         = module.network.public_subnets[0]
  security_group_id = module.network.sentry_security_group_id
  private_key_path  = var.private_key_path
  create_ansible    = var.create_ansible
}
```

## Examples

- [simple](https://github.com/insight-infrastructure/terraform-polkadot-aws-sentry-node/tree/master/examples/simple)

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
| ansible | github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.12.0 |  |
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_group\_ports | Additional ports to add to security group. | `list(string)` | <pre>[<br>  "22"<br>]</pre> | no |
| base\_path | Alternate base path for Polkadot client | `string` | `""` | no |
| consul\_enabled | Bool to enable Consul | `bool` | `true` | no |
| create | Boolean to make module or not | `bool` | `true` | no |
| create\_ansible | Boolean to make module or not | `bool` | `true` | no |
| create\_security\_group | Bool to create SG | `bool` | `true` | no |
| default\_telemetry\_enabled | Bool to enable telemetry submission to telemetry.polkadot.io | `bool` | `false` | no |
| health\_check\_enabled | Bool to enable client health check agent | `bool` | `true` | no |
| health\_check\_port | Port number for the health check | `string` | `"5500"` | no |
| iam\_instance\_profile | IAM instance profile name, overrides source of truth IAM. | `string` | `""` | no |
| instance\_count | Iteration number for this instance | `string` | `"0"` | no |
| instance\_type | Instance type | `string` | `"t2.micro"` | no |
| key\_name | The name of the preexisting key to be used instead of the local public\_key\_path | `string` | `""` | no |
| logging\_filter | String for polkadot logging filter | `string` | `"sync=trace,afg=trace,babe=debug"` | no |
| monitoring | Boolean for cloudwatch | `bool` | `false` | no |
| mount\_volumes | Bool to enable non-root volume mounting | `bool` | `false` | no |
| name | The name of the deployment | `string` | `"polkadot-api"` | no |
| network\_name | The network name, ie kusama / polkadot | `string` | `"polkadot"` | no |
| network\_settings | Map of network settings to apply. Use either this or set individual variables. | <pre>map(object({<br>    name                = string<br>    shortname           = string<br>    api_health          = string<br>    polkadot_prometheus = string<br>    json_rpc            = string<br>    ws_rpc              = string<br>  }))</pre> | `null` | no |
| network\_stub | The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3) | `string` | `"ksmcc3"` | no |
| node\_exporter\_enabled | Bool to enable node exporter | `bool` | `true` | no |
| node\_exporter\_hash | SHA256 hash of Node Exporter binary | `string` | `"b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"` | no |
| node\_exporter\_password | Password for node exporter | `string` | `"node_exporter_password"` | no |
| node\_exporter\_url | URL to Node Exporter binary | `string` | `"https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"` | no |
| node\_exporter\_user | User for node exporter | `string` | `"node_exporter_user"` | no |
| node\_purpose | What type of node are you deploying? (validator/library/truth) | `string` | `"library"` | no |
| polkadot\_additional\_common\_flags | Optional common flags for Polkadot client | `string` | `""` | no |
| polkadot\_additional\_validator\_flags | Optional validator flags for Polkadot client | `string` | `""` | no |
| polkadot\_client\_hash | SHA256 hash of Polkadot client binary | `string` | `"cdf31d39ed54e66489d1afe74ed7549d5bcdf8ff479759e8fc476d17d069901e"` | no |
| polkadot\_client\_url | URL to Polkadot client binary | `string` | `"https://github.com/w3f/polkadot/releases/download/v0.8.23/polkadot"` | no |
| polkadot\_prometheus\_port | Port number for the Prometheus Metrics exporter built into the Polkadot client | `string` | `"9610"` | no |
| polkadot\_restart\_day | Client cron restart day | `string` | `""` | no |
| polkadot\_restart\_enabled | Bool to enable client restart cron job | `bool` | `false` | no |
| polkadot\_restart\_hour | Client cron restart hour | `string` | `""` | no |
| polkadot\_restart\_minute | Client cron restart minute | `string` | `""` | no |
| polkadot\_restart\_month | Client cron restart month | `string` | `""` | no |
| polkadot\_restart\_weekday | Client cron restart weekday | `string` | `""` | no |
| private\_key\_path | Path to private key | `string` | `""` | no |
| project | Name of the project for node name | `string` | `"project"` | no |
| public\_key | The public ssh key. key\_name takes precidence | `string` | `""` | no |
| root\_volume\_size | Root volume size | `string` | `0` | no |
| rpc\_api\_port | Port number for the JSON RPC API | `string` | `"9933"` | no |
| security\_group\_cidr\_blocks | If create\_security\_group enabled, incoming cidr blocks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| security\_group\_ids | The ids of the security group to run in | `list(string)` | `[]` | no |
| source\_of\_truth\_enabled | Bool to enable SoT sync (for use with library nodes) | `bool` | `false` | no |
| ssh\_user | Username for SSH | `string` | `"ubuntu"` | no |
| storage\_driver\_type | Type of EBS storage the instance is using (nitro/standard) | `string` | `"standard"` | no |
| subnet\_id | The id of the subnet. | `string` | `""` | no |
| sync\_bucket\_uri | S3 bucket URI for SoT sync | `string` | `null` | no |
| tags | Tags to associate with resources. | `map(string)` | `{}` | no |
| telemetry\_url | WSS URL for telemetry | `string` | `""` | no |
| vpc\_id | The VPC ID to run inside. | `string` | `""` | no |
| wss\_api\_port | Port number for the Websockets API | `string` | `"9944"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | n/a |
| private\_ip | n/a |
| public\_ip | n/a |
| security\_group\_id | n/a |
| subnet\_id | n/a |
| sync\_bucket\_name | n/a |
| sync\_bucket\_uri | n/a |
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