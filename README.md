# STACKIT CMF Cloud Foundry Example

Dieses Repository stellt eine provider-native Terraform-Referenz fuer Replatforming nach STACKIT Cloud Foundry bereit.

Der Stack umfasst:

- SCF-Organisation und technischer Org-Manager via STACKIT Provider
- Spring-Music-App auf Cloud Foundry
- Redis und RabbitMQ als STACKIT Managed Services plus Credentials
- Cloud Foundry Service Instances fuer App-Binding
- Observability-Instanz auf STACKIT

## Usage

1. `cp env.tfvars.example terraform.tfvars`
2. Werte in `terraform.tfvars` anpassen
3. `terraform init`
4. `terraform plan`
5. `terraform apply`

## Prerequisites

- Terraform >= 1.5
- Zugriff auf ein STACKIT Projekt mit SCF/Redis/RabbitMQ/Observability Berechtigung
- Provider-Authentifizierung fuer `stackitcloud/stackit` ueber Umgebungsvariablen oder Service Account Key
- Erreichbarkeit der Cloud Foundry API fuer das Zielprojekt

## Architecture Notes

- SCF-Bootstrap folgt dem offiziellen Pattern:
  - `stackit_scf_organization`
  - `data.stackit_scf_platform`
  - `stackit_scf_organization_manager`
  - `provider "cloudfoundry"` wird mit diesen Outputs konfiguriert
- Redis/RabbitMQ werden als STACKIT Instanzen mit separaten Credentials erzeugt.
- Fuer Cloud Foundry werden dedizierte Service Instances erstellt und in die App gebunden.
- Die Route wird ueber die gemeinsame Domain `cf_domain` erstellt.

## Features

- `setup_observability`: Observability-Instanz erstellen
- `setup_database`: Redis und RabbitMQ inkl. Credentials und CF-Service-Instanzen erstellen
- `setup_workload`: Spring-Music-App und Route deployen

## Key Outputs

- `spring_music_route`: Oeffentliche App-URL
- `scf_org_id`: SCF-Organisation
- `cf_space_id`: Cloud Foundry Space
- `redis_instance_id` und `rabbitmq_instance_id`
- `observability_instance_id`

## Cleanup

- `terraform destroy`

Hinweis: Beim Destroy werden zuerst App und CF-Ressourcen entfernt, danach die zugrundeliegenden Managed Services.
