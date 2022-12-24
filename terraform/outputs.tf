output "lb_endpoint" {
  value = "https://${aws_lb.test_jaguar.dns_name}"
}

output "application_endpoint" {
  value = "https://${aws_lb.test_jaguar.dns_name}/index.php"
}

output "asg_name" {
  value = aws_autoscaling_group.test_jaguar.name
}
