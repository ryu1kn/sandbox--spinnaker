#!/bin/bash

set -xeuo pipefail

helm delete --purge my-spinnaker
minikube delete
