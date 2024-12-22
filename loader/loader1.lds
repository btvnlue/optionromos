OUTPUT_FORMAT("binary")
OUTPUT_ARCH("i386")

SECTIONS {
	. = 0;
	.loader1 : { *(.loaderstage1) }
}
