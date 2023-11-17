# armcm-devcontainer
[![License](https://img.shields.io/github/license/islandcontroller/armcm-devcontainer)](LICENSE) [![GitHub](https://shields.io/badge/github-islandcontroller%2Farmcm--devcontainer-black?logo=github)](https://github.com/islandcontroller/armcm-devcontainer) [![Docker Hub](https://shields.io/badge/docker-islandc%2Farmcm--devcontainer-blue?logo=docker)](https://hub.docker.com/r/islandc/armcm-devcontainer) ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/islandc/armcm-devcontainer?sort=semver)

*Arm Cortex-M development and debugging environment inside a VSCode devcontainer.*

![Screenshot](scr.PNG)

### Packages
* [Microsoft .NET 6.0 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) Version 6.0.25
* [Arm GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) Version 13.2rel1
* [SEGGER J-Link Software](https://www.segger.com/downloads/jlink/) Version 7.92o
* [xPack OpenOCD](https://github.com/xpack-dev-tools/openocd-xpack) Version 0.12.0-2
* [CMake](https://cmake.org/download) Version 3.27.7

## System Requirements
* VSCode [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
* [usbipd-win](https://learn.microsoft.com/en-us/windows/wsl/connect-usb) (Windows *and* WSL parts installed!)

## Usage
* Include this repo as `.devcontainer` in the root of your project
* Connect debug probe
* Select `Dev Containers: Reopen in Container`

For CMake projects:
* Upon prompt, select the `GCC x.x arm-none-eabi` CMake Kit. 
  * Alternatively, a toolchain definition file is provided in: `$CMAKE_CONFIGS_PATH/gcc-arm-none-eabi.cmake`.
* Run `CMake: Configure`
* Build using `CMake: Build [F7]`

### CMake+IntelliSense Notes
Upon first run, an error message may appear in Line 1, Column 1. Try re-running CMake configuration, or run a build.

### SEGGER J-Link Notes
You may need to install the SEGGER-provided udev rules file in order to access the debug probe without root privileges. See `/opt/SEGGER/JLink/README.txt` inside the devcontainer.

**Note:** the rules file needs to be installed on the **host**!

### OpenOCD Notes
In order to run OpenOCD without root privileges, you need to install the provided rules file in `/opt/OpenOCD/openocd/contrib/60-openocd.rules` on your host machine. See instructions inside the rules file.

## Licensing

If not stated otherwise, the contents of this project are licensed under The MIT License. The full license text is provided in the [`LICENSE`](LICENSE) file.

    SPDX-License-Identifier: MIT