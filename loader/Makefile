##########################################################################################
# This makefile builds the first stage and second stage bootloader, it also 
# merge them into a complete kernel loader
# Note: $(ASM) is a variant of nasm, be it nasmw(in windows) or nasm (in Linux)
##########################################################################################

include ../var.mak

ASM_FLAGS= -fbin
LOADER_OBJS=loader1.o loader2.o
LOADER_LDS=load1.lds load2.lds

all: $(KERNEL_LOADER)
	ls -l $(KERNEL_LOADER)

$(KERNEL_LOADER): $(FIRST_STAGE_LOADER) $(SECOND_STAGE_LOADER)
	cat $(FIRST_STAGE_LOADER) $(SECOND_STAGE_LOADER) > $(KERNEL_LOADER)

$(FIRST_STAGE_LOADER): loader1.o loader1.lds
	ld -T loader1.lds -o $@ $<

$(SECOND_STAGE_LOADER): loader2.o loader2.lds
	ld -T loader2.lds -o $@ $<

allraw: $(FIRST_STAGE_LOADER) $(SECOND_STAGE_LOADER) $(LOADER_OBJS)
	cp ../$(UTILS_DIR)/$(MERGEBIN) .
	./$(MERGEBIN) $(FIRST_STAGE_LOADER) $(SECOND_STAGE_LOADER) $(KERNEL_LOADER)

raw.$(FIRST_STAGE_LOADER): loader1.asm
	$(ASM) $(ASM_FLAGS) $< -o $@

raw.$(SECOND_STAGE_LOADER): loader2.asm
	$(ASM) $(ASM_FLAGS) $< -o $@

loader1.o: loader1.s
	gcc -g -m32 -c -o $@ $<

loader2.o: loader2.s
	gcc -g -m32 -c -o $@ $<

clean:
	rm -rf *.bin $(MERGEBIN) ??? *.o

BINSEGSIZE=204

dump: loader1.bin
	dd if=loader1.bin of=l1n.bin bs=$(BINSEGSIZE) skip=1
	dd if=loader2.bin of=l2n.bin bs=$(BINSEGSIZE) skip=1

	objdump -b binary -m i8086 -d -D loader1.bin > qqq
	objdump -b binary -m i8086 -d -D loader2.bin > fff

	hd loader1.bin > aaa
	hd loader2.bin > bbb
