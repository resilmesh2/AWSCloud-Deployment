output "public_subnet_id"   { value = aws_subnet.public.id }
output "security_group_ids" { value = values(aws_security_group.instance_per_ip)[*].id }