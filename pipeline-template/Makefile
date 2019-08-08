config_file := spin-config.yaml
app_name := foo-app

map-port:
	kubectl port-forward --namespace default $(shell kubectl get po -l cluster=spin-gate -o jsonpath='{.items[0].metadata.name}') 8084:8084 >> /dev/null &

get-pi:
	spin pipeline get --application $(app_name) --name $(pipeline_name) --config $(config_file)

render-pi:
	spin pipeline-templates plan --file $(pipeline_name).json --config $(config_file)

save-pi:
	spin pipeline save --file $(pipeline_name).json --config $(config_file)

save-tpl:
	spin pipeline-templates save --file $(template_name).json --config $(config_file)

save-app:
	spin application save --application-name $(app_name) \
		--owner-email example@example.com \
		--cloud-providers kubernetes \
		--config $(config_file)
