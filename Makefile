# Copyright (c) 2022 Manfred SCHLAEGL <manfred.schlaegl@gmx.at>
#
# SPDX-License-Identifier: BSD 3-clause "New" or "Revised" License
#

BUILDROOT_GIT=git://git.buildroot.net/buildroot
BUILDROOT_VERSION=2022.05
RISCV_VP_GIT=https://github.com/agra-uni-bremen/riscv-vp.git
RISCV_VP_VERSION=8ddfda7f8762955f926fa100c327afdd4300239b

.PHONY: all get dtb build_rv32 build_rv64 build clean distclean

all: build

get: .stamp/riscv-vp_get .stamp/buildroot_get

build_rv32: .stamp/riscv-vp_build .stamp/buildroot_rv32_build #dt/linux-vp_rv32.dtb

build_rv64: .stamp/riscv-vp_build .stamp/buildroot_rv64_build #dt/linux-vp_rv64.dtb

build: build_rv32 build_rv64

clean:
	- $(MAKE) clean -C riscv-vp
	- $(MAKE) clean -C buildroot_rv64
	- $(MAKE) clean -C buildroot_rv32
	- rm -rf dt/*.dtb
	- rm -rf .stamp/buildroot_config
	- rm -rf .stamp/buildroot_rv??_build

distclean:
	- rm -rf .stamp
	- rm -rf buildroot_rv32 buildroot_rv64
	- rm -rf riscv-vp
	- rm -rf dt/*.dts


## MISC/HELPERS

.stamp/init:
	@mkdir -p `dirname $@`
	@touch $@


## RISC-V VP

.stamp/riscv-vp_get: .stamp/init
	@echo " + GET RISC-V VP"
	rm -rf riscv-vp
	git clone $(RISCV_VP_GIT) riscv-vp
	( cd riscv-vp && git checkout $(RISCV_VP_VERSION) )
	@touch $@

.stamp/riscv-vp_build: .stamp/riscv-vp_get
	@echo " + BUILD RISC-V VP"
	# ensure release build
	CMAKE_BUILD_TYPE=Release $(MAKE) vps -C riscv-vp #-j$(NPROCS) (broken)
	@touch $@


## BUILDROOT

.stamp/buildroot_get: .stamp/init
	@echo " + GET BUILDROOT"
	rm -rf buildroot_rv32 buildroot_rv64
	git clone $(BUILDROOT_GIT) buildroot_rv32
	( cd buildroot_rv32 && git checkout $(BUILDROOT_VERSION) )
	cp -a buildroot_rv32 buildroot_rv64
	# TODO: prevent multiple downloads
	#( cd buildroot_rv64 && rm -rf dl && ln -s ../buildroot_rv32/dl )
	@touch $@

.stamp/buildroot_config: .stamp/buildroot_get
	@echo " + CONFIG BUILDROOT"
	cp configs/buildroot_rv32.config buildroot_rv32/.config
	cp configs/buildroot_rv64.config buildroot_rv64/.config
	@touch $@

.stamp/buildroot_rv32_build: .stamp/buildroot_config
	@echo " + BUILD BUILDROOT FOR RV32"
	make -C buildroot_rv32 source
	make -C buildroot_rv32
	@touch $@

.stamp/buildroot_rv64_build: .stamp/buildroot_config
	@echo " + BUILD BUILDROOT FOR RV64"
	make -C buildroot_rv64 source
	make -C buildroot_rv64
	@touch $@


## DEVICETREE

dt/linux-vp_rv32.dts: dt/linux-vp.dts.in
	@echo " + CREATE VP RV32 DTS: $@"
	sed $< \
		-e "s/@RISCV_ISA@/\"rv32imafdc\"/g"	\
		-e "s/@MMU_TYPE@/\"riscv-sv32\"/g"	\
		-e "s/@MEM_SIZE@/0x40000000/g"		\
		> $@

dt/linux-vp_rv64.dts: dt/linux-vp.dts.in
	@echo " + CREATE VP RV64 DTS: $@"
	sed $< \
		-e "s/@RISCV_ISA@/\"rv64imafdc\"/g"	\
		-e "s/@MMU_TYPE@/\"riscv-sv48\"/g"	\
		-e "s/@MEM_SIZE@/0x80000000/g"		\
		> $@

dt/linux-vp_rv32.dtb: dt/linux-vp_rv32.dts .stamp/buildroot_rv32_build
	@echo " + CREATE VP RV32 DTB: $@"
	buildroot_rv32/output/host/bin/dtc $< -o $@

dt/linux-vp_rv64.dtb: dt/linux-vp_rv64.dts .stamp/buildroot_rv64_build
	@echo " + CREATE VP RV64 DTB: $@"
	buildroot_rv64/output/host/bin/dtc $< -o $@
