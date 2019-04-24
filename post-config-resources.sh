#!/bin/bash

PROG="$(basename "${0}")"
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
VMNAME=""
POST_CONFIG_RESOURCES_FILE=""
VBOXMANAGE=`which vboxmanage`

usage() {
  echo -e "USAGE: ${PROG} [--vm-name <VMNAME>]\n"
}

help_exit() {
  usage
  echo "This is a utility script for post configure vm.
Options:
  -v, --vm-name VMNAME
              Name of VistualBox vm.
  -r, --post-config-resources POST_CONFIG_RESOURCES_FILE
              Path to an post config resources data file.              
  -h, --help  Output this help message.
"
  exit 0
}

assign() {
  key="${1}"
  value="${key#*=}"
  if [[ "${value}" != "${key}" ]]; then
    # key was of the form 'key=value'
    echo "${value}"
    return 0
  elif [[ "x${2}" != "x" ]]; then
    echo "${2}"
    return 2
  else
    output "Required parameter for '-${key}' not specified.\n"
    usage
    exit 1
  fi
  keypos=$keylen
}

while [[ $# -ge 1 ]]; do
  key="${1}"

  case $key in
    -*)
    keylen=${#key}
    keypos=1
    while [[ $keypos -lt $keylen ]]; do
      case ${key:${keypos}} in
        v|-vm-name)
        VMNAME=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        r|-post-config-resources)
        POST_CONFIG_RESOURCES_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        h*|-help)
        help_exit
        ;;
        *)
        output "Unknown option '${key:${keypos}}'.\n"
        usage
        exit 1
        ;;
      esac
      ((keypos++))
    done
    ;;
  esac
  shift
done

if [[ -z ${VMNAME} ]]; then
  echo "VM name not found"
  exit 1
fi

if [[ -z ${POST_CONFIG_RESOURCES_FILE} || ! -f ${POST_CONFIG_RESOURCES_FILE} ]]; then
  echo "Post config resources data file, not found"
  exit 1
fi

PROCESSORS=`cat ${POST_CONFIG_RESOURCES_FILE} | shyaml get-value processors`
MEMORY=`cat ${POST_CONFIG_RESOURCES_FILE} | shyaml get-value memory`

${VBOXMANAGE} modifyvm ${VMNAME} --cpuhotplug off
${VBOXMANAGE} modifyvm ${VMNAME} --cpus ${PROCESSORS} --memory ${MEMORY} --vram 33