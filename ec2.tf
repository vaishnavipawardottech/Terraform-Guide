# key-pair (login)
resource aws_key_pair my-key {
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")
}


# VPC & Security Group
resource aws_default_vpc default {

}

resource aws_security_group my_security_group {
    name = "automate-sg"
    description = "This will add a TF relatedSecurity group"
    vpc_id = aws_default_vpc.default.id   #interpolation

    # Inbound Rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH from anywhere"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP from anywhere"
    }

    # Outbound Rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }

    tags = {
        Name: "automate-sg"
    }
}

# ec2 instance
resource "aws_instance" "my_instance" {
    key_name = aws_key_pair.my-key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = var.ec2_instance_type
    ami = var.ec2_ami_id   #ubuntu
    user_data = file("install_nginx.sh")

    root_block_device {
        volume_size = 15
        volume_type = "gp3"
    }
    tags = {
        Name = "Created-using-Terraform"
    }
}