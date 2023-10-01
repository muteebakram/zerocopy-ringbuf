#define MAX_RINGBUFS 10
#define RINGBUF_SIZE 16
#define RINGBUF_NAME_LEN 16

struct ringbuf
{
    int refcount; // 0 for empty slot
    char name[RINGBUF_NAME_LEN];
    void *buf[RINGBUF_SIZE]; // physical addresses of pages that comprise the ring buffer
    void *book;
};

struct spinlock ringbuf_lock;
struct ringbuf ringbufs[MAX_RINGBUFS];