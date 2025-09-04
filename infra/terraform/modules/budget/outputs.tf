output "monthly_budget_id" {
  description = "ID of the monthly cost budget"
  value       = aws_budgets_budget.monthly_cost.id
}

output "service_budget_ids" {
  description = "IDs of the service-specific budgets"
  value       = { for k, v in aws_budgets_budget.service_budgets : k => v.id }
}

output "ec2_usage_budget_id" {
  description = "ID of the EC2 usage budget"
  value       = aws_budgets_budget.ec2_usage.id
}