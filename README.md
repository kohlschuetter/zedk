# zedk — suite of useful UEFI tools

## What

zedk provides UEFI binaries from TianoCore EDK II, an open-source UEFI reference implementation, and then some.

Currently, zedk has the following applications:

- Provide a recent UEFI shell binary
- Boot to a textual UEFI-Setup interface ("the BIOS") from the UEFI shell
- Unlock hidden settings in your UEFI Setup/BIOS without flashing a custom ROM
- Enable a remote UEFI-level console over the serial port without further configuration (which can be used to remotely enter the Setup, diagnose boot problems with iPXE, etc.)

<b>NOTE</b> The additional, otherwise hidden settings may be harmful to your computer, causing instabilities or crashes. Use entirely at your own risk.

## Why

In many UEFI/BIOS forums, certain UEFI binaries are referenced and/or shared, without a clear way how to obtain them from source. In contrast, _zedk_ provides a straightforward path from source code to a binary distribution. As a consequence, updating the binaries using newer versions of _EDK II_ becomes trivial, while trust is increased.

With respect to providing access to the Setup interface, _zedk_ is inspired by "UniversalAMDFormBrowser", which was only released in binary form and sadly later abandoned by its author, _SmokelessCPU_. Thankfully, they described the inner workings on the [Win-Raid Forum](https://winraid.level1techs.com/t/tool-universalamdformbrowser/40353/16). While indeed rather trivial in theory, in practice, taming EDK II's build system was much harder than uninstalling four UEFI protocols.

## How

Once copied to a USB stick, you can boot your computer directly to a UEFI shell, and access the provided binaries.

Binaries are provided on the [releases page](https://github.com/kohlschuetter/zedk/releases). 

Unzip the `zedk.zip` to a FAT32-formatted USB-stick. Reboot your computer use the Boot-Menu (F12) to select your USB drive. Alternatively, change the boot order to prioritize the USB flash drive over all other drives. Make sure _Secure Boot_ is disabled.

The build system of _EDK II_ (edk2) is hard to figure out and easy to get wrong. _zedk_ changes that.

The build logic is built around simple shell scripts running on Alpine Linux. By default, a container (Podman, Docker, Apple Containers) is launched to encapsulate the build process.

Cross-compilation is supported (tested on macOS with Apple Silicon). Currently, the only target platform is `x86_64`.

Due to some bugs in newer versions of EDK II, to get to a working solution, _zedk_ allows building and combining multiple versions of EDK II from source control. Custom UEFI programs are simply kept in a separate branch and referred to during build.

Additionally, `setup_var.efi`, which is used to unlock the hidden Setup entries, is built from source as well.

To build _zedk_ from scratch, run `./build.sh` from this repository. The zip artifact is then placed under `target/zedk.zip`.

## Where

- zedk should run on all UEFI systems.
- Additional hidden BIOS features are automatically unlocked for certain AMI UEFI setups (wherever _AmiSetupFormSetVar_). Tested systems so far:
  - Lenovo ThinkStation P330 Tiny
  - Lenovo ThinkCentre M920q/M920x Tiny
  - Lenovo ThinkCentre M625q

## Who and When

zedk was developed by [Christian Kohlschütter](https://kohlschuetter.github.io/blog/) on February 18-19, 2026.

## Dependencies

zedk depends/builds upon

- [TianoCore EDK II](https://github.com/tianocore/edk2), BSD-2-Clause-Patent License
- [datasone setup_var.efi](https://github.com/datasone/setup_var.efi), Apache 2.0/MIT License

## Related projects

- [pbatard's UEFI-Shell](https://github.com/pbatard/UEFI-Shell?tab=readme-ov-file) Pre-built UEFI Shell binary images
- [Smokeless_UMAF](https://github.com/DavidS95/Smokeless_UMAF) UniversalAMDFormBrowser (binary only)

## License

zedk is licensed under the Apache 2.0 License, available [here](LICENSE) or [online](https://www.apache.org/licenses/LICENSE-2.0).
