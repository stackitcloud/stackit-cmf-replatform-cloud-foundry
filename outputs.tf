output "project_id" {
  value       = local.effective_project_id
  description = "The STACKIT project ID used for provisioning."
}

output "scf_org_id" {
  value       = stackit_scf_organization.org.org_id
  description = "SCF organization ID."
}

output "scf_org_manager_username" {
  value       = stackit_scf_organization_manager.org_manager.username
  description = "Technical Cloud Foundry organization manager username."
}

output "cf_space_id" {
  value       = var.setup_cloudfoundry_resources ? cloudfoundry_space.app[0].id : null
  description = "Cloud Foundry space ID."
}

output "cf_api_url" {
  value       = data.stackit_scf_platform.platform.api_url
  description = "Cloud Foundry API URL for subsequent app deployment runs."
}

output "scf_org_manager_password" {
  value       = stackit_scf_organization_manager.org_manager.password
  description = "Technical Cloud Foundry organization manager password."
  sensitive   = true
}

output "spring_music_route" {
  value       = var.setup_workload ? "https://${var.cf_app_host}.${var.cf_domain}" : null
  description = "Public route for Spring Music."
}

output "redis_instance_id" {
  value       = var.setup_database ? stackit_redis_instance.redis[0].instance_id : null
  description = "Redis instance ID."
}

output "rabbitmq_instance_id" {
  value       = var.setup_database ? stackit_rabbitmq_instance.rabbitmq[0].instance_id : null
  description = "RabbitMQ instance ID."
}

output "observability_instance_id" {
  value       = var.setup_observability ? stackit_observability_instance.platform[0].instance_id : null
  description = "Observability instance ID."
}
