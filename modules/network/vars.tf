variable "vpc_cidr" { type = string }
variable "public_subnets"  { type = list(string) }
variable "tags"         { type = map(string) }
variable "enable_ssm" { default = true }
variable "my_ips" {
    type = list(string)
    description = "IPs allowed to access EC2 or view the ports exposed by services."
}
