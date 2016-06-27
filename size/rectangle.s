/* -----------------------------------------------------------------------------
 * RECTANGLE 80 implementation (optimized for size)
 *
 * Authors: Arjan Oortgiese and Mark Vink
 * -----------------------------------------------------------------------------
 */
.syntax unified
.thumb
.globl rec80encrypt

.data
.balign 1

key:
.byte 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00

.text

// SubColumn version for thumb.
// Note that we use marco for register renaming (it is used in a function).
.macro subColumn a0,a1,a2,a3,b0,t2,t3,t4
	mvn \t4, \a1

	// and \t2, \a0, \t4
	mov \t2, \a0
	and \t2, \t4

	// eor \t3, \a2, \a3
	mov \t3, \a3
	eor \t3, \a2

	// eor \b0, \t2, \t3
	mov \b0, \t2
	eor \b0, \t3

	// orr \t2, \a3, \t4
	mov \t2, \a3
	orr \t2, \t4

	// eor \t4, \a0, \t2
	mov \t4, \a0
	eor \t4, \t2

	mov \t2, \a1 // *1 (statement moved to here).

	// eor \b1, \a2, \t4
	mov \a1, \a2
	eor \a1, \t4

	// eor \t2, \a1, \a2
	// mov \t2, \a1 this statement his moved up *1
	eor \t2, \a2

	// and \b3, \t3, \t4
	mov \a3, \t3
	and \a3, \t4

	// eor \b3, \b3, \t2
	eor \a3, \t2

	// orr \t2, \b0, \t2
	orr \t2, \b0

	// eor \b2, \t4, \t2
	mov \a2, \t4
	eor \a2, \t2

	mov \a0, \b0 // put back ...
.endm

.func rec80encrypt
rec80encrypt:
	push {lr}

	// Assume stored as 000|S0 (first have).
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0

	ldr r7, =key

	mov r0, #0 // Counts the round and the key offset.
	mov r5, #0x1 // RC
loop:
	// Add round key.
	ldr r6, [r7, #0]
	eor r1, r6
	ldr r6, [r7, #2]
	eor r2, r6
	ldr r6, [r7, #4]
	eor r3, r6
	ldr r6, [r7, #6]
	eor r4, r6

	bl genroundkey

	add r0, #1
	cmp r0, #26
	beq loop_exit

	bl subColumn
	bfi r2, r2, #16, #16
	ror r2, #15 // is rotate left by 1
	bfi r3, r3, #16, #16
	ror r3, #4  // is rotate left by 12
	bfi r4, r4, #16, #16
	ror r4, #3  // is rotate left by 13

	b loop
loop_exit:

	// Result is in first have of: r1, r2, r3, r4
	pop {lr}
	bx lr // return to main.
.endfunc

subColumn:
	push {r5, r6, r7, lr}
	// We use LR because it is saved so it a free register.
	subColumn r1, r2, r3, r4, r5, r6, r7, lr
	pop {r5, r6, r7, lr}
	bx lr

genroundkey:
	push {r0,r1,r2,r3,r4,lr}

	ldrh r1, [r7, #0]
	ldrh r2, [r7, #2]
	ldrh r3, [r7, #4]
	ldrh r4, [r7, #6]

	bl subColumn

	// Restore rest of columns.
	mov r6, r1
	ldrh r1, [r7, #0]
	bfi r1, r6, #0, #4

	mov r6, r2
	ldrh r2, [r7, #2]
	bfi r2, r6, #0, #4

	mov r6, r3
	ldrh r3, [r7, #4]
	bfi r3, r6, #0, #4

	mov r6, r4
	ldrh r4, [r7, #6]
	bfi r4, r6, #0, #4

	ldrh r6, [r7, #8]

	// Feistel transformation.
	strh r1, [r7, #8]
	bfi r1, r1, #16, #16
	ror r1, #8
	eor r1, r2
	strh r3, [r7, #2]
	strh r4, [r7, #4]
	bfi r4, r4, #16, #16
	ror r4, #4
	eor r4, r6
	strh r4, [r7, #6]

	// Round constant
	eor r1, r5
	strh r1, [r7, #0]

	mov r2, r5
	mov lr, r5
	lsl r5, #1
	and r5, #0x1F
	lsr r2, #2
	lsr lr, #4
	eor r2, lr
	and r2, #1
	orr r5, r2

	pop {r0,r1,r2,r3,r4,lr}
	bx lr
