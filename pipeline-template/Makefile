template_file := pipeline-tpl.json
pipeline_file := pipeline.json
config_file := spin-config.yaml

get-pi:
	@spin pipeline get --application foobarapp --name foobarpipeline --config $(config_file)

render-pi:
	spin pipeline-templates plan --file $(pipeline_file) --config $(config_file)

save-pi:
	spin pipeline save --file $(pipeline_file) --config $(config_file)

save-tpl:
	spin pipeline-templates save --file $(template_file) --config $(config_file)
