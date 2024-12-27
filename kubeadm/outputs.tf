# Outputs
output "instance_public_ips" {
  value = { for name, instance in aws_instance.kubeadm_instances : name => instance.public_ip }
}

output "dns_records" {
  value = { for name, record in aws_route53_record.kubeadm_dns_records : name => record.fqdn }
}
