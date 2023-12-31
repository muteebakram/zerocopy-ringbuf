#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "ringbuf.h"

#define KLOG 1

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
      ++count;
      // if (KLOG) printf("Found %d contiguous virtual pages. va: %p\n", count, va);
      if (count == num_contiguous_pages)
      {
        if (KLOG)
          printf("Found %d contiguous virtual pages.\nStart: %p, End: %p\n", count, *base_va, va);
        found = 1;
        break;
      }
    }
    else
    {
      // Reset the base_va to va iterator to find next contiguous pages.
      // if (KLOG) printf("Reset %d contiguous virtual pages. va: %p\n", count, va);
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
  struct proc *pr = myproc();
  if (rb->refcount == 0)
  {
    void *mem;

    mem = kalloc(); // Returns phyiscal address of free memory (page).
    if (mem == 0)
    {
      if (KLOG)
        printf("Error: kalloc failed to find free page.\n");
      uvmdealloc(pr->pagetable, va, PGSIZE);
      return -1;
    }

    memset(mem, 0, PGSIZE);
    if (mappages(pr->pagetable, va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U | PTE_X) != 0)
    {
      if (KLOG)
        printf("Error: Failed to map page %d of va: %p\n", va);
      kfree(mem);
      uvmdealloc(pr->pagetable, va, PGSIZE);
      return -1;
    }

    rb->book = mem;
    if (KLOG)
      printf("Newly allocated book page. va: %p, pa: %p\n", va, rb->book);
    return 0;
  }
  else
  {
    if (mappages(pr->pagetable, va, PGSIZE, (uint64)rb->book, PTE_R | PTE_W | PTE_U | PTE_X) != 0)
    {
      if (KLOG)
        printf("Error: Failed to map page %d of va: %p\n", va);
      kfree(rb->book);
      uvmdealloc(pr->pagetable, va, PGSIZE);
      return -1;
    }
    if (KLOG)
      printf("Re-allocated book page for ringbuf '%s'. va: %p\n", rb->name, va);
  }

  return 0;
}

int mappages_to_proc(struct ringbuf *rb, uint64 base_va, int num_pages)
{
  void *mem;
  uint64 va, pa;

  struct proc *pr = myproc();

  if (rb->refcount < 0)
  {
    if (KLOG)
      printf("Error: Invalid refcount %d.", rb->refcount == 0);
    return -1;
  }
  else if (rb->refcount == 0) // When ref=0 need to create physical memory and map them to virtual pages twice.
  {
    for (int i = 0; i < num_pages; i++)
    {
      va = base_va - (i * PGSIZE);

      // Map once: Create physical memory and store the address in ringbuf.buf
      if (i < RINGBUF_SIZE)
      {
        mem = kalloc(); // Returns phyiscal address of free memory (page).
        if (mem == 0)
        {
          if (KLOG)
            printf("Error: kalloc failed to find free page.\n");
          uvmdealloc(pr->pagetable, va, PGSIZE);
          return -1;
        }
        memset(mem, 0, PGSIZE);
        rb->buf[i] = mem; // Store physical address for first 16 contigious virtual address. ringbuf.
        pa = (uint64)mem;
      }
      else
      {
        // Map twice: Get the physical memory to map the virtual page to same memory.
        pa = (uint64)rb->buf[i % RINGBUF_SIZE];
      }

      // TODO handle unmap of previous pages.
      if (mappages(pr->pagetable, va, PGSIZE, pa, PTE_R | PTE_W | PTE_X | PTE_U) != 0)
      {
        if (KLOG)
          printf("Error: Failed to map page %d of va: %p\n", i, va);
        kfree((void *)pa);
        uvmdealloc(pr->pagetable, va, PGSIZE);
        return -1;
      }

      if (KLOG)
        printf("Newly allocated virtual page %d. va: %p, pa: %p\n", i, va, pa);
    }
  }
  else // When ref>0 map only the new virtual pages to same physical memory.
  {
    for (int i = 0; i < num_pages; i++)
    {
      va = base_va - (i * PGSIZE);
      pa = (uint64)rb->buf[i % RINGBUF_SIZE]; // Map same physical address to the append ringbuf.

      if (mappages(pr->pagetable, va, PGSIZE, pa, PTE_R | PTE_W | PTE_X | PTE_U) != 0)
      {
        if (KLOG)
          printf("Error: Failed to map page %d of va: %p\n", i, va);
        kfree((void *)pa);
        uvmdealloc(pr->pagetable, va, PGSIZE);
        return -1;
      }
      if (KLOG)
        printf("Reallocated virtual page %d. va: %p, pa: %p\n", i, va, pa);
    }
  }

  return 0;
}

int validate_pages(pagetable_t pagetable, uint64 va)
{
  if (walkaddr(pagetable, va) == 0)
  {
    if (KLOG)
      printf("Error: Virtual pages are not allocated. va: %p\n", va);
    return -1;
  }

  return 0;
}

int copyout_user_addr(uint64 base_va, uint64 user_addr)
{

  struct proc *pr = myproc();

  // Copy the base va to addr that will be used in user space.
  if (copyout(pr->pagetable, user_addr, (char *)&(base_va), sizeof(uint64)) < 0)
  {
    if (KLOG)
      printf("Failed to send base virtual address of contigious pages to userspace.\n");
    return -1;
  }

  if (KLOG)
    printf("Copyout addr to userspace: %p\n", base_va);
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

int create_ringbuf(const char *name, uint64 addr)
{
  uint64 base_va, book_va;
  int ringbuf_index = 0, num_contiguous_pages = 1 + (2 * RINGBUF_SIZE) + 1; // 34 pages = 1 guard page + 32 pages + 1 book page.

  struct proc *pr = myproc();

  if (KLOG)
    printf("Creating new ringbuf name '%s' for process %d.\n", name, pr->pid);
  struct ringbuf new_ringbuf;
  new_ringbuf.refcount = 0; // Set to zero as no process is mapped to ringbuf.

  // Initialize the name to ringbuf.
  strncpy((char *)new_ringbuf.name, (char *)name, RINGBUF_NAME_LEN);

  if (find_contiguous_pages(pr->pagetable, &base_va, num_contiguous_pages) != 0)
  {
    if (KLOG)
      printf("Error: Could not find %d contiguous for '%s' ringbuf.", num_contiguous_pages, name);
    return -1;
  }

  // Add a guard page i, e top of each ringbuf.
  if (KLOG)
    printf("Assigned ringbuf guard page address: %p\n", base_va);

  // Map contigious pages to proc
  base_va = base_va - PGSIZE;
  if (mappages_to_proc(&new_ringbuf, base_va, 2 * RINGBUF_SIZE) != 0)
  {
    if (KLOG)
      printf("Error: Failed to map pages to process for ringbuf '%s'\n.", name);
    return -1;
  }

  if (validate_pages(pr->pagetable, base_va) != 0)
  {
    if (KLOG)
      printf("Error: Validate contiguous pages mapping for ringbuf '%s' failed.", name);
    return -1;
  }

  // Map book page at the end of Map contigious pages to ringbuf.
  book_va = (base_va - (2 * RINGBUF_SIZE * PGSIZE));
  if (mappage_to_book(&new_ringbuf, book_va) != 0)
  {
    if (KLOG)
      printf("Error: Failed to map page to book for ringbuf '%s'\n.", name);
    return -1;
  }

  if (validate_pages(pr->pagetable, book_va) != 0)
  {
    if (KLOG)
      printf("Error: Validate book page mapping for ringbuf '%s' failed.", name);
    return -1;
  }

  if (copyout_user_addr(base_va, addr) != 0)
  {
    if (KLOG)
      printf("Error: Failed to copyout user address for ringbuf '%s'\n", name);
    return -1;
  }

  ringbuf_index = get_ringbuf_index();

  new_ringbuf.refcount += 1;
  ringbufs[ringbuf_index] = new_ringbuf;

  if (KLOG)
    printf("Successfully created ringbuf %d of name '%s'.\n", ringbuf_index, name);
  return 0;
}

int append_ringbuf(const char *name, uint64 addr)
{
  struct ringbuf *rb;
  int ringbuf_found = 0, num_contiguous_pages = 1 + (2 * RINGBUF_SIZE) + 1; // 34 pages = 1 guard page + 32 pages + 1 book page.

  struct proc *pr = myproc();
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
    if (KLOG)
      printf("Error: Failed to append to ringbuf. Could not find ringbuf %s.\n", name);
    return -1;
  }

  if (KLOG)
    printf("Appending to ringbuf name '%s' to process %d.\n", name, pr->pid);
  if (find_contiguous_pages(pr->pagetable, &base_va, num_contiguous_pages) != 0)
  {
    if (KLOG)
      printf("Error: Could not find %d contiguous for '%s' ringbuf.", num_contiguous_pages, name);
    return -1;
  }

  // Add a guard page i, e top of each ringbuf.
  base_va = base_va - PGSIZE;
  if (KLOG)
    printf("Assigned ringbuf guard page address: %p\n", base_va);

  // Map contigious pages to proc after the guard.
  base_va = base_va - PGSIZE;
  if (mappages_to_proc(rb, base_va, 2 * RINGBUF_SIZE) != 0)
  {
    if (KLOG)
      printf("Error: Failed to append ringbuf map pages to process.");
    return -1;
  }

  // Map book page at the end of Map contigious pages to ringbuf.
  book_va = (base_va - (2 * RINGBUF_SIZE * PGSIZE));
  if (mappage_to_book(rb, book_va) != 0)
  {
    if (KLOG)
      printf("Error: Failed to map page to book. RB: %s\n", name);
    return -1;
  }

  if (copyout_user_addr(base_va, addr) != 0)
  {
    if (KLOG)
      printf("Error: Failed to append ringbuf copyout user address. RB: %s\n", name);
    return -1;
  }

  rb->refcount++;
  if (KLOG)
    printf("Successfully appended to ringbuf '%s' for process %d. refcount: %d\n", name, pr->pid, rb->refcount);
  return 0;
}

int unmap_ringbuf_pmem(struct ringbuf *rb)
{
  // Reset name to empty.
  strncpy((char *)rb->name, (char *)"", RINGBUF_NAME_LEN);

  // Delete the reference to book.
  kfree((void *)(uint64)rb->book);

  // clear buf physical memory address.
  for (int i = 0; i < RINGBUF_SIZE; i++)
    kfree(rb->buf[i]);

  return 0;
}

int unmap_ringbuf(const char *name, uint64 addr)
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
    if (KLOG)
      printf("Error: Could not find ringbuf %s.\n", name);
    return -1;
  }

  rb->refcount--;

  struct proc *pr = myproc();

  uint64 usr_buf_pa = walkaddr(pr->pagetable, addr) + (uint64)(addr % 4096);
  uint64 usr_buf_va = *((uint64 *)usr_buf_pa);
  // if (KLOG) printf("usr_buf_addr: %p, usr_buf_pa: %p\nstart usr_buf_va: %p, end usr_buf_va: %p\n", addr, usr_buf_pa, usr_buf_va, usr_buf_va - (15 * PGSIZE));

  if (validate_pages(pr->pagetable, usr_buf_va) != 0)
  {
    if (KLOG)
      printf("Error: Validate contiguous pages for ringbuf '%s' failed.\n", name);
    return -1;
  }

  usr_buf_va = usr_buf_va - ((2 * RINGBUF_SIZE) - 1) * PGSIZE; // Go 33 pages back i,e where 34 contigious pages are.
  if (KLOG)
    printf("Unmapping ringbuf %d '%s' from process %d. vaddr: %p\n", ringbuf_count, rb->name, pr->pid, usr_buf_va);
  uvmunmap(pr->pagetable, usr_buf_va, 2 * RINGBUF_SIZE, 0);

  if (KLOG)
    printf("Unmapping ringbuf book page: %p\n", usr_buf_va - PGSIZE);
  uvmunmap(pr->pagetable, usr_buf_va - PGSIZE, 1, 0);

  if (rb->refcount == 0)
  {
    unmap_ringbuf_pmem(rb); // For last ringbuf clear the physical memory.
    if (KLOG)
      printf("Successfully deleted ringbuf %d from ringbufs. # ringbufs: %d\n", ringbuf_count, get_ringbuf_index());
    return 0;
  }

  if (KLOG)
    printf("Successfully unmapped from ringbuf '%s'. # ringbufs: %d, refcount: %d\n\n", rb->name, get_ringbuf_index(), rb->refcount);
  return 0;
}

int ringbuf(const char *name, int open, uint64 addr)
{
  acquire(&ringbuf_lock);

  struct ringbuf *rb;
  int ringbuf_exists = 0, ringbuf_count = 0;

  // Step 1: Check if maximum ringbuf are already allocated.
  ringbuf_count = get_ringbuf_index();
  if (ringbuf_count >= MAX_RINGBUFS)
  {
    if (KLOG)
      printf("Maximum ringbuf are allocated. Ringbufs count: %d\n", ringbuf_count);
    release(&ringbuf_lock);
    return -1;
  }

  if (KLOG)
    printf("\nCurrent number of ringbufs: %d\n", ringbuf_count);

  // Step 2: Check if ringbuf name is greater than 16.
  int name_len = strlen(name);
  if (name_len > RINGBUF_NAME_LEN)
  {
    if (KLOG)
      printf("Error: Cannot create ringbuf name '%s' is too long (%d). Allowed: %d \n", name, name_len, RINGBUF_NAME_LEN);
    release(&ringbuf_lock);
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

  if (open) // Create/append the ringbuf from the user.
  {
    if (!ringbuf_exists && create_ringbuf(name, addr) != 0)
    {
      if (KLOG)
        printf("Error: Failed to create new ringbuf '%s'\n", name);
      release(&ringbuf_lock);
      return -1;
    }
    else if (ringbuf_exists && append_ringbuf(name, addr) != 0)
    {
      if (KLOG)
        printf("Error: Failed to append to ringbuf '%s'\n", name);
      release(&ringbuf_lock);
      return -1;
    }
  }
  else // Delete/Unmap the ringbuf from the user.
  {
    if (unmap_ringbuf(name, addr) != 0)
    {
      if (KLOG)
        printf("Error: Failed to unmap ringbuf '%s'\n", name);
      release(&ringbuf_lock);
      return -1;
    }
  }

  release(&ringbuf_lock);
  return 0;
}