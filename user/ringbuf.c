#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main(int argc, char *argv[])
{
    const char name[16] = "muteeb";
    void **buf1 = 0;
    void **buf2 = 0;

    uint64 **ptr1 = 0;
    uint64 **ptr2 = 0;
    ringbuf(name, 1, buf1);
    ringbuf(name, 1, buf2);
    // ringbuf("akeeb", 2, &buf2);

    ptr1 = (uint64 **)buf1;
    ptr2 = (uint64 **)buf2;
    printf("**buf %p: ", (ptr1));
    printf("**buf %p: ", (ptr2));

    // if((uint64 **)(buf1) != 0)
    //     printf("ringbuf: %p\n", (uint64 **)(buf1));
    // if((uint64 **)(buf2) != 0)
    //     printf("ringbuf: %p\n", (uint64 **)(buf2));
    printf("\ngoodbye\n");
    return 0;
}