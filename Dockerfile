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
ARG CMAKE_VERSION=3.30.0
ARG CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz"
ARG CMAKE_HASH="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-SHA-256.txt"

# Download and install package
RUN curl -sLO ${CMAKE_URL} && \
    curl -sL ${CMAKE_HASH} | grep $(basename "${CMAKE_URL}") | sha256sum -c - && \
    tar -xf $(basename "${CMAKE_URL}") -C /usr --strip-components=1 && \
    rm $(basename "${CMAKE_URL}")

# Prepare configuration storage
ENV CMAKE_CONFIGS_PATH=/usr/share/cmake/configs.d
RUN mkdir -p ${CMAKE_CONFIGS_PATH}

#- .NET 6 Runtime --------------------------------------------------------------
ARG DOTNET_VERSION=6.0.32
ARG DOTNET_URL="https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-x64.tar.gz"
ARG DOTNET_SHA512="9babfe66f4a4261dd454f3220899af0a19532ab93575b581cec838f1c5f130d98b6fb1aaae5ee8e5b2e70deb55b619a0d55347f014ace72cb84b78d61faf0a59"
ARG DOTNET_INSTALL_DIR="/opt/dotnet"

# Download and install package
RUN curl -sLO ${DOTNET_URL} && \
    echo "${DOTNET_SHA512} $(basename ${DOTNET_URL})" | sha512sum -c - && \
    mkdir -p ${DOTNET_INSTALL_DIR} && \
    tar -xf $(basename "${DOTNET_URL}") -C ${DOTNET_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${DOTNET_URL}")
ENV PATH=$PATH:${DOTNET_INSTALL_DIR}

#- Arm GNU Toolchain -----------------------------------------------------------
ARG TOOLCHAIN_VERSION=13.3.rel1
ARG TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/$TOOLCHAIN_VERSION/binrel/arm-gnu-toolchain-$TOOLCHAIN_VERSION-x86_64-arm-none-eabi.tar.xz"
ARG TOOLCHAIN_INSTALL_DIR="/opt/gcc-arm-none-eabi"

# Dependencies setup
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libncurses5* \
    libncursesw5* \
    && rm -rf /var/lib/apt/lists/*

# Download and install package
RUN curl -sLO ${TOOLCHAIN_URL} && \
    curl -sL ${TOOLCHAIN_URL}.asc | tr [:upper:] [:lower:] | md5sum -c - && \
    mkdir -p ${TOOLCHAIN_INSTALL_DIR} && \
    tar -xf $(basename ${TOOLCHAIN_URL}) -C ${TOOLCHAIN_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${TOOLCHAIN_URL}")
COPY gcc-arm-none-eabi.cmake ${CMAKE_CONFIGS_PATH}
ENV PATH=$PATH:${TOOLCHAIN_INSTALL_DIR}/bin

#- JLink Debugger --------------------------------------------------------------
ARG JLINK_VERSION=796t
ARG JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_V${JLINK_VERSION}_x86_64.tgz"
ARG JLINK_MD5="494853c877d2b15d7c362f8663812336"
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
ENV PATH=$PATH:${JLINK_INSTALL_DIR}

# Add dialout group for non-root debugger access
RUN usermod -aG dialout vscode

#- OpenOCD Debugger ------------------------------------------------------------
ARG OPENOCD_VERSION=0.12.0-3
ARG OPENOCD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v$OPENOCD_VERSION/xpack-openocd-$OPENOCD_VERSION-linux-x64.tar.gz"
ARG OPENOCD_INSTALL_DIR="/opt/OpenOCD"

# Download and install package
RUN curl -sLO ${OPENOCD_URL} && \
    curl -sL ${OPENOCD_URL}.sha | shasum -c -&& \
    mkdir -p ${OPENOCD_INSTALL_DIR}/ && \
    tar -xf $(basename "${OPENOCD_URL}") -C ${OPENOCD_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${OPENOCD_URL}")
ENV PATH=$PATH:${OPENOCD_INSTALL_DIR}/bin

#- Devcontainer utilities ------------------------------------------------------
ARG UTILS_INSTALL_DIR="/opt/devcontainer/"

# Add setup files and register in path
COPY setup-devcontainer ${UTILS_INSTALL_DIR}/bin/
COPY install-rules ${UTILS_INSTALL_DIR}
ENV PATH=$PATH:${UTILS_INSTALL_DIR}/bin

#- User setup ------------------------------------------------------------------
USER vscode

VOLUME [ "/workspaces" ]
WORKDIR /workspaces