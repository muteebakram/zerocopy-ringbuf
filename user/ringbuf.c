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

  printf("book addr with book: %p\n", (uint64 *)rb.book);
  struct book *book2 = (struct book *)rb.book;
  book2->read_done = 2;
  printf("book value with book: %p\n", book2->read_done);

  uint64 rb_book_addr = *(uint64 *)rb.buf - (16 * PGSIZE);

  struct book *book = (struct book *)rb_book_addr;
  printf("book value with buf: %p\n", book->read_done);
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
  struct book book = {.read_done = 10, .write_done = 0};

  // Map the book to particular book of ther user ringbufs
  user_ring_bufs[ringbuf_count].book = &book;

  // Get the virtual page book address from the created ringbuf
  uint64 *book_addr = (uint64 *)(*buf - (16 * PGSIZE));

  // Move the userspace book contents to the virtual page book address.
  memmove(book_addr, user_ring_bufs[ringbuf_count].book, sizeof(struct book));

  // To test if the book (virtual page book) has the userspace book.
  struct book *book_test;
  book_test = (struct book *)book_addr;
  printf("ringbuf_open book value: %p\n", book_test->read_done);

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
