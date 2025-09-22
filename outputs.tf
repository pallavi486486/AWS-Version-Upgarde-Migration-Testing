output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.example.arn
}
