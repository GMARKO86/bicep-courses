#!/usr/bin/env bash

function applyPolicy() {
    local templateFile="main.bicep"
    local today=$(date +"%d-%b-%Y")
    local deploymentName="sub-scope-$today"

    az deployment sub create \
        --name $deploymentName \
        --location 'westus' \
        --template-file $templateFile
}

function removePolicy() {
    local subscriptionId=$(az account show --query 'id' --output tsv)
    local policyName="DenyFandGSeriesVMs"

    az policy assignment delete --name "$policyName" --scope "/subscriptions/$subscriptionId"
    az policy definition delete --name "$policyName" --subscription "$subscriptionId"
}

if [ "$1" == "apply" ]; then
    applyPolicy
elif [ "$1" == "remove" ]; then
    removePolicy
else
    echo "Invalid option '$1'. Must be apply or remove."
    exit 1
fi
