variable "region"          {
    type = string
    default = "eu-west-1"
}
variable "profile"          {
    type = string
    default = "default"
}
variable "public_subnets"   { 
    type = list(string)
    default = ["10.92.2.0/24"] 
}
variable "instance_type"   {
    type = string
    default = "m5.4xlarge"
}
variable "ubuntu_owners"   {
    type = list(string)
    default = ["099720109477"]
} 
variable "tags" {
    type = map(string)
    default = { Project="RESILMESH", Environment="Pilot2" }
}
variable "vpc_cidr"        {
    type = string
    default = "10.92.0.0/16"
}
variable "enable_ssm"    { 
    type = bool
    default = false
}  
variable "client_public_ssh_keys" {
    type        = list(string)
    description = "Client SSH public keys for instance access."
}
variable "my_ips" {
    type = list(string)
    description = "IPs allowed to access EC2 or view the ports exposed by services."
}