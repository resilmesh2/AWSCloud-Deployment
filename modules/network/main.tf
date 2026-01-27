data "aws_region" "current" {}
data "aws_availability_zones" "azs" { state = "available" }

resource "aws_vpc" "this" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = merge(var.tags, { Name = "vpc-${var.tags.Project}-${var.tags.Environment}" })
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.this.id
    tags   = merge(var.tags, { Name = "igw-${var.tags.Project}-${var.tags.Environment}" })
}

resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.this.id
    cidr_block              = var.public_subnets[0]
    availability_zone       = data.aws_availability_zones.azs.names[0]
    map_public_ip_on_launch = false
    tags = merge(var.tags, { Name = "sn-public-${var.tags.Project}-${var.tags.Environment}" })
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id
    tags   = merge(var.tags, { Name = "rt-public-${var.tags.Project}-${var.tags.Environment}" })
}

resource "aws_route" "public_igw" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id       = aws_subnet.public.id
    route_table_id  = aws_route_table.public.id
}

locals {
    service_ports = {
        ssh                 = 22
        http                = 80
        https               = 443
        ndr                 = 3000
        nse_back            = 3002
        ppcti_front         = 3100
        iob_stix            = 3400
        shuffle             = 3443
        graphql1            = 4001
        sacd                = 4200
        nse_front           = 4201
        wazuh               = 4433
        isim_autimation     = 5000
        dfir                = 5005
        neo4j               = 7474
        neo4j_internal      = 7687
        isim                = 8000
        thf_api             = 8030
        ppcti_anonymizer    = 8070
        temporal            = 8080
        landing             = 8181
        thf_ui              = 8501 
        iob_sanic           = 9003
        iob_flow_builder    = 9080
        wazuh_indexer       = 9201
        misp                = 10443
        ndr_server          = 31057
    }
}

resource "aws_security_group" "instance_per_ip" {
    for_each    = toset(var.my_ips)
    name        = "sec-instance-${var.tags.Project}-${var.tags.Environment}-${trimsuffix(each.key, "/32")}"
    description = "EC2 access for all services, restricted only to IP: ${each.key}"
    vpc_id      = aws_vpc.this.id

    # Ingress dinámico
    dynamic "ingress" {
        for_each = local.service_ports

        content {
            description = "Allow ${ingress.key}"
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = [each.key]
        }
    }

    # Egress
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, { Name = "sg-instance-access-from-${trimsuffix(each.key, "/32")}" })
}