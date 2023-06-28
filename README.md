
[![License](https://img.shields.io/static/v1?label=License&style=flat-square&message=Apache-2.0&color=c92d3e&logo=apache)](https://www.apache.org/licenses/LICENSE-2.0)
[![Assembly version](https://img.shields.io/static/v1?label=Assembly&message=vARM8&style=flat-square&color=156c82&logo=assemblyscript)](https://www.cs.princeton.edu/courses/archive/spr19/cos217/reading/ArmInstructionSetOverview.pdf)
[![Raspberry version](https://img.shields.io/static/v1?label=Raspberry&message=3&style=flat-square&color=cc2455&?style=plastic&logo=raspberry-pi)](https://www.raspberrypi.org/)
[![QEMU version](https://img.shields.io/static/v1?label=QEMU&message=4.2.1&style=flat-square&color=fe6601&logo=qemu)](https://www.qemu.org/)

# VideoCore FrameBuffer

## Overview

An **image** and an **animation** of a _"GEO DASH"_ game, inspired by [Geometry Dash](https://play.google.com/store/apps/details?id=com.robtopx.geometryjumplite) and written in ARMv8 assembly. The image shows the start menu of the game, and the "game" itself is shown in the animation. The character can be chosen from several designs, and it will automatically jump over the boxes and advance to the next stage.
 
Provides default support for screen printing using a [Raspberry Pi 3](https://www.raspberrypi.com/products/raspberry-pi-3-model-b/) or an emulator like [QEMU](https://www.qemu.org/). Utilizes the framebuffer to draw pixels using ARMv8 architecture (requires QEMU or Raspberry Pi 3) with a native resolution of 640 x 480 pixels, using 32-bit ARGB colors. Each pixel on the screen corresponds to a specific location within the random access memory map.

Project developed as part of the _Computer Organization_ university course at [FaMAF](https://www.famaf.unc.edu.ar/) - [UNC](https://www.unc.edu.ar/).

## Getting started

1) Clone the repository

```bash
git clone https://github.com/Naevier/VideoCore-FrameBuffer
```

2) Install [aarch64](https://gcc.gnu.org/) toolchain and [QEMU](https://www.qemu.org/docs/master/index.html) for ARM

```bash
sudo apt install gcc-aarch64-linux-gnu
sudo apt install qemu-system-arm
```

3) The image or the animation can be played from its own directory (_/image_ or _/animation_) with

```bash
make
make run
```

The animation **speed** and the animation **character** can be changed in the first lines of the app.s code file.

Note: In Arch-based distros the package _gcc-aarch64-linux-gnu_ is named _aarch64-linux-gnu-gcc_.

<br>
<a href="https://www.youtube.com/watch?v=yxyNmy3QDX0">
  <img src="https://i.ytimg.com/vi/yxyNmy3QDX0/maxresdefault.jpg" alt="Watch demo video" width="800">
</a>

> Demo **video** with added sounds (_click the image!_)

## Files

| File                                  | Description           |
| -----------                           | -----------           |
| [app.s](animation/app.s)              | Main application file |
| [funciones.s](animation/funciones.s)  | Functions for drawing various elements used in the main module          |
| [memmap](animation/memmap)            | Description of the program's memory layout and section placement        |
| [start.s](animation/start.s)          | Configuration and initialization of the framebuffer on the Raspberry Pi |

## Qemu bug

In some devices, there is a known bug in QEMU that may cause the emulator to fail to start, displaying an _"Error 1: unsupported machine type"_ message. If you come across this issue, you can try resolving it by replacing line 21 of the Makefile with the following command:

`qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio`

If the problem persists, consider updating your operating system as an alternative solution.

## Authors

- [@IvanBainotti](https://github.com/IvanBainotti)
- [@naevier](https://github.com/naevier)
- [@IvanGarcia](...)

## License

This VideoCore FrameBuffer is licensed under the Apache License, Version 2.0 - See the [license](LICENSE) file for more information
