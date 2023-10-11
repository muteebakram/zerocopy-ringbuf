/**
 * @file rb.c
 * @author Muteeb Akram Nawaz, Doctor (u1471482@umail.utah.edu)
 * @author Gaurav, Sharma (u1320813@umail.utah.edu)
 * @brief Implemented zero copy circular ring buffer system call for inter process communication.
 * @date 2023-10-10
 * @copyright Copyright (c) 2023
 * 
 * 10MB transfer
 * 
 * the bandwidth (in MB/s) of an original xv6 pipe, on your machine
 *      PB # of clocks: 109 (cloudlab c6525-25g)
 *      PB # of clocks: 151 (Macbook 13" M1 2020)
 * 
 * the bandwidth of your fastest xv6 pipe
 *      PB # of clocks: 39 (Macbook 13" M1 2020)
 * 
 * the bandwidth of your ring buffer (Check README.md for output.)
 *      Zero-copy magic ringbuf # of clocks: 0 or 1 (Macbook 13" M1 2020)
 */

#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

#define SIZE 10 * 1024 * 1024

char read_buf[SIZE], write_buf[SIZE];

int main()
{
    int i, rd, pid, child_rc, clocks;

    // Goal: After transfer, read_buf should have contents of write_buf.
    printf("Filling buffer...");
    for (i = 0; i < SIZE; i++)
    {
        write_buf[i] = 'm'; // m will be written to ringbuf.
        read_buf[i] = 'g';  // data from ringbuf is transferred to read_buf.
    }
    printf("%d bytes\n", i);

    pid = fork();
    if (pid == 0) // child process
    {
        rd = ringbuf_open("muteeb");
        if (rd < 0)
        {
            printf("Error: Failed to open child ringbuf\n.");
            exit(0);
        }

        char *write_addr = 0;
        int bytes = 0, total_write = 0;
        while (total_write < SIZE)
        {
            ringbuf_start_write(rd, &write_addr, &bytes);
            if (bytes <= 0)
                continue;
            memcpy(write_addr, write_buf, bytes);
            total_write += bytes;
            ringbuf_finish_write(rd, bytes);
        }
        printf("Child completed...%d bytes write\n", total_write);

        if (ringbuf_close(rd, "muteeb") != 0)
        {
            printf("Error: Failed to close child ringbuf\n.");
            exit(1);
        }
        exit(0);
    }
    else if (pid > 0) // parent process
    {
        rd = ringbuf_open("muteeb");
        if (rd < 0)
        {
            printf("Error: Failed to open parent ringbuf\n.");
            exit(0);
        }

        clocks = uptime();
        char *read_addr = 0;
        int bytes = 0, total_read = 0;

        while (total_read < SIZE)
        {
            ringbuf_start_read(rd, &read_addr, &bytes);
            if (bytes <= 0)
                continue;

            memcpy(read_buf + total_read, read_addr, bytes);
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

        if (ringbuf_close(rd, "muteeb") != 0)
        {
            printf("Error: Failed to close parent ringbuf\n.");
            exit(1);
        }

        clocks = uptime() - clocks;
        printf("Zero-copy magic ringbuf # of clocks: %d\n", clocks);
    }
    else
    {
        printf("Failed to fork. PID: %d\n", pid);
    }

    printf("Data validation...");
    for (i = 0; i < SIZE; i++)
    {
        if ((write_buf[i] != 'm') || read_buf[i] != 'm')
        {
            printf("%dth bytes failed! Write value: %c, Read value: %c\n", i, write_buf[i], read_buf[i]);
            return -1;
        }
    }
    printf("%d bytes passed!\n", i);
    return 0;
}