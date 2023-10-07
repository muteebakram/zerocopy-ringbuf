#include "kernel/types.h"
#include "user/user.h"
#include "user/ringbuf.h"

void store(uint64 *p, uint64 v) {
  __atomic_store_8(p, v, __ATOMIC_SEQ_CST);
}
uint64 load(uint64 *p) {
  return __atomic_load_8(p, __ATOMIC_SEQ_CST);
}

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
  struct user_ring_buf *rb = 0;
  struct book* keep;
  char *buf = 0;
  uint64 read, write, src_addr, final_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  printf("ringbuf_start_read name: %d\n", rb->exists);

  buf = (char *)rb->buf;
  keep = (struct book*)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  src_addr = (uint64)buf;
  final_addr = src_addr + read/(sizeof(uint64)) + read%(USR_RINGBUF_SIZE*PG_SIZE/sizeof(uint64));
  *addr = (char *)final_addr;
  *bytes = (write - read);

}
void ringbuf_finish_read(int ring_desc, int bytes)
{
  struct user_ring_buf *rb = 0;
  char *buf = 0;
  struct book* keep;
  uint64 read, write, src_addr, final_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  printf("ringbuf_finish_read name: %d\n", rb->exists);

  buf = (char *)rb->buf;
  keep = (struct book*)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  if(write - read < bytes)
    return;

  src_addr = (uint64)buf;
  final_addr = src_addr + (read+bytes)/(sizeof(uint64)) + (read+bytes)%(USR_RINGBUF_SIZE*PG_SIZE/sizeof(uint64));

  if(final_addr > src_addr + USR_RINGBUF_SIZE*PG_SIZE){
    read =- USR_RINGBUF_SIZE*PG_SIZE;
    write =- USR_RINGBUF_SIZE*PG_SIZE;
  }

  store(&keep->read_done, read);
  store(&keep->write_done, write);
}

void ringbuf_start_write(int ring_desc, char **addr, int *bytes)
{
  struct user_ring_buf *rb = 0;
  struct book* keep;
  char *buf = 0;
  uint64 read, write, src_addr, final_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  printf("ringbuf_start_write name: %d\n", rb->exists);

  buf = (char *)rb->buf;
  keep = (struct book*)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  src_addr = (uint64)buf;
  final_addr = src_addr + write/(sizeof(uint64)) + write%(USR_RINGBUF_SIZE*PG_SIZE/sizeof(uint64));
  *addr = (char *)final_addr;
  *bytes = MAX_SIZE - (write - read);
}

void ringbuf_finish_write(int ring_desc, int bytes)
{
  struct user_ring_buf *rb = 0;
  //char *buf = 0;
  struct book* keep;
  uint64 read, write; //src_addr, final_addr;

  if (get_ringbuf_by_rd(ring_desc, rb) != 0)
    return;

  printf("ringbuf_finish_write name: %d\n", rb->exists);

  //buf = (char *)rb->buf;
  keep = (struct book*)rb->book;

  read = load(&keep->read_done);
  write = load(&keep->write_done);

  if(MAX_SIZE - (write - read) < bytes)
    return;

  //src_addr = (uint64)buf;
  //final_addr = src_addr + (read+bytes)/(sizeof(uint64)) + (read+bytes)%(USR_RINGBUF_SIZE*PG_SIZE/sizeof(uint64));

  store(&keep->write_done, write+bytes);
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
