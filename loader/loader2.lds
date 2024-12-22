OUTPUT_FORMAT("binary")
OUTPUT_ARCH("i386")

SECTIONS {
	. = 0x7c00;
	.loader2 : { *(.loaderstage2) }
}
