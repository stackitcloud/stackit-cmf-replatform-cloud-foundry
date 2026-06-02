locals {
  inferred_owner_email                   = var.service_account_key_path != null ? try(jsondecode(file(var.service_account_key_path)).credentials.iss, null) : null
  effective_owner_email                  = var.project_owner_email != null ? var.project_owner_email : local.inferred_owner_email
  effective_project_id                   = var.project_id != null ? var.project_id : stackit_resourcemanager_project.project[0].project_id
  admin_email_normalized                 = lower(trimspace(var.admin_email))
  technical_org_manager_email_normalized = lower(trimspace(stackit_scf_organization_manager.org_manager.username))
  admin_is_technical_org_manager         = local.admin_email_normalized != "" && local.admin_email_normalized == local.technical_org_manager_email_normalized
  selected_postgres_plan                 = trimspace(var.cf_postgres_service_plan_name)
  postgres_dashboard_parts               = split("/", try(cloudfoundry_service_instance.postgres[0].dashboard_url, ""))
  postgresflex_instance_id               = length(local.postgres_dashboard_parts) >= 2 ? local.postgres_dashboard_parts[length(local.postgres_dashboard_parts) - 2] : null
  postgres_bootstrap_credentials         = try(jsondecode(cloudfoundry_service_credential_binding.postgres_bootstrap_key[0].credential_binding).credentials, {})
  postgres_bootstrap_host                = try(local.postgres_bootstrap_credentials.host, null)
  postgres_bootstrap_port                = try(local.postgres_bootstrap_credentials.port, null)
  postgres_bootstrap_username            = try(local.postgres_bootstrap_credentials.username, null)
  postgres_bootstrap_password            = try(local.postgres_bootstrap_credentials.password, null)

  app_service_bindings = var.setup_database && var.bind_postgres_to_app && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? [
    {
      service_instance = cloudfoundry_service_instance.postgres[0].name
    }
  ] : []

  app_env = merge(
    {
      JBP_CONFIG_OPEN_JDK_JRE = "{ jre: { version: 17.+ } }"
    },
    var.setup_database && !var.bind_postgres_to_app && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? {
      SPRING_DATASOURCE_URL      = local.postgres_bootstrap_host != null && local.postgres_bootstrap_port != null ? "jdbc:postgresql://${local.postgres_bootstrap_host}:${local.postgres_bootstrap_port}/${var.postgres_database_name}?sslmode=require" : null
      SPRING_DATASOURCE_USERNAME = local.postgres_bootstrap_username
      SPRING_DATASOURCE_PASSWORD = local.postgres_bootstrap_password
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
  count    = var.setup_cloudfoundry_resources && var.assign_roles && var.admin_email != "" && !local.admin_is_technical_org_manager ? 1 : 0
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

resource "cloudfoundry_space_role" "space_manager" {
  count      = var.setup_cloudfoundry_resources && var.assign_roles && var.admin_email != "" ? 1 : 0
  username   = var.admin_email
  type       = "space_manager"
  space      = cloudfoundry_space.app[0].id
  depends_on = [cloudfoundry_org_role.org_user]
}

resource "stackit_observability_instance" "platform" {
  count      = var.setup_observability ? 1 : 0
  project_id = local.effective_project_id
  name       = "${var.cf_app_name}-observability"
  plan_name  = var.observability_plan_name
}

data "cloudfoundry_service_plan" "postgres" {
  count                 = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? 1 : 0
  service_offering_name = var.cf_postgres_service_offering_name
  name                  = local.selected_postgres_plan
}

data "cloudfoundry_service_plan" "autoscaler" {
  count                 = var.setup_autoscaler && var.setup_cloudfoundry_resources ? 1 : 0
  service_offering_name = var.cf_autoscaler_service_offering_name
  name                  = var.cf_autoscaler_service_plan_name
}

resource "cloudfoundry_service_instance" "postgres" {
  count        = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings ? 1 : 0
  name         = var.postgres_name
  type         = "managed"
  service_plan = data.cloudfoundry_service_plan.postgres[0].id
  space        = cloudfoundry_space.app[0].id

  parameters = jsonencode({
    acl = {
      items = var.postgres_acl_items
    }
  })
}

resource "cloudfoundry_service_credential_binding" "postgres_bootstrap_key" {
  count            = var.setup_database && var.setup_cloudfoundry_resources && var.setup_cf_service_bindings && (var.setup_postgres_db_with_stackit_provider || !var.bind_postgres_to_app) ? 1 : 0
  type             = "key"
  name             = var.postgres_bootstrap_key_name
  service_instance = cloudfoundry_service_instance.postgres[0].id
}

resource "stackit_postgresflex_database" "spring_music" {
  count = var.setup_database && var.setup_postgres_db_with_stackit_provider ? 1 : 0

  project_id  = local.effective_project_id
  instance_id = local.postgresflex_instance_id
  name        = var.postgres_database_name
  owner       = local.postgres_bootstrap_username

  depends_on = [
    cloudfoundry_service_credential_binding.postgres_bootstrap_key,
  ]
}

resource "cloudfoundry_service_instance" "autoscaler" {
  count        = var.setup_autoscaler && var.setup_cloudfoundry_resources ? 1 : 0
  name         = var.autoscaler_name
  type         = "managed"
  service_plan = data.cloudfoundry_service_plan.autoscaler[0].id
  space        = cloudfoundry_space.app[0].id
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
    cloudfoundry_service_instance.postgres,
    cloudfoundry_service_instance.autoscaler,
  ]
}

resource "cloudfoundry_service_credential_binding" "autoscaler_policy" {
  count            = var.setup_autoscaler && var.setup_autoscaler_policy && var.setup_workload && var.setup_cloudfoundry_resources ? 1 : 0
  type             = "app"
  app              = cloudfoundry_app.spring_music[0].id
  service_instance = cloudfoundry_service_instance.autoscaler[0].id

  parameters = jsonencode({
    instance_min_count = var.autoscaler_policy_min_instances
    instance_max_count = var.autoscaler_policy_max_instances
    scaling_rules = [
      {
        metric_type          = "cpu"
        breach_duration_secs = var.autoscaler_scale_up_cpu_breach_duration_secs
        threshold            = var.autoscaler_scale_up_cpu_threshold_percent
        operator             = ">="
        cool_down_secs       = var.autoscaler_scale_up_cool_down_secs
        adjustment           = "+1"
      },
      {
        metric_type          = "cpu"
        breach_duration_secs = var.autoscaler_scale_down_cpu_breach_duration_secs
        threshold            = var.autoscaler_scale_down_cpu_threshold_percent
        operator             = "<="
        cool_down_secs       = var.autoscaler_scale_down_cool_down_secs
        adjustment           = "-1"
      }
    ]
  })

  depends_on = [
    cloudfoundry_app.spring_music,
    cloudfoundry_service_instance.autoscaler,
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

resource "stackit_observability_scrapeconfig" "spring_music" {
  count = var.setup_observability && var.setup_workload && var.setup_cloudfoundry_resources && var.setup_observability_scrapeconfigs ? 1 : 0

  project_id      = local.effective_project_id
  instance_id     = stackit_observability_instance.platform[0].instance_id
  name            = var.spring_music_scrape_config_name
  scheme          = "https"
  metrics_path    = var.spring_music_metrics_path
  scrape_interval = var.spring_music_scrape_interval
  scrape_timeout  = var.spring_music_scrape_timeout
  sample_limit    = var.spring_music_scrape_sample_limit

  targets = [{
    urls = [cloudfoundry_route.spring_music[0].url]
    labels = {
      app   = var.cf_app_name
      space = var.cf_space_name
      role  = "workload"
    }
  }]

  depends_on = [
    stackit_observability_instance.platform,
    cloudfoundry_route.spring_music,
  ]
}

resource "stackit_observability_scrapeconfig" "loadgen" {
  count = var.setup_observability && var.setup_observability_scrapeconfigs && trimspace(var.loadgen_target_url) != "" ? 1 : 0

  project_id      = local.effective_project_id
  instance_id     = stackit_observability_instance.platform[0].instance_id
  name            = var.loadgen_scrape_config_name
  scheme          = "https"
  metrics_path    = var.loadgen_metrics_path
  scrape_interval = var.loadgen_scrape_interval
  scrape_timeout  = var.loadgen_scrape_timeout
  sample_limit    = var.loadgen_scrape_sample_limit

  targets = [{
    urls = [var.loadgen_target_url]
    labels = {
      app   = var.loadgen_app_name != "" ? var.loadgen_app_name : "loadgen"
      space = var.cf_space_name
      role  = "loadgen"
    }
  }]

  depends_on = [
    stackit_observability_instance.platform,
  ]
}

resource "terraform_data" "observability_dashboard" {
  count = var.setup_observability && var.provision_observability_dashboard ? 1 : 0

  triggers_replace = [
    stackit_observability_instance.platform[0].instance_id,
    filesha256("${path.module}/dashboards/cloud-foundry-overview.json"),
    var.cf_app_name,
    var.cf_space_name,
    stackit_scf_organization.org.name,
    tostring(var.setup_observability_scrapeconfigs),
    var.spring_music_scrape_config_name,
    var.spring_music_metrics_path,
    var.loadgen_scrape_config_name,
    var.loadgen_target_url,
    var.loadgen_metrics_path,
  ]

  # No provider-native dashboard import resource is currently available in this stack.
  # Keep this opt-in path as an explicit exception.
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      payload=$(jq -n --argfile dashboard "${path.module}/dashboards/cloud-foundry-overview.json" '{dashboard: $dashboard, folderId: 0, overwrite: true}')
      curl -sS -u "${stackit_observability_instance.platform[0].grafana_initial_admin_user}:${stackit_observability_instance.platform[0].grafana_initial_admin_password}" \
        -H "Content-Type: application/json" \
        -X POST "${stackit_observability_instance.platform[0].grafana_url}/api/dashboards/db" \
        -d "$payload" > /dev/null
    EOT
  }

  depends_on = [
    stackit_observability_instance.platform,
    cloudfoundry_app.spring_music,
    stackit_observability_scrapeconfig.spring_music,
    stackit_observability_scrapeconfig.loadgen,
  ]
}
