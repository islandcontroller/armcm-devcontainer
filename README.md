# armcm-devcontainer
Arm Cortex-M development and debugging environment inside a VSCode devcontainer.

![Screenshot](scr.PNG)

### Packages
* [Microsoft .NET 6.0 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) Version 6.0.22
* [Arm GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) Version 12.3rel1
* [SEGGER J-Link Software](https://www.segger.com/downloads/jlink/) Version 7.92k
* [xPack OpenOCD](https://github.com/xpack-dev-tools/openocd-xpack) Version 0.12.0-2
* CMake Version 3.22

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

## Licensing

If not stated otherwise, the contents of this project are licensed under The MIT License. The full license text is provided in the [`LICENSE`](LICENSE) file.

    SPDX-License-Identifier: MIT