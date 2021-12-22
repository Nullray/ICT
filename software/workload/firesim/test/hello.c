/**
 * Modified from https://raw.githubusercontent.com/mludvig/mini-printf/master/test1.c
 */
#include "printu.h"

int main(void)
{
	printu("Hello World\n");
	printu("testing %d %d %07d\n", 1, 2, 3);
	printu("faster %s %ccheaper%c\n", "and", 34, 34);
	printu("%x %% %X\n", 0xdeadf00d, 0xdeadf00d);
	printu("%09d%09d%09d%09d%09d\n", 1, 2, 3, 4, 5);
	printu("%d %u %d %u\n", 50, 50, -50, -50);
	return 0;
}
