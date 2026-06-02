# STACKIT CMF Cloud Foundry Example

Dieses Repository stellt eine provider-native Terraform-Referenz fuer Replatforming nach STACKIT Cloud Foundry bereit.

Der Stack umfasst:

- SCF-Organisation und technischer Org-Manager via STACKIT Provider
- Spring-Music-App auf Cloud Foundry
- Redis und RabbitMQ als echte Cloud Foundry Marketplace Managed Services
- App Autoscaler als Cloud Foundry Marketplace Managed Service
- Cloud Foundry Service-Instanzen direkt per Offering/Plan
- Observability-Instanz auf STACKIT

## Usage

1. `cp env.tfvars.example terraform.tfvars`
2. Werte in `terraform.tfvars` anpassen
3. `terraform init`
4. `terraform plan`
5. `terraform apply`

## Prerequisites

- Terraform >= 1.5
- Zugriff auf ein STACKIT Projekt mit SCF/Marketplace/Observability Berechtigung
- Provider-Authentifizierung fuer `stackitcloud/stackit` ueber Umgebungsvariablen oder Service Account Key
- Erreichbarkeit der Cloud Foundry API fuer das Zielprojekt

## Architecture Notes

- SCF-Bootstrap folgt dem offiziellen Pattern:
  - `stackit_scf_organization`
  - `data.stackit_scf_platform`
  - `stackit_scf_organization_manager`
  - `provider "cloudfoundry"` wird mit diesen Outputs konfiguriert
- Redis/RabbitMQ werden als CF Managed Services direkt aus dem Marketplace erstellt.
- App Autoscaler wird als CF Managed Service direkt aus dem Marketplace erstellt.
- Die Plan-ID wird ueber `data.cloudfoundry_service_plan` aus Offering- und Plan-Namen aufgeloest.
- App-Credentials werden ueber standardmaessige Service-Bindings in `VCAP_SERVICES` injiziert.
- Die Route wird ueber die gemeinsame Domain `cf_domain` erstellt.

## Features

- `setup_observability`: Observability-Instanz erstellen
- `setup_database`: Redis und RabbitMQ als CF Marketplace-Service-Instanzen erstellen
- `setup_autoscaler`: App-Autoscaler als CF Marketplace-Service-Instanz erstellen
- `setup_workload`: Spring-Music-App und Route deployen
- `setup_cf_service_bindings` ist standardmaessig `true`, damit VCAP_SERVICES fuer die App gesetzt wird
- `provision_observability_dashboard`: erstellt ein vorkonfiguriertes Grafana-Dashboard fuer den CF-Use-Case

## Marketplace Defaults

Das Beispiel nutzt folgende in der Ziel-Foundation verfuegbare Defaults:

- Redis: Offering `appcloud-redis7`
- RabbitMQ: Offering `appcloud-rabbitmq40`
- Autoscaler: Offering `autoscaler`, Plan `autoscaler-free-plan`

Planstrategie (bewusst statt zufaellig):

- `deployment_environment = "dev"` oder `"demo"`: Default auf Single-Plans
  - Redis: `redis-1.4.10-single`
  - RabbitMQ: `rabbitmq-2.4.10-single`
- `deployment_environment = "prod"`: Default auf Replica-Plans
  - Redis: `redis-2.8.10-replica`
  - RabbitMQ: `rabbitmq-2.4.10-replica`

Wenn eure Foundation andere Plan-Namen verwendet, passe in `terraform.tfvars` nur
`cf_redis_service_offering_name`, `cf_redis_service_plan_name`,
`cf_rabbitmq_service_offering_name` und `cf_rabbitmq_service_plan_name` an.

Hinweis: Setze `cf_redis_service_plan_name` und `cf_rabbitmq_service_plan_name` nur dann explizit, wenn du die environment-basierten Defaults ueberschreiben willst.

## Role Assignment Note

- Wenn `admin_email` dem technischen SCF-Org-Manager entspricht, wird die zusaetzliche CF-Rolle `organization_manager` nicht erneut erstellt.
- Damit werden Konflikte wie "already has organization_manager" vermieden.

## Key Outputs

- `spring_music_app_name`: Name der CF-App
- `spring_music_route`: Oeffentliche App-URL (direkt testbar)
- `scf_org_name` und `cf_space_name`: CF-Kontext fuer Login und Troubleshooting
- `cf_api_url`: CF-API-Endpunkt fuer `cf login`
- `observability_dashboard_url` und `observability_grafana_url`: direkte Links ins Monitoring
- `autoscaler_instance_id`: GUID der CF-Autoscaler-Service-Instanz
- `autoscaler_enabled`: zeigt, ob der Autoscaler-Service in diesem Deployment aktiviert ist
- `autoscaler_policy_thresholds`: dokumentierte Ziel-Schwellenwerte fuer Scale-up/Scale-down
- `loadgen_configuration`: Metadaten zum Lastgenerator-Setup fuer reproduzierbare Validierung
- zusaetzlich weiterhin IDs fuer Automatisierung (`project_id`, `scf_org_id`, `cf_space_id`, Service-IDs)

## Important Limitation (Provider Capability)

Die Installation des Autoscaler-Marketplace-Service ist vollstaendig Terraform-basiert.

Die konkrete Autoscaling-Policy (Rules wie CPU/throughput thresholds) kann mit den aktuell verfuegbaren Terraform-Resources des Providers `cloudfoundry/cloudfoundry` nicht als eigene Resource modelliert werden (im Schema sind u. a. `cloudfoundry_service_instance` vorhanden, aber keine `cloudfoundry_autoscaling_policy`-Resource).

Falls wir die Policy trotzdem automatisiert setzen sollen, gibt es zwei Optionen:

1. CLI/API-Post-Step (z. B. `cf attach-autoscaling-policy`) als explizit freigegebene Ausnahme.
2. Warten auf/Beitrag zu nativer Provider-Unterstuetzung fuer Autoscaler-Policies.

Ohne deine Freigabe bauen wir keinen CLI-Workaround in den Standard-Apply ein.

## Cleanup

- `terraform destroy`

Hinweis: Beim Destroy werden zuerst App und CF-Ressourcen entfernt, danach die zugrundeliegenden Managed Services.
