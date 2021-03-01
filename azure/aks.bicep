// params
param dnsPrefix string {
  default: 'cl01'
  metadata: {
    description: 'The DNS prefix to use with hosted Kubernetes API server FQDN.'
  }
}
param clusterName string {
  default: 'aks101'
  metadata: {
    description: 'The name of the Managed Cluster resource.'
  }
}

param subnetRef string {
  metadata: {
    description: ''
  }
}

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Specifies the Azure location where the key vault should be created.'
  }
}

param agentCount int {
  default: 1
  minValue: 1
  maxValue: 50
  metadata: {
    description: 'The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production'
  }
}
param agentVMSize string {
  default: 'Standard_D2_v3'
  metadata: {
    description: 'The size of the Virtual Machine.'
  }
}

// vars
var kubernetesVersion = '1.19.7'
var nodeResourceGroup = 'rg-${dnsPrefix}-${clusterName}'
var tags = {
  environment: 'test'
}
var agentPoolName = 'agentpool01'

// Azure kubernetes service
resource aks 'Microsoft.ContainerService/managedClusters@2020-09-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: agentPoolName
        count: agentCount
        mode: 'System'
        vmSize: agentVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: false
        vnetSubnetID: subnetRef
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'standard'
    }
  }
}

output id string = aks.id
output apiServerAddress string = aks.properties.fqdn