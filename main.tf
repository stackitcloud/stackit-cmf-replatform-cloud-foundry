locals {
  inferred_owner_email  = var.service_account_key_path != null ? try(jsondecode(file(var.service_account_key_path)).credentials.iss, null) : null
  effective_owner_email = coalesce(var.project_owner_email, local.inferred_owner_email)
  effective_project_id  = var.project_id != null ? var.project_id : stackit_resourcemanager_project.project[0].project_id

  app_service_bindings = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? [
    {
      service_instance = cloudfoundry_service_instance.redis[0].name
    },
    {
      service_instance = cloudfoundry_service_instance.rabbitmq[0].name
    }
  ] : []

  app_env = merge(
    {
      JBP_CONFIG_OPEN_JDK_JRE = "{ jre: { version: 17.+ } }"
    },
    var.setup_database ? {
      STACKIT_REDIS_HOST = stackit_redis_credential.redis[0].host
      STACKIT_REDIS_PORT = tostring(stackit_redis_credential.redis[0].port)
      STACKIT_REDIS_USER = stackit_redis_credential.redis[0].username
      STACKIT_REDIS_PASS = stackit_redis_credential.redis[0].password

      STACKIT_RABBITMQ_HOST = stackit_rabbitmq_credential.rabbitmq[0].host
      STACKIT_RABBITMQ_PORT = tostring(stackit_rabbitmq_credential.rabbitmq[0].port)
      STACKIT_RABBITMQ_USER = stackit_rabbitmq_credential.rabbitmq[0].username
      STACKIT_RABBITMQ_PASS = stackit_rabbitmq_credential.rabbitmq[0].password
    } : {},
    var.setup_observability ? {
      STACKIT_OBSERVABILITY_INSTANCE_ID = stackit_observability_instance.platform[0].instance_id
    } : {}
  )
}

resource "stackit_resourcemanager_project" "project" {
  count = var.setup_project && var.project_id == null && var.parent_container_id != null ? 1 : 0

  parent_container_id = var.parent_container_id
  name                = var.project_name
  owner_email         = local.effective_owner_email
}

resource "stackit_scf_organization" "org" {
  project_id = local.effective_project_id
  name       = var.scf_org_name
}

data "stackit_scf_platform" "platform" {
  project_id  = local.effective_project_id
  platform_id = stackit_scf_organization.org.platform_id
}

resource "stackit_scf_organization_manager" "org_manager" {
  project_id = local.effective_project_id
  org_id     = stackit_scf_organization.org.org_id
}

resource "cloudfoundry_space" "app" {
  count = var.setup_cloudfoundry_resources ? 1 : 0

  name = var.cf_space_name
  org  = stackit_scf_organization.org.org_id
}

resource "cloudfoundry_org_role" "org_user" {
  count    = var.setup_cloudfoundry_resources && var.assign_roles && var.admin_email != "" ? 1 : 0
  username = var.admin_email
  type     = "organization_user"
  org      = stackit_scf_organization.org.org_id
}

resource "cloudfoundry_org_role" "org_manager" {
  count    = var.setup_cloudfoundry_resources && var.assign_roles && var.admin_email != "" ? 1 : 0
  username = var.admin_email
  type     = "organization_manager"
  org      = stackit_scf_organization.org.org_id
}

resource "cloudfoundry_space_role" "space_developer" {
  count      = var.setup_cloudfoundry_resources && var.assign_roles && var.admin_email != "" ? 1 : 0
  username   = var.admin_email
  type       = "space_developer"
  space      = cloudfoundry_space.app[0].id
  depends_on = [cloudfoundry_org_role.org_user]
}

resource "stackit_observability_instance" "platform" {
  count      = var.setup_observability ? 1 : 0
  project_id = local.effective_project_id
  name       = "${var.cf_app_name}-observability"
  plan_name  = var.observability_plan_name
}

resource "stackit_redis_instance" "redis" {
  count      = var.setup_database ? 1 : 0
  project_id = local.effective_project_id
  name       = var.redis_name
  version    = var.redis_version
  plan_name  = var.redis_plan_name
}

resource "stackit_rabbitmq_instance" "rabbitmq" {
  count      = var.setup_database ? 1 : 0
  project_id = local.effective_project_id
  name       = var.rabbitmq_name
  version    = var.rabbitmq_version
  plan_name  = var.rabbitmq_plan_name
}

resource "stackit_redis_credential" "redis" {
  count       = var.setup_database ? 1 : 0
  project_id  = local.effective_project_id
  instance_id = stackit_redis_instance.redis[0].instance_id
}

resource "stackit_rabbitmq_credential" "rabbitmq" {
  count       = var.setup_database ? 1 : 0
  project_id  = local.effective_project_id
  instance_id = stackit_rabbitmq_instance.rabbitmq[0].instance_id
}

data "cloudfoundry_service_plan" "redis" {
  count                 = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? 1 : 0
  service_offering_name = var.cf_redis_service_offering_name
  name                  = var.cf_redis_service_plan_name
}

data "cloudfoundry_service_plan" "rabbitmq" {
  count                 = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? 1 : 0
  service_offering_name = var.cf_rabbitmq_service_offering_name
  name                  = var.cf_rabbitmq_service_plan_name
}

resource "cloudfoundry_service_instance" "redis" {
  count        = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? 1 : 0
  name         = "${var.cf_app_name}-redis"
  type         = "managed"
  space        = cloudfoundry_space.app[0].id
  service_plan = data.cloudfoundry_service_plan.redis[0].id
}

resource "cloudfoundry_service_instance" "rabbitmq" {
  count        = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? 1 : 0
  name         = "${var.cf_app_name}-rabbitmq"
  type         = "managed"
  space        = cloudfoundry_space.app[0].id
  service_plan = data.cloudfoundry_service_plan.rabbitmq[0].id
}

data "zipper_file" "spring_music" {
  count       = var.setup_workload ? 1 : 0
  type        = "git"
  source      = var.spring_music_repo_url
  output_path = "${path.module}/.terraform/spring-music.zip"
}

resource "cloudfoundry_app" "spring_music" {
  count      = var.setup_workload && var.setup_cloudfoundry_resources ? 1 : 0
  name       = var.cf_app_name
  org_name   = stackit_scf_organization.org.name
  space_name = cloudfoundry_space.app[0].name
  path       = "${path.module}/spring-music-1.0.jar"
  memory     = "1024M"
  disk_quota = "1024M"
  strategy   = "blue-green"
  instances  = 1
  no_route   = true

  service_bindings = length(local.app_service_bindings) > 0 ? local.app_service_bindings : null
  environment      = local.app_env

  depends_on = [
    cloudfoundry_service_instance.redis,
    cloudfoundry_service_instance.rabbitmq
  ]
}

data "cloudfoundry_domain" "apps" {
  count = var.setup_workload && var.setup_cloudfoundry_resources ? 1 : 0
  name  = var.cf_domain
}

resource "cloudfoundry_route" "spring_music" {
  count  = var.setup_workload && var.setup_cloudfoundry_resources ? 1 : 0
  space  = cloudfoundry_space.app[0].id
  domain = data.cloudfoundry_domain.apps[0].id
  host   = var.cf_app_host

  destinations = [{
    app_id = cloudfoundry_app.spring_music[0].id
  }]
}
