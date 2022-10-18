

# Resource Group

```
az group create --name xeniel --location westeurope --tags Purpose=Demo Production=NO --managed-by "moim.hossain@microsoft.com"
```

# Deploy
```
az deployment group create --confirm-with-what-if --resource-group xeniel --template-file main.bicep  --parameters param.json
```