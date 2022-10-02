#!/bin/bash

set -x

PROJECT_ID=$2 # ex: pid-gcp-tlz-pavan-5231
IMAGE_NAME=$1 # ex: demo-app

# Create an example docker file
cat <<EOF >Dockerfile
   FROM alpine
   RUN echo 'we are running some # of cool things'
   CMD tail -f /dev/null
EOF

# set the GCR path you will use to host the container image
CONTAINER_PATH=gcr.io/${PROJECT_ID}/${IMAGE_NAME}

# build container
docker build -t $CONTAINER_PATH ./

# push to GCR
#gcloud auth configure-docker --quiet
docker push $CONTAINER_PATH

<< EOC # test it out
 gcloud container clusters get-credentials test-cluster --region us-east4 --project pid-gcp-tlz-gke01-d0cc
 gsutil iam set gs://artifacts.pid-gcp-tlz-pavan-5231.appspot.com/ serviceAccount:336976643645-compute@developer.gserviceaccount.com:roles/storage.objectViewer

 # get list of attestations
 gcloud container binauthz attestations list --project=pid-gcp-tlz-gke-att-77d1 --attestor="projects/pid-gcp-tlz-gke-att-77d1/attestors/testlz-demo-common-attestor"

 # delete attestations if any
 curl -H "Authorization: Bearer $(gcloud auth print-access-token)" -X DELETE https://containeranalysis.googleapis.com/v1beta1/projects/pid-gcp-tlz-gke-att-77d1/occurrences/7778f5f8-459c-44bc-954b-fb03a8b7d89d

 # deploy
 kubectl create deployment demo-app --image=gcr.io/pid-gcp-tlz-gke01-d0cc/demo-app@sha256:97efb95ae2797bffe062e69114ccc0a628b38330b76525a9d417702d56b1bb35
 kubectl get pods

 # see the error message
 kubectl get event --template '{{range.items}}{{"\033[0;36m"}}{{.reason}}:{{"\033[0m"}}\{{.message}}{{"\n"}}{{end}}'

 # destroy deployment
 kubectl delete deployment demo-app
 kubectl delete event --all

EOC
