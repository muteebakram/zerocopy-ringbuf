#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"
#include "user/ringbuf.h"

int serial_read_write()
{
    // const char name[16] = "muteeb";

    if (ringbuf_open(0) != 0)
        return -1;

    if (ringbuf_open(0) != 0)
        return -1;

    if (ringbuf_close(0) != 0)
        return -1;

    if (ringbuf_close(0) != 0)
        return -1;

    return 0;
}

int main(int argc, char *argv[])
{
    printf("TEST: serial_read_write: %d\n\n", serial_read_write());

    printf("goodbye\n");
    return 0;
}