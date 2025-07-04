#!/bin/bash

TYPE="$1"
NUM_CORES="$2"
MEM_SIZE="$3"

usage() {
	echo "Usage: $0 rv32|rv64 <num worker cores> <memory-size>"
}

cd $(dirname $0)

RISCV_ISA_EXTENSIONS_CPU0="i m a c zicntr zicsr zifencei"
RISCV_ISA_EXTENSIONS="i m a f d c v zicntr zicsr zifencei"

if [[ $TYPE == rv32 ]] ; then
	RISCV_ISA_BASE="rv32i"
	MMU_TYPE="riscv,sv32"

	# on RV32 linux vmalloc size is very limited
	# -> only small memory areas (images sizes) possible
	ROOTFSTYPE="squashfs"
	MRAM_SIZE="0x4000000"	# 64MiB

elif [[ $TYPE == rv64 ]] ; then
	RISCV_ISA_BASE="rv64i"
	MMU_TYPE="riscv,sv39"
	ROOTFSTYPE="squashfs"
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

if [[ -z $MEM_SIZE ]] ; then
	echo "Missing memory size!"
	usage
	exit 1
fi

# args:
#  * isa base (e.g. "rv32i")
#  * isa extensions (e.g. "i m a c zicntr")
# result on stdout
gen_riscv_isa_dt() {
	local isa_base=$1
	local isa_ext=$2

	res="$isa_base"
	for e in $isa_ext ; do
		[[ $e == "i" ]] && continue
		if [[ ${#e} == 1 ]] ; then
			res+="$e"
		else
			res+="_$e"
		fi
	done
	echo "$res"
}

# args:
#  * isa base (e.g. "rv32i")
#  * isa extensions (e.g. "i m a c zicntr")
# result on stdout
gen_riscv_isa_extensions_dt() {
	local isa_ext=$2
	echo "\"${isa_ext// /\", \"}\""
}
	
RISCV_ISA_CPU0_DT="$(gen_riscv_isa_dt ${RISCV_ISA_BASE} "${RISCV_ISA_EXTENSIONS_CPU0}")"
RISCV_ISA_DT="$(gen_riscv_isa_dt ${RISCV_ISA_BASE} "${RISCV_ISA_EXTENSIONS_CPU0}")"
RISCV_ISA_EXTENSIONS_CPU0_DT="$(gen_riscv_isa_extensions_dt ${RISCV_ISA_BASE} "${RISCV_ISA_EXTENSIONS_CPU0}")"
RISCV_ISA_EXTENSIONS_DT="$(gen_riscv_isa_extensions_dt ${RISCV_ISA_BASE} "${RISCV_ISA_EXTENSIONS}")"

MEM_SIZE_DT="$(printf "0x%X 0x%.8X" $((MEM_SIZE>>32)) $((MEM_SIZE & ((1<<32)-1))))"

CPUS_TEMP=$(mktemp)

PLIC_INT_EXT="\n\t\t\t\t<\&cpu0_intc 0xffffffff>"
CLINT_INT_EXT="\n\t\t\t\t<\&cpu0_intc 3>, <\&cpu0_intc 7>"
CPU_MAP=""
for cpu_nr in $(seq 1 $NUM_CORES) ; do
	cat linux-vp_cpu.dts.in | sed											\
		-e "s/@CPU_NR@/$cpu_nr/g"											\
		-e "s/@RISCV_ISA_DT@/\"$RISCV_ISA_DT\"/g"							\
		-e "s/@RISCV_ISA_BASE@/\"$RISCV_ISA_BASE\"/g"						\
		-e "s/@RISCV_ISA_EXTENSIONS_DT@/$RISCV_ISA_EXTENSIONS_DT/g"			\
		-e "s/@MMU_TYPE@/\"$MMU_TYPE\"/g"									\
		>> $CPUS_TEMP
	CPU_MAP+="\n"
	CPU_MAP+="\t\t\t\tcore${cpu_nr} {\n"
	CPU_MAP+="\t\t\t\t\tcpu = <\&cpu${cpu_nr}>;\n"
	CPU_MAP+="\t\t\t\t};\n"
	CLINT_INT_EXT+=",\n\t\t\t\t<\&cpu${cpu_nr}_intc 3>, <\&cpu${cpu_nr}_intc 7>"
	PLIC_INT_EXT+=",\n\t\t\t\t<\&cpu${cpu_nr}_intc 0xffffffff>, <\&cpu${cpu_nr}_intc 9>"
done

cat linux-vp_base.dts.in | sed \
	-e "/\@CPUS\@/{
		s/\@CPUS\@//g
		r $CPUS_TEMP
	}" \
	-e "s/@RISCV_ISA_CPU0_DT@/\"$RISCV_ISA_CPU0_DT\"/g"						\
	-e "s/@RISCV_ISA_DT@/\"$RISCV_ISA_DT\"/g"								\
	-e "s/@RISCV_ISA_BASE@/\"$RISCV_ISA_BASE\"/g"							\
	-e "s/@RISCV_ISA_EXTENSIONS_DT@/\"$RISCV_ISA_EXTENSIONS_DT\"/g"			\
	-e "s/@RISCV_ISA_EXTENSIONS_CPU0_DT@/$RISCV_ISA_EXTENSIONS_CPU0_DT/g"	\
	-e "s/@CPU_MAP@/$CPU_MAP/g"												\
	-e "s/@ROOTFSTYPE@/$ROOTFSTYPE/g"										\
	-e "s/@MEM_SIZE_DT@/$MEM_SIZE_DT/g"										\
	-e "s/@MRAM_SIZE@/$MRAM_SIZE/g"											\
	-e "s/@CLINT_INT_EXT@/$CLINT_INT_EXT/g"									\
	-e "s/@PLIC_INT_EXT@/$PLIC_INT_EXT/g"									\

rm -rf $CPUS_TEMP
