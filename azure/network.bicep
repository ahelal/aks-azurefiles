// Azure virtual network

param virtualNetworkName string {
  default: 'aksVnet'
  metadata: {
    description: 'AKS virtual network name'
  }
}

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Specifies the Azure location where the key vault should be created.'
  }
}

var subnetName = 'Subnet01'
var subnetPrefix = '192.168.178.0/24'
var addressPrefix = '192.168.0.0/16'

var tags = {
  environment: 'test'
}

resource vn 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

output subnetRef string = '${vn.id}/subnets/${subnetName}'