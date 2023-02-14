## Terraform Gitlab Project to configure and deploy Airflow

This project will be used to configure and deploy Airflow to the GKE cluster. We will be following the standards set by the SRE team to make commits and running the pipelines

This is the basic project template for working with terraform code.

It uses Gitlab CI, to create Pipelines based on the Global IT Operations Department standard workflow.

This Template Contain

This Readme (README.md)

Templated terraform code dir (terraform)

Gitlab CI yml File (.gitlab-ci.yml)

A Makefile-QA template for local QA Checks. (Makefile-QA)

A Wiki Home page template (Wiki-Home-Page.md)

Please see Documentation here &lt;Link>

## Terraform Versions
  Terraform: 0.14.8
  Terraform GCP Providers (including beta): 3.60.0
  Terraform Vault Provider: 2.17.0
  Terraform Kubernetes Provider: 1.13.3

These are the version used in the main terraform providers.
In later version of terraform provider and version are set in the terraform-config.tf file.

```
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.60.0"
    }

    google-beta = {
      source  = "hashicorp/google"
      version = "3.60.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "2.17.0"
    }
  }
```
Configs for the providers are still set in provider config
Standard naming for provider is  _terraform-X-provider.tf_  in their terraform directory.

1. terraform-gcp-provider.tf
2. terraform-vault-provider.tf
3. terraform-k8s-provider.tf

## Your Next Steps

1. Create a Wiki Home Page from the template and fill it in
2. Create any Gitlab Labels Required
3. Update the Default issue template
4. Identify the Terraform State Bucket you will used
5. Choose a directory name for the Terraform State
6. Update the Terraform code state back end file

## Terraform State Bucket

### location of bucket is set via template in file terraform-state-file-storage.tf-template (default)

variables from gitlab-ci.yml

```
variables:
  TERRAFORM_STATE_BUCKET_NAME: tfsf-it-operations
  TERRAFORM_STATE_BUCKET_DIR: ${CI_PROJECT_NAME}

```
gsutil ls gs://tfsf-it-operations

This template is rendered in the before script, which runs _Before_ every other script defined.

*- if [ -f "/makefiles/Make-Terraform" ]; then make -f /makefiles/Make-Terraform template_render; fi*

The replace render will look for *ANY* files ending in -template create a new file without the -template ie _terraform-state-file-storage.tf_ and look to replace any ${VAR} with the corresponding value in the shell environment.

```
     terraform {
            backend "gcs" {
                # This configuration expects GOOGLE_CREDENTIALS to be available
                #credentials = "${file("${var.Service_Accounts_Dir}/sa_tfst_bucket_key.json")}"
                bucket = "${TERRAFORM_STATE_BUCKET_NAME}"
                prefix = "${TERRAFORM_STATE_BUCKET_DIR}"
            }
        }
```

### Hard coding, the backend file terraform-state-file-storage.tf
gsutil ls gs://my-awesome-bucket

```
       terraform {
            backend "gcs" {
                # This configuration expects GOOGLE_CREDENTIALS to be available
                #credentials = "${file("${var.Service_Accounts_Dir}/sa_tfst_bucket_key.json")}"
                bucket = "my-awesome-bucket"
                prefix = "my-dir"
```
### Statefile names are set to test, prod or deployed

Will look like test.tfstate

### Terraform lock on statefile
When terraform uses a state file it locks it to prevent other changes, some times if a pipeline has issue this can be left.
First check you really have an issue and some other pipeline, or process in not using the state file.

[Terraform Locked Statefile Docs](https://www.terraform.io/docs/state/locking.html "Terraform Locked Statefile Docs")

## Variables (default)
These are the global set environment variables that will be available to every job in the gitlab-ci.yml, local in the file or included for the standard set of jobs.

${CI_XXX} come form the standard gitlab environment variables set.

${TF_VAR_MY_VARIABLE} will be passed to any terraform code, but only used if a corresponding entry mines the *TF_VAR_*is  ie MY_Variable made in Terraform _terraform-variables.tf_  or other terraform file.

```
variables:
# Vault Settings CI Environment Variables
   VAULT_TOKENS_DIR: ${CI_PROJECT_DIR}/makefile-tokens-dir
   JWT_TOKEN: "/var/run/secrets/kubernetes.io/serviceaccount/token"
# Make file and CI file Environment Variables
   TERRAFORM_VERSION: "0.14.8"
   TF_PLUGIN_CACHE_DIR: ${CI_PROJECT_DIR}/makefile-terraform-dir
   VAULT_GCP_ROLE_NAME: terraform-project-editor
   GCP_SERVICE_ACCOUNT_SUFFIX: terraform-deploy
   TERRAFORM_STATE_BUCKET_NAME: tfsf-it-operations
   TERRAFORM_STATE_BUCKET_DIR: ${CI_PROJECT_NAME}
# Default CI/CD environment variables for possible use in Terraform Code
   TF_VAR_KUBE_NAMESPACE: ${KUBE_NAMESPACE}
   TF_VAR_CI_COMMIT_DESCRIPTION: ${CI_COMMIT_DESCRIPTION}
   TF_VAR_CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}
   TF_VAR_CI_COMMIT_REF_SLUG: ${CI_COMMIT_REF_SLUG}
   TF_VAR_CI_COMMIT_TAG: ${CI_COMMIT_TAG}
   TF_VAR_CI_ENVIRONMENT_NAME: ${CI_ENVIRONMENT_NAME}
   TF_VAR_CI_ENVIRONMENT_SLUG: ${CI_ENVIRONMENT_SLUG}
   TF_VAR_CI_ENVIRONMENT_URL: ${CI_ENVIRONMENT_URL}
   TF_VAR_CI_PROJECT_PATH_SLUG: ${CI_PROJECT_PATH_SLUG}
   TF_VAR_CI_PROJECT_NAME: ${CI_PROJECT_NAME} # Should be code safe
   TF_VAR_CI_PROJECT_TITLE: ${CI_PROJECT_TITLE} # Name Displayed in the GitLab web interface.
# Labels defined environment variables for possible use in Terraform Code
   TF_VAR_label_name: resource_name # name should be the hostname of the VM resource but if it is not defined pull in this default value.
   TF_VAR_label_service_name: service_name
   TF_VAR_label_service_component: ${CI_PROJECT_NAME}
   TF_VAR_label_service_owner: global-it-operations
   TF_VAR_label_business_contact: global-it-operations
   TF_VAR_label_budget_code: 70104
   TF_VAR_label_tech_contact: global-it-operations
   TF_VAR_label_release_id: ${CI_COMMIT_REF_NAME} # The branch or tag name for which project is built
# Gitlab CI/CD User Defined environment variables for possible use in Terraform Code
   TF_VAR_CI_example_id: ${CI_ENV_example_id} # Terraform Variable Passed from Gitlab CI/CD Variable
# User defined environment variables for possible use in Terraform Code
   TF_VAR_example_id: example_id # Terraform Variable passed from gitlab CI Yaml
```

## Chef InSpec Testing (default)
In the Terraform code directory is a Terraform file that produces terraform outputs.
see https://www.terraform.io/docs/configuration/outputs.html for overview or terraform output values.

The gitlab pipline in this template is set to export these values for use later in the pipeline.
Standard naming for put files is  _X-terraform-outputs.tf_  in their terraform directory.

1. Chef-InSpec-terraform-outputs.tf
```
## GCP project ID
#
output "gcp_project_id" {
  value = data.google_project.working_project.project_id
}
```

2. project-terraform-outputs.tf

_BLANK_

The file Chef-InSpec-terraform-outputs.tf contain the stands names that the chefinspec jobs are expecting.
Most are commented out, and should be commented back in as need.
See https://gitlab.greenpeace.org/gp/git/git-devops/docker_images/chef-inspec
for more information

## Before_script (default)
```
before_script:
   - mkdir -p ${VAULT_TOKENS_DIR}
   - mkdir -p ${TF_PLUGIN_CACHE_DIR}
   - if [ -f "/makefiles/Make-Terraform" ]; then make -f /makefiles/Make-Terraform template_render; fi
```

## .ci_gitlab.yml (default)
All the standard jobs in the pipeline are included from a gitlab repo of jobs,
see https://gitlab.greenpeace.org/gp/git/global-apps/gitlab/global-gitlab-ci-jobs
for more information.

## project-terraform-computer_instance-my-vm.tf

To apply the default labels to a VM resource. The "name" label should the hostname of the VM.

```
resource "google_compute_instance" "my-vm-01" {
  project                   = local.project_id
  name                      = my-vm-01
  hostname                  = my-vm-01.greenpeace.org
  allow_stopping_for_update = true
  machine_type              = "n1-standard-1"
  zone                      = "us-central1-a"
  labels                    = merge(local.labels, {name = "my-vm-01"})

...

}
```

we created a source directory in this we have directories like dags   , great expectation

## Dags

It is Airflow dags basically dags are scheduler you can schedule your script at a particular time by using the cron syntax 

you can learn more about dags from : https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html

here is the snippet how dag looks like 

```
with DAG(dag_id=dag_id,
​         default_args={'owner': 'airflow'},
​         schedule_interval='0 */12 * * *',
​         start_date=days_ago(1)
​         ) as dag:
​    async_hs_to_bq = AirbyteTriggerSyncOperator(
​        task_id=task_id,
​        airbyte_conn_id=airbyte_conn_id,
​        connection_id=connection_id,
​        asynchronous=True
​    )
```

## great expectations

great exceptation is a tool use to validate data , we had validate some table of a datasource and added into airflow dag 

you can learn more about great_exceptation from : https://docs.greatexpectations.io/docs/
The great expectations folder appears after you run the command `great_exceptation init` 
It will automatically made it's hierarchy to run things
