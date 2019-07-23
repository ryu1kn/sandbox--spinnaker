#!/bin/bash

set -xeuo pipefail

minikube start
helm init --wait
helm install --name my-spinnaker stable/spinnaker --timeout 600
kubectl expose deployment spin-deck --type=NodePort --name=spin-deck-2
kubectl expose deployment spin-gate --type=NodePort --name=spin-gate-2  # For spin cli
minikube service spin-deck-2 --url
