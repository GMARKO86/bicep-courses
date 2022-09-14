#!/usr/bin/env bash

function cleanup() {
    local resourceGroupName="learndeploymentscript_exercise_2"
    az group delete --name $resourceGroupName    
}

cleanup