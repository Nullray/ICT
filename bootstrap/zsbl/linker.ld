SECTIONS
{
    ROM_BASE = 0x10000;

    . = ROM_BASE;
    .text.init : { *(.text.init) }
    .text : { *(.text) }
    .data : { *(.data) }
}

INCLUDE sanctum_params.lds
