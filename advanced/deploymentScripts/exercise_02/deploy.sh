#!/usr/bin/env bash
function createResourceGroup() {
    local resourceGroupName="$1"
    az group create --location eastus --name "$resourceGroupName"
}

function deploy() {
    local resourceGroupName="$1"
    local deploymentName="$2"
    local templateFile="$3"
    local templateParameterFile="$4"

    az deployment group create \
        --resource-group $resourceGroupName \
        --name $deploymentName \
        --template-file $templateFile \
        --parameters $templateParameterFile
}

function verifyDeployment() {
    local resourceGroupName="$1"
    local storageAccountName="$2"
    local storageAccountName=$(az deployment group show --resource-group $resourceGroupName --name $deploymentName --query 'properties.outputs.storageAccountName.value' --output tsv)
    az storage blob list \
        --account-name $storageAccountName \
        --container-name config \
        --query '[].name'
}

function main() {
    local templateFile="main.bicep"
    local templateParameterFile="azuredeploy.parameters.json"
    local today=$(date +"%d-%b-%Y")
    local deploymentName="deploymentscript-"$today
    local resourceGroupName="learndeploymentscript_exercise_2"

    createResourceGroup "$resourceGroupName"
    deploy "$resourceGroupName" "$deploymentName" "$templateFile" "$templateParameterFile"
    verifyDeployment "$resourceGroupName" "$deploymentName"
}

main
