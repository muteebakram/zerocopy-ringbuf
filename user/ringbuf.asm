
user/_ringbuf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main(int argc, char *argv[])
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	add	s0,sp,32
    const char name[16] = "muteeb";
   8:	00001797          	auipc	a5,0x1
   c:	85878793          	add	a5,a5,-1960 # 860 <malloc+0x10a>
  10:	4398                	lw	a4,0(a5)
  12:	fee42023          	sw	a4,-32(s0)
  16:	0047d703          	lhu	a4,4(a5)
  1a:	fee41223          	sh	a4,-28(s0)
  1e:	0067c783          	lbu	a5,6(a5)
  22:	fef40323          	sb	a5,-26(s0)
  26:	fe0403a3          	sb	zero,-25(s0)
  2a:	fe040423          	sb	zero,-24(s0)
  2e:	fe0404a3          	sb	zero,-23(s0)
  32:	fe040523          	sb	zero,-22(s0)
  36:	fe0405a3          	sb	zero,-21(s0)
  3a:	fe040623          	sb	zero,-20(s0)
  3e:	fe0406a3          	sb	zero,-19(s0)
  42:	fe040723          	sb	zero,-18(s0)
  46:	fe0407a3          	sb	zero,-17(s0)
    void **buf1 = 0;
    void **buf2 = 0;

    uint64 **ptr1 = 0;
    uint64 **ptr2 = 0;
    ringbuf(name, 1, buf1);
  4a:	4601                	li	a2,0
  4c:	4585                	li	a1,1
  4e:	fe040513          	add	a0,s0,-32
  52:	00000097          	auipc	ra,0x0
  56:	37c080e7          	jalr	892(ra) # 3ce <ringbuf>
    ringbuf(name, 1, buf2);
  5a:	4601                	li	a2,0
  5c:	4585                	li	a1,1
  5e:	fe040513          	add	a0,s0,-32
  62:	00000097          	auipc	ra,0x0
  66:	36c080e7          	jalr	876(ra) # 3ce <ringbuf>
    // ringbuf("akeeb", 2, &buf2);

    ptr1 = (uint64 **)buf1;
    ptr2 = (uint64 **)buf2;
    printf("**buf %p: ", (ptr1));
  6a:	4581                	li	a1,0
  6c:	00000517          	auipc	a0,0x0
  70:	7d450513          	add	a0,a0,2004 # 840 <malloc+0xea>
  74:	00000097          	auipc	ra,0x0
  78:	62a080e7          	jalr	1578(ra) # 69e <printf>
    printf("**buf %p: ", (ptr2));
  7c:	4581                	li	a1,0
  7e:	00000517          	auipc	a0,0x0
  82:	7c250513          	add	a0,a0,1986 # 840 <malloc+0xea>
  86:	00000097          	auipc	ra,0x0
  8a:	618080e7          	jalr	1560(ra) # 69e <printf>

    // if((uint64 **)(buf1) != 0)
    //     printf("ringbuf: %p\n", (uint64 **)(buf1));
    // if((uint64 **)(buf2) != 0)
    //     printf("ringbuf: %p\n", (uint64 **)(buf2));
    printf("\ngoodbye\n");
  8e:	00000517          	auipc	a0,0x0
  92:	7c250513          	add	a0,a0,1986 # 850 <malloc+0xfa>
  96:	00000097          	auipc	ra,0x0
  9a:	608080e7          	jalr	1544(ra) # 69e <printf>
    return 0;
  9e:	4501                	li	a0,0
  a0:	60e2                	ld	ra,24(sp)
  a2:	6442                	ld	s0,16(sp)
  a4:	6105                	add	sp,sp,32
  a6:	8082                	ret

00000000000000a8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  a8:	1141                	add	sp,sp,-16
  aa:	e406                	sd	ra,8(sp)
  ac:	e022                	sd	s0,0(sp)
  ae:	0800                	add	s0,sp,16
  extern int main();
  main();
  b0:	00000097          	auipc	ra,0x0
  b4:	f50080e7          	jalr	-176(ra) # 0 <main>
  exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	274080e7          	jalr	628(ra) # 32e <exit>

00000000000000c2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c2:	1141                	add	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c8:	87aa                	mv	a5,a0
  ca:	0585                	add	a1,a1,1
  cc:	0785                	add	a5,a5,1
  ce:	fff5c703          	lbu	a4,-1(a1)
  d2:	fee78fa3          	sb	a4,-1(a5)
  d6:	fb75                	bnez	a4,ca <strcpy+0x8>
    ;
  return os;
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	add	sp,sp,16
  dc:	8082                	ret

00000000000000de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  de:	1141                	add	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cb91                	beqz	a5,fc <strcmp+0x1e>
  ea:	0005c703          	lbu	a4,0(a1)
  ee:	00f71763          	bne	a4,a5,fc <strcmp+0x1e>
    p++, q++;
  f2:	0505                	add	a0,a0,1
  f4:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	fbe5                	bnez	a5,ea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fc:	0005c503          	lbu	a0,0(a1)
}
 100:	40a7853b          	subw	a0,a5,a0
 104:	6422                	ld	s0,8(sp)
 106:	0141                	add	sp,sp,16
 108:	8082                	ret

000000000000010a <strlen>:

uint
strlen(const char *s)
{
 10a:	1141                	add	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cf91                	beqz	a5,130 <strlen+0x26>
 116:	0505                	add	a0,a0,1
 118:	87aa                	mv	a5,a0
 11a:	86be                	mv	a3,a5
 11c:	0785                	add	a5,a5,1
 11e:	fff7c703          	lbu	a4,-1(a5)
 122:	ff65                	bnez	a4,11a <strlen+0x10>
 124:	40a6853b          	subw	a0,a3,a0
 128:	2505                	addw	a0,a0,1
    ;
  return n;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	add	sp,sp,16
 12e:	8082                	ret
  for(n = 0; s[n]; n++)
 130:	4501                	li	a0,0
 132:	bfe5                	j	12a <strlen+0x20>

0000000000000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	1141                	add	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 13a:	ca19                	beqz	a2,150 <memset+0x1c>
 13c:	87aa                	mv	a5,a0
 13e:	1602                	sll	a2,a2,0x20
 140:	9201                	srl	a2,a2,0x20
 142:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 146:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14a:	0785                	add	a5,a5,1
 14c:	fee79de3          	bne	a5,a4,146 <memset+0x12>
  }
  return dst;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	add	sp,sp,16
 154:	8082                	ret

0000000000000156 <strchr>:

char*
strchr(const char *s, char c)
{
 156:	1141                	add	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	add	s0,sp,16
  for(; *s; s++)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cb99                	beqz	a5,176 <strchr+0x20>
    if(*s == c)
 162:	00f58763          	beq	a1,a5,170 <strchr+0x1a>
  for(; *s; s++)
 166:	0505                	add	a0,a0,1
 168:	00054783          	lbu	a5,0(a0)
 16c:	fbfd                	bnez	a5,162 <strchr+0xc>
      return (char*)s;
  return 0;
 16e:	4501                	li	a0,0
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	add	sp,sp,16
 174:	8082                	ret
  return 0;
 176:	4501                	li	a0,0
 178:	bfe5                	j	170 <strchr+0x1a>

000000000000017a <gets>:

char*
gets(char *buf, int max)
{
 17a:	711d                	add	sp,sp,-96
 17c:	ec86                	sd	ra,88(sp)
 17e:	e8a2                	sd	s0,80(sp)
 180:	e4a6                	sd	s1,72(sp)
 182:	e0ca                	sd	s2,64(sp)
 184:	fc4e                	sd	s3,56(sp)
 186:	f852                	sd	s4,48(sp)
 188:	f456                	sd	s5,40(sp)
 18a:	f05a                	sd	s6,32(sp)
 18c:	ec5e                	sd	s7,24(sp)
 18e:	1080                	add	s0,sp,96
 190:	8baa                	mv	s7,a0
 192:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 194:	892a                	mv	s2,a0
 196:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 198:	4aa9                	li	s5,10
 19a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19c:	89a6                	mv	s3,s1
 19e:	2485                	addw	s1,s1,1
 1a0:	0344d863          	bge	s1,s4,1d0 <gets+0x56>
    cc = read(0, &c, 1);
 1a4:	4605                	li	a2,1
 1a6:	faf40593          	add	a1,s0,-81
 1aa:	4501                	li	a0,0
 1ac:	00000097          	auipc	ra,0x0
 1b0:	19a080e7          	jalr	410(ra) # 346 <read>
    if(cc < 1)
 1b4:	00a05e63          	blez	a0,1d0 <gets+0x56>
    buf[i++] = c;
 1b8:	faf44783          	lbu	a5,-81(s0)
 1bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c0:	01578763          	beq	a5,s5,1ce <gets+0x54>
 1c4:	0905                	add	s2,s2,1
 1c6:	fd679be3          	bne	a5,s6,19c <gets+0x22>
  for(i=0; i+1 < max; ){
 1ca:	89a6                	mv	s3,s1
 1cc:	a011                	j	1d0 <gets+0x56>
 1ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d0:	99de                	add	s3,s3,s7
 1d2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d6:	855e                	mv	a0,s7
 1d8:	60e6                	ld	ra,88(sp)
 1da:	6446                	ld	s0,80(sp)
 1dc:	64a6                	ld	s1,72(sp)
 1de:	6906                	ld	s2,64(sp)
 1e0:	79e2                	ld	s3,56(sp)
 1e2:	7a42                	ld	s4,48(sp)
 1e4:	7aa2                	ld	s5,40(sp)
 1e6:	7b02                	ld	s6,32(sp)
 1e8:	6be2                	ld	s7,24(sp)
 1ea:	6125                	add	sp,sp,96
 1ec:	8082                	ret

00000000000001ee <stat>:

int
stat(const char *n, struct stat *st)
{
 1ee:	1101                	add	sp,sp,-32
 1f0:	ec06                	sd	ra,24(sp)
 1f2:	e822                	sd	s0,16(sp)
 1f4:	e426                	sd	s1,8(sp)
 1f6:	e04a                	sd	s2,0(sp)
 1f8:	1000                	add	s0,sp,32
 1fa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fc:	4581                	li	a1,0
 1fe:	00000097          	auipc	ra,0x0
 202:	170080e7          	jalr	368(ra) # 36e <open>
  if(fd < 0)
 206:	02054563          	bltz	a0,230 <stat+0x42>
 20a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20c:	85ca                	mv	a1,s2
 20e:	00000097          	auipc	ra,0x0
 212:	178080e7          	jalr	376(ra) # 386 <fstat>
 216:	892a                	mv	s2,a0
  close(fd);
 218:	8526                	mv	a0,s1
 21a:	00000097          	auipc	ra,0x0
 21e:	13c080e7          	jalr	316(ra) # 356 <close>
  return r;
}
 222:	854a                	mv	a0,s2
 224:	60e2                	ld	ra,24(sp)
 226:	6442                	ld	s0,16(sp)
 228:	64a2                	ld	s1,8(sp)
 22a:	6902                	ld	s2,0(sp)
 22c:	6105                	add	sp,sp,32
 22e:	8082                	ret
    return -1;
 230:	597d                	li	s2,-1
 232:	bfc5                	j	222 <stat+0x34>

0000000000000234 <atoi>:

int
atoi(const char *s)
{
 234:	1141                	add	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23a:	00054683          	lbu	a3,0(a0)
 23e:	fd06879b          	addw	a5,a3,-48
 242:	0ff7f793          	zext.b	a5,a5
 246:	4625                	li	a2,9
 248:	02f66863          	bltu	a2,a5,278 <atoi+0x44>
 24c:	872a                	mv	a4,a0
  n = 0;
 24e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 250:	0705                	add	a4,a4,1
 252:	0025179b          	sllw	a5,a0,0x2
 256:	9fa9                	addw	a5,a5,a0
 258:	0017979b          	sllw	a5,a5,0x1
 25c:	9fb5                	addw	a5,a5,a3
 25e:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 262:	00074683          	lbu	a3,0(a4)
 266:	fd06879b          	addw	a5,a3,-48
 26a:	0ff7f793          	zext.b	a5,a5
 26e:	fef671e3          	bgeu	a2,a5,250 <atoi+0x1c>
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	add	sp,sp,16
 276:	8082                	ret
  n = 0;
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <atoi+0x3e>

000000000000027c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27c:	1141                	add	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 282:	02b57463          	bgeu	a0,a1,2aa <memmove+0x2e>
    while(n-- > 0)
 286:	00c05f63          	blez	a2,2a4 <memmove+0x28>
 28a:	1602                	sll	a2,a2,0x20
 28c:	9201                	srl	a2,a2,0x20
 28e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 292:	872a                	mv	a4,a0
      *dst++ = *src++;
 294:	0585                	add	a1,a1,1
 296:	0705                	add	a4,a4,1
 298:	fff5c683          	lbu	a3,-1(a1)
 29c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a0:	fee79ae3          	bne	a5,a4,294 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	add	sp,sp,16
 2a8:	8082                	ret
    dst += n;
 2aa:	00c50733          	add	a4,a0,a2
    src += n;
 2ae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b0:	fec05ae3          	blez	a2,2a4 <memmove+0x28>
 2b4:	fff6079b          	addw	a5,a2,-1
 2b8:	1782                	sll	a5,a5,0x20
 2ba:	9381                	srl	a5,a5,0x20
 2bc:	fff7c793          	not	a5,a5
 2c0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c2:	15fd                	add	a1,a1,-1
 2c4:	177d                	add	a4,a4,-1
 2c6:	0005c683          	lbu	a3,0(a1)
 2ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ce:	fee79ae3          	bne	a5,a4,2c2 <memmove+0x46>
 2d2:	bfc9                	j	2a4 <memmove+0x28>

00000000000002d4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d4:	1141                	add	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2da:	ca05                	beqz	a2,30a <memcmp+0x36>
 2dc:	fff6069b          	addw	a3,a2,-1
 2e0:	1682                	sll	a3,a3,0x20
 2e2:	9281                	srl	a3,a3,0x20
 2e4:	0685                	add	a3,a3,1
 2e6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00e79863          	bne	a5,a4,300 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f4:	0505                	add	a0,a0,1
    p2++;
 2f6:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2f8:	fed518e3          	bne	a0,a3,2e8 <memcmp+0x14>
  }
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	a019                	j	304 <memcmp+0x30>
      return *p1 - *p2;
 300:	40e7853b          	subw	a0,a5,a4
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	add	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <memcmp+0x30>

000000000000030e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30e:	1141                	add	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 316:	00000097          	auipc	ra,0x0
 31a:	f66080e7          	jalr	-154(ra) # 27c <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	add	sp,sp,16
 324:	8082                	ret

0000000000000326 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 326:	4885                	li	a7,1
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exit>:
.global exit
exit:
 li a7, SYS_exit
 32e:	4889                	li	a7,2
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <wait>:
.global wait
wait:
 li a7, SYS_wait
 336:	488d                	li	a7,3
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33e:	4891                	li	a7,4
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <read>:
.global read
read:
 li a7, SYS_read
 346:	4895                	li	a7,5
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <write>:
.global write
write:
 li a7, SYS_write
 34e:	48c1                	li	a7,16
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <close>:
.global close
close:
 li a7, SYS_close
 356:	48d5                	li	a7,21
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <kill>:
.global kill
kill:
 li a7, SYS_kill
 35e:	4899                	li	a7,6
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exec>:
.global exec
exec:
 li a7, SYS_exec
 366:	489d                	li	a7,7
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <open>:
.global open
open:
 li a7, SYS_open
 36e:	48bd                	li	a7,15
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 376:	48c5                	li	a7,17
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37e:	48c9                	li	a7,18
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 386:	48a1                	li	a7,8
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <link>:
.global link
link:
 li a7, SYS_link
 38e:	48cd                	li	a7,19
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 396:	48d1                	li	a7,20
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39e:	48a5                	li	a7,9
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a6:	48a9                	li	a7,10
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ae:	48ad                	li	a7,11
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b6:	48b1                	li	a7,12
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3be:	48b5                	li	a7,13
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c6:	48b9                	li	a7,14
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <ringbuf>:
.global ringbuf
ringbuf:
 li a7, SYS_ringbuf
 3ce:	48d9                	li	a7,22
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d6:	1101                	add	sp,sp,-32
 3d8:	ec06                	sd	ra,24(sp)
 3da:	e822                	sd	s0,16(sp)
 3dc:	1000                	add	s0,sp,32
 3de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e2:	4605                	li	a2,1
 3e4:	fef40593          	add	a1,s0,-17
 3e8:	00000097          	auipc	ra,0x0
 3ec:	f66080e7          	jalr	-154(ra) # 34e <write>
}
 3f0:	60e2                	ld	ra,24(sp)
 3f2:	6442                	ld	s0,16(sp)
 3f4:	6105                	add	sp,sp,32
 3f6:	8082                	ret

00000000000003f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f8:	7139                	add	sp,sp,-64
 3fa:	fc06                	sd	ra,56(sp)
 3fc:	f822                	sd	s0,48(sp)
 3fe:	f426                	sd	s1,40(sp)
 400:	f04a                	sd	s2,32(sp)
 402:	ec4e                	sd	s3,24(sp)
 404:	0080                	add	s0,sp,64
 406:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 408:	c299                	beqz	a3,40e <printint+0x16>
 40a:	0805c963          	bltz	a1,49c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 40e:	2581                	sext.w	a1,a1
  neg = 0;
 410:	4881                	li	a7,0
 412:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 416:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 418:	2601                	sext.w	a2,a2
 41a:	00000517          	auipc	a0,0x0
 41e:	4b650513          	add	a0,a0,1206 # 8d0 <digits>
 422:	883a                	mv	a6,a4
 424:	2705                	addw	a4,a4,1
 426:	02c5f7bb          	remuw	a5,a1,a2
 42a:	1782                	sll	a5,a5,0x20
 42c:	9381                	srl	a5,a5,0x20
 42e:	97aa                	add	a5,a5,a0
 430:	0007c783          	lbu	a5,0(a5)
 434:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 438:	0005879b          	sext.w	a5,a1
 43c:	02c5d5bb          	divuw	a1,a1,a2
 440:	0685                	add	a3,a3,1
 442:	fec7f0e3          	bgeu	a5,a2,422 <printint+0x2a>
  if(neg)
 446:	00088c63          	beqz	a7,45e <printint+0x66>
    buf[i++] = '-';
 44a:	fd070793          	add	a5,a4,-48
 44e:	00878733          	add	a4,a5,s0
 452:	02d00793          	li	a5,45
 456:	fef70823          	sb	a5,-16(a4)
 45a:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 45e:	02e05863          	blez	a4,48e <printint+0x96>
 462:	fc040793          	add	a5,s0,-64
 466:	00e78933          	add	s2,a5,a4
 46a:	fff78993          	add	s3,a5,-1
 46e:	99ba                	add	s3,s3,a4
 470:	377d                	addw	a4,a4,-1
 472:	1702                	sll	a4,a4,0x20
 474:	9301                	srl	a4,a4,0x20
 476:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47a:	fff94583          	lbu	a1,-1(s2)
 47e:	8526                	mv	a0,s1
 480:	00000097          	auipc	ra,0x0
 484:	f56080e7          	jalr	-170(ra) # 3d6 <putc>
  while(--i >= 0)
 488:	197d                	add	s2,s2,-1
 48a:	ff3918e3          	bne	s2,s3,47a <printint+0x82>
}
 48e:	70e2                	ld	ra,56(sp)
 490:	7442                	ld	s0,48(sp)
 492:	74a2                	ld	s1,40(sp)
 494:	7902                	ld	s2,32(sp)
 496:	69e2                	ld	s3,24(sp)
 498:	6121                	add	sp,sp,64
 49a:	8082                	ret
    x = -xx;
 49c:	40b005bb          	negw	a1,a1
    neg = 1;
 4a0:	4885                	li	a7,1
    x = -xx;
 4a2:	bf85                	j	412 <printint+0x1a>

00000000000004a4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a4:	715d                	add	sp,sp,-80
 4a6:	e486                	sd	ra,72(sp)
 4a8:	e0a2                	sd	s0,64(sp)
 4aa:	fc26                	sd	s1,56(sp)
 4ac:	f84a                	sd	s2,48(sp)
 4ae:	f44e                	sd	s3,40(sp)
 4b0:	f052                	sd	s4,32(sp)
 4b2:	ec56                	sd	s5,24(sp)
 4b4:	e85a                	sd	s6,16(sp)
 4b6:	e45e                	sd	s7,8(sp)
 4b8:	e062                	sd	s8,0(sp)
 4ba:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4bc:	0005c903          	lbu	s2,0(a1)
 4c0:	18090c63          	beqz	s2,658 <vprintf+0x1b4>
 4c4:	8aaa                	mv	s5,a0
 4c6:	8bb2                	mv	s7,a2
 4c8:	00158493          	add	s1,a1,1
  state = 0;
 4cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ce:	02500a13          	li	s4,37
 4d2:	4b55                	li	s6,21
 4d4:	a839                	j	4f2 <vprintf+0x4e>
        putc(fd, c);
 4d6:	85ca                	mv	a1,s2
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	efc080e7          	jalr	-260(ra) # 3d6 <putc>
 4e2:	a019                	j	4e8 <vprintf+0x44>
    } else if(state == '%'){
 4e4:	01498d63          	beq	s3,s4,4fe <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4e8:	0485                	add	s1,s1,1
 4ea:	fff4c903          	lbu	s2,-1(s1)
 4ee:	16090563          	beqz	s2,658 <vprintf+0x1b4>
    if(state == 0){
 4f2:	fe0999e3          	bnez	s3,4e4 <vprintf+0x40>
      if(c == '%'){
 4f6:	ff4910e3          	bne	s2,s4,4d6 <vprintf+0x32>
        state = '%';
 4fa:	89d2                	mv	s3,s4
 4fc:	b7f5                	j	4e8 <vprintf+0x44>
      if(c == 'd'){
 4fe:	13490263          	beq	s2,s4,622 <vprintf+0x17e>
 502:	f9d9079b          	addw	a5,s2,-99
 506:	0ff7f793          	zext.b	a5,a5
 50a:	12fb6563          	bltu	s6,a5,634 <vprintf+0x190>
 50e:	f9d9079b          	addw	a5,s2,-99
 512:	0ff7f713          	zext.b	a4,a5
 516:	10eb6f63          	bltu	s6,a4,634 <vprintf+0x190>
 51a:	00271793          	sll	a5,a4,0x2
 51e:	00000717          	auipc	a4,0x0
 522:	35a70713          	add	a4,a4,858 # 878 <malloc+0x122>
 526:	97ba                	add	a5,a5,a4
 528:	439c                	lw	a5,0(a5)
 52a:	97ba                	add	a5,a5,a4
 52c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 52e:	008b8913          	add	s2,s7,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000ba583          	lw	a1,0(s7)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	ebc080e7          	jalr	-324(ra) # 3f8 <printint>
 544:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 546:	4981                	li	s3,0
 548:	b745                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b8913          	add	s2,s7,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000ba583          	lw	a1,0(s7)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	ea0080e7          	jalr	-352(ra) # 3f8 <printint>
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	b751                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 566:	008b8913          	add	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4641                	li	a2,16
 56e:	000ba583          	lw	a1,0(s7)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e84080e7          	jalr	-380(ra) # 3f8 <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	b7a5                	j	4e8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 582:	008b8c13          	add	s8,s7,8
 586:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 58a:	03000593          	li	a1,48
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e46080e7          	jalr	-442(ra) # 3d6 <putc>
  putc(fd, 'x');
 598:	07800593          	li	a1,120
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e38080e7          	jalr	-456(ra) # 3d6 <putc>
 5a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a8:	00000b97          	auipc	s7,0x0
 5ac:	328b8b93          	add	s7,s7,808 # 8d0 <digits>
 5b0:	03c9d793          	srl	a5,s3,0x3c
 5b4:	97de                	add	a5,a5,s7
 5b6:	0007c583          	lbu	a1,0(a5)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e1a080e7          	jalr	-486(ra) # 3d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c4:	0992                	sll	s3,s3,0x4
 5c6:	397d                	addw	s2,s2,-1
 5c8:	fe0914e3          	bnez	s2,5b0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5cc:	8be2                	mv	s7,s8
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bf21                	j	4e8 <vprintf+0x44>
        s = va_arg(ap, char*);
 5d2:	008b8993          	add	s3,s7,8
 5d6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5da:	02090163          	beqz	s2,5fc <vprintf+0x158>
        while(*s != 0){
 5de:	00094583          	lbu	a1,0(s2)
 5e2:	c9a5                	beqz	a1,652 <vprintf+0x1ae>
          putc(fd, *s);
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	df0080e7          	jalr	-528(ra) # 3d6 <putc>
          s++;
 5ee:	0905                	add	s2,s2,1
        while(*s != 0){
 5f0:	00094583          	lbu	a1,0(s2)
 5f4:	f9e5                	bnez	a1,5e4 <vprintf+0x140>
        s = va_arg(ap, char*);
 5f6:	8bce                	mv	s7,s3
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b5fd                	j	4e8 <vprintf+0x44>
          s = "(null)";
 5fc:	00000917          	auipc	s2,0x0
 600:	27490913          	add	s2,s2,628 # 870 <malloc+0x11a>
        while(*s != 0){
 604:	02800593          	li	a1,40
 608:	bff1                	j	5e4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 60a:	008b8913          	add	s2,s7,8
 60e:	000bc583          	lbu	a1,0(s7)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	dc2080e7          	jalr	-574(ra) # 3d6 <putc>
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	b5e1                	j	4e8 <vprintf+0x44>
        putc(fd, c);
 622:	02500593          	li	a1,37
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	dae080e7          	jalr	-594(ra) # 3d6 <putc>
      state = 0;
 630:	4981                	li	s3,0
 632:	bd5d                	j	4e8 <vprintf+0x44>
        putc(fd, '%');
 634:	02500593          	li	a1,37
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	d9c080e7          	jalr	-612(ra) # 3d6 <putc>
        putc(fd, c);
 642:	85ca                	mv	a1,s2
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	d90080e7          	jalr	-624(ra) # 3d6 <putc>
      state = 0;
 64e:	4981                	li	s3,0
 650:	bd61                	j	4e8 <vprintf+0x44>
        s = va_arg(ap, char*);
 652:	8bce                	mv	s7,s3
      state = 0;
 654:	4981                	li	s3,0
 656:	bd49                	j	4e8 <vprintf+0x44>
    }
  }
}
 658:	60a6                	ld	ra,72(sp)
 65a:	6406                	ld	s0,64(sp)
 65c:	74e2                	ld	s1,56(sp)
 65e:	7942                	ld	s2,48(sp)
 660:	79a2                	ld	s3,40(sp)
 662:	7a02                	ld	s4,32(sp)
 664:	6ae2                	ld	s5,24(sp)
 666:	6b42                	ld	s6,16(sp)
 668:	6ba2                	ld	s7,8(sp)
 66a:	6c02                	ld	s8,0(sp)
 66c:	6161                	add	sp,sp,80
 66e:	8082                	ret

0000000000000670 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 670:	715d                	add	sp,sp,-80
 672:	ec06                	sd	ra,24(sp)
 674:	e822                	sd	s0,16(sp)
 676:	1000                	add	s0,sp,32
 678:	e010                	sd	a2,0(s0)
 67a:	e414                	sd	a3,8(s0)
 67c:	e818                	sd	a4,16(s0)
 67e:	ec1c                	sd	a5,24(s0)
 680:	03043023          	sd	a6,32(s0)
 684:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 688:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 68c:	8622                	mv	a2,s0
 68e:	00000097          	auipc	ra,0x0
 692:	e16080e7          	jalr	-490(ra) # 4a4 <vprintf>
}
 696:	60e2                	ld	ra,24(sp)
 698:	6442                	ld	s0,16(sp)
 69a:	6161                	add	sp,sp,80
 69c:	8082                	ret

000000000000069e <printf>:

void
printf(const char *fmt, ...)
{
 69e:	711d                	add	sp,sp,-96
 6a0:	ec06                	sd	ra,24(sp)
 6a2:	e822                	sd	s0,16(sp)
 6a4:	1000                	add	s0,sp,32
 6a6:	e40c                	sd	a1,8(s0)
 6a8:	e810                	sd	a2,16(s0)
 6aa:	ec14                	sd	a3,24(s0)
 6ac:	f018                	sd	a4,32(s0)
 6ae:	f41c                	sd	a5,40(s0)
 6b0:	03043823          	sd	a6,48(s0)
 6b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b8:	00840613          	add	a2,s0,8
 6bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c0:	85aa                	mv	a1,a0
 6c2:	4505                	li	a0,1
 6c4:	00000097          	auipc	ra,0x0
 6c8:	de0080e7          	jalr	-544(ra) # 4a4 <vprintf>
}
 6cc:	60e2                	ld	ra,24(sp)
 6ce:	6442                	ld	s0,16(sp)
 6d0:	6125                	add	sp,sp,96
 6d2:	8082                	ret

00000000000006d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d4:	1141                	add	sp,sp,-16
 6d6:	e422                	sd	s0,8(sp)
 6d8:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6da:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6de:	00001797          	auipc	a5,0x1
 6e2:	9227b783          	ld	a5,-1758(a5) # 1000 <freep>
 6e6:	a02d                	j	710 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e8:	4618                	lw	a4,8(a2)
 6ea:	9f2d                	addw	a4,a4,a1
 6ec:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f0:	6398                	ld	a4,0(a5)
 6f2:	6310                	ld	a2,0(a4)
 6f4:	a83d                	j	732 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f6:	ff852703          	lw	a4,-8(a0)
 6fa:	9f31                	addw	a4,a4,a2
 6fc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6fe:	ff053683          	ld	a3,-16(a0)
 702:	a091                	j	746 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 704:	6398                	ld	a4,0(a5)
 706:	00e7e463          	bltu	a5,a4,70e <free+0x3a>
 70a:	00e6ea63          	bltu	a3,a4,71e <free+0x4a>
{
 70e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	fed7fae3          	bgeu	a5,a3,704 <free+0x30>
 714:	6398                	ld	a4,0(a5)
 716:	00e6e463          	bltu	a3,a4,71e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71a:	fee7eae3          	bltu	a5,a4,70e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 71e:	ff852583          	lw	a1,-8(a0)
 722:	6390                	ld	a2,0(a5)
 724:	02059813          	sll	a6,a1,0x20
 728:	01c85713          	srl	a4,a6,0x1c
 72c:	9736                	add	a4,a4,a3
 72e:	fae60de3          	beq	a2,a4,6e8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 732:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 736:	4790                	lw	a2,8(a5)
 738:	02061593          	sll	a1,a2,0x20
 73c:	01c5d713          	srl	a4,a1,0x1c
 740:	973e                	add	a4,a4,a5
 742:	fae68ae3          	beq	a3,a4,6f6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 746:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 748:	00001717          	auipc	a4,0x1
 74c:	8af73c23          	sd	a5,-1864(a4) # 1000 <freep>
}
 750:	6422                	ld	s0,8(sp)
 752:	0141                	add	sp,sp,16
 754:	8082                	ret

0000000000000756 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 756:	7139                	add	sp,sp,-64
 758:	fc06                	sd	ra,56(sp)
 75a:	f822                	sd	s0,48(sp)
 75c:	f426                	sd	s1,40(sp)
 75e:	f04a                	sd	s2,32(sp)
 760:	ec4e                	sd	s3,24(sp)
 762:	e852                	sd	s4,16(sp)
 764:	e456                	sd	s5,8(sp)
 766:	e05a                	sd	s6,0(sp)
 768:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76a:	02051493          	sll	s1,a0,0x20
 76e:	9081                	srl	s1,s1,0x20
 770:	04bd                	add	s1,s1,15
 772:	8091                	srl	s1,s1,0x4
 774:	0014899b          	addw	s3,s1,1
 778:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 77a:	00001517          	auipc	a0,0x1
 77e:	88653503          	ld	a0,-1914(a0) # 1000 <freep>
 782:	c515                	beqz	a0,7ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 784:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 786:	4798                	lw	a4,8(a5)
 788:	02977f63          	bgeu	a4,s1,7c6 <malloc+0x70>
  if(nu < 4096)
 78c:	8a4e                	mv	s4,s3
 78e:	0009871b          	sext.w	a4,s3
 792:	6685                	lui	a3,0x1
 794:	00d77363          	bgeu	a4,a3,79a <malloc+0x44>
 798:	6a05                	lui	s4,0x1
 79a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 79e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a2:	00001917          	auipc	s2,0x1
 7a6:	85e90913          	add	s2,s2,-1954 # 1000 <freep>
  if(p == (char*)-1)
 7aa:	5afd                	li	s5,-1
 7ac:	a895                	j	820 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7ae:	00001797          	auipc	a5,0x1
 7b2:	86278793          	add	a5,a5,-1950 # 1010 <base>
 7b6:	00001717          	auipc	a4,0x1
 7ba:	84f73523          	sd	a5,-1974(a4) # 1000 <freep>
 7be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c4:	b7e1                	j	78c <malloc+0x36>
      if(p->s.size == nunits)
 7c6:	02e48c63          	beq	s1,a4,7fe <malloc+0xa8>
        p->s.size -= nunits;
 7ca:	4137073b          	subw	a4,a4,s3
 7ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7d0:	02071693          	sll	a3,a4,0x20
 7d4:	01c6d713          	srl	a4,a3,0x1c
 7d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7de:	00001717          	auipc	a4,0x1
 7e2:	82a73123          	sd	a0,-2014(a4) # 1000 <freep>
      return (void*)(p + 1);
 7e6:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7ea:	70e2                	ld	ra,56(sp)
 7ec:	7442                	ld	s0,48(sp)
 7ee:	74a2                	ld	s1,40(sp)
 7f0:	7902                	ld	s2,32(sp)
 7f2:	69e2                	ld	s3,24(sp)
 7f4:	6a42                	ld	s4,16(sp)
 7f6:	6aa2                	ld	s5,8(sp)
 7f8:	6b02                	ld	s6,0(sp)
 7fa:	6121                	add	sp,sp,64
 7fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7fe:	6398                	ld	a4,0(a5)
 800:	e118                	sd	a4,0(a0)
 802:	bff1                	j	7de <malloc+0x88>
  hp->s.size = nu;
 804:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 808:	0541                	add	a0,a0,16
 80a:	00000097          	auipc	ra,0x0
 80e:	eca080e7          	jalr	-310(ra) # 6d4 <free>
  return freep;
 812:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 816:	d971                	beqz	a0,7ea <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81a:	4798                	lw	a4,8(a5)
 81c:	fa9775e3          	bgeu	a4,s1,7c6 <malloc+0x70>
    if(p == freep)
 820:	00093703          	ld	a4,0(s2)
 824:	853e                	mv	a0,a5
 826:	fef719e3          	bne	a4,a5,818 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 82a:	8552                	mv	a0,s4
 82c:	00000097          	auipc	ra,0x0
 830:	b8a080e7          	jalr	-1142(ra) # 3b6 <sbrk>
  if(p == (char*)-1)
 834:	fd5518e3          	bne	a0,s5,804 <malloc+0xae>
        return 0;
 838:	4501                	li	a0,0
 83a:	bf45                	j	7ea <malloc+0x94>
