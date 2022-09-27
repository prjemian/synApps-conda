FROM  ubuntu:latest
LABEL version="2.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2022-09-26" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root
WORKDIR /home

RUN echo "# -------------------------------- start OS install"
# Install necessary libraries from offical repo
RUN DEBIAN_FRONTEND=noninteractive apt-get update  -y && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y  \
        apt-utils \
        build-essential  \
        libreadline-dev  \
        nano  \
        screen \
        vim \
        && \
    rm -rf /var/lib/apt/lists/*

# additional software packages added here
ENV APP_ROOT="/opt"
ENV LOG_DIR="${APP_ROOT}/logs"
# for use with `crontab -e`
ENV EDITOR="nano"
# only show last few subdirs before console prompt
ENV PROMPT_DIRTRIM=3
RUN echo "# -------------------------------- end OS install"


RUN echo "# -------------------------------- start EPICS base"
# Get the latest version of EPICS
ENV BASE_VERSION=7.0.7
ENV EPICS_BASE_NAME=base-${BASE_VERSION}
ENV EPICS_BASE="${APP_ROOT}/${EPICS_BASE_NAME}"

ENV EPICS_HOST_ARCH=linux-x86_64
ENV PATH="${PATH}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"


WORKDIR ${APP_ROOT}
RUN mkdir ${LOG_DIR} && ls -lart
ADD https://epics.anl.gov/download/base/${EPICS_BASE_NAME}.tar.gz ./

RUN tar xzf ${EPICS_BASE_NAME}.tar.gz &&\
    rm  ${EPICS_BASE_NAME}.tar.gz &&\
    ln -s ${EPICS_BASE_NAME} base &&\
    ls -lAFgh

WORKDIR ${EPICS_BASE}
RUN pwd && ls
RUN make -j4 all CFLAGS="-fPIC" CXXFLAGS="-fPIC"  2>&1 | tee ${LOG_DIR}/build-base.log
RUN echo "# --- make clean ---" 2>&1 | tee -a ${LOG_DIR}/build-base.log
RUN make clean  2>&1 | tee -a ${LOG_DIR}/build-base.log

COPY ioc_files/* /opt/softIoc_base_demo/
CMD ["/bin/bash"]

WORKDIR ${EPICS_BASE}
RUN pwd && ls
RUN echo "# -------------------------------- end EPICS base"


RUN echo "# -------------------------------- start OS update for synApps"
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update  -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y  \
       git \
       libnet-dev \
       libpcap-dev \
       libusb-1.0-0-dev \
       libusb-dev \
       libx11-dev \
       libxext-dev \
       re2c \
       wget \
       && \
    rm -rf /var/lib/apt/lists/*
RUN echo "# -------------------------------- end OS update for synApps"

# ============ parent image definitions ============
# additional software packages added here
ENV APP_ROOT="/opt"
# for use with `crontab -e`
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_BASE="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"

# ============ EPICS synApps ============
# ENV MOTOR_HASH=master
ENV CAPUTRECORDER_HASH=master
ENV MOTOR_HASH=R7-2-2
ENV SYNAPPS="${APP_ROOT}/synApps"
ENV SUPPORT="${SYNAPPS}/support"
ENV PATH="${PATH}:${SUPPORT}/utils"
# ENV AD=${SUPPORT}/areaDetector-master
# ENV MOTOR=${SUPPORT}/motor-${MOTOR_HASH}
ENV XXX=${SUPPORT}/xxx-R6-2-1
ENV IOCXXX=${XXX}/iocBoot/iocxxx

# a directory for EPICS data (such as written from area detector IOCs)
RUN mkdir /data

RUN echo "# -------------------------------- start assemble_synApps.sh"
# TODO: build synApps out of source
WORKDIR ${APP_ROOT}
RUN pwd && ls -lAFh
# download the installer script
# ENV HASH=master
ENV HASH=R6-2-1
ADD https://raw.githubusercontent.com/EPICS-synApps/support/${HASH}/assemble_synApps.sh ./
# edit the script first!
COPY ./ioc_files/* ./
RUN bash ./edit_assemble_synApps.sh 2>&1 | tee ${LOG_DIR}/edit_assemble.log
# done editing
# review
RUN cat ./assemble_synApps.sh
# run the script now
ENV SYNAPPS_DIR="${SYNAPPS}"
RUN bash ./assemble_synApps.sh 2>&1 | tee ${LOG_DIR}/assemble.log

WORKDIR ${SUPPORT}
RUN pwd && ls -lAFgh
RUN echo "# -------------------------------- end assemble_synApps.sh"


RUN echo "# -------------------------------- start build synApps"
WORKDIR ${SUPPORT}
RUN pwd && ls -lAFgh
RUN make -j4 release rebuild 2>&1 | tee ${LOG_DIR}/build-synApps.log
RUN echo "# --- Building XXX IOC ---" 2>&1 | tee -a ${LOG_DIR}/build-synApps.log
RUN make -C ${IOCXXX}/ 2>&1 | tee -a ${LOG_DIR}/build-synApps.log
RUN ln -s ${IOCXXX}/ ./iocxxx
RUN echo "# -------------------------------- end build synApps"


RUN echo "# -------------------------------- start copy screens"
# copy all the MEDM/CSSBOY/caQtDM/... screens to /home/$MAMBA_USER/screens
RUN bash ${APP_ROOT}/copy_screens.sh ${SUPPORT} ${APP_ROOT}/screens | tee -a ${LOG_DIR}/copy_screens.log
# use this script in all IOCs
RUN bash ${APP_ROOT}/modify_adl_in_ui_files.sh  ${APP_ROOT}/screens/ui | tee -a ${LOG_DIR}/modify_adl_in_ui_files.log
RUN echo "# -------------------------------- end copy screens"


RUN echo "# -------------------------------- start customize xxx"
# TODO: duplicate the xxx module and work there
RUN mv ${APP_ROOT}/general_purpose.db ${IOCXXX}/substitutions
      
RUN ${APP_ROOT}/customize_xxx.sh && pwd
RUN bash ${APP_ROOT}/copy_screens.sh ${SUPPORT} ${APP_ROOT}/screens | tee -a ${LOG_DIR}/copy_screens.log
RUN bash ${APP_ROOT}/modify_adl_in_ui_files.sh  ${APP_ROOT}/screens/ui | tee -a ${LOG_DIR}/modify_adl_in_ui_files.log

# archive the template IOC, for making new XXX IOCs
WORKDIR ${SUPPORT}
RUN \
    pwd && ls -lAFgh && \
    tar czf ${APP_ROOT}/$(basename ${XXX}).tar.gz $(basename ${XXX})
RUN echo "# -------------------------------- end customize xxx"
