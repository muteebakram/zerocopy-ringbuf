#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

int ringbuf_count = 0;
const char *names[] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"};
struct user_ring_buf user_ring_bufs[10];

int create_ringbuf()
{
  int fd;
  if (ringbuf(names[ringbuf_count], 1, user_ring_bufs[ringbuf_count].buf))
  {
    printf("Failed to create ringbuf.\n");
    return -1;
  }
  fd = ringbuf_count;
  ringbuf_count++;

  return fd;
}

int delete_ringbuf(int fd)
{
  if (ringbuf(names[fd], 0, user_ring_bufs[fd].buf))
  {
    printf("Failed to create ringbuf.\n");
    return -1;
  }
  ringbuf_count--;

  return 0;
}
