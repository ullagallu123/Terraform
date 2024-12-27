# Fetch Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Launch Instances with Specific Names
resource "aws_instance" "kubeadm_instances" {
  for_each      = var.instance_names
  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value
  user_data     = file("${path.module}/kubeadm.sh")
  key_name      = var.key_name
  tags = {
    Name = "kubeadm-${each.key}"
  }
}

# Create Route53 Records for Each Instance
resource "aws_route53_record" "kubeadm_dns_records" {
  for_each = aws_instance.kubeadm_instances
  zone_id  = var.zone_id
  name     = "${each.key}.${var.zone_name}"
  type     = "A"
  ttl      = 1
  records  = [each.value.public_ip]
}
