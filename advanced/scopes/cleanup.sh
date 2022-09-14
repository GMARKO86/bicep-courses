#!/usr/bin/env bash

function removePolicy() {
    local subscriptionId=$(az account show --query 'id' --output tsv)
    local policyName="DenyFandGSeriesVMs"
    local resourceGroupName="ToyNetworking"

    az policy assignment delete --name "$policyName" --scope "/subscriptions/$subscriptionId"
    az policy definition delete --name "$policyName" --subscription "$subscriptionId"

    az group delete --name "$resourceGroupName"
}

removePolicy