
param containerName string {
  default: 'maincontainer'
  metadata: {
    description: 'Container to create'
  }
}

param storageAccountName string {
  metadata: {
    description: 'storage account to use'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageAccountName}/default/${containerName}'
}