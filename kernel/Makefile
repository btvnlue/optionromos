########################################################
# makefile for generating the 32-bit protected kernel 
# 
#######################################################

include ../var.mak

CC= gcc
ENTRYPOINT_CFLAGS= -ffreestanding -c -g -fno-pie -m32
CFLAGS= -c -g -fno-pie -m32
LD= ld
LOADER_SIZE:=$(shell stat -L -c %s ../loader/loader2.bin)
BASE_ADDRESS=0x8000
KERNEL_LDFLAGS= -m elf_i386 -s -Ttext $(BASE_ADDRESS) -e main -N --oformat binary
#KERNEL_ROMSIZE=65536
KERNEL_BIN_RAW=$(KERNEL_BIN).raw

all: main.o video.o ports.o
	$(LD) -o $(KERNEL_BIN_RAW) $(KERNEL_LDFLAGS) main.o video.o ports.o
#	cp ../$(UTILS_DIR)/$(ZEROEXTEND) .
#	dd if=/dev/zero bs=$(KERNEL_ROMSIZE) count=1 | cat $(KERNEL_BIN_RAW) - | dd bs=$(KERNEL_ROMSIZE) count=1 of=$(KERNEL_BIN)
#	./$(ZEROEXTEND) $(KERNEL_BIN) $(KERNEL_ROMSIZE)
	
video.o: video.c
	$(CC) $(CFLAGS) -o $@ $<

ports.o: ports.c
	$(CC) $(CFLAGS) -o $@ $<

main.o: main.c
	$(CC) $(ENTRYPOINT_CFLAGS) -o $@ $<

clean:
	rm -rf *.bin *.raw *.o 

%.s: %.c
	$(CC) -S $(CFLAGS) -o $@ $<

assembly: main.s video.s ports.s
