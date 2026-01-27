module "network" {
    source              = "./modules/network"
    vpc_cidr            = var.vpc_cidr
    public_subnets      = var.public_subnets
    my_ips              = var.my_ips
    enable_ssm          = var.enable_ssm
    tags                = var.tags
}
module "iam" {
    source  = "./modules/iam"
    tags    = var.tags
}
module "ec2" {
    source                = "./modules/ec2"
    client_public_ssh_keys= var.client_public_ssh_keys
    github_token          = var.github_token
    subnet_id             = module.network.public_subnet_id
    security_group_ids    = module.network.security_group_ids
    iam_instance_profile  = module.iam.instance_profile
    ami_id                = data.aws_ami.ubuntu_2404.id
    instance_type         = var.instance_type
    tags                  = var.tags
}