#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "ringbuf.h"

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

  printf("Allocated book page. va: %p, pa: %p\n", va, mem);
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
      // Store physical address for first ringbuf.
      rb->buf[i] = mem;
      pa = (uint64)mem;
    }
    else
    {
      // Map same physical address to the append ringbuf.
      pa = (uint64)rb->buf[i];
    }

    // TODO handle unmap of previous pages.
    if (mappages(pr->pagetable, va, PGSIZE, pa, PTE_R | PTE_W | PTE_X | PTE_U) != 0)
    {
      printf("Error: Failed to map page %d of va: %p\n", i, va);
      kfree((void *)pa);
      uvmdealloc(pr->pagetable, va, PGSIZE);
      release(&ringbuf_lock);
      return -1;
    }

    printf("Allocated virtual page %d. va: %p, pa: %p\n", i, va, pa);
  }

  return 0;
}

int validate_pages(pagetable_t pagetable, uint64 va)
{
  if (walkaddr(pagetable, va) == 0)
  {
    printf("Error: Virtual pages are not allocated. va: %p\n", va);
    return -1;
  }
  return 0;
}

int copyout_user_addr(uint64 base_va, uint64 *user_addr)
{
  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  // Copy the base va to addr that will be used in user space.
  if (copyout(pr->pagetable, *user_addr, (char *)&(base_va), sizeof(uint64)) < 0)
  {
    printf("Failed to send base virtual address of contigious pages to userspace.\n");
    release(&ringbuf_lock);
    return -1;
  }

  return 0;
}

int get_ringbuf_index()
{
  struct ringbuf *rb;
  int ringbuf_count = 0;

  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
    if (strncmp(rb->name, "", RINGBUF_NAME_LEN) != 0)
      ringbuf_count++;

  return ringbuf_count;
}

// TODO use this function
int get_ringbuf_by_name(struct ringbuf *rb, const char *name)
{
  // Find the particular ringbuf with name.
  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
    if (strncmp(rb->name, name, RINGBUF_NAME_LEN) == 0)
    {
      return 0;
    }

  return -1;
}

int create_ringbuf(const char *name, uint64 *addr)
{
  uint64 base_va, book_va;
  int ringbuf_index = 0, num_contiguous_pages = 18; // 18 pages = 1 guard page + 16 pages + 1 book page.

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();

  acquire(&ringbuf_lock);

  printf("Creating new ringbuf name '%s' for process %d.\n", name, pr->pid);
  struct ringbuf new_ringbuf;
  new_ringbuf.refcount = 0; // Set to zero as no process is mapped to ringbuf.

  // Initialize the name to ringbuf.
  strncpy((char *)new_ringbuf.name, (char *)name, RINGBUF_NAME_LEN);

  if (find_contiguous_pages(pr->pagetable, &base_va, num_contiguous_pages) != 0)
  {
    printf("Error: Could not find %d contiguous for '%s' ringbuf.", num_contiguous_pages, name);
    return -1;
  }

  // Add a guard page i, e top of each ringbuf.
  printf("Assigned ringbuf guard page address: %p\n", base_va);
  base_va = base_va - PGSIZE;

  // Map contigious pages to proc
  if (mappages_to_proc(&new_ringbuf, base_va, 16) != 0)
  {
    printf("Error: Failed to map pages to process for ringbuf '%s'\n.", name);
    return -1;
  }

  if (validate_pages(pr->pagetable, base_va) != 0)
  {
    printf("Error: Validate contiguous pages for ringbuf '%s' failed.", name);
    return -1;
  }

  // Map book page at the end of Map contigious pages to ringbuf.
  book_va = (base_va - (16 * PGSIZE));
  if (mappage_to_book(&new_ringbuf, book_va) != 0)
  {
    printf("Error: Failed to map page to book for ringbuf '%s'\n.", name);
    return -1;
  }

  if (copyout_user_addr(base_va, addr) != 0)
  {
    printf("Error: Failed to copyout user address for ringbuf '%s'\n", name);
    return -1;
  }

  ringbuf_index = get_ringbuf_index();

  new_ringbuf.refcount += 1;
  new_ringbuf.book = (void *)book_va;
  ringbufs[ringbuf_index] = new_ringbuf;

  printf("Successfully created ringbuf %d of name '%s'.\n", ringbuf_index, name);
  release(&ringbuf_lock);
  return 0;
}

int append_ringbuf(const char *name, uint64 *addr)
{
  struct ringbuf *rb;
  int ringbuf_found = 0, num_contiguous_pages = 18; // 18 pages = 1 guard page + 16 pages + 1 book page.

  struct proc *pr = myproc(); // Get my process to map va to it's pagetable.
  uint64 base_va, book_va;

  // TODO use get_ringbuf_by_name instead of repeated for loops.
  // Find the particular ringbuf with name.
  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
    if (strncmp(rb->name, name, RINGBUF_NAME_LEN) == 0)
    {
      ringbuf_found = 1;
      break;
    }

  if (!ringbuf_found)
  {
    printf("Error: Failed to append to ringbuf. Could not find ringbuf %s.\n", name);
    return -1;
  }

  printf("Appending to ringbuf name '%s' to process %d.\n", name, pr->pid);
  if (find_contiguous_pages(pr->pagetable, &base_va, num_contiguous_pages) != 0)
  {
    printf("Error: Could not find %d contiguous for '%s' ringbuf.", num_contiguous_pages, name);
    return -1;
  }

  // Add a guard page i, e top of each ringbuf.
  printf("Assigned ringbuf guard page address: %p\n", base_va);
  base_va = base_va - PGSIZE;

  // Map contigious pages to proc
  if (mappages_to_proc(rb, base_va, 16) != 0)
  {
    printf("Error: Failed to append ringbuf map pages to process.");
    return -1;
  }

  // Map book page at the end of Map contigious pages to ringbuf.
  book_va = (base_va - (17 * PGSIZE));
  if (mappage_to_book(rb, book_va) != 0)
  {
    printf("Error: Failed to map page to book. RB: %s\n", name);
    return -1;
  }

  if (copyout_user_addr(base_va, addr) != 0)
  {
    printf("Error: Failed to append ringbuf copyout user address. RB: %s\n", name);
    return -1;
  }

  return 0;
}

int unmap_ringbuf(const char *name, uint64 *addr)
{
  struct ringbuf *rb;
  int ringbuf_found = 0, ringbuf_count;

  ringbuf_count = get_ringbuf_index();
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
    printf("Error: Could not find ringbuf %s.\n", name);
    return -1;
  }

  // Get my process to map va to it's pagetable.
  struct proc *pr = myproc();
  printf("Unmapping ringbuf %d '%s' from process %d. vaddr: %p\n", ringbuf_count, rb->name, pr->pid, (uint64)rb->book);

  if (validate_pages(pr->pagetable, (uint64)rb->book) != 0)
  {
    printf("Error: Validate contiguous pages for ringbuf '%s' failed.", name);
    return -1;
  }

  rb->refcount--;
  uvmunmap(pr->pagetable, (uint64)rb->book, 15, rb->refcount);

  if (rb->refcount <= 0)
  {
    // Reset name to empty.
    strncpy((char *)rb->name, (char *)"", RINGBUF_NAME_LEN);

    // Set buf to zero to clear physical memory address.
    for (int i = 0; i < RINGBUF_SIZE; i++)
      rb->buf[i] = 0;

    // Delete the reference to book.
    rb->book = 0;
    printf("Deleted ringbuf %d from ringbufs.\n", ringbuf_count, get_ringbuf_index());
  }

  return 0;
}

int ringbuf(const char *name, int open, uint64 *addr)
{
  struct ringbuf *rb;
  int ringbuf_exists = 0, ringbuf_count = 0;

  // Step 1: Check if maximum ringbuf are already allocated.
  ringbuf_count = get_ringbuf_index();
  if (ringbuf_count >= MAX_RINGBUFS)
  {
    printf("Maximum # of ringbuf are allocated. Ringbufs count: %d\n", ringbuf_count);
    return -1;
  }
  printf("Current number of ringbufs: %d\n", ringbuf_count);

  // Step 2: Check if ringbuf name is greater than 16.
  int name_len = strlen(name);
  if (name_len > 16)
  {
    printf("Error: Cannot create ringbuf name '%s' is too long (%d). Allowed: %d \n", name, name_len, RINGBUF_NAME_LEN);
    return -1;
  }

  // Step 3: Check if ringbuf already exists else create or append ringbufs.
  for (rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++)
  {
    if (strncmp(rb->name, name, RINGBUF_NAME_LEN) == 0)
    {
      ringbuf_exists = 1;
      break;
    }
  }

  if (open)
  {
    if (!ringbuf_exists && create_ringbuf(name, addr) != 0)
    {
      printf("Error: Failed to create new ringbuf '%s'\n", name);
      return -1;
    }
    else if (ringbuf_exists && append_ringbuf(name, addr) != 0)
    {
      printf("Error: Failed to append to ringbuf '%s'\n", name);
      return -1;
    }
  }
  else
  {
    // Delete/Unmap the ringbuf from the user.
    if (unmap_ringbuf(name, addr) != 0)
    {
      printf("Error: Failed to unmap ringbuf '%s'\n", name);
      return -1;
    }
  }

  return 0;
}