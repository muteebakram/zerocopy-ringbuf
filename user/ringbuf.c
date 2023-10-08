#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

int ringbuf_count = 0;

const char *names[] = {"Obiwan Kenobi", "Chewbacca", "Ahsoka Tano", "Darth Vader", "Luke Skywalker", "Anakin", "Yoda", "Grogu", "Sebine", "Mandalorian"};

struct user_ring_buf user_ring_bufs[MAX_USR_RINGBUF];

void store(uint64 *p, uint64 v)
{
  __atomic_store_8(p, v, __ATOMIC_SEQ_CST);
}

uint64 load(uint64 *p)
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

void ringbuf_start_read(int ring_desc, char **addr, int *bytes)
{
  char *buf = 0;
  struct book *keep;
  struct user_ring_buf *rb = 0;
  uint64 read, write, src_addr, read_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  buf = (char *)rb->buf;
  keep = (struct book *)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  src_addr = (uint64)buf;
  // Start to read from buf +
  read_addr = src_addr + (read / sizeof(uint64)) + (read % (MAX_RINGBUF_BYTES / sizeof(uint64)));

  *addr = (char *)read_addr;
  *bytes = (write - read);
}

void ringbuf_finish_read(int ring_desc, int bytes)
{
  char *buf = 0;
  struct book *keep;
  struct user_ring_buf *rb = 0;
  uint64 read, write, src_addr, read_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  buf = (char *)rb->buf;
  keep = (struct book *)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  if (bytes > write - read)
    return;

  src_addr = (uint64)buf;
  read_addr = src_addr + ((read + bytes) / sizeof(uint64)) + ((read + bytes) % (MAX_RINGBUF_BYTES / sizeof(uint64)));

  if (read_addr > src_addr + MAX_RINGBUF_BYTES)
  {
    read -= MAX_RINGBUF_BYTES;
    write -= MAX_RINGBUF_BYTES;
  }

  store(&keep->read_done, read);
  store(&keep->write_done, write);
}

void ringbuf_start_write(int ring_desc, char **addr, int *bytes)
{
  char *buf = 0;
  struct book *keep;
  struct user_ring_buf *rb = 0;
  uint64 read, write, src_addr, write_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  buf = (char *)rb->buf;
  keep = (struct book *)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  src_addr = (uint64)buf;
  write_addr = src_addr + write / (sizeof(uint64)) + write % (MAX_RINGBUF_BYTES / sizeof(uint64));

  *addr = (char *)write_addr;
  *bytes = MAX_RINGBUF_BYTES - (write - read);
}

void ringbuf_finish_write(int ring_desc, int bytes)
{
  struct book *keep;
  uint64 read, write;
  struct user_ring_buf *rb = 0;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  keep = (struct book *)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  if (bytes > MAX_RINGBUF_BYTES - (write - read))
    return;

  store(&keep->write_done, write + bytes);
}

int ringbuf_open()
{
  int rd;
  uint64 *buf = (uint64 *)user_ring_bufs[ringbuf_count].buf;
  if (ringbuf(names[ringbuf_count], 1, user_ring_bufs[ringbuf_count].buf))
  {
    printf("Failed to open ringbuf.\n");
    return -1;
  }

  /* Create and map kernel book to userspace book. */

  // Create a userspace book with values initialized to zero.
  struct book book = {.read_done = 0, .write_done = 0};

  // Map the book to particular book of ther user ringbufs
  user_ring_bufs[ringbuf_count].book = &book;

  // Get the virtual page book address from the created ringbuf
  uint64 *book_addr = (uint64 *)(*buf - (MAX_RINGBUF_BYTES));

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
