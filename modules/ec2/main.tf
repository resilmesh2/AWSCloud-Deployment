resource "aws_instance" "this" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = var.security_group_ids
    iam_instance_profile        = var.iam_instance_profile
    associate_public_ip_address = false
    ebs_optimized               = true
    user_data_replace_on_change = true
    monitoring = true
    user_data = templatefile(
        "${path.module}/user_data.sh",
        {
            client_public_ssh_keys = var.client_public_ssh_keys,
            github_token = var.github_token
        }
    )
    tags = merge(var.tags, { Name = "ec2-${var.tags.Project}-${var.tags.Environment}" })

    root_block_device {
        volume_size = 1000
        volume_type = "gp3"
        encrypted   = true
        delete_on_termination = true
    }
}
resource "aws_eip" "this" {
    instance = aws_instance.this.id
    domain   = "vpc"
}