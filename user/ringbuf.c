#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"
#include "user/ringbuf.h"

int ringbuf_count = 0;

const char *names[] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"};

struct user_ring_buf user_ring_bufs[MAX_USR_RINGBUF];

void store(int *p, int v)
{
  __atomic_store_8(p, v, __ATOMIC_SEQ_CST);
}

int load(int *p)
{
  return __atomic_load_8(p, __ATOMIC_SEQ_CST);
}

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

void ringbuf_start_read(int ring_desc, char *addr, int *bytes)
{
  struct user_ring_buf rb;
  if (get_ringbuf_by_rd(ring_desc, &rb) != 0)
    return;

  rb = user_ring_bufs[ring_desc];

  uint64 *buf = (uint64 *)rb.buf;
  struct book *book = (struct book *)rb.book;

  uint64 read = load((int *)book->read_done);
  uint64 write = load((int *)book->write_done);

  // TODO Trying to write formula to get the read addr and how many bytes available.
  read = read % (16 * PGSIZE);
  write = write % (16 * PGSIZE);

  addr = (char *)(*buf + read % 16);
  bytes = (int *)(write - read);
  printf("buf: %c\n", addr);
  printf("book: %d\n", bytes);
}

void ringbuf_finish_read(int ring_desc, int bytes)
{
}

void ringbuf_start_write(int ring_desc, char **addr, int *bytes)
{
  struct user_ring_buf rb;
  if (get_ringbuf_by_rd(ring_desc, &rb) != 0)
    return;

  rb = user_ring_bufs[ring_desc];
  struct book *book = (struct book *)(rb.buf - (16 * PGSIZE));
  printf("write buf_addr: %p\n", book->write_done);
}

void ringbuf_finish_write(int ring_desc, int bytes)
{
}

int ringbuf_open()
{
  int rd;
  uint64 *buf = (uint64 *)user_ring_bufs[ringbuf_count].buf;
  if (ringbuf(names[ringbuf_count], 1, buf))
  {
    printf("Failed to open ringbuf.\n");
    return -1;
  }

  /* Create and map kernel book to userspace book. */

  // Create a userspace book with values initialized to zero.
  struct book book = {.read_done = 0, .write_done = 512};

  // Map the book to particular book of ther user ringbufs
  user_ring_bufs[ringbuf_count].book = &book;

  // Get the virtual page book address from the created ringbuf
  uint64 *book_addr = (uint64 *)(*buf - (16 * PGSIZE));

  // Move the userspace book contents to the virtual page book address.
  memmove(book_addr, user_ring_bufs[ringbuf_count].book, sizeof(struct book));

  // To test if the book (virtual page book) has the userspace book.
  // struct book *book_test;
  // book_test = (struct book *)book_addr;
  // printf("ringbuf_open book value: %p\n", book_test->read_done);

  // Now map the user ringbuf book to the book addr so that we can directly right to kernel mapped book with user_ring_buf.book
  user_ring_bufs[ringbuf_count].book = (void *)book_addr;

  /* Map the kernel sent virtual addr to the userspace ringbuf addr */
  user_ring_bufs[ringbuf_count].buf = (void *)buf;
  // printf("user_ring_bufs[ringbuf_count].buf value: %p\n", *(uint64 *)(user_ring_bufs[ringbuf_count].buf));

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
