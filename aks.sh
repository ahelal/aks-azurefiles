#!/bin/bash
set -e
ARGUMENT=${1}
set -u

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
AZURE_BICEP_DIR="${DIR}/azure"
BICEP_BIN="${BICEP_BIN:-bicep}"
#shellcheck disable=SC1090
source "${DIR}/conf.sh"

function bicep_build(){
    cd "${AZURE_BICEP_DIR}"
    rm -rf tmp; mkdir tmp;
    echo "* Buiding bicep files"
    for filename in ./*.bicep; do
        ${BICEP_BIN} build "${filename}" --outdir tmp/
    done
}

function help(){
    echo "Supported argument :"
    echo "  build"
    echo "  deploy"
    echo "  destroy"
    echo "  whatif"
    echo "  k8s-credentials"
    echo "  helm-deploy"
    echo "  helm-delete"
    echo "  helm-verify"
}

function removeTestPods(){
    kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep "\-test" | while read -r line ; do
        kubectl delete pod "${line}"
    done
}

if [ "${ARGUMENT}" = "deploy" ]; then
    echo "* Creating RG"
    az group create -l "${LOCATION}" -n "${RG}" > /dev/null
    bicep_build
    cd "${AZURE_BICEP_DIR}/tmp"
    echo "* Deploying ARM templates"
    az deployment group create \
                --resource-group "${RG}" \
                --parameters aksName="${AKSNAME}" location="${LOCATION}" \
                --template-file main.json
elif [ "${ARGUMENT}" = "build" ]; then
    bicep_build
elif [ "${ARGUMENT}" = "whatif" ]; then
    cd "${AZURE_BICEP_DIR}/tmp"
    echo "* WhatIf"
    az deployment group create \
                --resource-group "${RG}" \
                --parameters aksName="${AKSNAME}" location="${LOCATION}" \
                --template-file main.json \
                --confirm-with-what-if
elif [ "${ARGUMENT}" = "destroy" ]; then
    echo "* Destroying RG ${RG}"
    az group delete --name "${RG}"
elif [ "${ARGUMENT}" = "get-credentials" ]; then
    az aks get-credentials -n "${AKSNAME}" -g "${RG}"
elif [ "${ARGUMENT}" = "helm-deploy" ]; then
    cd "${DIR}"
    helm upgrade -i k8sstorage ./k8sstorage
elif [ "${ARGUMENT}" = "helm-delete" ]; then
    removeTestPods
    helm delete k8sstorage
elif [ "${ARGUMENT}" = "helm-verify" ]; then
    removeTestPods
    cd "${DIR}"
    helm test k8sstorage
elif [ "${ARGUMENT}" = "" ]; then
    echo "missing action"
    help
    exit 1
else
    echo "unknown action ${ARGUMENT}"
    help
    exit 1
fi
