# gcp-binary-authorization-attestor

Use CFF module https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/v16.1.0/modules/binary-authorization for creating attestor in a project

Which creates,
* An asymmetric keys in KMS
* Register with container analysis API with an authorisation note
* Creates an attestor
* Enables project for Binary Authorisation APIs, namely "binaryauthorization.googleapis.com", "containeranalysis.googleapis.com", "cloudkms.googleapis.com", "container.googleapis.com".


## Next steps
After building an Attestor, 
* Attestations can be created using KMS key, in the respective image built CI/CD pipeline.
* Create/update authorisation policies to use Attestor created, to complete the GKE/binary authorisation. You may use building block at https://github.com/codepil/terraform-code-bits/gcp_binary_authorization for the same.


