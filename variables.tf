variable "project_id" {
  type        = string
  description = "The STACKIT project ID."
  default     = null
}

variable "parent_container_id" {
  type        = string
  description = "Optional parent container ID used to create a new project when project_id is not set."
  default     = null
}

variable "project_name" {
  type        = string
  description = "Project name used when creating a new project."
  default     = "cmf-cloud-foundry"
}

variable "project_owner_email" {
  type        = string
  description = "Optional owner email used when creating a new project."
  default     = null
}

variable "region" {
  type        = string
  description = "STACKIT region used by the provider."
  default     = "eu01"
}

variable "enable_beta_resources" {
  type        = bool
  description = "Enable STACKIT beta resources where needed."
  default     = true
}

variable "service_account_key_path" {
  type        = string
  description = "Optional path to STACKIT service account key JSON used for provider authentication."
  default     = null
}

variable "setup_project" {
  type    = bool
  default = true
}

variable "setup_observability" {
  type    = bool
  default = true
}

variable "setup_database" {
  type    = bool
  default = true
}

variable "setup_cf_service_bindings" {
  type        = bool
  description = "Create Cloud Foundry managed service instances and bind them to the app."
  default     = true
}

variable "bind_postgres_to_app" {
  type        = bool
  description = "Bind the PostgreSQL service instance to the app (disable if network path to DB is unavailable)."
  default     = false
}

variable "provision_observability_dashboard" {
  type        = bool
  description = "Opt-in exception: provision a prebuilt Grafana dashboard via local-exec API call until a provider-native resource is available."
  default     = false
}

variable "setup_observability_scrapeconfigs" {
  type        = bool
  description = "Create observability scrape configs for Spring Music and optional load generator metrics."
  default     = true
}

variable "setup_workload" {
  type    = bool
  default = true
}

variable "setup_cloudfoundry_resources" {
  type        = bool
  description = "Create Cloud Foundry resources (space, service instances, app, route)."
  default     = true
}

variable "setup_autoscaler" {
  type        = bool
  description = "Create the Cloud Foundry App Autoscaler marketplace service instance."
  default     = true
}

variable "setup_autoscaler_policy" {
  type        = bool
  description = "Attach/update an App Autoscaler policy for the workload app via native cloudfoundry_service_credential_binding parameters."
  default     = true
}

variable "setup_dns" {
  type    = bool
  default = false
}

variable "scf_org_name" {
  type        = string
  description = "Name of the SCF organization to create."
  default     = "cmf-spring-music-org"
}

variable "cf_space_name" {
  type        = string
  description = "Cloud Foundry space for the Spring Music workload."
  default     = "app"
}

variable "admin_email" {
  type        = string
  description = "Optional human user to grant org/space roles to."
  default     = ""
}

variable "assign_roles" {
  type        = bool
  description = "Assign Cloud Foundry roles to admin_email when set."
  default     = false
}

variable "cf_domain" {
  type        = string
  description = "Cloud Foundry shared domain used for app routing."
  default     = "apps.01.cf.eu01.stackit.cloud"
}

variable "cf_api_url" {
  type        = string
  description = "Optional explicit Cloud Foundry API URL."
  default     = null
}

variable "cf_username" {
  type        = string
  description = "Optional explicit Cloud Foundry username."
  default     = null
}

variable "cf_password" {
  type        = string
  description = "Optional explicit Cloud Foundry password."
  default     = null
  sensitive   = true
}

variable "cf_app_name" {
  type    = string
  default = "spring-music"
}

variable "cf_app_host" {
  type        = string
  description = "Host part of the route for Spring Music."
  default     = "spring-music-cmf"
}

variable "spring_music_repo_url" {
  type    = string
  default = "https://github.com/cloudfoundry-samples/spring-music.git"
}

variable "observability_plan_name" {
  type        = string
  description = "STACKIT Observability plan name."
  default     = "Observability-Starter-EU01"
}

variable "postgres_name" {
  type        = string
  description = "Cloud Foundry managed PostgreSQL service instance name."
  default     = "cmf-spring-music-postgres"
}

variable "autoscaler_name" {
  type        = string
  description = "Cloud Foundry managed App Autoscaler service instance name."
  default     = "cmf-spring-music-autoscaler"
}

variable "deployment_environment" {
  type        = string
  description = "Deployment environment profile for default marketplace plan selection (dev/demo => single, prod => replica)."
  default     = "dev"

  validation {
    condition     = contains(["dev", "demo", "prod"], var.deployment_environment)
    error_message = "deployment_environment must be one of: dev, demo, prod."
  }
}

variable "cf_postgres_service_offering_name" {
  type        = string
  description = "Cloud Foundry service offering for PostgreSQL in SCF."
  default     = "stackit-postgres-flex"
}

variable "cf_postgres_service_plan_name" {
  type        = string
  description = "Cloud Foundry PostgreSQL plan name."
  default     = "stackit-postgres-flex"
}

variable "postgres_acl_items" {
  type        = list(string)
  description = "ACL CIDR entries passed to the PostgreSQL service broker on create (parameters.acl.items)."
  default = [
    "193.148.160.0/19",
    "45.129.40.0/21",
  ]
}

variable "postgres_database_name" {
  type        = string
  description = "Database name expected by the Spring Music app binding credentials."
  default     = "stackit"
}

variable "postgres_bootstrap_key_name" {
  type        = string
  description = "Service credential key name used by Terraform for native PostgreSQL database provisioning or app env injection."
  default     = "tf-postgres-bootstrap"
}

variable "setup_postgres_db_with_stackit_provider" {
  type        = bool
  description = "Manage PostgreSQL database creation via native stackit_postgresflex_database resource."
  default     = true
}

variable "cf_autoscaler_service_offering_name" {
  type        = string
  description = "Cloud Foundry service offering for App Autoscaler in SCF."
  default     = "autoscaler"
}

variable "cf_autoscaler_service_plan_name" {
  type        = string
  description = "Cloud Foundry App Autoscaler plan name."
  default     = "autoscaler-free-plan"
}

variable "autoscaler_policy_min_instances" {
  type        = number
  description = "Recommended minimum app instances for autoscaling policy output metadata."
  default     = 1
}

variable "autoscaler_policy_max_instances" {
  type        = number
  description = "Recommended maximum app instances for autoscaling policy output metadata."
  default     = 3
}

variable "autoscaler_scale_up_throughput_threshold_rps" {
  type        = number
  description = "Recommended throughput threshold (requests/sec) for scale-up metadata."
  default     = 20
}

variable "autoscaler_scale_up_throughput_breach_duration_secs" {
  type        = number
  description = "Recommended breach duration for throughput scale-up metadata."
  default     = 60
}

variable "autoscaler_scale_up_cpu_threshold_percent" {
  type        = number
  description = "Recommended CPU threshold percentage for scale-up metadata."
  default     = 45
}

variable "autoscaler_scale_up_cpu_breach_duration_secs" {
  type        = number
  description = "Recommended breach duration for CPU scale-up metadata."
  default     = 60
}

variable "autoscaler_scale_up_memory_threshold_mb" {
  type        = number
  description = "Recommended memory threshold in MB for scale-up metadata."
  default     = 700
}

variable "autoscaler_scale_up_memory_breach_duration_secs" {
  type        = number
  description = "Recommended breach duration for memory scale-up metadata."
  default     = 120
}

variable "autoscaler_scale_down_cpu_threshold_percent" {
  type        = number
  description = "Recommended CPU threshold percentage for scale-down metadata."
  default     = 20
}

variable "autoscaler_scale_down_cpu_breach_duration_secs" {
  type        = number
  description = "Recommended breach duration for CPU scale-down metadata."
  default     = 120
}

variable "autoscaler_scale_down_throughput_threshold_rps" {
  type        = number
  description = "Recommended throughput threshold (requests/sec) for scale-down metadata."
  default     = 3
}

variable "autoscaler_scale_down_throughput_breach_duration_secs" {
  type        = number
  description = "Recommended breach duration for throughput scale-down metadata."
  default     = 120
}

variable "autoscaler_scale_up_cool_down_secs" {
  type        = number
  description = "Recommended cool-down duration for scale-up rules metadata."
  default     = 60
}

variable "autoscaler_scale_down_cool_down_secs" {
  type        = number
  description = "Recommended cool-down duration for scale-down rules metadata."
  default     = 120
}

variable "loadgen_enabled" {
  type        = bool
  description = "Whether a load generator is used for autoscaling validation."
  default     = false
}

variable "loadgen_mode" {
  type        = string
  description = "Load generator mode metadata (for example: external-tool or cf-app)."
  default     = "external-tool"
}

variable "loadgen_app_name" {
  type        = string
  description = "Optional Cloud Foundry app name for load generator metadata."
  default     = ""
}

variable "loadgen_notes" {
  type        = string
  description = "Optional notes for load generation setup and behavior."
  default     = ""
}

variable "spring_music_scrape_config_name" {
  type        = string
  description = "Scrape config job name for Spring Music metrics."
  default     = "spring-music-metrics"
}

variable "spring_music_metrics_path" {
  type        = string
  description = "Metrics path for Spring Music Prometheus scraping."
  default     = "/actuator/prometheus"
}

variable "spring_music_scrape_interval" {
  type        = string
  description = "Scrape interval for Spring Music metrics."
  default     = "1m"
}

variable "spring_music_scrape_timeout" {
  type        = string
  description = "Scrape timeout for Spring Music metrics."
  default     = "10s"
}

variable "spring_music_scrape_sample_limit" {
  type        = number
  description = "Sample limit for Spring Music scrape config."
  default     = 5000
}

variable "loadgen_scrape_config_name" {
  type        = string
  description = "Scrape config job name for load generator metrics."
  default     = "spring-music-loadgen-metrics"
}

variable "loadgen_target_url" {
  type        = string
  description = "Optional load generator target URL host (without scheme) for observability scraping."
  default     = ""
}

variable "loadgen_metrics_path" {
  type        = string
  description = "Metrics path for load generator scraping."
  default     = "/actuator/prometheus"
}

variable "loadgen_scrape_interval" {
  type        = string
  description = "Scrape interval for load generator metrics."
  default     = "1m"
}

variable "loadgen_scrape_timeout" {
  type        = string
  description = "Scrape timeout for load generator metrics."
  default     = "10s"
}

variable "loadgen_scrape_sample_limit" {
  type        = number
  description = "Sample limit for load generator scrape config."
  default     = 5000
}
