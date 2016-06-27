/* -----------------------------------------------------------------------------
 * RECTANGLE 80 implementation (optimized for speed)
 *
 * Authors: Arjan Oortgiese and Mark Vink
 * -----------------------------------------------------------------------------
 */
.syntax unified
.globl rec80encrypt

.data
.balign 4

.include "roundkeys-0.s"

.text

.macro subColumn a0,a1,a2,a3,b0,b1,b2,b3,t2,t3,t4
	mvn \t4, \a1
	and \t2, \a0, \t4
	eor \t3, \a2, \a3
	eor \b0, \t2, \t3
	orr \t2, \a3, \t4
	eor \t4, \a0, \t2
	eor \b1, \a2, \t4
	eor \t2, \a1, \a2
	and \b3, \t3, \t4
	eor \b3, \b3, \t2
	orr \t2, \b0, \t2
	eor \b2, \t4, \t2
.endm

.macro shiftRow a1, a2, a3, b1, b2, b3, t0
	// rotate 1
	lsl \t0, \a1, #1
	and \b1, \t0, 0xFFFEFFFE
	lsr \t0, \a1, #15
	and \t0, \t0, 0x00010001
	orr \b1, \b1, \t0

	// rotate 12
	lsl \t0, \a2, #12
	and \b2, \t0, 0xF000F000
	lsr \t0, \a2, #4
	and \t0, \t0, 0x0FFF0FFF
	orr \b2, \b2, \t0

	// rotate 13
	lsl \t0, \a3, #13
	and \b3, \t0, 0xE000E000
	lsr \t0, \a3, #3
	and \t0, \t0, 0x1FFF1FFF
	orr \b3, \b3, \t0
.endm

.macro addRoundKey a0, a1, a2, a3, t0, t1, t2, t3, roundkeys, o1, o2, o3, o4
    ldr \t0, [\roundkeys, #\o1]
    ldr \t1, [\roundkeys, #\o2]
    ldr \t2, [\roundkeys, #\o3]
    ldr \t3, [\roundkeys, #\o4]
    eor \a0, \a0, \t0
    eor \a1, \a1, \t1
    eor \a2, \a2, \t2
    eor \a3, \a3, \t3
.endm

.macro addRoundKey0 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 0 4 8 12
.endm

.macro addRoundKey1 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 16 20 24 28
.endm

.macro addRoundKey2 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 32 36 40 44
.endm

.macro addRoundKey3 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 48 52 56 60
.endm

.macro addRoundKey4 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 64 68 72 76
.endm

.macro addRoundKey5 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 80 84 88 92
.endm

.macro addRoundKey6 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 96 100 104 108
.endm

.macro addRoundKey7 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 112 116 120 124
.endm

.macro addRoundKey8 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 128 132 136 140
.endm

.macro addRoundKey9 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 144 148 152 156
.endm

.macro addRoundKey10 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 160 164 168 172
.endm

.macro addRoundKey11 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 176 180 184 188
.endm

.macro addRoundKey12 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 192 196 200 204
.endm

.macro addRoundKey13 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 208 212 216 220
.endm

.macro addRoundKey14 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 224 228 232 236
.endm

.macro addRoundKey15 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 240 244 248 252
.endm

.macro addRoundKey16 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 256 260 264 268
.endm

.macro addRoundKey17 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 272 276 280 284
.endm

.macro addRoundKey18 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 288 292 296 300
.endm

.macro addRoundKey19 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 304 308 312 316
.endm

.macro addRoundKey20 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 320 324 328 332
.endm

.macro addRoundKey21 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 336 340 344 348
.endm

.macro addRoundKey22 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 352 356 360 364
.endm

.macro addRoundKey23 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 368 372 376 380
.endm

.macro addRoundKey24 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 384 388 392 396
.endm

.macro addRoundKey25 a0, a1, a2, a3, t0, t1, t2, t3, r
    addRoundKey \a0, \a1, \a2, \a3, \t0, \t1, \t2, \t3, \r 400 404 408 412
.endm

.func rec80encrypt
rec80encrypt:
	mov r1, 0
	mov r2, 0
	mov r3, 0
	mov r4, 0

	ldr r0, =roundkeys
	addRoundKey0 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey1 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey2 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey3 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey4 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey5 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey6 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey7 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey8 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey9 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey10 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey11 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey12 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey13 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey14 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey15 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey16 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey17 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey18 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey19 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey20 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey21 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey22 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey23 r5, r2, r3, r4, r1, r6, r7, r8, r0
	subColumn r5, r2, r3, r4, r1, r6, r7, r8, r9, r10, r11
	shiftRow r6, r7, r8, r2, r3, r4, r10

	addRoundKey24 r1, r2, r3, r4, r5, r6, r7, r8, r0
	subColumn r1, r2, r3, r4, r5, r11, r10, r9, r8, r6, r7
	shiftRow r11, r10, r9, r6, r7, r8, r1

	addRoundKey25 r5, r6, r7, r8, r1, r2, r3, r4, r0

	// Result is in: r5, r6, r7, r8
	bx lr // return to main.
