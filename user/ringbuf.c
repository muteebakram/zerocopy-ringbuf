#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

struct user_ring_buf user_ring_bufs[MAX_USR_RINGBUF];

uint64 load(uint64 *p) { return __atomic_load_8(p, __ATOMIC_SEQ_CST); }
void store(uint64 *p, uint64 v) { __atomic_store_8(p, v, __ATOMIC_SEQ_CST); }

int is_rd_valid(int rd)
{
  if (rd < 0 || rd > MAX_USR_RINGBUF || user_ring_bufs[rd].exists == 0)
  {
    printf("Invalid ring descriptor or ring buffer does not exists: %d", rd);
    return -1;
  }

  return 0;
}

void ringbuf_start_read(int rd, char **addr, int *bytes)
{
  if (is_rd_valid(rd) != 0)
    exit(1);

  struct book *keep;
  struct user_ring_buf *rb = &user_ring_bufs[rd];
  uint64 read, write, src_addr, read_addr;

  keep = (struct book *)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  src_addr = (uint64)rb->buf;
  read_addr = src_addr + (read % MAX_RINGBUF_BYTES);

  *addr = (char *)read_addr;
  *bytes = (int)(write - read);
}

void ringbuf_finish_read(int rd, int bytes)
{
  if (is_rd_valid(rd) != 0)
    exit(1);

  struct book *keep;
  uint64 read, write;
  struct user_ring_buf *rb = &user_ring_bufs[rd];

  keep = (struct book *)rb->book;
  read = load(&keep->read_done);
  write = load(&keep->write_done);

  if (bytes > write - read)
    return;

  if (bytes <= write)
    store(&keep->read_done, read + bytes);
}

void ringbuf_start_write(int rd, char **addr, int *bytes)
{
  if (is_rd_valid(rd) != 0)
    exit(1);

  struct book *keep;
  struct user_ring_buf *rb = &user_ring_bufs[rd];
  uint64 read, write, src_addr, write_addr;

  keep = (struct book *)rb->book;
  read = load(&keep->read_done);
  write = load(&keep->write_done);

  src_addr = (uint64)rb->buf;
  write_addr = src_addr + write % (MAX_RINGBUF_BYTES);

  *addr = (char *)write_addr;
  *bytes = (int)(MAX_RINGBUF_BYTES - (write - read));
}

void ringbuf_finish_write(int rd, int bytes)
{
  if (is_rd_valid(rd) != 0)
    exit(1);

  struct book *keep;
  uint64 read, write;
  struct user_ring_buf *rb = &user_ring_bufs[rd];

  keep = (struct book *)rb->book;
  read = load(&keep->read_done);
  write = load(&keep->write_done);

  if (bytes > MAX_RINGBUF_BYTES - (write - read))
  {
    printf("Write exceeded read.\n");
    exit(1);
  }

  store(&keep->write_done, write + bytes);
}

int ringbuf_open(char *name)
{
  int i = 0;
  uint64 addr;
  if (ringbuf(name, 1, &addr) != 0)
  {
    printf("Failed to open ringbuf\n");
    return -1;
  }

  for (; i < MAX_USR_RINGBUF; i++)
  {
    if (user_ring_bufs[i].exists != 1)
    {
      /**
       * @brief What's happening in next two lines?
       *
       * Organization of virtual pages: MAXVA ....  1 guard page + 32 buf pages + 1 book page ... 0
       *
       * Kernel sends the top higher address close to MAXVA address of the 33 contigious pages.
       * But we need the bottom virtual address of the ringbuf i,e 32nd page.
       *
       * Therefore, to get the bottom of buffer go 31 pages below & to get book go one more page below.
       */
      uint64 buf = addr - ((2 * USR_RINGBUF_SIZE) - 1) * PGSIZE;
      uint64 book = buf - PGSIZE;

      user_ring_bufs[i].buf = (void *)buf;
      user_ring_bufs[i].book = (void *)book;
      user_ring_bufs[i].exists = 1;
      return i;
    }
  }
  return -1;
}

int ringbuf_close(int rd, char *name)
{
  if (is_rd_valid(rd) != 0)
    exit(1);

  /**
   * @brief What's happening in next two lines?
   *
   * Get the buf from user_ring_bufs and change the buf to point to the first virtual page close to MAXVA.
   * From that addr kernel can unmap the next 33 contigious pages
   */

  uint64 addr = (uint64)user_ring_bufs[rd].buf;
  addr = addr + ((2 * USR_RINGBUF_SIZE) - 1) * PGSIZE;

  if (ringbuf(name, 0, &addr) != 0)
  {
    printf("Failed to close ringbuf\n");
    return -1;
  }

  user_ring_bufs[rd].exists = 0;
  user_ring_bufs[rd].buf = (void *)0;
  user_ring_bufs[rd].book = (void *)0;

  return 0;
}
