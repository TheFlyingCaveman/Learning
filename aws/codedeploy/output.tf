output "instance_public_dns" {
  value = [aws_instance.web.*.public_dns]
}

output "instance_public_ip" {
  value = [aws_instance.web.*.public_ip]
}

output "lb_dns" {
  value = aws_lb.main.dns_name
}