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
ARG CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-linux-x86_64.tar.gz"
ARG CMAKE_HASH="https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-SHA-256.txt"

# Download and install package
RUN curl -sLO ${CMAKE_URL} && \
    curl -sL ${CMAKE_HASH} | grep $(basename "${CMAKE_URL}") | sha256sum -c - && \
    tar -xf $(basename "${CMAKE_URL}") -C /usr --strip-components=1 && \
    rm $(basename "${CMAKE_URL}")

# Prepare configuration storage
ENV CMAKE_CONFIGS_PATH=/usr/share/cmake/configs.d
RUN mkdir -p ${CMAKE_CONFIGS_PATH}

#- .NET 6 Runtime --------------------------------------------------------------
ARG DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/872b4f32-dd0d-49e5-bca3-2b27314286a7/e72d2be582895b7053912deb45a4677d/dotnet-runtime-6.0.24-linux-x64.tar.gz"
ARG DOTNET_SHA512="3a72ddae17ecc9e5354131f03078f3fbfa1c21d26ada9f254b01cddcb73869cb33bac5fc0aed2200fbb57be939d65829d8f1514cd0889a2f5858d1f1eec136eb"
ARG DOTNET_INSTALL_DIR="/opt/dotnet"

# Download and install package
RUN curl -sLO ${DOTNET_URL} && \
    echo "${DOTNET_SHA512} $(basename ${DOTNET_URL})" | sha512sum -c - && \
    mkdir -p ${DOTNET_INSTALL_DIR} && \
    tar -xf $(basename "${DOTNET_URL}") -C ${DOTNET_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${DOTNET_URL}")
ENV PATH=$PATH:${DOTNET_INSTALL_DIR}

#- Arm GNU Toolchain -----------------------------------------------------------
# Package download URL
ARG TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz"
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
# Package download data
ARG JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_V792o_x86_64.tgz"
ARG JLINK_MD5="76548626a7358eacab3ec87234dac367"
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
# Package download
ARG OPENOCD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-2/xpack-openocd-0.12.0-2-linux-x64.tar.gz"
ARG OPENOCD_INSTALL_DIR="/opt/OpenOCD"

# Download and install package
RUN curl -sLO ${OPENOCD_URL} && \
    curl -sL ${OPENOCD_URL}.sha | shasum -c -&& \
    mkdir -p ${OPENOCD_INSTALL_DIR}/ && \
    tar -xf $(basename "${OPENOCD_URL}") -C ${OPENOCD_INSTALL_DIR} --strip-components=1 && \
    rm $(basename "${OPENOCD_URL}")
ENV PATH=$PATH:${OPENOCD_INSTALL_DIR}/bin

#- User setup ------------------------------------------------------------------
USER vscode

VOLUME [ "/workspaces" ]
WORKDIR /workspaces