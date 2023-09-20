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
    cmake \
    make \
    software-properties-common \
    tar \
    udev \
    usbutils \
    wget

# Setup dir for packages installation
WORKDIR /tmp

#- CMake Configurations Storage ------------------------------------------------
ENV CMAKE_CONFIGS_PATH=/usr/share/cmake/configs.d
RUN mkdir -p ${CMAKE_CONFIGS_PATH}

#- .NET 6 Runtime --------------------------------------------------------------
ARG DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/f812da49-53de-4f59-93d2-742a61229149/35ff2eb90bf2583d21ad25146c291fe4/dotnet-runtime-6.0.22-linux-x64.tar.gz"
ARG DOTNET_SHA512="c24ed83cd8299963203b3c964169666ed55acaa55e547672714e1f67e6459d8d6998802906a194fc59abcfd1504556267a839c116858ad34c56a2a105dc18d3d"

# Downlaod and install package
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
ARG JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_V792f_x86_64.tgz"
ARG JLINK_MD5="e3ab50d910be526ccf58d130603ac0aa"
ARG JLINK_POST="accept_license_agreement=accepted&submit=Download+software"

# Dependeencies setup
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
# Dependencies setup
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openocd

#- User setup ------------------------------------------------------------------
USER vscode

VOLUME [ "/src" ]
WORKDIR /src