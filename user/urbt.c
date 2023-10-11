#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"
#include "user/ringbuf.h"

int serial_read_write()
{
    int rd1 = ringbuf_open("muteeb"), rd2 = ringbuf_open("muteeb");
    if (rd1 < 0)
        return -1;

    if (rd2 < 0)
        return -1;

    if (ringbuf_close(rd1, "muteeb") != 0)
        return -1;

    if (ringbuf_close(rd2, "muteeb") != 0)
        return -1;

    return 0;
}

int main(int argc, char *argv[])
{
    printf("TEST: serial_read_write: %d\n\n", serial_read_write());

    printf("goodbye\n");
    return 0;
}