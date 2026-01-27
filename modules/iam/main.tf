data "aws_iam_policy_document" "assume_ec2" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}
resource "aws_iam_role" "ec2" {
    name               = "role-ec2-${var.tags.Project}-${var.tags.Environment}"
    assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
    tags               = var.tags
}
resource "aws_iam_role_policy_attachment" "ssm" {
    role       = aws_iam_role.ec2.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "this" {
    name = "iprof-ec2-${var.tags.Project}-${var.tags.Environment}"
    role = aws_iam_role.ec2.name
}
