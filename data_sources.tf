data "aws_ami" "ubuntu_2404" {
    owners      = var.ubuntu_owners
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}