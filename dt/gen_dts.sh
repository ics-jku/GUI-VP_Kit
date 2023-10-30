#!/bin/bash

TYPE="$1"
NUM_CORES="$2"

usage() {
	echo "Usage: $0 rv32|rv64 <num worker cores>"
}

cd $(dirname $0)

if [[ $TYPE == rv32 ]] ; then
	RISCV_ISA_CPU0="rv32imac"
	RISCV_ISA="rv32imafdc"
	MMU_TYPE="riscv,sv32"
	MEM_SIZE="0x40000000"	# 1 GiB

	# on RV32 linux vmalloc size is very limited
	# -> only small memory areas (images sizes) possible
	ROOTFSTYPE="squashfs"
	MRAM_SIZE="0x4000000"	# 64MiB

elif [[ $TYPE == rv64 ]] ; then
	RISCV_ISA_CPU0="rv64imac"
	RISCV_ISA="rv64imafdc"
	MMU_TYPE="riscv,sv39"
	MEM_SIZE="0x80000000"	# 2 GiB
	ROOTFSTYPE="romfs"
	MRAM_SIZE="0x20000000"	# 512MiB
else
	echo "Invalid type: \"$TYPE\"!"
	usage
	exit 1
fi

if [[ -z $NUM_CORES ]] ; then
	echo "Missing number of worker cores!"
	usage
	exit 1
fi

CPUS_TEMP=$(mktemp)

PLIC_INT_EXT="\n\t\t\t\t<\&cpu0_intc 0xffffffff>"
CPU_MAP=""
for cpu_nr in $(seq 1 $NUM_CORES) ; do
	cat linux-vp_cpu.dts.in | sed			\
		-e "s/@CPU_NR@/$cpu_nr/g"		\
		-e "s/@RISCV_ISA@/\"$RISCV_ISA\"/g"	\
		-e "s/@MMU_TYPE@/\"$MMU_TYPE\"/g"	\
		>> $CPUS_TEMP
	CPU_MAP+="\n"
	CPU_MAP+="\t\t\t\tcore${cpu_nr} {\n"
	CPU_MAP+="\t\t\t\t\tcpu = <\&cpu${cpu_nr}>;\n"
	CPU_MAP+="\t\t\t\t};\n"
	PLIC_INT_EXT+=",\n\t\t\t\t<\&cpu${cpu_nr}_intc 0xffffffff>, <\&cpu${cpu_nr}_intc 9>"
done

cat linux-vp_base.dts.in | sed \
	-e "/\@CPUS\@/{
		s/\@CPUS\@//g
		r $CPUS_TEMP
	}" \
	-e "s/@RISCV_ISA_CPU0@/\"$RISCV_ISA_CPU0\"/g"	\
	-e "s/@RISCV_ISA@/\"$RISCV_ISA\"/g"		\
	-e "s/@CPU_MAP@/$CPU_MAP/g"			\
	-e "s/@ROOTFSTYPE@/$ROOTFSTYPE/g"		\
	-e "s/@MEM_SIZE@/$MEM_SIZE/g"			\
	-e "s/@MRAM_SIZE@/$MRAM_SIZE/g"			\
	-e "s/@CLINT_INT_EXT@/$CLINT_INT_EXT/g"		\
	-e "s/@PLIC_INT_EXT@/$PLIC_INT_EXT/g"		\

rm -rf $CPUS_TEMP
