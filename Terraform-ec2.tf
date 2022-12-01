resource "aws_instance" "webserver"{
 ami                           = "ami-074dc0a6f6c764218"
 instance_type                 = "t2.micro"
 subnet_id                     = aws_subnet.publicsubnet.id
 vpc_security_group_ids        = [aws_security_group.pubsg.id]
 key_name                      = "LINUXNEW"
 associate_public_ip_address   = true
}
