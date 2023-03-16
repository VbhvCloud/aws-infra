## Add terrform outputs here.
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_route_id" {
  value = aws_route.public_route.id
}

output "instance_public_link" {
  value = "http://${var.a_record_name}:8000/healthz"
}

output "db_instance_ip" {
  value = aws_db_instance.main.address
} 