// Implementation RECTANGLE.
// See for paper RECTANGLE: A Bit-slice Lightweight Block Cipher Suitable for 
// Multiple Platforms: https://eprint.iacr.org/2014/084/20160106:055422
#include "rectange.h"
#include <stdio.h>
#include <memory.h>

typedef unsigned char byte;

char RC(char current);
void applySboxToColumn(unsigned short* pKey, int column);
void applySboxToColumnInt(unsigned int* pKey, int column);
unsigned short shiftLeftShort(unsigned short input, int left);
unsigned int shiftLeftInt(unsigned int input, int left);
unsigned short shiftRightShort(unsigned short input, int right);
void addRoundKey(unsigned short* pState, unsigned short* pRoundKey);
void subColumn(unsigned short* pState, byte* sbox);
void shiftRow(unsigned short* pState);
void shiftRowBack(unsigned short* pState);

byte sbox[16] = {
	0x6, 0x5, 0xC, 0xA,
	0x1, 0xE, 0x7, 0x9,
	0xB, 0x0, 0x3, 0xD,
	0x8, 0xF, 0x4, 0x2
};

byte rbox[16] = {
	0x9, 0x4, 0xF, 0xA,
	0xE, 0x1, 0x0, 0x6,
	0xC, 0x7, 0x3, 0x8,
	0x2, 0xB, 0x5, 0xD
};

/*
 * The round constants RC[i] (i = 0,1,...,24) are genrered by
 * a 5-bit LFSR. At ech round, the 5 bits (rc4,rc3,rc2,rc1,rc0) are left 
 * shiftend over 1 bit. the new value of rc0 is comptued as rc4 OR rc2.
 *
 * Implementation notes:
 * & 0x1F                   : ensures that it stays a 5-bit.
 * (current & 0x4) >> 2     : takes the second bit and moves it to position one.
 */
char RC(char current)
{
	return ((current << 1) & 0x1F) | 
		((current & 0x4) >> 2) ^ ((current & 0x16) >> 4);
}

/*
 * Applay the S-box to column x of the key.
 * 
 * e.g
 * | k15,0 ... k0,0 |
 * | k15,1 ... k0,1 |
 * | k15,2 ... k0,2 |
 * | k15,3 ... k0,3 |
 * | k15,4 ... k0,4 |
 * | k15,5 ... k0,5 |
 *
 * In case of column 0:
 * S(k0,3 | k0,2 | k0,1 | k0,0) where S is the S-box function.
 */
void applySboxToColumn(unsigned short* pKey, int column)
{
	int mask = 0x01 << column;
	byte c = (pKey[0] & mask) >> column;
	c = c | ((pKey[1] & mask) >> column) << 1;
	c = c | ((pKey[2] & mask) >> column) << 2;
	c = c | ((pKey[3] & mask) >> column) << 3;

	c = sbox[c];

	pKey[0] = pKey[0] & (0xFFFF - mask) | (c & 0x01) << column;
	pKey[1] = pKey[1] & (0xFFFF - mask) | ((c & 0x02) >> 1) << column;
	pKey[2] = pKey[2] & (0xFFFF - mask) | ((c & 0x04) >> 2) << column;
	pKey[3] = pKey[3] & (0xFFFF - mask) | ((c & 0x08) >> 3) << column;
}

void applySboxToColumnInt(unsigned int* pKey, int column)
{
	int mask = 0x01 << column;
	byte c = (pKey[0] & mask) >> column;
	c = c | ((pKey[1] & mask) >> column) << 1;
	c = c | ((pKey[2] & mask) >> column) << 2;
	c = c | ((pKey[3] & mask) >> column) << 3;

	c = sbox[c];

	pKey[0] = pKey[0] & (0xFFFFFFFF - mask) | (c & 0x01) << column;
	pKey[1] = pKey[1] & (0xFFFFFFFF - mask) | ((c & 0x02) >> 1) << column;
	pKey[2] = pKey[2] & (0xFFFFFFFF - mask) | ((c & 0x04) >> 2) << column;
	pKey[3] = pKey[3] & (0xFFFFFFFF - mask) | ((c & 0x08) >> 3) << column;
}

/*
 * Shift number of positons to the left.
 */
unsigned short shiftLeftShort(unsigned short input, int left)
{
	return (input << left) | (input >> (sizeof(input) * 8 - left));
}

/*
* Shift number of positons to the left.
*/
unsigned int shiftLeftInt(unsigned int input, int left)
{
	return (input << left) | (input >> (sizeof(input) * 8 - left));
}

/*
* Shift number of positons to the right.
*/
unsigned short shiftRightShort(unsigned short input, int right)
{
	return (input >> right) | (input << (sizeof(input) * 8 - right));
}

void generateRoundKeys80(unsigned short* pKey, 
	unsigned short pRoundSubkey[26][4])
{
	int i;
	byte rc = 0x1;

	for (i = 0; i < 25; i++)
	{
		// Extracting the round subkey.
		pRoundSubkey[i][0] = pKey[0];
		pRoundSubkey[i][1] = pKey[1];
		pRoundSubkey[i][2] = pKey[2];
		pRoundSubkey[i][3] = pKey[3];

		// Applay S-box to 4 uppermost rows and the 4 rightmost columns.
		applySboxToColumn(pKey, 0);
		applySboxToColumn(pKey, 1);
		applySboxToColumn(pKey, 2);
		applySboxToColumn(pKey, 3);

		// Applay 1-round generalized Feistel transformation.
		unsigned short row0 = pKey[0];
		unsigned short row1 = pKey[1];
		unsigned short row2 = pKey[2];
		unsigned short row3 = pKey[3];
		unsigned short row4 = pKey[4];

		pKey[0] = (shiftLeftShort(row0, 8) ^ row1) & 0xFFFF;
		pKey[1] = row2;
		pKey[2] = row3;
		pKey[3] = (shiftLeftShort(row3, 12) ^ row4) & 0xFFFF;
		pKey[4] = row0;

		// A 5-bit round constant RC[i] is XORed with the 5-bit key state.
		pKey[0] = pKey[0] ^ rc;
		rc = RC(rc);

		int j = 2;
	}

	// Extracting the round subkey.
	pRoundSubkey[25][0] = pKey[0];
	pRoundSubkey[25][1] = pKey[1];
	pRoundSubkey[25][2] = pKey[2];
	pRoundSubkey[25][3] = pKey[3];
}

void generateRoundKeys128(unsigned int* pKey, 
	unsigned short pRoundSubkey[26][4])
{
	int i;
	int j;
	byte rc = 0x1;

	for (i = 0; i < 25; i++)
	{
		// Extracting the round subkey.
		pRoundSubkey[i][0] = pKey[0] & 0xFFFF;
		pRoundSubkey[i][1] = pKey[1] & 0xFFFF;
		pRoundSubkey[i][2] = pKey[2] & 0xFFFF;
		pRoundSubkey[i][3] = pKey[3] & 0xFFFF;

		// Applay S-box to 4 uppermost rows and the 4 rightmost columns.
		for (j = 0; j < 8; j++)
		{
			applySboxToColumnInt(pKey, j);
		}

		// Applay 1-round generalized Feistel transformation.
		unsigned int row0 = pKey[0];
		unsigned int row1 = pKey[1];
		unsigned int row2 = pKey[2];
		unsigned int row3 = pKey[3];

		pKey[0] = (shiftLeftInt(row0, 8) ^ row1);
		pKey[1] = row2;
		pKey[2] = (shiftLeftInt(row2, 16) ^ row3);
		pKey[3] = row0;

		// A 5-bit round constant RC[i] is XORed with the 5-bit key state.
		pKey[0] = pKey[0] ^ rc;
		rc = RC(rc);
	}

	// Extracting the round subkey.
	pRoundSubkey[25][0] = pKey[0] & 0xFFFF;
	pRoundSubkey[25][1] = pKey[1] & 0xFFFF;
	pRoundSubkey[25][2] = pKey[2] & 0xFFFF;
	pRoundSubkey[25][3] = pKey[3] & 0xFFFF;
}

void addRoundKey(unsigned short* pState, unsigned short* pRoundKey)
{
	pState[0] = pState[0] ^ pRoundKey[0];
	pState[1] = pState[1] ^ pRoundKey[1];
	pState[2] = pState[2] ^ pRoundKey[2];
	pState[3] = pState[3] ^ pRoundKey[3];
}

void subColumn(unsigned short* pState, byte* sbox)
{
	int i;
	byte c;
	int mask = 0x8000;

	for (i = 0; i < 16; i++)
	{
		c = 0;
		c = c | (pState[0] & mask) >> (15 - i);
		c = c | ((pState[1] & mask) >> (15 - i)) << 1;
		c = c | ((pState[2] & mask) >> (15 - i)) << 2;
		c = c | ((pState[3] & mask) >> (15 - i)) << 3;

		c = sbox[c];

		pState[0] = pState[0] & (0xFFFF - mask) | (c & 0x01) << (15 - i);
		pState[1] = pState[1] & (0xFFFF - mask) | ((c & 0x02) >> 1) << (15 - i);
		pState[2] = pState[2] & (0xFFFF - mask) | ((c & 0x04) >> 2) << (15 - i);
		pState[3] = pState[3] & (0xFFFF - mask) | ((c & 0x08) >> 3) << (15 - i);

		mask = mask / 2;
	}
}

/*
* From the paper, not used but is used to check the setColumn method.
* Note that this method is simplified (less variables).
*/
void subColumnBitSlicing(unsigned short* pState)
{
	unsigned short b0 = 0;
	unsigned short b1 = 0;
	unsigned short b2 = 0;
	unsigned short b3 = 0;

	unsigned short t2 = 0;
	unsigned short t3 = 0;
	unsigned short t4 = 0;

	t2 = pState[0] & ~pState[1];
	t3 = pState[2] ^ pState[3];
	b0 = t2 ^ t3;
	t2 = pState[3] | ~pState[1];
	t4 = pState[0] ^ t2;
	b1 = pState[2] ^ t4;
	t2 = pState[1] ^ pState[2];
	b3 = t2 ^ t3 & t4;
	t2 = b0 | t2;
	b2 = t4 ^ t2;

	pState[0] = b0;
	pState[1] = b1;
	pState[2] = b2;
	pState[3] = b3;
}

void shiftRow(unsigned short* pState)
{
	pState[1] = shiftLeftShort(pState[1], 1);
	pState[2] = shiftLeftShort(pState[2], 12);
	pState[3] = shiftLeftShort(pState[3], 13);
}

void shiftRowBack(unsigned short* pState)
{
	pState[1] = shiftRightShort(pState[1], 1);
	pState[2] = shiftRightShort(pState[2], 12);
	pState[3] = shiftRightShort(pState[3], 13);
}

void rec80encrypt(unsigned short* pState, unsigned short* pKey)
{
	int i;
	int j;
	unsigned short roundSubkey[26][4];
	memset(roundSubkey, 0, sizeof(unsigned short) * 26 * 4);

	generateRoundKeys80(pKey, roundSubkey);
	for (i = 0; i < 25; i++)
	{
		addRoundKey(pState, roundSubkey[i]);
		subColumn(pState, sbox);
		shiftRow(pState);
	}
	addRoundKey(pState, roundSubkey[25]);
}

void rec80decrypt(unsigned short* pState, unsigned short* pKey)
{
	int i;
	unsigned short roundSubkey[26][4];
	memset(roundSubkey, 0, sizeof(unsigned short) * 26 * 4);

	generateRoundKeys80(pKey, roundSubkey);
	for (i = 25; i > 0; i--)
	{
		addRoundKey(pState, roundSubkey[i]);
		shiftRowBack(pState);
		subColumn(pState, rbox);
	}
	addRoundKey(pState, roundSubkey[0]);
}

void rec128encrypt(unsigned short* pState, unsigned int* pKey)
{
	int i;
	unsigned short roundSubkey[26][4];
	memset(roundSubkey, 0, sizeof(unsigned short) * 26 * 4);

	generateRoundKeys128(pKey, roundSubkey);
	for (i = 0; i < 25; i++)
	{
		addRoundKey(pState, roundSubkey[i]);
		subColumn(pState, sbox);
		shiftRow(pState);
	}
	addRoundKey(pState, roundSubkey[25]);
}

void rec128decrypt(unsigned short* pState, unsigned int* pKey)
{
	int i;
	unsigned short roundSubkey[26][4];
	memset(roundSubkey, 0, sizeof(unsigned short) * 26 * 4);

	generateRoundKeys128(pKey, roundSubkey);
	for (i = 25; i > 0; i--)
	{
		addRoundKey(pState, roundSubkey[i]);
		shiftRowBack(pState);
		subColumn(pState, rbox);
	}
	addRoundKey(pState, roundSubkey[0]);
}
