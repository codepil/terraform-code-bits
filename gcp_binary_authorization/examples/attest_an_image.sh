#!/bin/bash
set -x
<< EOC
 # list policy
 gcloud container binauthz policy export

 # list all images and digest in GCR
 gcloud container images list-tags gcr.io/pid-gcp-tlz-gke01-d0cc/demo-app --format=json

 # list all images and digest in Artifact registry
 gcloud artifacts docker images list LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/IMAGE
EOC

IMAGE_PATH=$1 # ex: "gcr.io/google-samples/hello-app"
IMAGE_DIGEST=$2 # ex: "sha256:c62ead5b8c15c231f9e786250b07909daf6c266d0fcddd93fea882eb722c3be4"
ATTESTATION_PROJECT_ID=pid-gcp-tlz-gke-att-77d1
ATTESTOR_PROJECT_ID=pid-gcp-tlz-gke-att-77d1
ATTESTOR_NAME=testlz-demo-common-attestor

KMS_KEY_NAME=attesting-key-demo
KMS_KEY_VERSION=1
KMS_KEYRING_NAME=attestor-key-ring
KMS_KEY_PROJECT_ID=${ATTESTOR_PROJECT_ID}
KMS_KEY_LOCATION=global

# Verify no attestations exists
gcloud --project=${ATTESTATION_PROJECT_ID} \
    container binauthz attestations list \
    --attestor=$ATTESTOR_NAME --attestor-project=$ATTESTOR_PROJECT_ID


# Generate a signature payload
gcloud --project=${ATTESTATION_PROJECT_ID} \
    container binauthz create-signature-payload \
    --artifact-url=${IMAGE_PATH}@${IMAGE_DIGEST} > /tmp/generated_payload.json

# Sign payload file
# PS: user should have at sufficient permissions to sign (ex: cryptoOperator role) using the KMS_KEY_NAME
gcloud kms asymmetric-sign \
      --location=${KMS_KEY_LOCATION} \
      --keyring=${KMS_KEYRING_NAME} \
      --key=${KMS_KEY_NAME} \
      --version=${KMS_KEY_VERSION} \
      --digest-algorithm=sha512 \
      --input-file=/tmp/generated_payload.json \
      --signature-file=/tmp/ec_signature \
      --project ${KMS_KEY_PROJECT_ID}

# Attest
# PS: user should have at sufficient permissions to read bin-auth
PUBLIC_KEY_ID=$(gcloud container binauthz attestors describe ${ATTESTOR_NAME} \
--format='value(userOwnedGrafeasNote.publicKeys[0].id)' --project ${ATTESTOR_PROJECT_ID})

IMAGE_TO_ATTEST=${IMAGE_PATH}@${IMAGE_DIGEST}

gcloud container binauthz attestations create \
    --project="${ATTESTATION_PROJECT_ID}" \
    --artifact-url="${IMAGE_TO_ATTEST}" \
    --attestor="projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}" \
    --signature-file=/tmp/ec_signature \
    --public-key-id="${PUBLIC_KEY_ID}" \
    --validate

<< EOC # verify deployment
 gcloud container clusters get-credentials test-cluster --region us-east4 --project pid-gcp-tlz-gke01-d0cc

 # deploy
 kubectl create deployment demo-app --image=gcr.io/pid-gcp-tlz-gke01-d0cc/demo-app@sha256:97efb95ae2797bffe062e69114ccc0a628b38330b76525a9d417702d56b1bb35
 kubectl get pods

 # list attestations
 gcloud container binauthz attestations list --project=pid-gcp-tlz-gke-att-77d1 --attestor="projects/pid-gcp-tlz-gke-att-77d1/attestors/testlz-demo-common-attestor"

 OCCURRENCE_ID listed in 'projects/pid-gcp-tlz-gke-att-77d1/occurrences/7778f5f8-459c-44bc-954b-fb03a8b7d89d'

 # Destroy deployment
 kubectl delete deployment demo-app

 # delete attestations
 curl -H "Authorization: Bearer $(gcloud auth print-access-token)" -X DELETE https://containeranalysis.googleapis.com/v1beta1/projects/pid-gcp-tlz-gke-att-77d1/occurrences/7778f5f8-459c-44bc-954b-fb03a8b7d89d

EOC