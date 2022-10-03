#!/usr/bin/env bash

set -e
set -u

helm_version="$(helm version --short)"
if ! [[ $helm_version == v3.* ]] ; then
  echo "Helm version 3 is required. Version found: $helm_version"
  exit 1
fi


helm repo add jenkins https://charts.jenkins.io
helm repo update

helm upgrade --install --namespace jenkins jenkins jenkins/jenkins --version="2.19.0" -f ./helm/jenkins-values.yaml
