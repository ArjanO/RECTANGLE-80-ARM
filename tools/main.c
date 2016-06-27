#include <stdio.h>
#include "rectange.h"
#include "binaryutil.h"

int main()
{
	int i;

	unsigned short key[] = { 0x0, 0x0, 0x0, 0x0, 0x0 };
	unsigned short data[] = { 0x0, 0x0, 0x0, 0x0 };

	printf("Key: \n");
	for (i = 0; i < 5; i++)
	{
		printbinary(key[i]);
	}

	printf("\nPlaintext: \n");
	for (i = 0; i < 4; i++)
	{
		printbinary(data[i]);
	}

	rec80encrypt(data, key);

	printf("\nEncrypted result: \n");
	for (i = 0; i < 4; i++)
	{
		printbinary(data[i]);
	}

	printf("\n\n");
	printhex(data[0]);
	printhex(data[1]);
	printhex(data[2]);
	printhex(data[3]);
	printf("");

	key[0] = 0;
	key[1] = 0;
	key[2] = 0;
	key[3] = 0;
	key[4] = 0;

	rec80decrypt(data, key);

	printf("\nDecrypted result: \n");
	for (i = 0; i < 4; i++)
	{
		printbinary(data[i]);
	}

	return 0;
}
