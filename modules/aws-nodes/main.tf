resource "aws_instance" "nodes" {
  ami                         = var.ami
  instance_type               = var.ec2-instance-type
  # TODO REM double check this key.
  # key_name                    = aws_key_pair.debug1.key_name
  # TODO Make this a variable.
  associate_public_ip_address = true
  subnet_id                   = var.subnet-id
  vpc_security_group_ids = var.security-group-ids
  user_data = element(var.user-datas.*.rendered, count.index)
  count                       = var.num-nodes

  tags = {
    Name = "${var.name-prefix}-${count.index}"
  }
}
