#!/usr/bin/env bash

resourceGroupID="$1"

az account set --subscription "Concierge Subscription"
subscriptionId=$(az account list --refresh --query "[?contains(name, 'Concierge Subscription')].id" --output tsv)
az account set --subscription "$subscriptionId"
az configure --defaults group="$resourceGroupID"