output "lb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.main.id
}

output "lb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.main.arn_suffix
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.main.arn_suffix
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.main.name
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}
