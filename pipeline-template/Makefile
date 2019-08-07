template_file := pipeline-tpl.json
pipeline_file := pipeline.json

get-pi:
	@spin pipeline get --application foobarapp --name foobarpipeline

render-pi:
	spin pipeline-templates plan --file $(template_file)

save-pi:
	spin pipeline save --file $(pipeline_file)

save-tpl:
	spin pipeline-templates save --file $(template_file)
