#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main(int argc, char *argv[])
{
    const char name[16] = "muteeb";
    uint64 buf1;
    uint64 *start;
    // uint64 buf2;

    ringbuf(name, 1, &buf1);
    // ringbuf(name, 1, &buf2);
    start = (uint64*)buf1;

    printf("ringbuf: %p\n", (buf1));
    //char *s = (char *)(buf1);
    printf("ringbuf: %s\n", *((char*)start));
    
    
    printf("\ngoodbye\n");
    return 0;
}