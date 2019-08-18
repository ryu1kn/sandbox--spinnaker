map-ports: map-deck map-orca

map-deck:
	kubectl port-forward svc/spin-deck 8080:9000 >> /dev/null &

map-orca:
	kubectl port-forward svc/spin-orca 8084 >> /dev/null &

log-orca:
	kubectl logs -f deploy/spin-orca

log-clouddriver:
	kubectl logs -f deploy/spin-clouddriver
