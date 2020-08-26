.section .text
.globl lab02d

lab02d:
	ADD x1, x0, 0x308
	ADRP x0, myvalue
	ADD x0, x0, :lo12:myvalue
	STUR x1,[x0,0]
	BR x30


.section .data
//print:
//.asciz "The value + 1000 is: "

myvalue:
.word
