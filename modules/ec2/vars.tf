variable "ami_id"               { type = string }
variable "instance_type"        { type = string }
variable "subnet_id"            { type = string }
variable "iam_instance_profile" { type = string }
variable "tags"                 { type = map(string) }
variable "client_public_ssh_keys" {
    type        = list(string)
    description = "Client SSH public keys for instance access."
}
variable "github_token" {
    type        = string
    description = "GitHub token for accessing private repositories."
}
variable "security_group_ids" {
    description = "Lista de IDs de Security Groups a adjuntar a la instancia EC2."
    type        = list(string)
}