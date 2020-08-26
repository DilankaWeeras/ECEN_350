/* main.c simple program to test assembler program */

#include <stdio.h>

//extern long long int test(long long int a, long long int b);
extern void lab03b();
extern void lab03c();


int main(void)
{
//    long long int a = test(3, 5);
    //printf("Result of test(3, 5) = %ld\n", a);
    lab03b();
    lab03c();
    return 0;
}
