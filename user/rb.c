#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

int main()
{
    printf("Running rb...\n");
    int rd = ringbuf_open();
    printf("ringbuf_open rd: %d\n", rd);

    // char x[10];
    // int bytes = 10;
    // ringbuf_start_read(rd, x, &bytes);

    int ret = ringbuf_close(rd);
    printf("ringbuf_close ret: %d\n", ret);
    return ret;
}