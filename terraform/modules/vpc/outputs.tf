output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway (if enabled)"
  value       = var.enable_nat_gateway ? aws_eip.nat.public_ip : null
}