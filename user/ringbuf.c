#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"
// #include "kernel/ringbuf.h"

int main(int argc, char *argv[])
{
    const char name[16] = "muteeb";
    uint64 buf1;
    // uint64 buf2;

    ringbuf(name, 1, &buf1);
    // ringbuf(name, 1, &buf2);

    printf("ringbuf: %p\n", (buf1));
    printf("ringbuf book page: %p\n", (buf1 - (16 *  4096)));

    printf("\ngoodbye\n");
    return 0;
}