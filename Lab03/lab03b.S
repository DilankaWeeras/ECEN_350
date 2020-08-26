.globl lab03b

lab03b:

ADRP x2, myUin // place myUin
ADD x2, x2, :lo12:myUin

LDUR x0, [x2, 0] // load the value in x2

MOV x1, #0 // make x1 0

loop: // loop through

SUB x3, x1, #10 // check if x3 is equal to 10
CBZ x3, finish
sub x0, x0, #1 // subtract from Uin
add x1, x1, #1 // ad 1 to count

B loop

finish:
STUR x0, [x2, 0] // place new Uin into adress x2
BR x30


.section .data
myUin:
.word 31
