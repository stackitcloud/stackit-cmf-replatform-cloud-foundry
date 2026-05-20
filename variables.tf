variable "project_id" {
  type        = string
  description = "The STACKIT project ID."
}

variable "setup_project" {
  type    = bool
  default = true
}

variable "setup_observability" {
  type    = bool
  default = false
}

variable "setup_database" {
  type    = bool
  default = false
}

variable "setup_workload" {
  type    = bool
  default = true
}

variable "setup_loadgen" {
  type    = bool
  default = false
}

variable "setup_dns" {
  type    = bool
  default = false
}

variable "cf_api_endpoint" {
  type        = string
  description = "Cloud Foundry API endpoint"
}

variable "cf_org" {
  type        = string
  description = "Cloud Foundry Organization"
}

variable "cf_space" {
  type        = string
  description = "Cloud Foundry Space"
}

variable "cf_username" {
  type        = string
  description = "Cloud Foundry Username"
}

variable "cf_password" {
  type        = string
  sensitive   = true
  description = "Cloud Foundry Password"
}

variable "cf_app_name" {
  type    = string
  default = "spring-music"
}

variable "spring_music_repo_url" {
  type    = string
  default = "https://github.com/cloudfoundry-samples/spring-music.git"
}
