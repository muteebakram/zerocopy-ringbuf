#include <stdio.h>
#include <stdint.h>

void func(uint64_t *a)
{
    printf("*a: %llu\n", *a);
    *a = 10;

}

void main()
{
    uint64_t a = 5;
    func(&a);
    printf("a: %llu\n", a);
}