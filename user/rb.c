#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

int main()
{
    printf("Running rb...\n");
    int rd = ringbuf_open();
    printf("ringbuf_open rd: %d\n", rd);

    int ret = ringbuf_close(rd);
    printf("ringbuf_close ret: %d\n", ret);
    return ret;
}