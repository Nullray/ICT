// See LICENSE for license details.

#include "platform.h"

char banner[] = "RISC-V Execution in BootROM...\n\rPassing Control to RISC-V Berkeley Boot Loader(BBL)...\n\r";

char hangmsg[] = "RISC-V Debugging Mode\n\r";

#define PAUSE_REQ (GPIO_REG(SW_OFFSET) & GPIO_SW_0_MASK)

static inline void _putc(char c) 
{
    while(UART_REG(CH_STAT) & UART_TXFIFO_FULL);
    UART_REG(CH_FIFO) = c;
}

static inline void prints(char *s) {
    char c;
    while (c = *s++)
        _putc(c);
}

int _print()
{
    if (PAUSE_REQ) {
        prints(hangmsg);
        while (PAUSE_REQ) {
        //    __asm__ volatile ("wfi");
			;
        }
    }

    prints(banner);

    return 0;
}
