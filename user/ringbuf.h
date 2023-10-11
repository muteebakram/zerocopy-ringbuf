#define PGSIZE 4096
#define MAX_USR_RINGBUF 10
#define USR_RINGBUF_SIZE 16
#define MAX_RINGBUF_BYTES USR_RINGBUF_SIZE *PGSIZE

struct user_ring_buf
{
  void *buf;
  void *book;
  int exists;
};

struct book
{
  uint64 read_done, write_done;
};

int ringbuf_open(char *name);
int ringbuf_close(int rd, char *name);

void ringbuf_start_read(int ring_desc, char **addr, int *bytes);
void ringbuf_finish_read(int ring_desc, int bytes);
void ringbuf_start_write(int ring_desc, char **addr, int *bytes);
void ringbuf_finish_write(int ring_desc, int bytes);