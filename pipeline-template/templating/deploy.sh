#!/bin/bash

set -euo pipefail

config='--config ../spin-config.yaml'

spin pipeline-templates save --file template.json $config
spin pipeline save --file pipeline.json $config
