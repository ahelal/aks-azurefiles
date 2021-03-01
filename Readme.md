# AKS and azure files

## Prerequisite 
##
### Required tools

* az cli https://docs.microsoft.com/en-us/cli/azure/
* bicep https://github.com/Azure/bicep/blob/main/docs/installing.md
* kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl/
* Helm https://helm.sh/

### Enable features on subscriptions

* https://docs.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to?tabs=linux#step-1-register-the-nfs-30-protocol-feature-with-your-subscription
* https://docs.microsoft.com/en-us/azure/storage/files/storage-files-how-to-create-nfs-shares?tabs=azure-portal#register-the-nfs-41-protocol


## Deploying 

Have a `config.sh` and `azure/main.bicep`. Use `az login` and set the desired azure subscription `az account set -s SUBSCRIPTION_ID`

```bash
# Deploy storage account and AKS cluster
./aks.sh deploy
# get kubectl credentials and cluster config
./aks.sh k8s-credentials
# Deploy helm
./aks.sh helm-deploy
# test nfs3.0 and nfs4.1 are accessible to cluster
./aks.sh helm-verify

# Destroy cluster
./aks.sh destroy
```

