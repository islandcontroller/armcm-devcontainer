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
    make \
    software-properties-common \
    tar \
    udev \
    usbutils \
    wget

# Setup dir for packages installation
WORKDIR /tmp

#- CMake -----------------------------------------------------------------------
ARG CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-linux-x86_64.tar.gz"
ARG CMAKE_HASH="https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-SHA-256.txt"

# Download and install package
RUN wget -nv ${CMAKE_URL} && \
    wget -nv ${CMAKE_HASH} && \
    grep $(basename "${CMAKE_URL}") $(basename "${CMAKE_HASH}") > $(basename "${CMAKE_HASH}.sng") && \
    sha256sum -c $(basename "${CMAKE_HASH}.sng")
RUN tar -xf $(basename "${CMAKE_URL}") -C /usr --strip-components=1 && \
    rm $(basename "${CMAKE_URL}") $(basename "${CMAKE_HASH}") $(basename "${CMAKE_HASH}.sng")

# Prepare configuration storage
ENV CMAKE_CONFIGS_PATH=/usr/share/cmake/configs.d
RUN mkdir -p ${CMAKE_CONFIGS_PATH}

#- .NET 6 Runtime --------------------------------------------------------------
ARG DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/872b4f32-dd0d-49e5-bca3-2b27314286a7/e72d2be582895b7053912deb45a4677d/dotnet-runtime-6.0.24-linux-x64.tar.gz"
ARG DOTNET_SHA512="3a72ddae17ecc9e5354131f03078f3fbfa1c21d26ada9f254b01cddcb73869cb33bac5fc0aed2200fbb57be939d65829d8f1514cd0889a2f5858d1f1eec136eb"

# Download and install package
RUN wget -nv ${DOTNET_URL} && \
    echo "${DOTNET_SHA512} $(basename ${DOTNET_URL})" > $(basename "${DOTNET_URL}.asc") && \
    sha512sum -c $(basename "${DOTNET_URL}.asc")
RUN mkdir -p /opt/dotnet && \
    tar -xf $(basename "${DOTNET_URL}") -C /opt/dotnet --strip-components=1 && \
    rm $(basename "${DOTNET_URL}") $(basename "${DOTNET_URL}.asc")
ENV PATH=$PATH:/opt/dotnet

#- Arm GNU Toolchain -----------------------------------------------------------
# Package download URL
ARG TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/binrel/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz"

# Dependencies setup
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libncurses5* \
    libncursesw5*

# Download and install package
RUN wget -nv ${TOOLCHAIN_URL}.asc && \
    wget -nv ${TOOLCHAIN_URL} && \
    md5sum -c $(basename "${TOOLCHAIN_URL}.asc")
RUN mkdir -p /opt/gcc-arm-none-eabi && \
    tar -xf $(basename ${TOOLCHAIN_URL}) -C /opt/gcc-arm-none-eabi --strip-components=1 && \
    rm $(basename "${TOOLCHAIN_URL}") $(basename "${TOOLCHAIN_URL}.asc")
COPY gcc-arm-none-eabi.cmake ${CMAKE_CONFIGS_PATH}
ENV PATH=$PATH:/opt/gcc-arm-none-eabi/bin

#- JLink Debugger --------------------------------------------------------------
# Package download data
ARG JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_V792m_x86_64.tgz"
ARG JLINK_MD5="833f710a378bee4b0d117ff59cf93b25"
ARG JLINK_POST="accept_license_agreement=accepted&submit=Download+software"

# Dependencies setup
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3.8

# Download and install package
RUN wget --post-data ${JLINK_POST} -nv ${JLINK_URL} && \
    echo "${JLINK_MD5} $(basename ${JLINK_URL})" > $(basename "${JLINK_URL}.asc") && \
    md5sum -c $(basename "${JLINK_URL}.asc")
RUN mkdir -p /opt/SEGGER/JLink && \
    tar -xf $(basename "${JLINK_URL}") -C /opt/SEGGER/JLink --strip-components=1 && \
    rm $(basename "${JLINK_URL}") $(basename "${JLINK_URL}.asc")
ENV PATH=$PATH:/opt/SEGGER/JLink

# Add dialout group for non-root debugger access
RUN sudo usermod -aG dialout vscode

#- OpenOCD Debugger ------------------------------------------------------------
# Package download
ARG OPENOCD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-2/xpack-openocd-0.12.0-2-linux-x64.tar.gz"

# Download and install package
RUN wget -nv ${OPENOCD_URL}.sha && \
    wget -nv ${OPENOCD_URL} && \
    shasum -c $(basename "${OPENOCD_URL}.sha")
RUN mkdir -p /opt/OpenOCD/ && \
    tar -xf $(basename "${OPENOCD_URL}") -C /opt/OpenOCD --strip-components=1 && \
    rm $(basename "${OPENOCD_URL}") $(basename "${OPENOCD_URL}.sha")
ENV PATH=$PATH:/opt/OpenOCD/bin

#- User setup ------------------------------------------------------------------
USER vscode

VOLUME [ "/src" ]
WORKDIR /src