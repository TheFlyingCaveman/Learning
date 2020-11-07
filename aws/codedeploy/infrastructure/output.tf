output "instance_public_dns" {
  value = [aws_instance.web.*.public_dns]
}

output "lb_dns" {
  value = "http://${aws_lb.main.dns_name}"
}