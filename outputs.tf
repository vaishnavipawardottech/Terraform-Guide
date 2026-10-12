
# outputs for count
# output "ec2_public_ip" {
#     value = aws_instance.my_instance.public_ip
# }

# output "ec2_public_dns" {
#     value = aws_instance.my_instance.public_dns
# }


# output for for_each
output "ec2_public_ip" {
    value = [
        for instance in aws_instance.my_instance :  instance.public_ip
    ]
}