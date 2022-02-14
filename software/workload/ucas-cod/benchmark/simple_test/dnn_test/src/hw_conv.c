#include "printf.h"
#include "trap.h"

#define GPIO_START_ADDR		0x40040000
#define GPIO_DONE_ADDR		0x40040008

int main()
{
	volatile int* gpio_start = (void*)(GPIO_START_ADDR);
	volatile int* gpio_done = (void*)(GPIO_DONE_ADDR);

	printf("Launching task...\n");
	*gpio_start = 1;
	*gpio_start = 0;

	while(*(gpio_done) != 1);
	printf("FPGA acceleration done\n");

	return 0;
}
