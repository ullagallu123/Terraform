output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for public in aws_subnet.public : public.id]
}

output "private_subnet_ids" {
  value = [for private in aws_subnet.private : private.id]
}

output "db_subnet_ids" {
  value = [for db in aws_subnet.db : db.id]
}

output "db_subnet_group" {
  value = aws_db_subnet_group.default[0].name
}

output "eip" {
  value = [for eip in aws_eip.nat : eip.public_ip]
}

output "nat_id" {
  value = [for nat in aws_nat_gateway.example : nat.id]
}

