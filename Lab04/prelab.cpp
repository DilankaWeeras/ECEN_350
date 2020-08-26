#include <iostream>

using namespace std;

int f(int n, int k)
{
    int b;
    b = k+2;
    if(n==0) {b = 8;}
    else {b = b + 4*n + f(n-1, k+1);}
    return b + k;
}
main()
{
    cout << f(2,4);
}