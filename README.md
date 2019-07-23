
# Spinnaker sandbox

## Prerequisites

* Docker
* [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* [helm](https://helm.sh/)
* [Spin CLI](https://www.spinnaker.io/guides/spin/)
* (Optional) [Halyard CLI](https://www.spinnaker.io/setup/install/halyard/)

## Start Spinnaker

```sh
$ ./start.sh
+ minikube start
😄  minikube v1.2.0 on darwin (amd64)
...
http://192.168.64.9:32635
```

Open the last displayed URL with the browser and you get Spinnaker UI.

## Stop Spinnaker

```sh
$ ./stop.sh
```

## Refs

* [Spinnaker Guides](https://www.spinnaker.io/guides/)
