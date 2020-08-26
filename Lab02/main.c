#include <stdio.h>
//extern long long int test();
//extern void lab02c(long long int a);
extern long long int lab02d(long long int b);
int main(void)
{
//	test();
//	lab02b();
//	lab02c(16);

	long long int b = lab02d(1);
	printf("Result is = %lld\n", b);
    return 0;
}
