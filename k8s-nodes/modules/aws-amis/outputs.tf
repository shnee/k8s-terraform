output "amis" {
  value = tomap({ for type, ami in data.aws_ami.amis : type => ami.id })
}
