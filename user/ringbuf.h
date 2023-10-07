#define MAX_USR_RINGBUF 10
#define USR_RINGBUF_SIZE 16
#define PG_SIZE 4096
#define MAX_SIZE 4096*16

struct user_ring_buf
{
  void *buf;
  void *book;
  int exists;
};

struct book {
   uint64 read_done, write_done;
};

// void store(int *p, int v)
// {
//   __atomic_store_8(p, v, __ATOMIC_SEQ_CST);
// }

// int load(int *p)
// {
//   return __atomic_load_8(p, __ATOMIC_SEQ_CST);
// }

int ringbuf_open(void);
int ringbuf_close(int);

void ringbuf_start_read(int ring_desc, char **addr, int *bytes);
void ringbuf_finish_read(int ring_desc, int bytes);
void ringbuf_start_write(int ring_desc, char **addr, int *bytes);
void ringbuf_finish_write(int ring_desc, int bytes);