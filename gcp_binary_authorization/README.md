# gcp-binary-authorization


[Binary Authorization (BinAuthz)](https://cloud.google.com/binary-authorization/) is a GCP service that enforces deploy-time policies to your Kubernetes Engine cluster. Policies can be written to require one or more trusted parties (called "attestors") to approve of an image before it can be deployed. For a multi-stage deployment pipeline where images progress from development to testing to production clusters, attestors can be used to ensure that all required processes have completed before software moves to the next stage.

![attestations](https://cdn.qwiklabs.com/RXPfaDeQ1Mv%2Bs2RYXmRFIDD%2Be1AoKAf9qEOD9m5t%2F80%3D)

The identity of attestors is established and verified using cryptographic public keys, and attestations are digitally signed using the corresponding private keys. This ensures that only trusted parties can authorize deployment of software in your environment.

At deployment time, Binary Authorization enforces the policy you defined by checking that the container image has passed all required constraints – including that all required attestors have verified that the image is ready for deployment. If the image passes, the service allows it to be deployed. Otherwise, deployment is blocked and the image cannot be deployed until it is compliant.

![Enforcement of Policy](https://cdn.qwiklabs.com/2eczz6ago2COUKvuw9adq64v0g1SFqVaRTar7mLyTSc%3D)

The three TF modules here in this building block supports creating,
* An attestor, with respective container analysis note and IAM bindings 
* A crypto key with respective IAM permissions 
* A default Policy
    * plus Cluster specific policy, if any
* Whitelisting of images, if any 

Terraform modules here are modeled (and tested) with 1) one common Attestor central to all projects in a given BU, this project stores attestations and attestor keys in the same the same project. 2) Multiple Deployer projects exists hosting GKE cluster with their respective Binary authorisation policies. 

For any other models, please use these modules as a reference to create your own modules. 

## Steps
As detailed in [multi-project setup guide](https://cloud.google.com/binary-authorization/docs/multi-project-setup-cli),
* Enable respective APIs in both Attestor project and Deployer project(s). 
    * Refer to pre-requisites below, which are to be done in respective project's manifests.
* Add below roles to your Automation SA, in their respective project manifests.
    * "roles/binaryauthorization.attestorsAdmin" and "roles/cloudkms.admin" in Attestor project
    * "roles/binaryauthorization.policyAdmin" in Deployer project(s)
* Create crypto key in a attestor_project, or identify the key from your kms_project and add respective permissions, Refer to or use module [./key](./key) for the same.
* Create an Attestor with container analysis note, in a given attestor_project, using module [./attestor](./attestor). 
    * PS: Attestors can only be created using Service Account and user accounts are not supported.
* Create default Binary Authorisation policy in each deployer_project(s), using module [./policy](./policy).

## Test the setup
* Deploy GKE cluster in Deployer project, refer to [examples/create-gke](./examples/create-gke) for TF script.
* (Optional) Update Policy TF to add cluster specific rule(s), example below
```hcl-terraform
  cluster_admission_rules = [
    {
      cluster = "us-east4.testlz-gke-cluster"
      evaluation_mode = "REQUIRE_ATTESTATION"
    }
```
* Deploy an image. Which is expected to fail since no attestation is created yet.
```commandline
kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080
```
* Create Attestation. PS: verify no vulnerabilities before attesting.
```commandline
# More details, refer to examples/attest_an_image.sh script for creating an attestation, at high level
gcloud container binauthz attestations create --project=pid-gcp-tlz-gke-att-77d1 --artifact-url=gcr.io/google-samples/hello-app@sha256:c62ead5b8c15c231f9e786250b07909daf6c266d0fcddd93fea882eb722c3be4 --attestor=projects/pid-gcp-tlz-gke-att-77d1/attestors/testlz-common-attestor --signature-file=/tmp/ec_signature --public-key-id=//cloudkms.googleapis.com/v1/projects/pid-gcp-tlz-gke-att-77d1/locations/global/keyRings/attestor-key-ring/cryptoKeys/attesting-key1/cryptoKeyVersions/1 --validate
```
* Now deploying the image should be successful, confirm by 'kubectl get pods'. PS: You must deploy the image using the digest rather than a tag like 1.0 or latest. Refer to [examples/create-gke/test/create_pod.yaml](./examples/create-gke//test/create_pod.yaml)
* (Optional) To test whitelisting, update the [policy TF](./policy) module by adding an image URL to 'images_exempted' Or by [break-glass](https://cloud.google.com/binary-authorization/docs/using-breakglass) annotations in CRDs. Use [examples/create-gke/test/create_pod.yaml](./examples/create-gke//test/create_pod.yaml) to test break-glass feature.
* Do the clean up, by deleting the cluster and remove if any cluster specific policies.

## Recommendations
* Creating one or more Attestor(s) in a central attestor_project, per BU.
* Create a default global policy in each deployer/GKE project(s).

## Pre-requisites
* Deployer project(s) should have enabled APIs namely "binaryauthorization.googleapis.com", "containerregistry.googleapis.com" and "artifactregistry.googleapis.com".
    * Automation SA should have equivalent roles of "roles/container.admin" (for GKE), "roles/binaryauthorization.policyAdmin" (for Policies)
* Attestor project should have enabled APIs namely "binaryauthorization.googleapis.com" and "containeranalysis.googleapis.com"
    * Automation SA should have equivalent roles of "roles/binaryauthorization.attestorsAdmin", "roles/binaryauthorization.policyAdmin" and "roles/cloudkms.admin" 
* Google Kubernetes Engine(GKE) cluster crated with "Binary Authorization" enabled. See examples/create-gke for reference.
* In your CI/CD pipeline or in K8s resource definitions, you must deploy the image using the digest rather than a tag like 1.0 or latest, as Binary Authorization uses both the image path and digest to look up attestations.




