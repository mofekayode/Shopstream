output "repository_urls" {
  description = "Map of repository names to URLs"
  value = {
    for k, v in aws_ecr_repository.services : k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to ARNs"
  value = {
    for k, v in aws_ecr_repository.services : k => v.arn
  }
}

output "registry_id" {
  description = "The registry ID"
  value       = values(aws_ecr_repository.services)[0].registry_id
}