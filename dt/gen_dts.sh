#!/bin/bash

TYPE="$1"
NUM_CORES="$2"

usage() {
	echo "Usage: $0 rv32|rv64 <num worker cores>"
}

cd $(dirname $0)

if [[ $TYPE == rv32 ]] ; then
	RISCV_ISA="rv32imafdc"
	MMU_TYPE="riscv-sv32"
	MEM_SIZE="0x40000000"
elif [[ $TYPE == rv64 ]] ; then
	RISCV_ISA="rv64imafdc"
	MMU_TYPE="riscv-sv48"
	MEM_SIZE="0x80000000"
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

CLINT_INT_EXT=""
PLIC_INT_EXT=""
status="disabled"
for i in $(seq 0 $NUM_CORES) ; do
	cat linux-vp_cpu.dts.in | sed			\
		-e "s/@CPU_NR@/$i/g"			\
		-e "s/@STATUS@/\"$status\"/g"		\
		-e "s/@RISCV_ISA@/\"$RISCV_ISA\"/g"	\
		-e "s/@MMU_TYPE@/\"$MMU_TYPE\"/g"	\
		>> $CPUS_TEMP
	CLINT_INT_EXT+="\n	\&CPU${i}_intc 3 \&CPU${i}_intc 7"
	PLIC_INT_EXT+="\n	\&CPU${i}_intc 11"
	if [[ $i != 0 ]] ; then
		PLIC_INT_EXT+=" \&CPU${i}_intc 9"
	fi
	# first cpu is always disabled
	status="okay"
done

cat linux-vp_base.dts.in | sed \
	-e "/\@CPUS\@/{
		s/\@CPUS\@//g
		r $CPUS_TEMP
	}" \
	-e "s/@MEM_SIZE@/$MEM_SIZE/g"			\
	-e "s/@CLINT_INT_EXT@/$CLINT_INT_EXT/g"		\
	-e "s/@PLIC_INT_EXT@/$PLIC_INT_EXT/g"		\

rm -rf $CPUS_TEMP
