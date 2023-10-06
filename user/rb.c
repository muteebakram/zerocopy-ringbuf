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
    printf("running rb...\n");
    int ret = create_ringbuf();
    printf("create_ringbuf: %d", ret);
    return ret;
}