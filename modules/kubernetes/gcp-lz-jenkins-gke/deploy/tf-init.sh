#!/usr/bin/env bash

# ex: ./deploy/tf-init.sh lz-jenkins-bootstrap-tf-state main

set -e
set -u

start_dir="$(pwd)"
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <BACKEND_BUCKET> <BACKEND_PREFIX>"
  echo
  exit 1
fi

backend_bucket="${1}"
backend_prefix="${2}"

terraform init \
    -backend-config=bucket=${backend_bucket} \
    -backend-config=prefix=${backend_prefix}
