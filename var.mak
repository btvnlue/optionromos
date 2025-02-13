#
# This is the variables used during make
#

#ROM related make variables
ROM_BIN=boot.bin
ROM_SIZE=65536
KERNEL_DIR=kernel
KERNEL_BIN=kernel.bin
KERNEL_BIN_RAW=kernel.bin.raw
LOADER_DIR=loader
FIRST_STAGE_LOADER=loader1.bin
SECOND_STAGE_LOADER=loader2.bin
KERNEL_LOADER=loader.bin #a.k.a pzos.bin

#utilities related make variables
UTILS_DIR=utility
ZEROEXTEND=zeroextend
MERGEBIN=mergebin
PATCH2PNPROM=patch2pnprom

#NASM related variable
ASM=nasm
