#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

int ringbuf_count = 0;

const char *names[] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"};

struct user_ring_buf user_ring_bufs[MAX_USR_RINGBUF];

int get_ringbuf_by_rd(int rd, struct user_ring_buf *rb)
{
  if (rd < 0)
  {
    printf("Invalid ring descriptor: %d\n", rd);
    return -1;
  }

  for (int i = 0; i < MAX_USR_RINGBUF; i++)
  {
    if (i == rd)
    {
      *rb = user_ring_bufs[i];
      return 0;
    }
  }

  printf("Could not find the ringbuf for ring descriptor: %d\n", rd);
  return -1;
}

void ringbuf_start_read(int ring_desc, char **addr, int *bytes)
{
  struct user_ring_buf rb;
  if (get_ringbuf_by_rd(ring_desc, &rb) != 0)
    return;

  printf("ringbuf_start_read name: %d\n", rb.exists);
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
  int rd;
  if (ringbuf(names[ringbuf_count], 1, user_ring_bufs[ringbuf_count].buf))
  {
    printf("Failed to open ringbuf.\n");
    return -1;
  }
  rd = ringbuf_count;
  ringbuf_count++;

  return rd;
}

int ringbuf_close(int rd)
{
  if (ringbuf(names[rd], 0, user_ring_bufs[rd].buf))
  {
    printf("Failed to close ringbuf.\n");
    return -1;
  }
  ringbuf_count--;

  return 0;
}
