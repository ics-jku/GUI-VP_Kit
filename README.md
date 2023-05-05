# GUI-VP Kit: A RISC-V VP Meets Linux Graphics -- Enabling Interactive Graphical Application Development

The goal of this project is to provide a quick-to-create and easy-to-use platform for experimentation with Linux on the open-source SystemC RISC-V based virtual prototype [GUI-VP](https://github.com/ics-jku/GUI-VP).
*GUI-VP* is a greatly extended and improved open-source [RISC-V VP](https://github.com/agra-uni-bremen/riscv-vp), that enables the simulation of interactive graphical Linux applications.
*GUI-VP Kit* handles the generation of all necessary software parts and provides an experimentation environment for running Linux with interactive graphical applications on RV32- and RV64-based VPs.

*GUI-VP Kit* and *GUI-VP* were created at the [Institute for Complex Systems](https://ics.jku.at/), Johannes Kepler University, Linz.
They were first introduced in 2023 at the *ACM Great Lakes Symposium on VLSI*, by Manfred Schlägl and Daniel Große with [GUI-VP Kit: A RISC-V VP meets Linux graphics - enabling interactive graphical application development](https://ics.jku.at/files/2023GLSVLSI_GUI-VP_Kit.pdf).
A BibTex entry to cite to the paper can be found in the last section.

## Key Features
The project
 * downloads and builds [GUI-VP](https://github.com/ics-jku/GUI-VP) (vp executables)
 * downloads and builds [buildroot](https://buildroot.org) for rv32 and rv64, including
   * the C/C++ toolchain (gcc, glibc) (also for external use -- see below)
   * the root filesystem (based on busybox)
   * the linux kernel image including the root filesystem (initramfs)
   * the openSBI bootloader image (including linux kernel and root filesystem)
 * builds the device tree blobs describing the rv32 and rv64 (fu540 compatible) single- and multicore vps
 * can start the created rv32 and rv64 images on linux-vp(rv64 multicore), linux32-vp(rv32 multicore), linux-sc-vp(rv64 singlecore) and linux32-sc-vp(rv32 singlecore)
 * supports graphic output, mouse- and keyboard input via [Virtual Network Computing](https://en.wikipedia.org/wiki/Virtual_Network_Computing) (VNC) (see below)
 * supports networking between the host and the system inside the vp (see below)

## Build & Run
This section explains how to build the project and boot the vp.

### Prerequisites

 1. A running Linux system with at least 25GB of free disk memory and an internet connection
     * The project was developed and tested on Debian 11
 2. Installed packages necessary for GUI-VP
     * see [rescv-vp README.md](https://github.com/ics-jku/GUI-VP/blob/master/README.md)
 3. Installed packages necessary for buildroot
     * see [Buildroot Manual -- Chapter 2. System requirements](https://buildroot.org/downloads/manual/manual.html#requirement)
 4. The project repository
 5. An active shell in the project directory

### Help
A list of all useful make targets is provided by ```make help``` or simply ```make```.

### Build
**Note:** Builds can take a long time.

 * Build everything (rv32 and rv64): ```make```
 * Build rv32 only: ```make build_rv32```
 * Build rv64 only: ```make build_rv64```

### Run
**Note:** It can take some time until kernel output is visible (>30 seconds).

 * Run rv32 singlecore vp: ```make run_rv32_sc```
 * Run rv64 singlecore vp: ```make run_rv64_sc```
 * Run rv32 multicore vp: ```make run_rv32_mc```
 * Run rv64 multicore vp: ```make run_rv64_mc```

Login with *root* and empty password.

**Example (rv32, singlecore):**
```
$ make run_rv32_sc
GUI-VP/vp/build/bin/linux32-vp                                        \
        --use-data-dmi --tlm-global-quantum=1000 --tun-device tun10   \
        --dtb-file=dt/linux-vp_rv32_sc.dtb                            \
        buildroot_rv32/output/images/fw_payload.elf

        SystemC 2.3.3-Accellera --- Aug 11 2022 14:52:20
        Copyright (c) 1996-2018 by all Contributors,
        ALL RIGHTS RESERVED

OpenSBI v0.9
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name             : SiFive Freedom U540
Platform Features         : timer,mfdeleg
Platform HART Count       : 4
Firmware Base             : 0x80000000
Firmware Size             : 132 KB
Runtime SBI Version       : 0.2

Domain0 Name              : root
Domain0 Boot HART         : 1
Domain0 HARTs             : 1*,2*,3*,4*
Domain0 Region00          : 0x80000000-0x8003ffff ()
Domain0 Region01          : 0x00000000-0xffffffff (R,W,X)
Domain0 Next Address      : 0x80400000
Domain0 Next Arg1         : 0x88000000
Domain0 Next Mode         : S-mode
Domain0 SysReset          : yes

Boot HART ID              : 1
Boot HART Domain          : root
Boot HART ISA             : rv32imafdcnsu
Boot HART Features        : scounteren,mcounteren,time
Boot HART PMP Count       : 16
Boot HART PMP Granularity : 4
Boot HART PMP Address Bits: 32
Boot HART MHPM Count      : 0
Boot HART MHPM Count      : 0
Boot HART MIDELEG         : 0x00000222
Boot HART MEDELEG         : 0x0000b109
[    0.000000] Linux version 5.17.13 (ame@blackdwarf) (riscv32-buildroot-linux-gnu-gcc.br_real (Buildroot 2022.05) 10.3.0, GNU ld (GNU Binutils) 2.37) #2 SMP Thu Aug 11 15:22:54 CEST 2022
[    0.000000] OF: fdt: Ignoring memory range 0x80000000 - 0x80400000
[    0.000000] Machine model: ub,vp-bare
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000080400000-0x00000000bfffffff]
[    0.000000] Movable zone start for each node

...

[    7.396227] debug_vm_pgtable: [debug_vm_pgtable         ]: Validating architecture page table helpers
[   16.656213] Freeing unused kernel image (initmem) memory: 6536K
[   16.659675] Run /init as init process
Starting syslogd: OK
Starting klogd: OK
Running sysctl: OK
Saving random seed: [   22.191178] random: dd: uninitialized urandom read (32 bytes read)
OK
Starting network: OK
Starting telnetd: OK

Welcome to Buildroot
buildroot login: root
# 
```

### Cleanup
 * Clean all build artefacts: ```make clean```
 * Clean everything (including downloads): ```make distclean```

## Graphics (VNC Framebuffer and Mouse)
GUI-VP provides graphical output and pointer(mouse)/keyboard event propagation via VNC.
Any VNC client (e.g. [Remmina](https://remmina.org/)) can be used.

Example (on the host)
```
remmina vnc://localhost
```

### Xorg
The root filesystem comes with a modular [Xorg](https://www.x.org/wiki/) server and some some small test applications including also the small footprint web browser [Dillo](https://www.dillo.org/).

The Xorg server is not automatically started on boot.
To start the Xorg server a start script must be called:
```
/etc/init.d/optional_xorg/start.sh
```

Example: Start the dillo webbrowser showing a locally provided demo page:
```
dillo localhost
```
NOTE: The dillo web browser does not support https yet.

Other demo applications:
 * The X logo: ```xlogo```
 * Classic X demo: ```xeyes```
 * X wall clocks: ```xclock``` and ```oclock```
 * X Calculator: ```xcalc```
 * A simple window manager: ```fluxbox```


### Direct framebuffer and SDL
The root filesystem includes some applications that provide graphical output via framebuffer (directly or via [Simple DirectMedia Layer](https://www.libsdl.org/) (SDL).

 * The framebuffer test suite: ```fb-test```
 * Screenshot tools: ```fbdump``` and ```fbgrab```
 * Image viewer: ```fbv```
 * SDL Doom clone [PrBoom](https://prboom.sourceforge.net/) with Shareware WAD

If Xorg is running, it must be stopped, before these applications can be used:
```
/etc/init.d/optional_xorg/S40xorg stop
```

Example: Show the RISC-V Logo:
```
fbv /var/www/riscv-color.jpg
```

Example: Run prboom demo (no control yet!) with 350x250 resolution
```
/usr/games/prboom -width 350 -height 250
```

prboom has been extended to output statistics about frames per second (milli fps) and instructions per frame (ipf) on the console. Here an example of of prboom statistics output on linux-rv32-sc:
```
...
STAT: INIT -> START WARMUP
STAT: WARMUP COMPLETE -> RUNNING
STAT:
 * cur_mfps = 5484, avg_mfps = 5522, min_mfps = 5484, max_mfps = 5560
 * cur_ipf = 3664832, avg_ipf = 3649438, min_ipf = 3634044, max_ipf = 3664832
STAT:
 * cur_mfps = 5519, avg_mfps = 5137, min_mfps = 3872, max_mfps = 5639
 * cur_ipf = 3531341, avg_ipf = 3862197, min_ipf = 3531341, max_ipf = 4832150
...
```
NOTE: Statistics on instructions per frame (ipf) are only valid for single core VPs!


## Networking
*GUI-VP* provides networking using [Serial Line Internet Protocol](https://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol) (Slip) and [TUN/TAP](https://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol). The virtual serial interface */dev/ttySIF1* provides the slip interface. The hosts *tun10* provides the corresponding tun interface.

### Setup
**Note:** The IP addresses must be chosen carefully to avoid conflicts in the host's network configuration. By default 10.0.0.1 is used for the host and 10.0.0.2 for linux running inside the vp. The addresses can be changed in ```tools/setup_host_networking.sh``` and ```buildroot_fs_overlay/etc/network/interfaces``` (buildroot rebuild necessary).

**Once on the host before starting the vp (priviliges needed):**
```
tools/setup_host_networking.sh
```
Sets up the device *tun10* with IP 10.0.0.1 and enables routing and masquerading (nat).

**Inside the vp after each boot:**
```
ifup sl0
```
Sets up the slip interface *sl0* with IP 10.0.0.2, routing via 10.0.0.1 and domain name resolution (via 8.8.8.8)

**Test:**

To test the configuration, each side can now be pinged from the other one:
 * Ping the system inside the vp from the host
   ```
   $ ping 10.0.0.2
   PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
   64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=15.1 ms
   64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=15.0 ms
   ...
   ```
 * Ping the host from inside the vp:
   ```
   # ping 10.0.0.1
   PING 10.0.0.1 (10.0.0.1): 56 data bytes
   64 bytes from 10.0.0.1: seq=0 ttl=64 time=11.216 ms
   64 bytes from 10.0.0.1: seq=1 ttl=64 time=8.070 ms
   ...
   ```

To test the domain name resultion and routing, an external site (e.g. riscv.org) can be pinged from the vp:
```
# ping riscv.org
PING riscv.org (23.185.0.1): 56 data bytes
64 bytes from 23.185.0.1: seq=0 ttl=58 time=26.976 ms
64 bytes from 23.185.0.1: seq=1 ttl=58 time=27.261 ms
...
```

### Access via Telnet
The root filesystem comes with a running telnet server.
Once the network is configured, a remote login from host to the system inside the vp is possible.

On the host:
```
$ telnet 10.0.0.2
Trying 10.0.0.2...
Connected to 10.0.0.2.
Escape character is '^]'.

buildroot login: root
# 
```

### Access via http
The root filesystem comes with a running http server providing a simple demo page.
Once the network is configured, the demo page can be accessed by [http://10.0.0.2](http://10.0.0.2).


### Mounting Network Volumes
A working network configuration allows mounting of [Network File System](https://en.wikipedia.org/wiki/Network_File_System) (NFS) volumes provided by the host in the system running inside the vp.
This is especially useful for transferring data or software to the system running on the vp without rebuilding the root file system or restarting the vp.

**Once on the host (priviliges needed):**
 1. Have a running nfs-server setup (see documentation of your distribution)
    * e.g. Debian/Ubuntu: ```apt-get install nfs-kernel-server```
 1. Create a directory to be exported (e.g. */srv/nfs_for_vp*)
    ```
    mkdir /srv/nfs_for_vp
    ```
 1. Export a volume accessable by the vp
    ```
    /srv/nfs_for_vp -rw,sync,no_subtree_check,no_root_squash        \
                    10.0.0.0/24                                     \
    ```
 1. Restart the nfs server
    * e.g. Debian/Ubuntu: ```service nfs-kernel-server restart```

**Inside the vp after each boot and network configuration:** Mount the volume to */mnt*

```
mount 10.0.0.1:/srv/nfs_for_vp /mnt -o nolock
```

The host directory */srv/nfs_for_vp* is now accessible on the system inside the vp at */mnt*.
Changes to directory are visible in almost real time on both systems.

## Using the Buildroot Toolchain for external Projects
The C/C++ toolchain build by buildroot provides support for external use (e.g. to build own projects outside of buildroot).

**To setup a running shell for cross compilation using the created toolchain:**
 * for rv32: ```. <path_to_GUI-VP_linux>/buildroot_rv32/output/host/environment-setup```
 * for rv64: ```. <path_to_GUI-VP_linux>/buildroot_rv64/output/host/environment-setup```

**Example (rv32):**
```
alice@host:~/myprojects$ cd hello_world_c
alice@host:~/myprojects/hello_world_c$ . ../GUI-VP_Kit/buildroot_rv32/output/host/environment-setup
 _           _ _     _                 _
| |__  _   _(_) | __| |_ __ ___   ___ | |_
| '_ \| | | | | |/ _` | '__/ _ \ / _ \| __|
| |_) | |_| | | | (_| | | | (_) | (_) | |_
|_.__/ \__,_|_|_|\__,_|_|  \___/ \___/ \__|

       Making embedded Linux easy!

Some tips:
* PATH now contains the SDK utilities
* Standard autotools variables (CC, LD, CFLAGS) are exported
* Kernel compilation variables (ARCH, CROSS_COMPILE, KERNELDIR) are exported
* To configure do "./configure $CONFIGURE_FLAGS" or use
  the "configure" alias
* To build CMake-based projects, use the "cmake" alias

alice@host:~/myprojects/hello_world_c$ make
riscv32-buildroot-linux-gnu-gcc -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64  -Os -g0 -D_FORTIFY_SOURCE=1 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64   hello_world.c   -o hello_world
alice@host:~/myprojects/hello_world_c$ 
```

More details on this can be found in the [Buildroot manual -- 8.13.1. Using the generated toolchain outside Buildroot](https://buildroot.org/downloads/manual/manual.html#_advanced_usage).




## *GUI-VP Kit: A RISC-V VP meets Linux graphics - enabling interactive graphical application development*

[Manfred Schlägl and Daniel Große. GUI-VP Kit: A RISC-V VP meets Linux graphics - enabling interactive graphical application development. In GLSVLSI, 2023.
](https://ics.jku.at/files/2023GLSVLSI_GUI-VP_Kit.pdf)

```
@inproceedings{SG:2023,
  author =        {Manfred Schl{\"{a}}gl and Daniel Gro{\ss}e},
  booktitle =     {ACM Great Lakes Symposium on VLSI},
  title =         {{GUI-VP Kit}: A {RISC-V} {VP} Meets {Linux} Graphics
                   - Enabling Interactive Graphical Application
                   Development},
  year =          {2023},
}
```
