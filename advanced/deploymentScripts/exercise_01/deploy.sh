#!/usr/bin/env bash

function createResourceGroup() {
    local resourceGroupName="$1"
    az group create --location eastus --name $resourceGroupName
}

function deployTemplate() {
    local resourceGroupName="$1"
    local deploymentName="$2"
    local templateFile="$3"

    az deployment group create \
        --resource-group "$resourceGroupName" \
        --name "$deploymentName" \
        --template-file "$templateFile"
}

function verifyDeployment() {
    local resourceGroupName="$1"
    local deploymentName="$2"
    local uri=$(az deployment group show --resource-group $resourceGroupName --name $deploymentName --query 'properties.outputs.fileUri.value' --output tsv)
    curl $uri
}

function main() {
    local resourceGroupName="learndeploymentscript_exercise_1"
    local today=$(date +"%d-%b-%Y")
    local deploymentName="deploymentscript-$today"
    local templateFile="main.bicep"

    createResourceGroup "$resourceGroupName"
    deployTemplate "$resourceGroupName" "$deploymentName" "$templateFile"
    verifyDeployment "$resourceGroupName" "$deploymentName"
}

main