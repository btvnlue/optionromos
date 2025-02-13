###########################################################
# This code is based on Darmawan-MS/Pinczakko Expansion-ROM-OS project
# Code is revised to GNU assembly with AT&T format.
# (Reference to loader1.asm for original code with NASM compiler environment.)
#
# Code shall be compile into binary format, loader1 and loader2 fit into 512 byte(s) each.
# _init_code : The entry of BIOS call for OptionROM initialization,
#              this is entry/process OptionROM can setup it self. Far return to BIOS, and mark AX = 0x20
# _boot_entry : Boot entry loaded by BIOS, the actual OS (level) loading entry defined in _pnp_header:BEV
#               This rom act as LAN network bios, uses BEV as booting entry.
#               Simulate Video/Storage device need switch to BCV entry instead
###########################################################

# BIOS load code in 16bit format/intructions
.code16

# section mark for linker script
# "ax" as execution

.section ".loaderstage1", "ax", @progbits

# rom size * 512 (bytes)
# loader1 = 512
# loader2 = 512
# kernel = C code

romsize = 0x80

_start:

_init:

# rom magic signature, 0x55 0xAA
        .byte   0x55
        .byte   0xaa
_romsize:
        .byte   romsize ## romsize * 512 (bytes)
        jmp     _init_code ## near jump to initialization

#        .fill   0x18 - (. - _start), 1, 0
	.zero	0x18 - (. - _start)
        .word   _pci_data_struct ## pointer to PCI Header, @18h

#        .fill   0x1a - (. - _start), 1, 0
	.zero	0x1a - (. - _start)
        .word   _pnp_header ## pointer to pnp header, @1Ah

#################################
# PCI data structure
#################################

_pci_data_struct:
        .ascii  "PCIR"                                     ## PCI header singature
        .word   0x10ec                                     ## Vendor ID
        .word   0x8139                                     ## Device ID
        .word   0x0                                        ## VPD
        .word   0x18                                                                               ## PCI Data struct length (byte)
        .byte   0x0                                                                                ## Rev
        .byte   0x02                                                                               ## Base class, 02h = Network Controller
        .byte   0x0                                                                                ## Sub class, 00h = Ethernet Controller
        .byte   0x0                                                                                ## Interface code, PCI Spec Rev2.2, Appendix D
        .word   romsize                                                                            ## size * 512 (byte), little endian format
        .word   0x0                                                                                ## Rev
        .byte   0x0                                                                                ## Code type, 00h = x86
        .byte   0x80                                                                               ## Last image indicator
        .word   0x0                                                                                ## Rev

#################################
# PnP ROM header structure
#################################

_pnp_header:
        .ascii  "$PnP"                                                                                  ## PnP Rom header signature
        .byte   0x01                                                                                    ## Structure Revision
        .byte   0x02                                                                                    ## Header structure length, size * 16 (bytes)
        .word   0x0                                                                                     ##  Offset to next header, 00h : None
        .byte   0x0                                                                                     ## Rev
        .byte   0x7a                                                                                    ## 8bit checksum, update after compile
        .long   0x0                                                                                     ## PnP Device ID, 00h : (in Realtek RPL ROM)
        .word   _manufacture_str                                                                        ## Pointer to manufacturer string
        .word   _product_str                                                                            ##  Pointer to product string
        .byte   0x02, 0x0, 0x0                                                                          ## Device Type, 3 bytes
        .byte   0x14                                                                                    ## Device Indicator, Reference to PnP BIOS spec.
        .word   0x0                                                                                     ## Book Connection Vector, 00h = Disabled
        .word   0x0                                                                                     ## Disconnect Vector, 00h = Disabled
        .word   _boot_entry                                                                             ## Bootstrap Entry Vector (BEV)
        .word   0x0                                                                                     ## Rev
        .word   0x0                                                                                     ## Static resource information vector, 0000h = Unused

_manufacture_str:
        .ascii  "Pinczakko Corporation"
        .byte   0x0

_product_str:
        .ascii  "Realtek Hacked ROM"
        .byte   0x0

_init_code:
        mov     %cs, %ax                                                      ## Sync DS
        mov     %ax, %ds
        lea     _bios_init_msg, %si                                           ## Display _init message
        call    _disp_str

        mov     $0x20, %ax                                                    ## return IPL device attached, PnP Spec Rev1.0
        retf                                                                  ## Far return to BIOS

        mov     $_romsize, %bx                                                ## Remove this section of code, stuck boot loading (BEV) in QEMU
        xor     %ax, %ax
        mov     %ax, (%bx)
        or      $0x20, %ax
        lret

_bios_init_msg:
        .byte   10, 13
        .ascii  "PCI expansion rom initialization called..."
        .byte   10, 13
        .byte   '$'

_disp_str:
        cld
__do_disp:
        lodsb                                                                 ## Load from SI
        cmp     $'$', %al
        je      __done_disp
        mov     $0x0e, %ah
        mov     $0x07, %bx
        int     $0x10
        jmp     __do_disp
__done_disp:
        ret

_boot_entry:
        mov     %cs, %ax                                                      ## Sync ES, DS
        mov     %ax, %es
        mov     %ax, %ds
        lea     _pnp_msg, %si
        call    _disp_str
        mov     $0x0, %ah
        int     $0x16                                                         ## Wait key input

_boot_code:
        cli                                                                   ## Copy code from _code_start --> 7C00h
        mov     $_code_seg, %ax
        mov     %ax, %es
        mov     $_code_offset, %ax
        mov     %ax, %di
        lea     _code_start, %si
        cld

        xor     %ecx, %ecx
        mov     $_code_size_word, %ecx                                        ## move code size from loader2 --> 7C00h

_move_code:
        lodsw
        stosw
        loop    _move_code

        mov     %cs, %ax
        mov     %ax, %es
        xor     %di, %di

        ljmp    $_code_seg, $_code_offset                                     ## Far jump to 07C0:0000h

_pnp_msg:
        .byte   10,13
        .ascii  "PnP BEV Routine Invoked!"
        .byte   10,13
        .byte   '>'
        .byte   '$'

_code_seg = 0x07c0
_code_offset = 0x0
_code_size_word = (romsize - 1 ) * 512 / 2                                    ## move code size from loader2, end of loader1

        .fill   512 - (. - _start), 1, 0
_end:
_code_start:
