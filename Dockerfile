#-------------------------------------------------------------------------------
# Arm GNU Toolchain Devcontainer
# Copyright © 2023 islandcontroller and contributors
#-------------------------------------------------------------------------------

# Base image: Ubuntu Dev Container
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Root user for setup
USER root

# Dependencies setup
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cu \
    curl \
    make \
    software-properties-common \
    tar \
    udev \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# Setup dir for packages installation
WORKDIR /tmp

#- CMake -----------------------------------------------------------------------
ARG CMAKE_VERSION=4.4.2
ARG CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz"
ARG CMAKE_HASH="3ada9a3f5d8a85413579bdd0ea6aa8e8da86efdd6d15c91a1afa517f2021956c"

# Download and install package
RUN curl -sLO ${CMAKE_URL} && \
    echo "${CMAKE_HASH} $(basename ${CMAKE_URL})" | sha256sum -c - && \
    tar -xf $(basename "${CMAKE_URL}") -C /usr --strip-components=1 && \
    rm $(basename "${CMAKE_URL}")

#- .NET 6 Runtime --------------------------------------------------------------
ARG DOTNET_INSTALL_DIR="/opt/dotnet"

# Display warning for tools still using deprecated .NET version
ADD dotnet-info.sh ${DOTNET_INSTALL_DIR}/
RUN ln -s ${DOTNET_INSTALL_DIR}/dotnet-info.sh ${DOTNET_INSTALL_DIR}/dotnet
ENV PATH=$PATH:${DOTNET_INSTALL_DIR}

#- Arm GNU Toolchain -----------------------------------------------------------
ARG TOOLCHAIN_VERSION=15.3.rel1
ARG TOOLCHAIN_URL="https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/$TOOLCHAIN_VERSION/arm-gnu-toolchain-$TOOLCHAIN_VERSION-x86_64-arm-none-eabi.tar.xz"
ARG TOOLCHAIN_MD5="bbe1e4bf65591692ed93cd19706c93af"
ARG TOOLCHAIN_INSTALL_DIR="/opt/gcc-arm-none-eabi"

# Dependencies setup
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libncurses5* \
    libncursesw5* \
    libpython3.8 \
    && rm -rf /var/lib/apt/lists/*

# Download and install package
RUN curl -sLO ${TOOLCHAIN_URL} && \
    echo "$TOOLCHAIN_MD5 $(basename ${TOOLCHAIN_URL})" | md5sum -c - && \
    mkdir -p ${TOOLCHAIN_INSTALL_DIR} && \
    tar -xf $(basename ${TOOLCHAIN_URL}) -C ${TOOLCHAIN_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${TOOLCHAIN_URL}")
COPY gcc-arm-none-eabi.cmake ${TOOLCHAIN_INSTALL_DIR}
ENV PATH=$PATH:${TOOLCHAIN_INSTALL_DIR}/bin

#- JLink Debugger --------------------------------------------------------------
ARG JLINK_VERSION=964
ARG JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_V${JLINK_VERSION}_x86_64.tgz"
ARG JLINK_MD5="e980f3ce4260763bc13ed695e28a88e3"
ARG JLINK_POST="accept_license_agreement=accepted&submit=Download+software"
ARG JLINK_INSTALL_DIR="/opt/SEGGER/JLink"

# Dependencies setup
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3.8 \
    && rm -rf /var/lib/apt/lists/*

# Download and install package
RUN curl -sLO -d ${JLINK_POST} -X POST ${JLINK_URL} && \
    echo "${JLINK_MD5} $(basename ${JLINK_URL})" | md5sum -c - && \
    mkdir -p ${JLINK_INSTALL_DIR} && \
    tar -xf $(basename "${JLINK_URL}") -C ${JLINK_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${JLINK_URL}")
# Workaround for JFlash not starting correctly, see:
# https://forum.segger.com/thread/8238-solved-j-flash-v7-54d-error-could-not-open-flash-device-list-file/?postID=30359#post30359
RUN find ${JLINK_INSTALL_DIR} -name "J*" -exec sh -c 'for f in $@; do ln -Tsf $f /usr/bin/$(basename "$f"); done' {} +

# Add dialout group for non-root debugger access
RUN usermod -aG dialout vscode

#- OpenOCD Debugger ------------------------------------------------------------
ARG OPENOCD_VERSION=0.12.0-7
ARG OPENOCD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v$OPENOCD_VERSION/xpack-openocd-$OPENOCD_VERSION-linux-x64.tar.gz"
ARG OPENOCD_HASH="94b3790983beaf8ed57e646c0620dd66d705fddae03d290823a6ed3b439468d6"
ARG OPENOCD_INSTALL_DIR="/opt/OpenOCD"

# Download and install package
RUN curl -sLO ${OPENOCD_URL} && \
    echo "${OPENOCD_HASH} $(basename ${OPENOCD_URL})" | sha256sum -c -&& \
    mkdir -p ${OPENOCD_INSTALL_DIR}/ && \
    tar -xf $(basename "${OPENOCD_URL}") -C ${OPENOCD_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${OPENOCD_URL}")
ENV PATH=$PATH:${OPENOCD_INSTALL_DIR}/bin

#- Devcontainer utilities ------------------------------------------------------
ARG UTILS_INSTALL_DIR="/opt/devcontainer/"

# Add setup files and register in path
COPY setup-devcontainer ${UTILS_INSTALL_DIR}/bin/
COPY install-rules ${UTILS_INSTALL_DIR}
COPY cmake-tools-kits.json ${UTILS_INSTALL_DIR}
ENV PATH=$PATH:${UTILS_INSTALL_DIR}/bin

#- User setup ------------------------------------------------------------------
# Add plugdev group for non-root ttyUSB access
RUN usermod -aG plugdev vscode

USER vscode

VOLUME [ "/workspaces" ]
WORKDIR /workspaces