# Copyright (c) 2022 Manfred SCHLAEGL <manfred.schlaegl@gmx.at>
#
# SPDX-License-Identifier: BSD 3-clause "New" or "Revised" License
#

BUILDROOT_GIT=git://git.buildroot.net/buildroot
BUILDROOT_VERSION=2022.08.1
GUI_VP_GIT=git@github.com:ics-jku/GUI-VP.git
GUI_VP_VERSION=GUI-VP_glsvlsi_2023
GUI_VP_ARGS=\
	--use-data-dmi			\
	--tlm-global-quantum=1000000	\
	--tun-device tun10


.PHONY: help all get dtb build_rv32 build_rv64 build vp-rebuild \
	buildroot_rv32-rebuild buildroot_rv64-rebuild \
	run_rv32 run_rv64 clean distclean

help:
	@echo
	@echo "Targets:"
	@grep '^[^#[:space:]].*:' Makefile | cut -d':' -f1 | grep -v '\.\|dt/\|='
	@echo

all: build

get: .stamp/gui-vp_get .stamp/buildroot_get

build_rv32: .stamp/gui-vp_build .stamp/buildroot_rv32_build dt/linux-vp_rv32_sc.dtb dt/linux-vp_rv32_mc.dtb

build_rv64: .stamp/gui-vp_build .stamp/buildroot_rv64_build dt/linux-vp_rv64_sc.dtb dt/linux-vp_rv64_mc.dtb

build: build_rv32 build_rv64

vp-rebuild:
	rm -rf .stamp/gui-vp_build
	make .stamp/gui-vp_build

buildroot_rv32-rebuild:
	rm -rf .stamp/buildroot_rv32_build
	make .stamp/buildroot_rv32_build

buildroot_rv64-rebuild:
	rm -rf .stamp/buildroot_rv64_build
	make .stamp/buildroot_rv64_build

build_all_dts: dt/linux-vp_rv32_sc.dts dt/linux-vp_rv64_sc.dts dt/linux-vp_rv32_mc.dts dt/linux-vp_rv64_mc.dts

build_all_dtb: dt/linux-vp_rv32_sc.dtb dt/linux-vp_rv64_sc.dtb dt/linux-vp_rv32_mc.dtb dt/linux-vp_rv64_mc.dtb

run_rv32_sc: build_rv32
	GUI-VP/vp/build/bin/linux32-sc-vp			\
		$(GUI_VP_ARGS)					\
		--dtb-file=dt/linux-vp_rv32_sc.dtb		\
		buildroot_rv32/output/images/fw_payload.elf

run_rv64_sc: build_rv64
	GUI-VP/vp/build/bin/linux-sc-vp				\
		$(GUI_VP_ARGS)					\
		--dtb-file=dt/linux-vp_rv64_sc.dtb		\
		buildroot_rv64/output/images/fw_payload.elf

run_rv32_mc: build_rv32
	GUI-VP/vp/build/bin/linux32-vp				\
		$(GUI_VP_ARGS)					\
		--dtb-file=dt/linux-vp_rv32_mc.dtb		\
		buildroot_rv32/output/images/fw_payload.elf

run_rv64_mc: build_rv64
	GUI-VP/vp/build/bin/linux-vp				\
		$(GUI_VP_ARGS)					\
		--dtb-file=dt/linux-vp_rv64_mc.dtb		\
		buildroot_rv64/output/images/fw_payload.elf

clean:
	- $(MAKE) clean -C GUI-VP
	- $(MAKE) clean -C buildroot_rv64
	- $(MAKE) clean -C buildroot_rv32
	- rm -rf dt/*.dtb
	- rm -rf .stamp/buildroot_config
	- rm -rf .stamp/buildroot_rv??_build

distclean:
	- rm -rf .stamp
	- rm -rf buildroot_rv32 buildroot_rv64 buildroot_dl
	- rm -rf GUI-VP
	- rm -rf dt/*.dts


## MISC/HELPERS

.stamp/init:
	@mkdir -p `dirname $@`
	@touch $@


## GUI VP

.stamp/gui-vp_get: .stamp/init
	@echo " + GET RISC-V VP"
	rm -rf GUI-VP
	git clone $(GUI_VP_GIT) GUI-VP
	( cd GUI-VP && git checkout $(GUI_VP_VERSION) )
	@touch $@

.stamp/gui-vp_build: .stamp/gui-vp_get
	@echo " + BUILD RISC-V VP"
	# ensure release build
	RELEASE_BUILD=ON $(MAKE) vps -C GUI-VP #-j$(NPROCS) (broken)
	@touch $@


## BUILDROOT

.stamp/buildroot_get: .stamp/init
	@echo " + GET BUILDROOT"
	rm -rf buildroot_rv32 buildroot_rv64
	git clone $(BUILDROOT_GIT) buildroot_rv32
	( cd buildroot_rv32 && git checkout $(BUILDROOT_VERSION) )
	cp -a buildroot_rv32 buildroot_rv64
	@touch $@

.stamp/buildroot_config: .stamp/buildroot_get
	@echo " + CONFIG BUILDROOT"
	cp configs/buildroot_rv32.config buildroot_rv32/.config
	cp configs/buildroot_rv64.config buildroot_rv64/.config
	cp configs/busybox.config buildroot_rv32
	cp configs/busybox.config buildroot_rv64
	cp configs/linux_rv32.config buildroot_rv32
	cp configs/linux_rv64.config buildroot_rv64
	@touch $@

.stamp/buildroot_rv32_build: .stamp/buildroot_config
	@echo " + BUILD BUILDROOT FOR RV32"
	make -C buildroot_rv32 source
	make -C buildroot_rv32
	make -C buildroot_rv32 opensbi-rebuild
	@touch $@

.stamp/buildroot_rv64_build: .stamp/buildroot_config
	@echo " + BUILD BUILDROOT FOR RV64"
	make -C buildroot_rv64 source
	make -C buildroot_rv64
	make -C buildroot_rv64 opensbi-rebuild
	@touch $@


## DEVICETREE

dt/linux-vp_rv32_sc.dts: dt/linux-vp_base.dts.in dt/linux-vp_cpu.dts.in dt/gen_dts.sh
	@echo " + CREATE VP RV32 SINGLECORE DTS: $@"
	./dt/gen_dts.sh rv32 1 > $@

dt/linux-vp_rv64_sc.dts: dt/linux-vp_base.dts.in dt/linux-vp_cpu.dts.in dt/gen_dts.sh
	@echo " + CREATE VP RV64 SINGLECORE DTS: $@"
	./dt/gen_dts.sh rv64 1 > $@

dt/linux-vp_rv32_mc.dts: dt/linux-vp_base.dts.in dt/linux-vp_cpu.dts.in dt/gen_dts.sh
	@echo " + CREATE VP RV32 MULTICORE DTS: $@"
	./dt/gen_dts.sh rv32 4 > $@

dt/linux-vp_rv64_mc.dts: dt/linux-vp_base.dts.in dt/linux-vp_cpu.dts.in dt/gen_dts.sh
	@echo " + CREATE VP RV64 MULTICORE DTS: $@"
	./dt/gen_dts.sh rv64 4 > $@

dt/linux-vp_rv32_sc.dtb: dt/linux-vp_rv32_sc.dts .stamp/buildroot_rv32_build
	@echo " + CREATE VP RV32 SINGLECORE DTB: $@"
	buildroot_rv32/output/host/bin/dtc $< -o $@

dt/linux-vp_rv64_sc.dtb: dt/linux-vp_rv64_sc.dts .stamp/buildroot_rv64_build
	@echo " + CREATE VP RV64 SINGLECORE DTB: $@"
	buildroot_rv32/output/host/bin/dtc $< -o $@

dt/linux-vp_rv32_mc.dtb: dt/linux-vp_rv32_mc.dts .stamp/buildroot_rv32_build
	@echo " + CREATE VP RV32 MULTICORE DTB: $@"
	buildroot_rv32/output/host/bin/dtc $< -o $@

dt/linux-vp_rv64_mc.dtb: dt/linux-vp_rv64_mc.dts .stamp/buildroot_rv64_build
	@echo " + CREATE VP RV64 MULTICORE DTB: $@"
	buildroot_rv32/output/host/bin/dtc $< -o $@
