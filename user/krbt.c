#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int create_one_ringbuf()
{
  uint64 buf1;
  const char name[16] = "muteeb";
  return ringbuf(name, 1, &buf1);
}

int create_two_ringbuf_same_name()
{
  const char name[16] = "muteeb";
  uint64 buf1;
  uint64 buf2;

  if (ringbuf(name, 1, &buf1) != 0)
    return -1;
  if (ringbuf(name, 1, &buf2) != 0)
    return -1;

  printf("ringbuf1: %p\n", (buf1));
  printf("ringbuf1 book page: %p\n", (buf1 - (16 * 4096)));

  printf("ringbuf2: %p\n", (buf2));
  printf("ringbuf2 book page: %p\n", (buf2 - (16 * 4096)));

  return 0;
}

int create_two_ringbuf_diff_name()
{
  uint64 buf1;
  uint64 buf2;
  const char name1[16] = "muteeb";
  const char name2[16] = "gaurav";

  if (ringbuf(name1, 1, &buf1) != 0)
    return -1;
  if (ringbuf(name2, 1, &buf2) != 0)
    return -1;

  printf("ringbuf1: %p\n", (buf1));
  printf("ringbuf1 book page: %p\n", (buf1 - (16 * 4096)));

  printf("ringbuf2: %p\n", (buf2));
  printf("ringbuf2 book page: %p\n", (buf2 - (16 * 4096)));

  return 0;
}

int create_delete_ringbuf()
{
  uint64 buf1 = 0;
  const char name[16] = "muteeb";

  printf("my buf: %p\n", buf1);
  printf("my buf addr: %p\n", &buf1);
  if (ringbuf(name, 1, &buf1) != 0)
    return -1;

  printf("ringbuf1: %p\n", (buf1));
  printf("ringbuf1 &: %p\n", (&buf1));
  if (ringbuf(name, 0, &buf1) != 0)
    return -1;

  return 0;
}

int create_two_delete_ringbuf_one()
{
  uint64 buf1;
  const char name[16] = "muteeb";

  if (ringbuf(name, 1, &buf1) != 0)
    return -1;

  if (ringbuf(name, 1, &buf1) != 0)
    return -1;

  if (ringbuf(name, 0, &buf1) != 0)
    return -1;

  return 0;
}

int create_two_delete_two_ringbuf()
{
  uint64 buf1;
  uint64 buf2;
  const char name[16] = "muteeb";

  if (ringbuf(name, 1, &buf1) != 0)
    return -1;

  if (ringbuf(name, 1, &buf2) != 0)
    return -1;

  if (ringbuf(name, 0, &buf1) != 0)
    return -1;

  if (ringbuf(name, 0, &buf2) != 0)
    return -1;

  return 0;
}

int only_delete_ringbuf()
{
  uint64 buf1;
  const char name[16] = "muteeb";

  if (ringbuf(name, 0, &buf1) != 0)
    return -1;

  return 0;
}

int max_ringbuf()
{
  uint64 buf1;
  const char *name[] = {"muteeb0", "muteeb1", "muteeb2", "muteeb3", "muteeb4", "muteeb5", "muteeb6", "muteeb7", "muteeb8", "muteeb9", "muteeb10", "muteeb11", "muteeb12", "muteeb13", "muteeb14", "muteeb15", "muteeb16"};

  for (int i = 0; i < 17; i++)
  {
    printf("\nUserspace: Creating ringbuf '%s'\n", name[i]);
    if (ringbuf(name[i], 1, &buf1) != 0)
      return -1;
  }

  return 0;
}

int long_ringbuf_name()
{
  uint64 buf1;
  const char name[] = "muteeb1muteeb1muteeb1muteeb1muteeb1";

  if (ringbuf(name, 1, &buf1) != 0)
    return -1;

  return 0;
}

int main(int argc, char *argv[])
{
  // printf("\nTEST: create_one_ringbuf: %d\n\n", create_one_ringbuf());
  // printf("\nTEST: create_two_ringbuf_same_name: %d\n\n", create_two_ringbuf_same_name());
  // printf("\nTEST: create_two_ringbuf_diff_name: %d\n\n", create_two_ringbuf_diff_name());
  // printf("\nTEST: create_delete_ringbuf: %d\n\n", create_delete_ringbuf());
  // printf("\nTEST: only_delete_ringbuf: %d\n\n", only_delete_ringbuf());
  // printf("\nTEST: max_ringbuf: %d\n\n", max_ringbuf());
  // printf("\nTEST: long_ringbuf_name: %d\n\n", long_ringbuf_name());
  // printf("\nTEST: create_two_delete_ringbuf_one: %d\n\n", create_two_delete_ringbuf_one());
  printf("\nTEST: create_two_delete_two_ringbuf: %d\n\n", create_two_delete_two_ringbuf());

  printf("goodbye\n");
  return 0;
}