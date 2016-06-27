#include "binaryutil.h"
#include <stdio.h>

void printbinary(unsigned short value)
{
	int i;
	for (i = 15; i >= 0; i--)
	{
		printf("%d", ((value >> i) & 0x1));
	}
	printf("\n");
}

void printhex(unsigned short value)
{
	printf("%X\n", value);
}
