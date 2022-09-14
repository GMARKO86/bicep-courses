#!/usr/bin/env bash

cleanup () {
    local resourceGroupName="learndeploymentscript_exercise_1"
    az group delete --name "$resourceGroupName"
}

cleanup