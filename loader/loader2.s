###########################################################
# Entry code execute from 07c0:0000
# 16bit(s) code instruments
###########################################################

.code16

.section ".loaderstage2", "ax", @progbits

_code_start:

	mov	%cs, %ax                                        ## Sync DS, ES
	mov	%ax, %ds
	mov	%ax, %es

	mov	$_code_loaded_msg - _code_start, %si            ## offset of message
	call	_disp_str
	
	mov	$0x0, %ah                                       ## Wait key input
	int	$0x16

	jmp	_enable_a20

_disp_str:
        cld
__do_disp:
        lodsb
        cmp     $'$', %al
        je      __done_disp
        mov     $0x0e, %ah
        mov     $0x07, %bx
        int     $0x10
        jmp     __do_disp
__done_disp:
        ret

_code_loaded_msg:
	.byte	10, 13
	.ascii	"Operating System Loaded!"
	.byte	10, 13
	.byte	'>'
	.byte	'$'

_a20_enabled_msg:
	.byte	10, 13
	.ascii	"Gate A20 enabled!"
	.byte	10, 13
	.byte	'>'
	.byte	'$'

_enable_a20:
	
	cli                                                      ## Disable interrupts

	call	_a20wait_a                                       ## Enable A20 by following IBM instructions
	mov	$0xad, %al
	out	%al, $0x64

	call	_a20wait_a
	mov	$0xd0, %al
	out	%al, $0x64

	call	_a20wait_b
	in	$0x60, %al
	push	%eax

	call	_a20wait_a
	mov	$0xd1, %al
	out	%al, $0x64

	call	_a20wait_a
	pop	%eax
	or	$0x2, %al
	out	%al, $0x60

	call	_a20wait_a
	mov	$0xae, %al
	out	%al, $0x64

	call	_a20wait_a
	jmp	_done_a20

_a20wait_a:
_awla0:
	mov	$65536, %ecx
_awla1:
	in	$0x64, %al
	test	$2, %al
	jz	_awla2
	loop	_awla1
	jmp	_awla0
_awla2:
	ret

_a20wait_b:
_awlb0:
	mov	$65536, %ecx
_awlb1:
	in	$0x64, %al
	test	$1, %al
	jnz	_awlb2
	loop	_awlb1
	jmp	_awlb0
_awlb2:
	ret

_done_a20:
	sti                                                     ## Enable interrupts
	mov	$_a20_enabled_msg - _code_start, %si
	call	_disp_str
	mov	$0x0, %ah
	int	$0x16

_enable_pmode:
	cli                                                     ## Setup GDT, disable interrupts
	lgdt	_gdt_desc - _code_start	                        ## GDTR setup

	mov	%cr0, %eax                                      ## Enable GDT in CR0
	or	$0x1, %eax
	mov	%eax, %cr0

	ljmp	$gdt_code_seg, $_core_pmode

############################################
# 32bit code main
############################################

.code32

_core_pmode:

	xor	%esi, %esi
	xor	%edi, %edi
	mov	$0x10,%eax                                      ## seg #2 in gdt descriptor
	mov	%eax, %ds
	mov	$0x18, %eax                                     ## seg #3 in gdt descriptor
	mov	%eax, %ss
	mov	$0x90000, %esp                                  ## stack location 90000h

# Output to VGA video buffer b8000/color, b0000/mono

	mov	$0x18, %ecx
_local_disp:
	lea	_pmode_msg, %esi	
	call	_disp_str_pmode
	loop	_local_disp
_local_loop:
#	jmp	_local_loop

#	ljmp	$gdt_code_seg, $0x7e00                           ## jump to C code kernel
	ljmp	$gdt_code_seg, $_kernel_start                           ## jump to C code kernel

_disp_str_pmode:
        cld
__do_disp_pmode:
        lodsb
        cmp     $'$', %al
        je      __done_disp_pmode
	call	_disp_pmode_ee
        jmp     __do_disp_pmode
__done_disp_pmode:
        ret

_pmode_msg:
	.ascii	"P-Mode3"
	.byte	10,13,'$'

# _disp_pmode_cc:	
# 	mov	$'P', %al	
# 	call	_disp_pmode_bb
# 	mov	$'-', %al	
# 	call	_disp_pmode_bb
# 	mov	$'M', %al	
# 	call	_disp_pmode_bb
# 	mov	$'o', %al	
# 	call	_disp_pmode_bb
# 	mov	$'d', %al	
# 	call	_disp_pmode_bb
# 	mov	$'e', %al	
# 	call	_disp_pmode_bb
# 	ret

_disp_pmode_ee:
	mov	$gdt_video_seg, %edx
	mov	%edx, %es
	movl	video_offset, %ebx
	movb	%al, %es:(%ebx)
	incl	video_offset

	movl	video_offset, %ebx
	movb	$0x9b, %es:(%ebx)
	incl	video_offset
	ret

# _disp_pmode_bb:
# 	mov	$0xb8000, %ebx
# 	addl	video_offset, %ebx
# 	movb	%al, %ds:(%ebx)
# 	incl	video_offset
# 
# 	mov	$0xb8000, %ebx
# 	addl	video_offset, %ebx
# 	movb	$0x9b, %ds:(%ebx)
# 	incl	video_offset
# 	ret

# _disp_pmode_aa:
# 	movb	$'P', %ds:0xb8000                               ## put into video memory
# 	movb	$0x9b, %ds:0xb8001                              ## text attribute
# 	movb	$'-', %ds:0xb8002
# 	movb	$0x9b, %ds:0xb8003
# 	movb	$'M', %ds:0xb8004
# 	movb	$0x9b, %ds:0xb8005
# 	movb	$'O', %ds:0xb8006
# 	movb	$0x9b, %ds:0xb8007
# 	movb	$'D', %ds:0xb8008
# 	movb	$0x9b, %ds:0xb8009
# 	movb	$'E', %ds:0xb800a
# 	movb	$0x9b, %ds:0xb800b
# 	ret


video_offset:	.long	0

.align 4                                                         ## GDT address 4 byte aligned

_gdt_def:                                                        ## dummy descriptor
	.word	0x0
	.word	0x0
	.byte	0x0, 0x0, 0x0, 0x0

gdt_code_seg = . - _gdt_def

_gdt_seg1:
	.word	0xffff                                           ## seg_length_0-15
	.word	0x0                                              ## base_addr_0-15
	.byte	0x0                                              ## base_addr_16-23
	.byte	0x9a                                             ## flags
	.byte	0xcf                                             ## access
	.byte	0x0                                              ## base_addr_24-31

gdt_data_seg = . - _gdt_def

_gdt_seg2:
	.word	0xffff                                           ## seg_length_0-15
	.word	0x0                                              ## base_addr_0-15
	.byte	0x0                                              ## base_addr_16-23
	.byte	0x92                                             ## flags
	.byte	0xcf                                             ## access
	.byte	0x0                                              ## base_addr_24-31

gdt_stack_seg = . - _gdt_def

_gdt_seg3:
	.word	0xffff                                           ## seg_length_0-15
	.word	0x0                                              ## base_addr_0-15
	.byte	0x0                                              ## base_addr_16-23
	.byte	0x92                                             ## flags
	.byte	0xcf                                             ## access
	.byte	0x0                                              ## base_addr_24-31

gdt_video_seg = . - _gdt_def

_gdt_seg4:
	.word	0xffff                                           ## seg_length_0-15
	.word	0x8000                                           ## base_addr_0-15
	.byte	0xb                                              ## base_addr_16-23
	.byte	0x92                                             ## flags
	.byte	0xcf                                             ## access
	.byte	0x0                                              ## base_addr_24-31
_gdt_def_end:

_gdt_desc:                                                       ## descriptor for LGDT
	.word	_gdt_def_end - _gdt_def - 1                      ## blocksize - 1
	.long	_gdt_def                                         ## definition address

	.fill 1024 - ( . - _code_start )
_kernel_start:
