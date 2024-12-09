# GUI-VP Kit: A RISC-V VP Meets Linux Graphics -- Enabling Interactive Graphical Application Development

The aim of this project is to provide a quick to create and easy to use platform for experimenting with Linux on the open-source SystemC RISC-V based virtual prototype [RISCV-VP++](https://github.com/ics-jku/riscv-vp-plusplus).
*RISCV-VP++* is a powerful open-source VP that allows simulation of RISC-V platforms capable of running Linux with interactive graphical applications.
*GUI-VP Kit* handles the generation of all the necessary software parts and provides an experimentation environment for Linux with interactive graphical applications.

*GUI-VP Kit* was originally developed for use with [GUI-VP](https://github.com/ics-jku/GUI-VP), which was introduced together with *GUI-VP Kit* at the *ACM Great Lakes Symposium on VLSI*, by Manfred Schlägl and Daniel Große with [GUI-VP Kit: A RISC-V VP meets Linux graphics - enabling interactive graphical application development](https://ics.jku.at/files/2023GLSVLSI_GUI-VP_Kit.pdf). (A BibTex entry to cite the paper can be found in the last section.)
However, since the integration of the full functionality of *GUI-VP* into *RISC-VP++* in 2023, *GUI-VP Kit* uses *RISC-VP++* for simulation.

*GUI-VP Kit* and *RISCV-VP++* were created and are maintained at the [Institute for Complex Systems](https://ics.jku.at/), Johannes Kepler University, Linz.

## Key Features
The project
 * downloads and builds [RISCV-VP++](https://github.com/ics-jku/riscv-vp-plusplus) (vp executables)
 * downloads and builds [buildroot](https://buildroot.org) for rv32 and rv64, including
   * the C/C++ toolchain (gcc, glibc) (also for external use -- see below)
   * the root filesystem (based on busybox)
   * the linux kernel image including the root filesystem (initramfs)
   * the openSBI bootloader image (including linux kernel and root filesystem)
 * builds the device tree blobs describing the rv32 and rv64 (fu540 compatible) single- and multicore vps
 * can start the created rv32 and rv64 images on linux-vp(rv64 multicore), linux32-vp(rv32 multicore), linux-sc-vp(rv64 singlecore) and linux32-sc-vp(rv32 singlecore)
 * supports graphic output, mouse- and keyboard input via [Virtual Network Computing](https://en.wikipedia.org/wiki/Virtual_Network_Computing) (VNC) (see below)
 * supports networking between the host and the system inside the vp (see below)
 * supports large storage devices (image files) as virtual sd-card (see below)

## Build & Run
This section explains how to build the project and boot the vp.

### Prerequisites

 1. A running Linux system with at least 27 GiB of free disk memory and an internet connection
     * The project was developed and tested on Debian 11 and 12
 2. Installed packages necessary for *RISCV-VP++*
     * see [riscv-vp README.md](https://github.com/ics-jku/riscv-vp-plusplus/blob/master/README.md)
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

**Example (rv64, singlecore):**
```
$ make run_rv64_sc
"riscv-vp-plusplus"/vp/build/bin/linux-sc-vp				\
	--use-data-dmi --tlm-global-quantum=1000000 --tun-device tun10						\
	--dtb-file=dt/linux-vp_rv64_sc.dtb			\
	--mram-root-image runtime_mram/mram_rv64_root.img	\
	--mram-data-image runtime_mram/mram_rv64_data.img	\
	buildroot_rv64/output/images/fw_payload.elf

        SystemC 2.3.3-Accellera --- Nov 10 2023 12:43:08
        Copyright (c) 1996-2018 by all Contributors,
        ALL RIGHTS RESERVED
10/11/2023 12:53:16 Listening for VNC connections on TCP port 5900
10/11/2023 12:53:16 Listening for VNC connections on TCP6 port 5900

OpenSBI v1.3
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|___/_____|
        | |
        |_|

Platform Name             : Generic
Platform Features         : medeleg
Platform HART Count       : 1
Platform IPI Device       : aclint-mswi
Platform Timer Device     : aclint-mtimer @ 1000000Hz
Platform Console Device   : sifive_uart
Platform HSM Device       : ---
Platform PMU Device       : ---
Platform Reboot Device    : sifive_test
Platform Shutdown Device  : sifive_test
Platform Suspend Device   : ---
Platform CPPC Device      : ---
Firmware Base             : 0x80000000
Firmware Size             : 322 KB
Firmware RW Offset        : 0x40000
Firmware RW Size          : 66 KB
Firmware Heap Offset      : 0x48000
Firmware Heap Size        : 34 KB (total), 2 KB (reserved), 9 KB (used), 22 KB (free)
Firmware Scratch Size     : 4096 B (total), 760 B (used), 3336 B (free)
Runtime SBI Version       : 1.0

Domain0 Name              : root
Domain0 Boot HART         : 1
Domain0 HARTs             : 1*
Domain0 Region00          : 0x0000000002008000-0x000000000200bfff M: (I,R,W) S/U: ()
Domain0 Region01          : 0x0000000002000000-0x0000000002007fff M: (I,R,W) S/U: ()
Domain0 Region02          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U: ()
Domain0 Region03          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U: ()
Domain0 Region04          : 0x0000000000000000-0xffffffffffffffff M: (R,W,X) S/U: (R,W,X)
Domain0 Next Address      : 0x0000000080200000
Domain0 Next Arg1         : 0x0000000082200000
Domain0 Next Mode         : S-mode
Domain0 SysReset          : yes
Domain0 SysSuspend        : yes

Boot HART ID              : 1
Boot HART Domain          : root
Boot HART Priv Version    : v1.11
Boot HART Base ISA        : rv64imafdcn
Boot HART ISA Extensions  : time
Boot HART PMP Count       : 16
Boot HART PMP Granularity : 4
Boot HART PMP Address Bits: 54
Boot HART MHPM Count      : 0
Boot HART MIDELEG         : 0x0000000000000222
Boot HART MEDELEG         : 0x000000000000b109
[    0.000000] Linux version 6.6.0 (ame@pulsar) (riscv64-buildroot-linux-gnu-gcc.br_real (Buildroot 2023.08.2) 13.2.0, GNU ld (GNU Binutils) 2.40) #1 SMP Mon Oct 30 19:29:01 CET 2023
[    0.000000] Machine model: sifive,fu540-c000
[    0.000000] SBI specification v1.0 detected
[    0.000000] SBI implementation ID=0x1 Version=0x10003
[    0.000000] SBI TIME extension detected
[    0.000000] SBI IPI extension detected
[    0.000000] SBI RFENCE extension detected
[    0.000000] SBI SRST extension detected

...

[    4.786928] VFS: Mounted root (romfs filesystem) readonly on device 31:0.
[    4.834007] devtmpfs: mounted
[    4.902461] Freeing unused kernel image (initmem) memory: 2156K
[    4.988638] Run /sbin/init as init process
Mount /dev/mtdblock1 to /data
 * Check
e2fsck 1.47.0 (5-Feb-2023)
/dev/mtdblock1: clean, 14/32768 files, 6385/131072 blocks
 * Mount
[    6.821228] EXT4-fs (mtdblock1): mounted filesystem 23538d76-1dd2-11b2-9df6-1132e6b7713a r/w with ordered data mode. Quota mode: disabled.
seedrng: can't create directory '/var/lib/seedrng': Read-only file system
Starting syslogd: OK
Starting klogd: OK
Running sysctl: OK
Starting network: OK
Starting darkhttpd: OK
Starting telnetd: OK

Welcome to Buildroot
buildroot login: root
# 
```

### Cleanup
 * Clean all build artefacts: ```make clean```
 * Clean everything (including downloads): ```make distclean```

## Graphics (VNC Framebuffer and Mouse)
*RISCV-VP++* provides graphical output and pointer(mouse)/keyboard event propagation via VNC.
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
 * Lightweight window managers: ```openbox``` and ```fluxbox```


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

Example: Run prboom demo with 320x200 resolution
```
/usr/games/prboom -width 320 -height 200
```

prboom has been extended to output statistics about frames per second (milli fps) and instructions per frame (ipf) on the console. Here an example of of prboom statistics output on linux-rv32-sc:
```
/usr/games/prboom -width 320 -height 200 -rendering_stats2

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


### Qt5 (linuxfb)
The root filessystem includes the Qt5 framework with some sample applications.

Qt5 uses *qpa* with the *linuxfb* backend.
If Xorg is running, it must be stopped, before Qt can be used:
```
/etc/init.d/optional_xorg/S40xorg stop
```

The examples are located in ```/usr/lib/qt/examples```.

Example: Calculator
```
/usr/lib/qt/examples/widgets/widgets/calculator/calculator
```

Example: Widget Gallery
```
/usr/lib/qt/examples/widgets/gallery/gallery
```

## Networking
*RISCV-VP++* provides networking using [Serial Line Internet Protocol](https://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol) (Slip) and [TUN/TAP](https://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol). The virtual serial interface */dev/ttySIF1* provides the slip interface. The hosts *tun10* provides the corresponding tun interface.

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

**Note: If the above mount fails, it may be because the server only supports NFSv4, which is the case with some Linux distributions. In this case, please use the following command**

```
mount 10.0.0.1:/srv/nfs_for_vp /mnt -o nolock,vers=4
```

The host directory */srv/nfs_for_vp* is now accessible on the system inside the vp at */mnt*.
Changes to directory are visible in almost real time on both systems.

## Virtual SD-Card support
The RISC-V VP++ Linux configurations support virtual SD-Cards backed by an image file.

An SD-Card image can be attached via the VP parameter ```--sd-card-image <image-name>```.
The size of the image must be a multiple of 512 bytes.

### Example: Attaching a new, empty SD-Card image

 1. Create an empty sd-card image with 100MiB
    ```
    dd if=/dev/zero of=sd-card.img bs=1024 count=102400
    ```
 1. Start the vp with the attached image using the VP parameter ```--sd-card-image sd-card.img```
    ```
    VP_ARGS="--use-data-dmi --tlm-global-quantum=1000000 --tun-device tun10 --sd-card-image sd-card.img" make run_rv64_sc
    ```

**The card is now detected on Linux bootup and available as ```/dev/mmcblk0``` from the Linux system running inside the VP.**
```
...
[    7.070696] mmc0: new SDHC card on SPI
[    7.276887] mmcblk0: mmc0:0000 RVVP2 100 MiB
...
```

The card can now, for example be
 * formatted with a filesystem: ```mkfs.ext4 /dev/mmcblk0```,
 * mounted: ```mount /dev/mmcblk0 /mnt```,
 * partitioned: ```fdisk /dev/mmcblk0```,
 * ...

The image file will retain any changes made to the SD-Card from inside the VP.
The image file can also be manipulated on the host system (e.g. format, mount, ...) when the VP is not running.

## Using the Buildroot Toolchain for external Projects
The C/C++ toolchain build by buildroot provides support for external use (e.g. to build own projects outside of buildroot).

**To setup a running shell for cross compilation using the created toolchain:**
 * for rv32: ```. <path_to_GUI-VP_Kit>/buildroot_rv32/output/host/environment-setup```
 * for rv64: ```. <path_to_GUI-VP_Kit>/buildroot_rv64/output/host/environment-setup```

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
