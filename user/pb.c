/**
 * @file pb.c
 * @author Muteeb Akram Nawaz (u1471482)
 * @brief Pipe benchmark for 10MB data transfer from child to parent.
 * @date 2023-08-27
 */

/**
Question (Assignment 1):
------------------------
Start with a fresh copy of xv6, Write a userspace program called pb, implemented in a single file called pb.c (which stands for "pipebench"), which you should put into the user subdirectory of the xv6-riscv-f23 project. You'll need to modify UPROGS in Makefile as well to get it to compile when you make qemu.

This program should:

1. create a pipe using the pipe system call
2. fork a child process
3. in the parent, get the current time using the uptime() system call
4. send 10 MB of data from the child to the parent
5. the parent must ensure that the bytes received from the child are the correct ones; if any byte is in error, an error message should be printed and the program should terminate
6. in the parent, get the current time again and print the elapsed number of ticks
7. in the parent, wait() for the child process before exiting

as a baseline, on my Macbook it takes about 100-150 clock ticks to transfer 10 MB across a pipe depending on the compiler flags I use.


Output (cloudlab c6525-25g):
-----------------------------
$ pb
Filling buffer...10000000 bytes
Creating pipe...
Forking child...
Parent is reading...
Child completed...10000000 bytes write
Parent completed...10000000 bytes read
Parent waiting for child...done
Buffer validation...10000000 bytes passed!
PB # of clocks: 109
$

*/

#include "kernel/types.h"
#include "user/user.h"

#define ITR 10
#define MB 1024 * 1024

char buf[ITR * MB];

int main()
{
    int i, n, total, pid, clocks, child_rc, p[2];

    printf("Filling buffer...");
    for (i = 0; i < ITR * MB; i++)
    {
        buf[i] = 'm';
        // printf("i: %d, buf: %d\n", i, buf[i]);
    }
    printf("%d bytes\n", i);

    printf("Creating pipe...\n");
    if (pipe(p) != 0)
    {
        printf("Failed to create pipe.\n");
        exit(1);
    }

    printf("Forking child...\n");
    pid = fork();
    if (pid == 0) // child process
    {
        // close(1); // close std write 1 & dup to child p[1] write.
        // dup(p[1]);

        close(p[0]); // close p[0] read as child will not read.

        total = 0;
        for (i = 0; i < ITR; i++)
        {
            n = write(p[1], buf, MB);
            total += n;
            if (n != MB)
            {
                printf("Failed to write byte: %d", i);
                close(p[1]);
                exit(1);
            }
        }

        printf("Child completed...%d bytes write\n", total);
        close(p[1]);
        exit(0);
    }
    else if (pid > 0) // parent process
    {
        clocks = uptime();

        // close(0); // close std read 0 & dup to parent p[0] read.
        // dup(p[0]);

        close(p[1]); // close parent p[1] write as it will not be writing.

        total = 0;
        printf("Parent is reading...\n");
        for (;;)
        {
            n = read(p[0], buf, MB);
            total += n;
            if (n <= 0)
                break;
        }
        printf("Parent completed...%d bytes read\n", total);

        printf("Parent waiting for child...");
        wait(&child_rc);
        if (child_rc != 0)
        {
            printf("Child (%d) failed to write. rc: %d\n", pid, child_rc);
            close(p[0]);
            exit(1);
        }

        printf("done\n");
        close(p[0]); // Parent is done reading close read pipe.

        printf("Buffer validation...");
        for (i = 0; i < ITR * MB; i++)
        {
            if (buf[i] != 'm')
            {
                printf("%dth bytes failed!\n", i);
                exit(1);
            }
        }
        printf("%d bytes passed!\n", i);

        clocks = uptime() - clocks;
        printf("PB # of clocks: %d\n", clocks);
    }
    else
    {
        printf("Failed to fork. PID: %d\n", pid);
    }

    return 0;
}
