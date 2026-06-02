output "project_id" {
  value       = local.effective_project_id
  description = "The STACKIT project ID used for provisioning."
}

output "scf_org_id" {
  value       = stackit_scf_organization.org.org_id
  description = "SCF organization ID."
}

output "scf_org_name" {
  value       = stackit_scf_organization.org.name
  description = "SCF organization name."
}

output "scf_org_manager_username" {
  value       = stackit_scf_organization_manager.org_manager.username
  description = "Technical Cloud Foundry organization manager username."
}

output "cf_space_id" {
  value       = try(cloudfoundry_space.app[0].id, null)
  description = "Cloud Foundry space ID."
}

output "cf_space_name" {
  value       = try(cloudfoundry_space.app[0].name, null)
  description = "Cloud Foundry space name."
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

output "spring_music_app_name" {
  value       = try(cloudfoundry_app.spring_music[0].name, null)
  description = "Spring Music application name in Cloud Foundry."
}

output "spring_music_app_id" {
  value       = try(cloudfoundry_app.spring_music[0].id, null)
  description = "Spring Music application GUID."
}

output "spring_music_route" {
  value       = try("https://${cloudfoundry_route.spring_music[0].url}", null)
  description = "Public route for Spring Music."
}

output "spring_music_route_host" {
  value       = try(cloudfoundry_route.spring_music[0].host, null)
  description = "Host part of the Spring Music route."
}

output "spring_music_route_domain" {
  value       = var.cf_domain
  description = "Domain used for the Spring Music route."
}

output "postgres_instance_id" {
  value       = try(cloudfoundry_service_instance.postgres[0].id, null)
  description = "Cloud Foundry PostgreSQL service instance GUID."
}

output "autoscaler_instance_id" {
  value       = try(cloudfoundry_service_instance.autoscaler[0].id, null)
  description = "Cloud Foundry App Autoscaler service instance GUID."
}

output "autoscaler_enabled" {
  value       = var.setup_autoscaler
  description = "Whether App Autoscaler marketplace service provisioning is enabled in this Terraform deployment."
}

output "autoscaler_service_instance_name" {
  value       = try(cloudfoundry_service_instance.autoscaler[0].name, var.autoscaler_name)
  description = "App Autoscaler service instance name."
}

output "autoscaler_plan" {
  value       = var.cf_autoscaler_service_plan_name
  description = "Configured Cloud Foundry App Autoscaler plan name."
}

output "autoscaler_policy_thresholds" {
  value = {
    instance_min_count = var.autoscaler_policy_min_instances
    instance_max_count = var.autoscaler_policy_max_instances
    scale_up = {
      throughput = {
        threshold_rps        = var.autoscaler_scale_up_throughput_threshold_rps
        breach_duration_secs = var.autoscaler_scale_up_throughput_breach_duration_secs
        cool_down_secs       = var.autoscaler_scale_up_cool_down_secs
      }
      cpu = {
        threshold_percent    = var.autoscaler_scale_up_cpu_threshold_percent
        breach_duration_secs = var.autoscaler_scale_up_cpu_breach_duration_secs
        cool_down_secs       = var.autoscaler_scale_up_cool_down_secs
      }
      memory = {
        threshold_mb         = var.autoscaler_scale_up_memory_threshold_mb
        breach_duration_secs = var.autoscaler_scale_up_memory_breach_duration_secs
        cool_down_secs       = var.autoscaler_scale_up_cool_down_secs
      }
    }
    scale_down = {
      throughput = {
        threshold_rps        = var.autoscaler_scale_down_throughput_threshold_rps
        breach_duration_secs = var.autoscaler_scale_down_throughput_breach_duration_secs
        cool_down_secs       = var.autoscaler_scale_down_cool_down_secs
      }
      cpu = {
        threshold_percent    = var.autoscaler_scale_down_cpu_threshold_percent
        breach_duration_secs = var.autoscaler_scale_down_cpu_breach_duration_secs
        cool_down_secs       = var.autoscaler_scale_down_cool_down_secs
      }
    }
    note = "Policy is applied natively via cloudfoundry_service_credential_binding parameters."
  }
  description = "Recommended autoscaling thresholds metadata for operations and validation."
}

output "loadgen_configuration" {
  value = {
    enabled                   = var.loadgen_enabled
    mode                      = var.loadgen_mode
    app_name                  = var.loadgen_app_name
    target_url                = var.loadgen_target_url
    scrape_config_enabled     = var.setup_observability_scrapeconfigs && trimspace(var.loadgen_target_url) != ""
    scrape_config_name        = var.loadgen_scrape_config_name
    scrape_metrics_path       = var.loadgen_metrics_path
    target_route              = try("https://${cloudfoundry_route.spring_music[0].url}", null)
    notes                     = var.loadgen_notes
    terraform_managed         = false
    terraform_management_note = "Load generator deployment is not managed by this Terraform example."
  }
  description = "Load generation metadata used for autoscaling validation runs."
}

output "spring_music_scrape_config" {
  value = {
    enabled      = var.setup_observability_scrapeconfigs
    name         = var.spring_music_scrape_config_name
    target_url   = try(cloudfoundry_route.spring_music[0].url, null)
    metrics_path = var.spring_music_metrics_path
    interval     = var.spring_music_scrape_interval
    timeout      = var.spring_music_scrape_timeout
  }
  description = "Observability scrape configuration metadata for Spring Music metrics ingestion."
}

output "loadgen_scrape_config" {
  value = {
    enabled      = var.setup_observability_scrapeconfigs && trimspace(var.loadgen_target_url) != ""
    name         = var.loadgen_scrape_config_name
    target_url   = var.loadgen_target_url
    metrics_path = var.loadgen_metrics_path
    interval     = var.loadgen_scrape_interval
    timeout      = var.loadgen_scrape_timeout
  }
  description = "Observability scrape configuration metadata for optional load generator metrics ingestion."
}

output "observability_instance_id" {
  value       = try(stackit_observability_instance.platform[0].instance_id, null)
  description = "Observability instance ID."
}

output "observability_name" {
  value       = try(stackit_observability_instance.platform[0].name, null)
  description = "Observability instance name."
}

output "observability_dashboard_url" {
  value       = try(stackit_observability_instance.platform[0].dashboard_url, null)
  description = "STACKIT portal dashboard URL for the Observability instance."
}

output "observability_grafana_url" {
  value       = try(stackit_observability_instance.platform[0].grafana_url, null)
  description = "Grafana URL for the Observability instance."
}
