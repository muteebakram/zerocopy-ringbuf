#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

#define SIZE 1 * 1024 * 1024

char read_buf[SIZE], write_buf[SIZE];

int main()
{
    int i, rd, pid, child_rc, clocks;

    printf("Filling buffer...");
        for (i = 0; i < SIZE; i++)
    {
        write_buf[i] = 'm'; // m will be written to ringbuf.
        read_buf[i] = 'g';  // data from ringbuf is transferred to read_buf.
    }
    printf("%d bytes\n", i);

    rd = ringbuf_open();
    printf("Created ringbuf: %d\n", rd);

    pid = fork();
    if (pid == 0) // child process
    {
        // printf("in child\n");

        char *write_addr = 0;
        int bytes = 0, total_write = 0;
        printf("in child\n\n\n");

        while (total_write < SIZE)
        {
            ringbuf_start_write(rd, &write_addr, &bytes);
            memcpy(write_addr, write_buf, bytes);
            total_write += bytes;
            ringbuf_finish_write(rd, bytes);
        }
        printf("Child completed...%d bytes write\n", total_write);
        exit(0);
    }
    else
    {
        clocks = uptime();

        char *read_addr = 0;
        int bytes = 0, total_read = 0;
        while (total_read < SIZE)
        {
            ringbuf_start_read(rd, &read_addr, &bytes);
            memcpy(read_addr, read_buf, bytes);
            total_read += bytes;
            ringbuf_finish_read(rd, bytes);
        }

        wait(&child_rc);
        if (child_rc != 0)
        {
            printf("Child (%d) failed to write. rc: %d\n", pid, child_rc);
            exit(1);
        }
        printf("Parent completed...%d bytes read\n", total_read);

        clocks = uptime() - clocks;
        printf("Zero-copy magic ringbuf # of clocks: %d\n", clocks);
    }

    printf("Data validation...");
    for (i = 0; i < SIZE; i++)
    {
        if ((write_buf[i] != 'm') || read_buf[i] != 'm')
        {
            printf("%dth bytes failed! Write value: %s, Read value: %s\n", i, write_buf[i], read_buf[i]);
            break;
        }
    }
    printf("%d bytes passed!\n", i);

    int ret = ringbuf_close(rd);
    printf("Closing ringbuf: %d\n", rd);
    return ret;
}