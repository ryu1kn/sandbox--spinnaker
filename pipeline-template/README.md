
# Spinnaker Pipeline Template

## Prerequisite

* `spin-gate` is accessible

    ```sh
    $ kubectl port-forward --namespace default $(kubectl get po -l cluster=spin-gate -o jsonpath='{.items[0].metadata.name}') 8084:8084 >> /dev/null &
    ```

## Refs

* [Using Pipeline Templates](https://www.spinnaker.io/guides/user/pipeline/pipeline-templates/)
* [Pipeline Expression Reference](https://www.spinnaker.io/reference/pipeline/expressions/)
