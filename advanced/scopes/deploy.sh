#!/usr/bin/env bash

function deploy() {
    local templateFile="main.bicep"
    local today=$(date +"%d-%b-%Y")
    local deploymentName="sub-scope-$today"
    local virtualNetworkName="rnd-vnet-001"
    local virtualNetworkAddressPrefix="10.0.0.0/24"

    az deployment sub create \
        --name $deploymentName \
        --location 'westus' \
        --template-file $templateFile \
        --parameters virtualNetworkName=$virtualNetworkName \
                     virtualNetworkAddressPrefix=$virtualNetworkAddressPrefix
}

deploy
