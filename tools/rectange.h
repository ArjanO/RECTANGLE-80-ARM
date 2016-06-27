#ifndef RECTANGLE_H
#define RECTANGLE_H

void generateRoundKeys80(unsigned short* pKey,
	unsigned short pRoundSubkey[26][4]);

void generateRoundKeys128(unsigned int* pKey, 
	unsigned short pRoundSubkey[26][4]);

void rec80encrypt(unsigned short* pState, unsigned short* pKey);

void rec80decrypt(unsigned short* pState, unsigned short* pKey);

void rec128encrypt(unsigned short* pState, unsigned int* pKey);

void rec128decrypt(unsigned short* pState, unsigned int* pKey);

#endif
