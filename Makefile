#################################################################
#this is the makefile that controls the build of my kernel
#which is executed from the PCI expansion/option ROM
#of a Realtek 8139A based ethernet card 
#First build of this makefile: Feb 03, 2004
##################################################################

include var.mak

all: build

build: 
	$(MAKE) -C $(UTILS_DIR) all
	$(MAKE) -C $(LOADER_DIR) all
	$(MAKE) -C $(KERNEL_DIR) all
#	cp ./$(KERNEL_DIR)/$(KERNEL_BIN_RAW) .
#	cp ./$(LOADER_DIR)/$(KERNEL_LOADER) .
#	cp ./$(UTILS_DIR)/$(MERGEBIN) .
#	cp ./$(UTILS_DIR)/$(PATCH2PNPROM) .
#	./$(MERGEBIN) $(KERNEL_LOADER) $(KERNEL_BIN) $(ROM_BIN) 
	dd if=/dev/zero bs=$(ROM_SIZE) count=1 of=tempzeroblock
	cat ./$(LOADER_DIR)/$(KERNEL_LOADER) ./$(KERNEL_DIR)/$(KERNEL_BIN_RAW) tempzeroblock > boot.bin.raw
	dd if=boot.bin.raw bs=$(ROM_SIZE) count=1 of=$(ROM_BIN)
	rm -v boot.bin.raw tempzeroblock
	./$(UTILS_DIR)/$(PATCH2PNPROM) $(ROM_BIN)

clean:
	$(MAKE) -C $(UTILS_DIR) clean
	$(MAKE) -C $(LOADER_DIR) clean
	$(MAKE) -C $(KERNEL_DIR) clean
	rm $(MERGEBIN) $(PATCH2PNPROM) *.bin

test: build
	qemu -netdev id=extnet,type=user -device rtl8139,bootindex=0,romfile=boot.bin,netdev=extnet -vnc reverse=on,vnc=192.168.5.248:5500 -monitor stdio

debug: build
	qemu-system-i386 -s -S -netdev id=extnet,type=user -device rtl8139,bootindex=0,romfile=boot.bin,netdev=extnet -vnc reverse=on,vnc=192.168.5.248:5500 -monitor stdio
