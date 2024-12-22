.code16

.section ".loaderstage1", "ax", @progbits
romsize = 0x04

_start:

_init:

	.byte	0x55
	.byte	0xaa
_romsize:
	.byte	romsize
	jmp	_init_code

	.fill	0x18 - (. - _start), 1, 0
	.word	_pci_data_struct

	.fill	0x1a - (. - _start), 1, 0
	.word	_pnp_header

_pci_data_struct:
	.ascii	"PCIR"
	.word	0x10ec
	.word	0x8139
	.word	0x0
	.word	0x18
	.byte	0x0
	.byte	0x02
	.byte	0x0
	.byte	0x0
	.word	romsize
	.word	0x0
	.byte	0x0
	.byte	0x80
	.word	0x0

_pnp_header:
	.ascii	"$PnP"
	.byte	0x01
	.byte	0x02
	.word	0x0
	.byte	0x0
	.byte	0x7a
	.long	0x0
	.word	_manufacture_str
	.word	_product_str
	.byte	0x02, 0x0, 0x0
	.byte	0x14
	.word	0x0
	.word	0x0
	.word	_boot_entry
	.word	0x0
	.word	0x0

_manufacture_str:
	.ascii	"Pinczakko Corporation"
	.byte	0x0

_product_str:
	.ascii	"Realtek Hacked ROM"
	.byte	0x0

_init_code:
	mov	%cs, %ax
	mov	%ax, %ds
	lea	_bios_init_msg, %si
	call	_disp_str
	
	mov	$0x20, %ax
	retf

	mov	$_romsize, %bx
	xor	%ax, %ax
	mov	%ax, (%bx)
	or	$0x20, %ax
	lret

_bios_init_msg:
	.byte	10, 13
	.ascii	"PCI expansion rom initialization called..."
	.byte	10, 13
	.byte	'$'

_disp_str:
	cld
__do_disp:
	lodsb
	cmp	$'$', %al
	je	__done_disp
	mov	$0x0e, %ah
	mov	$0x07, %bx
	int	$0x10
	jmp	__do_disp
__done_disp:
	ret

_boot_entry:
	mov	%cs, %ax
	mov	%ax, %es
	mov	%ax, %ds
	lea	_pnp_msg, %si
	call	_disp_str
	mov	$0x0, %ah
	int	$0x16

_boot_code:
	cli
	mov	$_code_seg, %ax
	mov	%ax, %es
	mov	$_code_offset, %ax
	mov	%ax, %di
	lea	_code_start, %si
	cld

	xor	%ecx, %ecx
	mov	$_code_size_word, %ecx

_move_code:
	lodsw
	stosw
	loop	_move_code

	mov	%cs, %ax
	mov	%ax, %es
	xor	%di, %di

	ljmp	$_code_seg, $_code_offset

_pnp_msg:
	.byte	10,13
	.ascii	"PnP BEV Routine Invoked!"
	.byte	10,13
	.byte	'>'
	.byte	'$'

_code_seg = 0x07c0
_code_offset = 0x0
_code_size_word = (romsize - 1 ) * 512 / 2

	.fill	512 - (. - _start), 1, 0
_end:
_code_start:

