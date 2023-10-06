#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

int ringbuf_count = 0;

const char *names[] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"};

struct user_ring_buf user_ring_bufs[10];

void ringbuf_start_read(int ring_desc, char **addr, int *bytes)
{
}

void ringbuf_finish_read(int ring_desc, int bytes)
{
}

void ringbuf_start_write(int ring_desc, char **addr, int *bytes)
{
}

void ringbuf_finish_write(int ring_desc, int bytes)
{
}

int ringbuf_open()
{
  int fd;
  if (ringbuf(names[ringbuf_count], 1, user_ring_bufs[ringbuf_count].buf))
  {
    printf("Failed to open ringbuf.\n");
    return -1;
  }
  fd = ringbuf_count;
  ringbuf_count++;

  return fd;
}

int ringbuf_close(int fd)
{
  if (ringbuf(names[fd], 0, user_ring_bufs[fd].buf))
  {
    printf("Failed to close ringbuf.\n");
    return -1;
  }
  ringbuf_count--;

  return 0;
}
