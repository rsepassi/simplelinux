# zigroot

Inspired by [Rob Landley][rob].

"The smallest possible complete development environment capable of rebuilding
itself from source code".

1. C compiler: [`zig`][zig]
2. C standard library: [`musl`][musl]
3. Command line utilities: [`busybox`][busybox]
4. Kernel: [`linux`][linux]

## Usage

```
ZIGROOT_ARCH=x86_64 ./build.sh
```

Builds:

* busybox, statically linked
* Linux kernel
* simpleboot bootloader
* `zigroot.iso`

And then launches the iso in qemu, dropping you into a busybox shell.

`ZIGROOT_ARCH` can be one of `{x86, x86_64, aarch64}`.

## Status

*As of 09/26*

`build.sh` cross-compiles (from `x86_64` to `arm_64`) busybox and the Linux
kernel, builds an image, launches in QEMU, and builds and runs a Zig hello
world.

The Busybox build uses `make` but calls out to `zig cc`, `zig ar`, and `zig
objcopy`. The Linux build uses `make` and `llvm-16`. 

The idea is now to start swapping out the build pieces until it's all Zig, and
then to be able to rebuild it all again within the VM.

## Some other things that would be cool

* Build Zig from source too
* Use [`ziglibc`][ziglibc]
* Graphical user space with [`ghostty`][ghostty]
* Make it all pluggable

[rob]: https://www.landley.net
[ziglibc]: https://github.com/marler8997/ziglibc
[zig]: https://github.com/ziglang/zig
[busybox]: https://www.busybox.net
[linux]: https://github.com/torvalds/linux
[ghostty]: https://mitchellh.com/ghostty
[musl]: https://musl.libc.org
