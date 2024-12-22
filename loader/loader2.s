.code16

.section ".loaderstage2", "ax", @progbits

_code_start:

	mov	%cs, %ax
	mov	%ax, %ds
	mov	%ax, %es

	mov	$_code_loaded_msg - _code_start, %si
	call	_disp_str
	
	mov	$0x0, %ah
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
	.ascii	"Gate A20 enabled !"
	.byte	10, 13
	.byte	'>'
	.byte	'$'

_enable_a20:
	
	cli

	call	_a20wait_a
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
	sti
	mov	$_a20_enabled_msg - _code_start, %si
	call	_disp_str
	mov	$0x0, %ah
	int	$0x16

_enable_pmode:
	cli
	lgdt	_gdt_desc - _code_start

	mov	%cr0, %eax
	or	$0x1, %eax
	mov	%eax, %cr0

	ljmp	$gdt_code_seg, $_core_pmode

.code32

_core_pmode:

	xor	%esi, %esi
	xor	%edi, %edi
	mov	$0x10,%eax
	mov	%eax, %ds
	mov	$0x18, %eax
	mov	%eax, %ss
	mov	$0x90000, %esp

	movb	$'P', %ds:0xb8000
	movb	$0x9b, %ds:0xb8001
	movb	$'-', %ds:0xb8002
	movb	$0x9b, %ds:0xb8003
	movb	$'M', %ds:0xb8004
	movb	$0x9b, %ds:0xb8005
	movb	$'O', %ds:0xb8006
	movb	$0x9b, %ds:0xb8007
	movb	$'D', %ds:0xb8008
	movb	$0x9b, %ds:0xb8009
	movb	$'E', %ds:0xb800a
	movb	$0x9b, %ds:0xb800b

	ljmp	$gdt_code_seg, $0x7e00

_gdt_def:
	.word	0x0
	.word	0x0
	.byte	0x0, 0x0, 0x0, 0x0

gdt_code_seg = . - _gdt_def

_gdt_seg1:
	.word	0xffff
	.word	0x0
	.byte	0x0
	.byte	0x9a
	.byte	0xcf
	.byte	0x0

gdt_data_seg = . - _gdt_def

_gdt_seg2:
	.word	0xffff
	.word	0x0
	.byte	0x0
	.byte	0x92
	.byte	0xcf
	.byte	0x0

gdt_stack_seg = . - _gdt_def

_gdt_seg3:
	.word	0xffff
	.word	0x0
	.byte	0x0
	.byte	0x92
	.byte	0xcf
	.byte	0x0
_gdt_def_end:

_dummy_text:
	.ascii	"mmmmmm"
_gdt_desc:
	.word	_gdt_def_end - _gdt_def - 1
	.long	_gdt_def

	.fill 512 - ( . - _code_start )
