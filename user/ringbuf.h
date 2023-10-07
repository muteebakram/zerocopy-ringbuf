#define MAX_USR_RINGBUF 10

struct book
{
  uint64 read_done;
  uint64 write_done;
};

struct user_ring_buf
{
  void *buf;
  void *book;
  int exists;
};

int ringbuf_open(void);
int ringbuf_close(int);

void ringbuf_start_read(int ring_desc, char *addr, int *bytes);
void ringbuf_finish_read(int ring_desc, int bytes);
void ringbuf_start_write(int ring_desc, char **addr, int *bytes);
void ringbuf_finish_write(int ring_desc, int bytes);