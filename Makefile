# Copyright (c) 2022 Manfred SCHLAEGL <manfred.schlaegl@gmx.at>
#
# SPDX-License-Identifier: BSD 3-clause "New" or "Revised" License
#

BUILDROOT_GIT=git://git.buildroot.net/buildroot
BUILDROOT_VERSION=2024.05.1
VP_NAME=riscv-vp-plusplus
VP_GIT=https://github.com/ics-jku/$(VP_NAME).git
VP_VERSION=master
MRAM_IMAGE_DIR=runtime_mram
# VP_ARGS can be overriden by user ($ VP_ARGS="..." make run_...)
VP_ARGS?=--use-data-dmi --tlm-global-quantum=1000000 --tun-device tun10
BR_DTC="output/host/bin/dtc"

.PHONY: help all get dtb build_rv32 build_rv64 build vp-rebuild buildroot-reconfigure	\
	buildroot_rv32-rebuild buildroot_rv64-rebuild buildroot-rebuild						\
	run_rv32 run_rv64 clean distclean

help:
	@echo
	@echo "Targets:"
	@grep '^[^#[:space:]].*:' Makefile | cut -d':' -f1 | grep -v '\.\|dt/\|='
	@echo
	@echo "VP Arguments:"
	@echo $(VP_ARGS)
	@echo "Can be overriden by user"
	@echo "Example: VP_ARGS=\"$(VP_ARGS)\" make run_rv32_sc"
	@echo

all: build

get: .stamp/vp_get .stamp/buildroot_get

build_rv32: .stamp/vp_build .stamp/buildroot_rv32_build dt/linux-vp_rv32_sc.dtb dt/linux-vp_rv32_mc.dtb

build_rv64: .stamp/vp_build .stamp/buildroot_rv64_build dt/linux-vp_rv64_sc.dtb dt/linux-vp_rv64_mc.dtb

build: build_rv32 build_rv64

vp-rebuild:
	rm -rf .stamp/vp_build
	make .stamp/vp_build

buildroot-reconfigure:
	rm -rf .stamp/buildroot_config
	make .stamp/buildroot_config

buildroot_rv32-rebuild:
	rm -rf .stamp/buildroot_rv32_build
	make .stamp/buildroot_rv32_build

buildroot_rv64-rebuild:
	rm -rf .stamp/buildroot_rv64_build
	make .stamp/buildroot_rv64_build

buildroot-rebuild: buildroot_rv32-rebuild buildroot_rv64-rebuild

build_all_dts: dt/linux-vp_rv32_sc.dts dt/linux-vp_rv64_sc.dts dt/linux-vp_rv32_mc.dts dt/linux-vp_rv64_mc.dts

build_all_dtb: dt/linux-vp_rv32_sc.dtb dt/linux-vp_rv64_sc.dtb dt/linux-vp_rv32_mc.dtb dt/linux-vp_rv64_mc.dtb

run_rv32_sc: build_rv32
	$(VP_NAME)/vp/build/bin/linux32-sc-vp						\
		$(VP_ARGS)												\
		--dtb-file=dt/linux-vp_rv32_sc.dtb						\
		--mram-root-image $(MRAM_IMAGE_DIR)/mram_rv32_root.img	\
		--mram-data-image $(MRAM_IMAGE_DIR)/mram_rv32_data.img	\
		buildroot_rv32/output/images/fw_payload.elf

run_rv64_sc: build_rv64
	$(VP_NAME)/vp/build/bin/linux-sc-vp							\
		$(VP_ARGS)												\
		--dtb-file=dt/linux-vp_rv64_sc.dtb						\
		--mram-root-image $(MRAM_IMAGE_DIR)/mram_rv64_root.img	\
		--mram-data-image $(MRAM_IMAGE_DIR)/mram_rv64_data.img	\
		buildroot_rv64/output/images/fw_payload.elf

run_rv32_mc: build_rv32
	$(VP_NAME)/vp/build/bin/linux32-vp							\
		$(VP_ARGS)												\
		--dtb-file=dt/linux-vp_rv32_mc.dtb						\
		--mram-root-image $(MRAM_IMAGE_DIR)/mram_rv32_root.img	\
		--mram-data-image $(MRAM_IMAGE_DIR)/mram_rv32_data.img	\
		buildroot_rv32/output/images/fw_payload.elf

run_rv64_mc: build_rv64
	$(VP_NAME)/vp/build/bin/linux-vp							\
		$(VP_ARGS)												\
		--dtb-file=dt/linux-vp_rv64_mc.dtb						\
		--mram-root-image $(MRAM_IMAGE_DIR)/mram_rv64_root.img	\
		--mram-data-image $(MRAM_IMAGE_DIR)/mram_rv64_data.img	\
		buildroot_rv64/output/images/fw_payload.elf

clean:
	- $(MAKE) clean -C $(VP_NAME)
	- $(MAKE) clean -C buildroot_rv64
	- $(MAKE) clean -C buildroot_rv32
	- rm -rf dt/*.dtb
	- rm -rf .stamp/buildroot_config
	- rm -rf .stamp/buildroot_get_sources
	- rm -rf .stamp/buildroot_rv??_build

distclean:
	- rm -rf .stamp
	- rm -rf buildroot_rv32 buildroot_rv64 buildroot_dl
	- rm -rf $(VP_NAME)
	- rm -rf dt/*.dtb
	- rm -rf dt/*.dts


## MISC/HELPERS

.stamp/init:
	@mkdir -p `dirname $@`
	@touch $@


## VP

.stamp/vp_get: .stamp/init
	@echo " + GET RISC-V VP"
	rm -rf $(VP_NAME)
	git clone $(VP_GIT) $(VP_NAME)
	( cd $(VP_NAME) && git checkout $(VP_VERSION) )
	@touch $@

.stamp/vp_build: .stamp/vp_get
	@echo " + BUILD RISC-V VP"
	# ensure release build
	RELEASE_BUILD=ON $(MAKE) vps -C $(VP_NAME) -j$(NPROCS)
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

.stamp/buildroot_get_sources: .stamp/buildroot_config
	@echo " + GET BUILDROOT PACKAGE SOURCES"
	make -C buildroot_rv32 source
	make -C buildroot_rv64 source
	@touch $@

.stamp/buildroot_rv32_build: .stamp/buildroot_get_sources
	@echo " + BUILD BUILDROOT FOR RV32"
	make -C buildroot_rv32
	make -C buildroot_rv32 opensbi-rebuild
	mkdir -p $(MRAM_IMAGE_DIR)
	# NOTE: Since RV32 rootfs is restricted to 64MiB we have to use the compressed squashfs here
	cp buildroot_rv32/output/images/rootfs.squashfs $(MRAM_IMAGE_DIR)/mram_rv32_root.img
	@touch $@

.stamp/buildroot_rv64_build: .stamp/buildroot_get_sources
	@echo " + BUILD BUILDROOT FOR RV64"
	make -C buildroot_rv64
	make -C buildroot_rv64 opensbi-rebuild
	mkdir -p $(MRAM_IMAGE_DIR)
	cp buildroot_rv64/output/images/rootfs.romfs $(MRAM_IMAGE_DIR)/mram_rv64_root.img
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
	buildroot_rv32/$(BR_DTC) $< -o $@

dt/linux-vp_rv64_sc.dtb: dt/linux-vp_rv64_sc.dts .stamp/buildroot_rv64_build
	@echo " + CREATE VP RV64 SINGLECORE DTB: $@"
	buildroot_rv64/$(BR_DTC) $< -o $@

dt/linux-vp_rv32_mc.dtb: dt/linux-vp_rv32_mc.dts .stamp/buildroot_rv32_build
	@echo " + CREATE VP RV32 MULTICORE DTB: $@"
	buildroot_rv32/$(BR_DTC) $< -o $@

dt/linux-vp_rv64_mc.dtb: dt/linux-vp_rv64_mc.dts .stamp/buildroot_rv64_build
	@echo " + CREATE VP RV64 MULTICORE DTB: $@"
	buildroot_rv64/$(BR_DTC) $< -o $@
