.globl lab03c

lab03c:

ADRP x2, myUin // place the address of myUin into x2
ADD x2, x2, :lo12:myUin

ADRP x4, my_array // place the adress of my_array into x4
ADD x4, x4, :lo12:my_array

LDUR x0, [x2, 0] // load the value of myUin in x2

MOV x1, #0 // fills x1 with value 10 to make check later

loop: // loop through

SUB x3, x1, #10 // check if x3 is equal to 10
CBZ x3, finish  // x3 is the count and if it reaches 10 then finish
STUR x0, [x4,0] // store x0 into the array at adress x4
ADD x4, x4, #4 // add 4 to the adress to make space for a new word
ADD x0, x0, #1  // add to myUin
ADD x1, x1, #1  // add to the count

B loop // go back to loop

finish:
BR x30 // return to main


.section .data
myUin:
.word 31 // the value of my Uin all added together
my_array:
.space 40 // enough space for 10 words, a word is 4 bytes
