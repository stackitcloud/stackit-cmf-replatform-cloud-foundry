resource "null_resource" "spring_music_deployment" {
  count = var.setup_workload ? 1 : 0

  triggers = {
    app_name = var.cf_app_name
  }

  provisioner "local-exec" {
    command = "bash scripts/deploy_spring_music_cf.sh"
    environment = {
      CF_API      = var.cf_api_endpoint
      CF_ORG      = var.cf_org
      CF_SPACE    = var.cf_space
      CF_USERNAME = var.cf_username
      CF_PASSWORD = var.cf_password
      APP_NAME    = var.cf_app_name
      REPO_URL    = var.spring_music_repo_url
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash scripts/destroy_spring_music_cf.sh"
    environment = {
      CF_API      = self.triggers.app_name # Simplified trigger for example
      # Pass necessary env for destroy here
    }
  }
}
