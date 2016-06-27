#include <stdio.h>
#include <memory.h>
#include "rectange.h"

int main(int argc, char *argv[])
{
	int i;
	int size = 0;
	unsigned short key[] = { 0, 0, 0, 0, 0 };
	unsigned short roundSubkey[26][4];
	memset(roundSubkey, 0, sizeof(unsigned short) * 26 * 4);

	generateRoundKeys80(key, roundSubkey);

	if (argc > 1 && strcmp(argv[1], "-size") == 0)
	{
		size = 1;
	}

	printf("roundkeys:\n\n");
	for (i = 0; i < 26; i++)
	{
		if (size)
		{
			printf("// roundkey %d \n", i);
			printf(".word 0x%04X%04X \n", roundSubkey[i][1], roundSubkey[i][0]);
			printf(".word 0x%04X%04X \n", roundSubkey[i][3], roundSubkey[i][2]);
			printf("\n");
		}
		else
		{
			printf("// roundkey %d \n", i);
			printf(".word 0x%04X%04X \n", roundSubkey[i][0], roundSubkey[i][0]);
			printf(".word 0x%04X%04X \n", roundSubkey[i][1], roundSubkey[i][1]);
			printf(".word 0x%04X%04X \n", roundSubkey[i][2], roundSubkey[i][2]);
			printf(".word 0x%04X%04X \n", roundSubkey[i][3], roundSubkey[i][3]);
			printf("\n");
		}
	}

	return 0;
}
