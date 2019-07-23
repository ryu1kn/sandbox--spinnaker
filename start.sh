#!/bin/bash

set -euo pipefail

minikube start
helm init
helm install --name my-spinnaker stable/spinnaker --timeout 600
kubectl expose deployment spin-deck --type=NodePort --name=spin-deck-2
kubectl expose deployment spin-gate --type=NodePort --name=spin-gate-2  # For spin cli
open $(minikube service spin-deck-2 --url)
