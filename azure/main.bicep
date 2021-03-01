param aksName string
param location string

module vn './network.bicep' = {
  name: 'vn'
  params: {
      location: location
  }
}

module aks './aks.bicep' = {
  name: 'aks'
  params: {
      location: location
      clusterName: aksName
      subnetRef: vn.outputs.subnetRef
  }
}

module saSMB './storageAccount.bicep' = {
  name: 'saSMB'
  params: {
      storagePrefix: 'sasmb'
      location: location
  }
}

module smbContainer './azureFiles.bicep' = {
  name: 'smbContainer'
  params: {
    storageAccountName: saSMB.outputs.storageAccountName
    shareName: 'main'
    protocol: 'SMB'
  }
}

// https://docs.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to?tabs=linux
module saNFS3 './storageAccount.bicep' = {
  name: 'saNFS3'
  params: {
      storagePrefix: 'sanfs3'
      storageTier: 'Premium'
      storageaccountkind: 'BlockBlobStorage'
      storgeaccountRedundancy: 'Premium_LRS'
      storageHNS: true
      blobNFS3: true
      httpsTrafficOnly: false
      location: location
      storageSubnet: vn.outputs.subnetRef
  }
}

module nfs3Blob './blobContainer.bicep' = {
  name: 'nfs3Blob'
  params: {
      storageAccountName: saNFS3.outputs.storageAccountName
      containerName: 'main'
  }
}

// https://docs.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to?tabs=linux
module saNFS4 './storageAccount.bicep' = {
  name: 'saNFS4'
  params: {
    storagePrefix: 'sanfs4'
    storageTier: 'Premium'
    storageaccountkind: 'FileStorage'
    storgeaccountRedundancy: 'Premium_LRS'
    httpsTrafficOnly: false
    location: location
    storageSubnet: vn.outputs.subnetRef
  }
}

module nfs4Fileservice'./azureFiles.bicep' = {
  name: 'nfs4Fileservice'
  params: {
      storageAccountName: saNFS4.outputs.storageAccountName
      shareName: 'main'
      protocol: 'NFS'
  }
}

output name string = aksName
output loc string = location
