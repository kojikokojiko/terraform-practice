terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

# module "describe_regions_for_ec2"{
#     source = "./iam_role"
#     name = "describe_regions_for_ec2"
#     identifer = "ec2.amazonaws.com"
#     policy=data.aws_iam_policy_document.allow_describe_regions.json
# }

module "example_sg"{
    source = "./security_group"
    name = "module-sg"
    vpc_id = aws_vpc.example.id
    port=80
    cidr_blocks = ["0.0.0.0/0"]

}

module "http_sg"{
    source = "./security_group"
    name = "http-sg"
    vpc_id = aws_vpc.example.id
    port=80
    cidr_blocks = ["0.0.0.0/0"]
}


module "https_sg"{
    source = "./security_group"
    name = "https-sg"
    vpc_id = aws_vpc.example.id
    port=443
    cidr_blocks = ["0.0.0.0/0"]
}


module "http_redirect_sg"{
    source = "./security_group"
    name = "http-redirect-sg"
    vpc_id = aws_vpc.example.id
    port=8080
    cidr_blocks = ["0.0.0.0/0"]
}
