#!/bin/bash

PROG="$(basename "${0}")"
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
BASE_IMAGE=""
LINUX_DISTRIBUTION="debian"
HOSTNAME=""
SSH_PUB_KEY_FILE=""
META_DATA_FILE="meta-data"
USER_DATA_FILE="user-data"
NETWORK_INTERFACES_FILE=""
POST_CONFIG_INTERFACES_FILE=""
POST_CONFIG_STORAGES_FILE=""
POST_CONFIG_RESOURCES_FILE=""
AUTO_START="true"
VBOXMANAGE=`which vboxmanage`
GENISOIMAGE=`which genisoimage`
SED=`which sed`
UUIDGEN=`which uuidgen`
POSTCONFIGUREINTERFACES=${SCRIPT_DIR}/post-config-interfaces.sh
POSTCONFIGURESTORAGES=${SCRIPT_DIR}/post-config-storages.sh
POSTCONFIGURERESOURCES=${SCRIPT_DIR}/post-config-resources.sh

usage() {
  echo -e "USAGE: ${PROG} [--base-image <BASE_IMAGE>] [--linux-distribution LINUX_DISTRIBUTION]
        [--hostname <HOSTNAME>] [--ssh-pub-keyfile <SSH_PUB_KEY_FILE>] [--meta-data <META_DATA_FILE>] 
        [--user-data <USER_DATA_FILE>] [--networ-interfaces <NETWORK_INTERFACES_FILE>]
        [--post-config-interfaces POST_CONFIG_INTERFACES_FILE]
        [--post-config-storages POST_CONFIG_STORAGES_FILE]
        [--post-config-resources POST_CONFIG_RESOURCES_FILE]
        [--auto-start true|false]\n"
}

help_exit() {
  usage
  echo "This is a utility script for create image using cloud-init.
Options:
  -b, --base-image BASE_IMAGE
              Name of VirtualBox base image.
  -l, --linux-distribution LINUX_DISTRIBUTION (debian|ubuntu)
              Name of Linux distribution. Default is '${LINUX_DISTRIBUTION}'.
  -o, --hostname HOSTNAME
              Hostname of new image
  -k, --ssh-pub-keyfile SSH_PUB_KEY_FILE
              Path to an SSH public key.
  -m, --meta-data META_DATA_FILE
              Path to an meta data file. Default is '${META_DATA_FILE}'.
  -u, --user-data USER_DATA_FILE
              Path to an user data file. Default is '${USER_DATA_FILE}'.
  -n, --network-interfaces NETWORK_INTERFACES_FILE
              Path to an network interface data file.
  -i, --post-config-interfaces POST_CONFIG_INTERFACES_FILE
              Path to an post config interface data file.
  -s, --post-config-storages POST_CONFIG_STORAGES_FILE
              Path to an post config storage data file.
  -r, --post-config-resources POST_CONFIG_RESOURCES_FILE
              Path to an post config resources data file.              
  -a, --auto-start true|false
              Auto start vm. Default is true.
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
        b|-base-image)
        BASE_IMAGE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        l|-linux-distribution)
        LINUX_DISTRIBUTION=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;        
        o|-hostname)
        HOSTNAME=$(assign "${key:${keypos}}" "${2}")
        HOSTNAME=`echo ${HOSTNAME} | tr '[:upper:]' '[:lower:]'`
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        k|-ssh-pub-keyfile)
        SSH_PUB_KEY_FILE=$(assign "${key:${keypos}}" "${2}")
        SSH_PUB_KEY_FILE_CONTENT=`cat ${SSH_PUB_KEY_FILE}`
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        m|-meta-data)
        META_DATA_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        u|-user-data)
        USER_DATA_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        n|-network-interfaces)
        NETWORK_INTERFACES_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        i|-post-config-interfaces)
        POST_CONFIG_INTERFACES_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        s|-post-config-storages)
        POST_CONFIG_STORAGES_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;
        r|-post-config-resources)
        POST_CONFIG_RESOURCES_FILE=$(assign "${key:${keypos}}" "${2}")
        if [[ $? -eq 2 ]]; then shift; fi
        keypos=$keylen
        ;;        
        a|-auto-start)
        AUTO_START=$(assign "${key:${keypos}}" "${2}")
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

META_DATA_FILE=${SCRIPT_DIR}/data/${LINUX_DISTRIBUTION}/${META_DATA_FILE}
USER_DATA_FILE=${SCRIPT_DIR}/data/${LINUX_DISTRIBUTION}/${USER_DATA_FILE}
NETWORK_INTERFACES_FILE=${SCRIPT_DIR}/data/${LINUX_DISTRIBUTION}/${NETWORK_INTERFACES_FILE}
POST_CONFIG_INTERFACES_FILE=${SCRIPT_DIR}/data/${LINUX_DISTRIBUTION}/${POST_CONFIG_INTERFACES_FILE}
POST_CONFIG_STORAGES_FILE=${SCRIPT_DIR}/data/${LINUX_DISTRIBUTION}/${POST_CONFIG_STORAGES_FILE}
POST_CONFIG_RESOURCES_FILE=${SCRIPT_DIR}/data/${LINUX_DISTRIBUTION}/${POST_CONFIG_RESOURCES_FILE}

if [[ -z ${BASE_IMAGE} ]]; then
  echo "Base image not found"
  exit 1
fi

if [[ -z ${HOSTNAME} ]]; then
  echo "Hostname not set"
  exit 1
fi

if [[ -z ${SSH_PUB_KEY_FILE} || ! -f ${SSH_PUB_KEY_FILE} ]]; then
  echo "SSH public key File not found!"
  exit 1
fi

if [[ -z ${META_DATA_FILE} || ! -f ${META_DATA_FILE} ]]; then
  echo "Meta data File not found!"
  exit 1
fi

if [[ -z ${USER_DATA_FILE} || ! -f ${USER_DATA_FILE} ]]; then
  echo "User data File not found!"
  exit 1
fi

mkdir -p ${SCRIPT_DIR}/vms/${HOSTNAME}

UUID=`${UUIDGEN}`

FILES="${SCRIPT_DIR}/vms/${HOSTNAME}/user-data ${SCRIPT_DIR}/vms/${HOSTNAME}/meta-data"

${SED} -e "s|#HOSTNAME#|${HOSTNAME}|g" -e "s|#UUID#|${UUID}|g" ${META_DATA_FILE} > ${SCRIPT_DIR}/vms/${HOSTNAME}/meta-data
${SED} -e "s|#SSH-PUB-KEY#|${SSH_PUB_KEY_FILE_CONTENT}|g" ${USER_DATA_FILE} > ${SCRIPT_DIR}/vms/${HOSTNAME}/user-data

if [[ -f ${NETWORK_INTERFACES_FILE} ]]; then
  ${SED} -e "s|#HOSTNAME#|${HOSTNAME}|g" -e "s|#UUID#|${UUID}|g" ${NETWORK_INTERFACES_FILE} > ${SCRIPT_DIR}/vms/${HOSTNAME}/network-config
  FILES="${SCRIPT_DIR}/vms/${HOSTNAME}/user-data ${SCRIPT_DIR}/vms/${HOSTNAME}/meta-data ${SCRIPT_DIR}/vms/${HOSTNAME}/network-config"
fi

${GENISOIMAGE} -input-charset utf-8 \
  -output ${SCRIPT_DIR}/vms/${HOSTNAME}/${HOSTNAME}-cidata.iso \
  -volid cidata -joliet -rock ${FILES}

${VBOXMANAGE} clonevm ${BASE_IMAGE} --mode all --name ${HOSTNAME} --register

${VBOXMANAGE} storageattach ${HOSTNAME} --storagectl "IDE" --port 1 --device 0 \
    --type dvddrive --medium ${SCRIPT_DIR}/vms/${HOSTNAME}/${HOSTNAME}-cidata.iso

if [[ -f ${POST_CONFIG_INTERFACES_FILE} ]]; then
  ${POSTCONFIGUREINTERFACES} -v ${HOSTNAME} -i ${POST_CONFIG_INTERFACES_FILE}
fi

if [[ -f ${POST_CONFIG_STORAGES_FILE} ]]; then
  ${POSTCONFIGURESTORAGES} -v ${HOSTNAME} -s ${POST_CONFIG_STORAGES_FILE}
fi

if [[ -f ${POST_CONFIG_RESOURCES_FILE} ]]; then
  ${POSTCONFIGURERESOURCES} -v ${HOSTNAME} -r ${POST_CONFIG_RESOURCES_FILE}
fi

if [[ "${AUTO_START}" = "true" ]]; then
  ${VBOXMANAGE} startvm ${HOSTNAME} --type headless
fi
