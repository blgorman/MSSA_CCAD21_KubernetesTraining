ACR_NAME=acrsimplekubedemo20260305blg       
RG=rg-simplekubedemo
LOCATION=centralus
CLUSTER=aks-simplekubedemo
K8S_VERSION=1.29


az acr create \
  --resource-group $RG \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled false

# Backend (--platform linux/amd64 required when building on ARM64 machines for AKS amd64 nodes)
docker build --platform linux/amd64 -t "$ACR_NAME.azurecr.io/simple-kube-demo-backend:v1.0.0" ./backend

# Frontend
docker build --platform linux/amd64 -t "$ACR_NAME.azurecr.io/simple-kube-demo-frontend:v1.0.0" ./frontend

docker push "$ACR_NAME.azurecr.io/simple-kube-demo-backend:v1.0.0"
docker push "$ACR_NAME.azurecr.io/simple-kube-demo-frontend:v1.0.0"


az acr repository show-tags \
  --name $ACR_NAME \
  --repository simple-kube-demo-backend \
  --output table

az aks create \
  --resource-group $RG \
  --name $CLUSTER \
  --kubernetes-version $K8S_VERSION \
  --node-count 2 \
  --node-vm-size Standard_D2s_v3 \
  --attach-acr $ACR_NAME \
  --enable-managed-identity \
  --generate-ssh-keys

# If the cluster already existed without ACR attachment, run this to grant pull access:
az aks update \
  --resource-group $RG \
  --name $CLUSTER \
  --attach-acr $ACR_NAME


  az aks approuting enable --resource-group $RG --name $CLUSTER
