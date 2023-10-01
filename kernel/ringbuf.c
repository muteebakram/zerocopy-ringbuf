// #include "types.h"
// #include "param.h"
// #include "memlayout.h"
// #include "riscv.h"
// #include "spinlock.h"
// #include "proc.h"
// #include "defs.h"
// #include "ringbuf.h"

// int create_ringbuf()
// {
//   struct ringbuf new_ringbuf;
//   new_ringbuf.refcount = 0;
//   strncpy((char *)new_ringbuf.name, (char *)name, RINGBUF_NAME_LEN); // copy name

//   void *mem;
//   void **abs = new_ringbuf.buf;
//   int count = 0, num_contiguous_pages = 18; // 18 pages = 1 guard page + 16 pages + 1 book page.

//   uint64 va, pg, base_va;
//   struct proc *pr = myproc();

//   // MAX virtual address - trampoline - trapframe - gurad page.
//   base_va = PGROUNDUP(MAXVA - PGSIZE - PGSIZE - PGSIZE);

//   // Iterate from base_va to kernel base to find cintiguous pages.
//   for (va = base_va; va > KERNBASE; va -= PGSIZE)
//   {
//     pa = walkaddr(pr->pagetable, va);
//     if (pa == 0)
//     {
//       // Physical address is not mapped and can be used to page allocation.
//       count++;
//       if (count == 18)
//       {
//         printf("Found contiguous %d pages end: %p\n", count, va);
//         break;
//       }
//     }
//     else
//     {
//       // Reset the base_va to va iterator to find next contiguous pages.
//       count = 0;
//       base_va = va;
//     }
//   }
//   printf("Staring virtual address (base) of %d pages: %p\n", count, base_va);

//   // start from 1 because allocate gurad page at top
//   for (int i = 1; i <= 16; i++)
//   {
//     a = base_va - (i * PGSIZE);
//     mem = kalloc(); // Physcall address
//     if (mem == 0)
//     {
//       uvmdealloc(pr->pagetable, a, PGSIZE);
//       return -1;
//     }

//     memset(mem, 0, PGSIZE);
//     printf("allocated page i: %d, va: %p\n", i, a);

//     // TODO handle unmap of previoous pages.
//     if (mappages(pr->pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U | PTE_X) != 0)
//     {
//       printf("Error: Failed to map page %d of va: %p\n", i, a);
//       kfree(mem);
//       uvmdealloc(pr->pagetable, a, PGSIZE);
//       return -1;
//     }

//     *(abs + i - 1) = mem;
//   }
//   char *str = "Hello";
//   strncpy((char *)mem, str, RINGBUF_NAME_LEN);

//   new_ringbuf.book = &base_va - (17 * PGSIZE);
//   printf("mem: %s\n", (char *)new_ringbuf.buf[15]);
//   uint64 temp = base_va - (16 * PGSIZE);
//   if (copyout(myproc()->pagetable, addr, (char *)&(temp), sizeof(uint64)) < 0)
//   {
//     printf("Failed to perform copyout operation\n");
//     return -1;
//   }
//   printf("before addr: %p, temp: %p, buf: %p\n", addr, temp, new_ringbuf.buf[0]);

//   printf("book: %p, base_va: %p, addr: %p\n", new_ringbuf.book, base_va, (uint64)addr);
//   ringbufs[++ringbuf_count] = new_ringbuf;
// }

// int ringbuf(const char *name, int open, uint64 addr)
// {
//   struct ringbuf *rb;
//   int ringbuf_count = 0;
//   bool ringbuf_exists = false;

//   // Step 1: Check if maximum ringbuf are already allocated.
//   for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
//     if (strncmp(rb->name, "", RINGBUF_NAME_LEN) != 0)
//       ringbuf_count++;

//   if (ringbuf_count >= MAX_RINGBUFS)
//   {
//     printf("Maximum # of ringbuf are allocated. Ringbufs count: %d\n", ringbuf_lock);
//     return -1;
//   }

//   // Step 2: Check if ringbuf already exists else create or append ringbufs.
//   for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
//   {
//     if (strncmp(rb->name, name, RINGBUF_NAME_LEN) == 0)
//     {
//       ringbuf_exists = 1;
//       break;
//     }
//   }

//   if (!ringbuf_exists && create_ringbuf() != 0)
//   {
//     printf("Failed to create new ringuf: %s\n", name);
//     return -1;
//   }
//   else if (append_ringbuf() != 0)
//   {
//     printf("Failed to append to ringuf: %s\n", name);
//     return -1;
//   }

//   return 0;
// }