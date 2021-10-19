// See LICENSE for license details.

#ifndef _SERVE_PLATFORM_H
#define _SERVE_PLATFORM_H

/****************************************************************************
 * Platform definitions
 *****************************************************************************/

// Memory map
#define STACK_OFFSET 0x100000

#define CH_FIFO		0x30
#define CH_STAT		0x2C

//GPIO base address and offset
#define GPIO_BASE	0xF7FF0000

#define BTN_OFFSET	0x0
#define SW_OFFSET	0x4

//CLINT ctrl registers
#define CLINT_CTRL_ADDR		0x2000000

// IOF masks

#define UART_TXFIFO_FULL	(1 << 4)

#define GPIO_BTN_0_MASK	(1 << 0) 
#define GPIO_BTN_1_MASK	(1 << 1) 
#define GPIO_BTN_3_MASK	(1 << 2)
#define GPIO_BTN_4_MASK	(1 << 3)

#define GPIO_SW_0_MASK	(1 << 0)
#define GPIO_SW_1_MASK	(1 << 1)

// Helper functions
#define _REG32(p, i) (*(volatile unsigned int *)((p) + (i)))

#define UART_REG(offset) _REG32(UART_BASE, offset)
#define GPIO_REG(offset) _REG32(GPIO_BASE, offset)

#endif /* _SERVE_PLATFORM_H */
