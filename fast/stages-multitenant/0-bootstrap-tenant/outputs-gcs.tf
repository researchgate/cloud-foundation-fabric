/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Output files persistence to automation GCS bucket.

resource "google_storage_bucket_object" "providers" {
  bucket = module.automation-tf-output-gcs.name
  # provider suffix allows excluding via .gitignore when linked from stages
  name    = "tenants/${var.tenant_config.short_name}/providers/1-resman-tenant-providers.tf"
  content = local.provider
}

resource "google_storage_bucket_object" "tfvars" {
  bucket  = module.automation-tf-output-gcs.name
  name    = "tenants/${var.tenant_config.short_name}/tfvars/0-bootstrap-tenant.auto.tfvars.json"
  content = jsonencode(local.tfvars)
}

resource "google_storage_bucket_object" "workflows" {
  for_each = local.cicd_workflows
  bucket = (
    each.key == "bootstrap"
    ? var.automation.outputs_bucket
    : module.automation-tf-output-gcs.name
  )
  name    = "tenants/${var.tenant_config.short_name}/workflows/${each.key}-${local.cicd_repositories[each.key].type}.yaml"
  content = each.value
}
