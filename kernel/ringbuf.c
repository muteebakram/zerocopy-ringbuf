#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "ringbuf.h"

int ringbuf_count;

int find_contiguous_pages(pagetable_t pagetable, uint64 *base_va, int num_contiguous_pages)
{
  uint64 va, pa;
  int count = 0, found = 0;

  // MAX virtual address - trampoline - trapframe - gurad page.
  *base_va = PGROUNDUP(MAXVA - PGSIZE - PGSIZE - PGSIZE);

  // Iterate from base_va to kernel base to find contiguous pages.
  for (va = *base_va; va > KERNBASE; va -= PGSIZE)
  {
    pa = walkaddr(pagetable, va);
    if (pa == 0)
    {
      // Physical address is not mapped and can be used to page allocation.
      count++;
      // printf("Found %d contiguous virtual pages. va: %p\n", count, va);
      if (count == num_contiguous_pages)
      {
        printf("Found %d contiguous virtual pages.\nStart: %p, End: %p\n", count, *base_va, va);
        found = 1;
        break;
      }
    }
    else
    {
      // Reset the base_va to va iterator to find next contiguous pages.
      // printf("Reset %d contiguous virtual pages. va: %p\n", count, va);
      count = 0;
      *base_va = va;
    }
  }

  if (!found)
    return -1;

  return 0;
}

int mappage_to_book(struct ringbuf *rb, uint64 va)
{
  void *mem;

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  mem = kalloc(); // Returns phyiscal address of free memory (page).
  if (mem == 0)
  {
    printf("Error: kalloc failed to find free page.\n");
    uvmdealloc(pr->pagetable, va, PGSIZE);
    release(&ringbuf_lock);
    return -1;
  }

  memset(mem, 0, PGSIZE);
  if (mappages(pr->pagetable, va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U | PTE_X) != 0)
  {
    printf("Error: Failed to map page %d of va: %p\n", va);
    kfree(mem);
    uvmdealloc(pr->pagetable, va, PGSIZE);
    release(&ringbuf_lock);
    return -1;
  }
  rb->book = mem;

  printf("Allocated book page. va: %p, pa: %p\n", va, (uint64)rb->book);
  return 0;
}

int mappages_to_proc(struct ringbuf *rb, uint64 base_va, int num_pages)
{
  void *mem;
  uint64 va, pa;

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
    if (rb->refcount == 0)
    {
      // Store physical address to first ringbuf.
      rb->buf[i] = mem;
      pa = (uint64)mem;
    }
    else
    {
      // Map same physical address to the append ringbuf.
      pa = (uint64)rb->buf[i];
    }

    // TODO handle unmap of previous pages.
    if (mappages(pr->pagetable, va, PGSIZE, pa, PTE_R | PTE_W | PTE_U | PTE_X) != 0)
    {
      printf("Error: Failed to map page %d of va: %p\n", i, va);
      kfree(mem);
      uvmdealloc(pr->pagetable, va, PGSIZE);
      release(&ringbuf_lock);
      return -1;
    }

    printf("Allocated virtual page %d to process. va: %p, pa: %p\n", i, va, pa);
  }

  return 0;
}

int copyout_user_addr(uint64 base_va, uint64 user_addr)
{
  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  // Copy the base va to addr that will be used in user space.
  if (copyout(pr->pagetable, user_addr, (char *)&(base_va), sizeof(uint64)) < 0)
  {
    printf("Failed to send base virtual address of contigious pages to userspace.\n");
    release(&ringbuf_lock);
    return -1;
  }

  return 0;
}

int create_ringbuf(const char *name, uint64 addr)
{
  uint64 base_va, book_va;
  int num_contiguous_pages = 18; // 18 pages = 1 guard page + 16 pages + 1 book page.

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  acquire(&ringbuf_lock);

  printf("Creating new ringbuf name '%s'\n", name);
  struct ringbuf new_ringbuf;
  new_ringbuf.refcount = 0; // Set to zero as this is the first process ie mapped to ringbuf.

  // Initialize the name to ringbuf.
  strncpy((char *)new_ringbuf.name, (char *)name, RINGBUF_NAME_LEN);

  if (find_contiguous_pages(pr->pagetable, &base_va, num_contiguous_pages) != 0)
  {
    printf("Error: Could not find %d contiguous for '%s' ringbuf.", num_contiguous_pages, name);
    return -1;
  }

  // Add a guard page i, e top of each ringbuf.
  printf("Guard page address: %p\n", base_va);
  base_va = base_va - PGSIZE;
  if (mappages_to_proc(&new_ringbuf, base_va, 16) != 0)
  {
    printf("Error: Failed to map pages to process.");
    return -1;
  }

  book_va = (base_va - (17 * PGSIZE));
  if (mappage_to_book(&new_ringbuf, book_va) != 0)
  {
    printf("Error: Failed to map page to book.");
    return -1;
  }

  if (copyout_user_addr(base_va, addr) != 0)
  {
    printf("Error: Failed to copyout user address.\n");
    return -1;
  }

  new_ringbuf.refcount += 1;
  ringbufs[++ringbuf_count] = new_ringbuf;

  printf("Successfully created ringbuf %d of name %s.\n", ringbuf_count, name);
  release(&ringbuf_lock);
  return 0;
}

int append_ringbuf(const char *name, uint64 addr)
{
  printf("Appending to ringbuf name '%s'\n", name);

  struct ringbuf *rb;
  int ringbuf_found = 0, num_contiguous_pages = 18; // 18 pages = 1 guard page + 16 pages + 1 book page.

  uint64 base_va, book_va;

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

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

  if (find_contiguous_pages(pr->pagetable, &base_va, num_contiguous_pages) != 0)
  {
    printf("Error: Could not find %d contiguous for '%s' ringbuf.", num_contiguous_pages, name);
    return -1;
  }

  // Add a guard page i, e top of each ringbuf.
  printf("Guard page address: %p\n", base_va);
  base_va = base_va - PGSIZE;
  if (mappages_to_proc(rb, base_va, 16) != 0)
  {
    printf("Error: Failed to map pages to process.");
    return -1;
  }

  book_va = (base_va - (17 * PGSIZE));
  if (mappage_to_book(rb, book_va) != 0)
  {
    printf("Error: Failed to map page to book. RB: %s\n", name);
    return -1;
  }

  if (copyout_user_addr(base_va, addr) != 0)
  {
    printf("Error: Failed to copyout user address. RB: %s\n", name);
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
  else if (ringbuf_exists && append_ringbuf(name, addr) != 0)
  {
    printf("Error: Failed to append to ringbuf: %s\n", name);
    return -1;
  }

  return 0;
}