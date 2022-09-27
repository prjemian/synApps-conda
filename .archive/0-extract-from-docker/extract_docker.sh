#!/bin/bash

# file: extract_docker.sh

# Extract IOC content from docker containers
# Can we create a conda package with the same IOCs
#   I build into the docker containers?
# Just extract the operating content
#   from the containers?

AD_IOC=iocad
GP_IOC=iocgp
DOCKER_EPICS_ROOT=/opt/base
DOCKER_SYNAPPS_ROOT=/opt/synApps/support
TARGET_ROOT=/tmp/ioc
PREFIX=${AD_IOC}:${DOCKER_SYNAPPS_ROOT}

/bin/rm -rf "${TARGET_ROOT}"
# export LD_LIBRARY_PATH="${TARGET_ROOT}/lib/linux-x86_64"

function transfer_files
{
    # echo "source files: $1"
    # echo "target path: $2"
    for fname in $1; do
        echo ${fname}
        docker cp ${AD_IOC}:${fname} $2
    done
}

# EPICS synApps binaries
TARGET=${TARGET_ROOT}/bin/linux-x86_64
mkdir -p "${TARGET}"
# area detector
FILE_LIST=$(\
    docker exec -it "${AD_IOC}" \
        find "${DOCKER_SYNAPPS_ROOT}" -type f \
    | grep bin/linux-x86_64 \
    | grep /iocs/ \
    | grep -- -master \
    | sed  "s/^[ \r\t]*//g;s/[ \r\t]*$//g"
    )
transfer_files "$FILE_LIST" $TARGET
# xxx
FILE_LIST=$(\
    docker exec -it "${AD_IOC}" \
        find "${DOCKER_SYNAPPS_ROOT}" -type f \
    | grep /xxx \
    | grep bin/linux-x86_64 \
    | sed  "s/^[ \r\t]*//g;s/[ \r\t]*$//g"
    )
transfer_files "$FILE_LIST" $TARGET

# EPICS base libraries
TARGET=${TARGET_ROOT}/lib/linux-x86_64
mkdir -p "${TARGET}"
FILE_LIST=$(\
    docker exec -it "${AD_IOC}" \
        find "${DOCKER_EPICS_ROOT}/lib/linux-x86_64" -type f \
    | grep \\.so \
    | sed  "s/^[ \r\t]*//g;s/[ \r\t]*$//g"
    )
transfer_files "$FILE_LIST" $TARGET

# EPICS synApps libraries
TARGET=${TARGET_ROOT}/lib/linux-x86_64
mkdir -p "${TARGET}"
FILE_LIST=$(\
    docker exec -it "${AD_IOC}" \
        find "${DOCKER_SYNAPPS_ROOT}" -type f \
    | grep lib/linux-x86_64/lib \
    | grep \\.so \
    | sed  "s/^[ \r\t]*//g;s/[ \r\t]*$//g"
    )
transfer_files "$FILE_LIST" $TARGET

# XXX support files
XXX=$( \
    docker exec -it "${GP_IOC}" \
        env \
    | grep XXX= \
    | grep -v IOCXXX= \
    | sed  "s/^[ \r\t]*//g;s/[ \r\t]*$//g" \
    | sed  "s/XXX=//"
    )
for subdir in db dbd; do
    echo "Copy entire directory: ${XXX}/${subdir}"
    docker cp "${GP_IOC}:${XXX}/${subdir}" "${TARGET_ROOT}"
done

# IOC directory: XXX
IOCXXX=$( \
    docker exec -it "${GP_IOC}" \
        realpath iocxxx/ \
    | sed  "s/^[ \r\t]*//g;s/[ \r\t]*$//g"
    )
echo "Copy entire directory: ${IOCXXX}"
docker cp "${GP_IOC}:${IOCXXX}" "${TARGET_ROOT}"

# TODO: keep copying enoughfiles to get the IOC running
# Keep track of the path changes needed for the IOC files
# make modifications with sed
# envPaths -> many changes (needs some decisions)
# st.cmd.Linux
#       dbLoadDatabase    sed "s|../../dbd|../dbd|"
#       TODO
# settings.iocsh
