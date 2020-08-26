.globl factorial

factorial:
		sub sp, sp, 16 // make space in the stack
		stur x1, [sp, 8] // place current value of x1 in the stack
		stur x30, [sp, 0] // place the branch to main -- after first step then the branch to my_mul

		if:
			cbnz x0, else // if x0 is not zero it will go to else
			mov x0, 1 // moves the value 1 into x0 to start the multiplication process
			b finish //goes to finish to begin popping the stack and multiplying the stack
		else:
			mov x1, x0 // put x0 into x1 to be placed in the stack
			sub x0, x0, 1 // subtracts x0 by one to re-enter the recursion
			bl factorial // branch back to factorial and save branch to my_mul in x30
			bl my_mul // after popping the stack in finish it will multipy each x1 by x0


		finish:
			ldur x30, [sp,0] // pop the branch to my_mul -- final pop the branch to main
			ldur x1, [sp, 8] // pop the saved value of x0.
			add sp, sp, 16 // return stack pointer by 16 for space after popping
			br x30 // return to my_mul then to main.

.section .data




