
# Spinnaker on local (macOS)

Bring up your local Spinnaker.

## Prerequisite

* [yq](http://mikefarah.github.io/yq/)
* [kind](https://kind.sigs.k8s.io/)
* [Minio][2]
* Cloned all Spinnaker microservices in your GitHub account. See [the list][4].
* Following environment variables are set: `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `GITHUB_USERNAME`

## Setup

Follow [Getting Set Up for Spinnaker Development][1] to setup the environment with the following choices.

* Choose [Minio][2] for a storage service
* Choose [Kubernetes V2][3] for a cloud provider

## References

* [K3s, minikube or microk8s?](https://www.reddit.com/r/kubernetes/comments/be0415/k3s_minikube_or_microk8s/)

[1]: https://www.spinnaker.io/guides/developer/getting-set-up/#getting-set-up-for-spinnaker-development
[2]: https://www.spinnaker.io/setup/install/storage/minio/
[3]: https://www.spinnaker.io/setup/install/providers/kubernetes-v2/
[4]: https://www.spinnaker.io/reference/architecture/#spinnaker-microservices
