map-ports: map-deck map-orca

map-deck:
	kubectl port-forward --namespace default $(shell kubectl get po -l cluster=spin-deck -o jsonpath='{.items[0].metadata.name}') 8080:9000 >> /dev/null &

map-orca:
	kubectl port-forward --namespace default $(shell kubectl get po -l cluster=spin-orca -o jsonpath='{.items[0].metadata.name}') 8084:8084 >> /dev/null &

log-orca:
	kubectl logs -f deploy/spin-orca

log-clouddriver:
	kubectl logs -f deploy/spin-clouddriver
