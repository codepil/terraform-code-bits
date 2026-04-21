# GCP Landing Zone Business Unit Stack

This module is used as a blueprint to create and manage Landing Zone instances for each business unit or operating unit.

This module creates the following:

* a root Google Cloud folder for this landing zone
* three SDLC-specific folders to contain application projects
    * Dev-QA, Non-CDE, and CDE, all under the root LZ folder
* a BU Operations folder under the root LZ folder, containing:
    * a landing zone operations project to store LZ-specific operational resources such as Terraform state and Terraform service accounts
* three SDLC-specific Shared VPC host projects, for use by application projects as needed
* one "shared" Shared VPC host project, to be connected to all SDLC environments as needed
* one "lz-images" project to contain VM images, image build processes, and an LZ specific instance of GCR, with Twistlock service account granted permissions by default.
* any standardized organization policies, IAM policies, and user groups to support various Landing Zone operations
* a BU-specific Google Cloud service account for managing BU application projects for each SDLC folder and the Operations folder
* Kubernetes service accounts with workload identity bindings for each project and folder
