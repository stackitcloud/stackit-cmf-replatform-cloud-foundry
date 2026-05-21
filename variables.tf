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
  default     = false
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

variable "setup_loadgen" {
  type    = bool
  default = false
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

variable "redis_name" {
  type        = string
  description = "Redis instance name."
  default     = "cmf-spring-music-redis"
}

variable "redis_version" {
  type        = string
  description = "Redis major version."
  default     = "7"
}

variable "redis_plan_name" {
  type        = string
  description = "STACKIT Redis plan name."
  default     = "stackit-redis-1.2.10-replica"
}

variable "rabbitmq_name" {
  type        = string
  description = "RabbitMQ instance name."
  default     = "cmf-spring-music-rabbitmq"
}

variable "rabbitmq_version" {
  type        = string
  description = "RabbitMQ major/minor version."
  default     = "4.1"
}

variable "rabbitmq_plan_name" {
  type        = string
  description = "STACKIT RabbitMQ plan name."
  default     = "stackit-rabbitmq-1.2.10-replica"
}

variable "cf_redis_service_offering_name" {
  type        = string
  description = "Cloud Foundry service offering for Redis in SCF."
  default     = "redis"
}

variable "cf_redis_service_plan_name" {
  type        = string
  description = "Cloud Foundry service plan for Redis in SCF."
  default     = "shared"
}

variable "cf_rabbitmq_service_offering_name" {
  type        = string
  description = "Cloud Foundry service offering for RabbitMQ in SCF."
  default     = "rabbitmq"
}

variable "cf_rabbitmq_service_plan_name" {
  type        = string
  description = "Cloud Foundry service plan for RabbitMQ in SCF."
  default     = "shared"
}
