# Landing Zone Jenkins GKE

This repository creates the centralized Jenkins GKE cluster and related resources
used in landing zone automation processes. This includes:

- a stand-alone VPC network and subnet for Jenkins GKE
- a private GKE cluster with VPC-native routing and workload identity
- Cloud NAT for Jenkins pipelines to reach external dependencies
- Kubernetes service accounts and IAM bindings for workload identity to the initial LZ Google service account
- a Jenkins installation per [jenkinsci/helm-charts](https://github.com/jenkinsci/helm-charts)

> Note: it is NOT recommended that this code be executed from a pipeline within the resulting Jenkins instance

It is assumed that the following resources exist, per the [org-automation-project](https://github.com/codepil/terraform-code-bits/org-automation-project) bootstrap:

- a central org automation project
- a Google Cloud Folder to serve as the root node of all Landing Zone resources
- a Google service account with Folder Admin, Folder Editor, and Project Creator on the
Landing Zone Folder

These resources can be generated using the
[org-automation-project](https://github.com/codepil/terraform-code-bits/org-automation-project)
and [top-lz-folder](https://github.com/codepil/terraform-code-bits/top-lz-folder) repositories

The individual executing this codebase should have permission to create service
accounts in the automation project, and to create IAM bindings on the LZ automation
service account.

## Installation

The installation process for this codebase is broken into three steps:

1. Terraform for base Google Cloud resource creation
2. Terraform for Kubernetes-internal resources
3. Helm for deployment of Jenkins

### Prerequisites

The individual executing the installation should have the following tools installed:

- [Terraform 0.13.4](https://www.terraform.io/downloads.html) or greater
- [Helm version 3.4.0](https://github.com/helm/helm/releases/tag/v3.4.0) or greater
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for configuring client access

### Base Google Cloud resource creation

To create the base Google Cloud resources, initialize the Terraform codebase.
In order to store Terraform state for future management, run the following commands:

```bash
./deploy/tf-init.sh <GCS_BUCKET> main
```

Then execute Terraform with `create_kube_bindings=false` to exclude cluster-internal
resources

```bash
terraform plan -var-file example-com.tfvars -var create_kube_bindings=false -out planfile

terraform apply planfile
```

### DNS and Certificate configuration
Once base cluster is created, create the DNS record for the public IP. To get the public IP, run:

```bash
terraform state show google_compute_global_address.jenkins_elb
```

Then create the certificate resource.  This is manual so it doesn't store the certificate key in terraform state:
```
gcloud compute ssl-certificates create lz-jenkins-ingress \
  --certificate entrustcert.cert.pem \
  --private-key jenkins-k8s-server.key
```
(assumes entrusecert.cert.pem and jenkins-k8s-server.key are already created via your typical CA process)

### Create the Identity Aware Proxy
Create the identity aware proxy via CLI.  Note this can't be automated at this time due to restrictions on account types:
```
gcloud alpha iap oauth-brands create \
  --application_title="gcp Landing Zone Automation" \
  --support_email=bijjalap@example.com
```
NOTE: support_email must match the email address of the user running the command (as authenticated via gcloud)

Edit example-com.tfvars, and provide the brand name generated from the gcloud command above (ie, "projects/####/brands/####") to the iap_client_brand variable.

Run terraform again:
```bash
terraform plan -var-file example-com.tfvars -var create_kube_bindings=false -out planfile

terraform apply planfile
```

### Kubernetes-internal resource creation

Once the cluster is created, authenticate in order to create cluster-internal resources

```bash
gcloud container clusters get-credentials --region <REGION> <CLUSTER>
```

Then execute Terraform with `create_kube_bindings=true` to include cluster-internal
resources

```bash
terraform plan -var-file example-com.tfvars -var create_kube_bindings=true  -out planfile

terraform apply planfile
```

### Jenkins installation with Helm

To install Jenkins on the new GKE cluster, ensure that Helm 3 is installed, and
run the following command:

```bash
./deploy/install-jenkins.sh
```

The Jenkins ingress will not come online until a `BackendConfig` is created that matches
the ingress annotations. To create this, run the following:

```bash
kubectl apply --namespace jenkins -f ./helm/backend-config.yaml
```

Future updates to Jenkins can be applied by modifying `./helm/jenkins-values.yaml`
and re-running the install-jenkins.sh command.

> Note: Jenkins Plugins (and updates) should be managed through modifying `./helm/jenkins-values.yaml`.
> Plugins should not be directly managed through the Jenkins UI.

### Post-install steps

Per helm outputs, the Jenkins admin login credentials can be retrieved by executing
the following command. Use this to login to Jenkins (after authenticating with IAP).

```bash
printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```

The master LZ automation service account is isolated from the rest of Jenkins through
the use of a dedicated [Kubernetes Cloud Configuration](https://plugins.jenkins.io/kubernetes).
In order for Jenkins to execute jobs as this service account, create a new Jenkins
secret containing the `lz-automation/lz-automation-master` service account token.

First, retrieve the `lz-automation/lz-automation-master` service account token:

```bash
SA_TOKEN_NAME=$(kubectl get serviceaccount -n lz-automation lz-automation-master-tf -o jsonpath="{.secrets[0].name}")

printf $(kubectl get secret -n lz-automation $SA_TOKEN_NAME -o jsonpath="{.data.token}" | base64 --decode);echo
```

Next, create a new Jenkins system-scoped secret for this service account. Navigate
to https://jenkins-lz.example.com/credentials/store/system/domain/_/newCredentials,
and provide the following values:

```yaml
Kind:         Secret text
Scope:        System (Jenkins and nodes only)
Secret:       <TOKEN_VALUE>
ID:           ksa-lz-automation
Description:  Kubernetes service account token for lz-automation-master
```

> Note: ID must be `ksa-lz-automation` exactly to match Jenkins configuration-as-code.

Then create one additional Jenkins secret to store a read-only GitLab access token:

```yaml
Kind:         Username with password
Scope:        Global (Jenkins, nodes, items, all child items, etc.)
Username:     <GitLab User>
ID:           gitlab-token
Description:  Read-only access token for Gitlab
```

Finally, configure the LZ-Automation Jenkins shared library.

- Navigate to https://jenkins-lz.example.com/configure
- Under "Global Pipeline Libraries", add a new item:
  - Name: lz-jenkins-shared-lib
  - Default version: master
  - Retrieval Method: Modern SCM
  - Source Code Management: git
    - Project Repository: https://github.com/codepil/terraform-code-bits/lz-jenkins-shared-library.git
    - Credentials: gitlab-token

At this point, Jenkins is configured and users can begin configuring Jenkins Folders and Pipelines.

## TODO

- configure user authentication (AD or Google Auth) for general user access
- capture initial landing zone pipelines as Jenkins-configuration-as-code
- automation creation of BU-specific Landing Zone pipelines
- evaluate additional secret/credential providers such as Kubernetes secrets and Google Cloud Secret Manager
- enable automated backups through Google Cloud disk snapshots
