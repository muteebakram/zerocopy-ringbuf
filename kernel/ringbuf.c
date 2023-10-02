#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "ringbuf.h"

int ringbuf_count;

int mappages_to_proc(struct ringbuf *rb, uint64 base_va, int num_pages, uint64 user_addr)
{
  void *mem;
  uint64 va;

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  for (int i = 0; i < num_pages; i++)
  {
    va = base_va - (i * PGSIZE);
    mem = kalloc(); // Returns phyiscal address of free memory (page).
    if (mem == 0)
    {
      printf("Error: kalloc failed to find free page.\n");
      uvmdealloc(pr->pagetable, va, PGSIZE);
      release(&ringbuf_lock);
      return -1;
    }

    memset(mem, 0, PGSIZE);
    // TODO handle unmap of previoous pages.
    if (mappages(pr->pagetable, va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U | PTE_X) != 0)
    {
      printf("Error: Failed to map page %d of va: %p\n", i, va);
      kfree(mem);
      uvmdealloc(pr->pagetable, va, PGSIZE);
      release(&ringbuf_lock);
      return -1;
    }
    rb->buf[i] = mem;
    printf("Allocated virtual page %d to process. va: %p\n", i, va);
  }

  // Allocate the last page to book.
  rb->book = (void *)(base_va - (num_pages * PGSIZE));
  printf("Book page address: %p\n", (uint64)rb->book);

  // Copy the base va to addr that will be used in user space.
  if (copyout(myproc()->pagetable, user_addr, (char *)&(base_va), sizeof(uint64)) < 0)
  {
    printf("Failed to send base virtual address of contigious pages to userspace.\n");
    release(&ringbuf_lock);
    return -1;
  }

  return 0;
}

int create_ringbuf(const char *name, uint64 addr)
{
  uint64 va, pa, base_va;
  int count = 0, num_contiguous_pages = 18; // 18 pages = 1 guard page + 16 pages + 1 book page.

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  // MAX virtual address - trampoline - trapframe - gurad page.
  base_va = PGROUNDUP(MAXVA - PGSIZE - PGSIZE - PGSIZE);

  acquire(&ringbuf_lock);

  printf("Creating new ringbuf name '%s'", name);
  struct ringbuf new_ringbuf;
  new_ringbuf.refcount = 0; // Set to zero as this is the first process ie mapped to ringbuf.

  // Initialize the name to ringbuf.
  strncpy((char *)new_ringbuf.name, (char *)name, RINGBUF_NAME_LEN);

  // Iterate from base_va to kernel base to find cintiguous pages.
  for (va = base_va; va > KERNBASE; va -= PGSIZE)
  {
    pa = walkaddr(pr->pagetable, va);
    if (pa == 0)
    {
      // Physical address is not mapped and can be used to page allocation.
      count++;
      if (count == num_contiguous_pages)
      {
        printf("Found %d contiguous pages.\nStart: %p, End: %p\n", count, base_va, va);
        break;
      }
    }
    else
    {
      // Reset the base_va to va iterator to find next contiguous pages.
      count = 0;
      base_va = va;
    }
  }

  // Add a guard page i, e top of each ringbuf.
  printf("Guard page address: %p\n", base_va);
  base_va = base_va - PGSIZE;

  if (mappages_to_proc(&new_ringbuf, base_va, 16, addr) != 0)
  {
    printf("Error: Failed to map pages to process.");
    return -1;
  }

  ringbufs[++ringbuf_count] = new_ringbuf;
  printf("Created ringbuf %d of name %s.\n", ringbuf_count, name);
  release(&ringbuf_lock);
  return 0;
}

int append_ringbuf(const char *name)
{
  printf("Appending to ringbuf name '%s'", name);

  struct ringbuf *rb;
  int ringbuf_found = 0;

  // Find the particular ringbuf with name.
  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
  {
    if (strncmp(rb->name, name, RINGBUF_NAME_LEN) == 0)
    {
      ringbuf_found = 1;
      break;
    }
  }

  if (!ringbuf_found)
  {
    printf("Error: Failed to append to ringbuf. Could not find ringbuf %s.\n", name);
    return -1;
  }

  return 0;
}

int ringbuf(const char *name, int open, uint64 addr)
{
  struct ringbuf *rb;
  int ringbuf_exists = 0;

  // Step 1: Check if maximum ringbuf are already allocated.
  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
    if (strncmp(rb->name, "", RINGBUF_NAME_LEN) != 0)
      ringbuf_count++;

  if (ringbuf_count >= MAX_RINGBUFS)
  {
    printf("Maximum # of ringbuf are allocated. Ringbufs count: %d\n", ringbuf_lock);
    return -1;
  }

  // Step 2: Check if ringbuf already exists else create or append ringbufs.
  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
  {
    if (strncmp(rb->name, name, RINGBUF_NAME_LEN) == 0)
    {
      ringbuf_exists = 1;
      break;
    }
  }

  if (!ringbuf_exists && create_ringbuf(name, addr) != 0)
  {
    printf("Error: Failed to create new ringbuf: %s\n", name);
    return -1;
  }
  else if (ringbuf_exists && rb->refcount)
  {
    printf("Error: Ringbuf already mapped into two process.");
    return -1;
  }
  else if (ringbuf_exists && append_ringbuf(name) != 0)
  {
    printf("Error: Failed to append to ringbuf: %s\n", name);
    return -1;
  }

  return 0;
}