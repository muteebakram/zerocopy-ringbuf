
user/_ringbuf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main(int argc, char *argv[])
{
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	add	s0,sp,64
    const char name[16] = "muteeb";
   a:	00001797          	auipc	a5,0x1
   e:	86678793          	add	a5,a5,-1946 # 870 <malloc+0x11e>
  12:	4398                	lw	a4,0(a5)
  14:	fce42823          	sw	a4,-48(s0)
  18:	0047d703          	lhu	a4,4(a5)
  1c:	fce41a23          	sh	a4,-44(s0)
  20:	0067c783          	lbu	a5,6(a5)
  24:	fcf40b23          	sb	a5,-42(s0)
  28:	fc040ba3          	sb	zero,-41(s0)
  2c:	fc040c23          	sb	zero,-40(s0)
  30:	fc040ca3          	sb	zero,-39(s0)
  34:	fc040d23          	sb	zero,-38(s0)
  38:	fc040da3          	sb	zero,-37(s0)
  3c:	fc040e23          	sb	zero,-36(s0)
  40:	fc040ea3          	sb	zero,-35(s0)
  44:	fc040f23          	sb	zero,-34(s0)
  48:	fc040fa3          	sb	zero,-33(s0)
    uint64 buf1;
    uint64 *start;
    // uint64 buf2;

    ringbuf(name, 1, &buf1);
  4c:	fc840613          	add	a2,s0,-56
  50:	4585                	li	a1,1
  52:	fd040513          	add	a0,s0,-48
  56:	00000097          	auipc	ra,0x0
  5a:	374080e7          	jalr	884(ra) # 3ca <ringbuf>
    // ringbuf(name, 1, &buf2);
    start = (uint64*)buf1;
  5e:	fc843483          	ld	s1,-56(s0)

    printf("ringbuf: %p\n", (buf1));
  62:	85a6                	mv	a1,s1
  64:	00000517          	auipc	a0,0x0
  68:	7dc50513          	add	a0,a0,2012 # 840 <malloc+0xee>
  6c:	00000097          	auipc	ra,0x0
  70:	62e080e7          	jalr	1582(ra) # 69a <printf>
    //char *s = (char *)(buf1);
    printf("ringbuf: %s\n", *((char*)start));
  74:	0004c583          	lbu	a1,0(s1)
  78:	00000517          	auipc	a0,0x0
  7c:	7d850513          	add	a0,a0,2008 # 850 <malloc+0xfe>
  80:	00000097          	auipc	ra,0x0
  84:	61a080e7          	jalr	1562(ra) # 69a <printf>
    
    
    printf("\ngoodbye\n");
  88:	00000517          	auipc	a0,0x0
  8c:	7d850513          	add	a0,a0,2008 # 860 <malloc+0x10e>
  90:	00000097          	auipc	ra,0x0
  94:	60a080e7          	jalr	1546(ra) # 69a <printf>
    return 0;
  98:	4501                	li	a0,0
  9a:	70e2                	ld	ra,56(sp)
  9c:	7442                	ld	s0,48(sp)
  9e:	74a2                	ld	s1,40(sp)
  a0:	6121                	add	sp,sp,64
  a2:	8082                	ret

00000000000000a4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  a4:	1141                	add	sp,sp,-16
  a6:	e406                	sd	ra,8(sp)
  a8:	e022                	sd	s0,0(sp)
  aa:	0800                	add	s0,sp,16
  extern int main();
  main();
  ac:	00000097          	auipc	ra,0x0
  b0:	f54080e7          	jalr	-172(ra) # 0 <main>
  exit(0);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	274080e7          	jalr	628(ra) # 32a <exit>

00000000000000be <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  be:	1141                	add	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c4:	87aa                	mv	a5,a0
  c6:	0585                	add	a1,a1,1
  c8:	0785                	add	a5,a5,1
  ca:	fff5c703          	lbu	a4,-1(a1)
  ce:	fee78fa3          	sb	a4,-1(a5)
  d2:	fb75                	bnez	a4,c6 <strcpy+0x8>
    ;
  return os;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	add	sp,sp,16
  d8:	8082                	ret

00000000000000da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  da:	1141                	add	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cb91                	beqz	a5,f8 <strcmp+0x1e>
  e6:	0005c703          	lbu	a4,0(a1)
  ea:	00f71763          	bne	a4,a5,f8 <strcmp+0x1e>
    p++, q++;
  ee:	0505                	add	a0,a0,1
  f0:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	fbe5                	bnez	a5,e6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f8:	0005c503          	lbu	a0,0(a1)
}
  fc:	40a7853b          	subw	a0,a5,a0
 100:	6422                	ld	s0,8(sp)
 102:	0141                	add	sp,sp,16
 104:	8082                	ret

0000000000000106 <strlen>:

uint
strlen(const char *s)
{
 106:	1141                	add	sp,sp,-16
 108:	e422                	sd	s0,8(sp)
 10a:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10c:	00054783          	lbu	a5,0(a0)
 110:	cf91                	beqz	a5,12c <strlen+0x26>
 112:	0505                	add	a0,a0,1
 114:	87aa                	mv	a5,a0
 116:	86be                	mv	a3,a5
 118:	0785                	add	a5,a5,1
 11a:	fff7c703          	lbu	a4,-1(a5)
 11e:	ff65                	bnez	a4,116 <strlen+0x10>
 120:	40a6853b          	subw	a0,a3,a0
 124:	2505                	addw	a0,a0,1
    ;
  return n;
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	add	sp,sp,16
 12a:	8082                	ret
  for(n = 0; s[n]; n++)
 12c:	4501                	li	a0,0
 12e:	bfe5                	j	126 <strlen+0x20>

0000000000000130 <memset>:

void*
memset(void *dst, int c, uint n)
{
 130:	1141                	add	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 136:	ca19                	beqz	a2,14c <memset+0x1c>
 138:	87aa                	mv	a5,a0
 13a:	1602                	sll	a2,a2,0x20
 13c:	9201                	srl	a2,a2,0x20
 13e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 142:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 146:	0785                	add	a5,a5,1
 148:	fee79de3          	bne	a5,a4,142 <memset+0x12>
  }
  return dst;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	add	sp,sp,16
 150:	8082                	ret

0000000000000152 <strchr>:

char*
strchr(const char *s, char c)
{
 152:	1141                	add	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	add	s0,sp,16
  for(; *s; s++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb99                	beqz	a5,172 <strchr+0x20>
    if(*s == c)
 15e:	00f58763          	beq	a1,a5,16c <strchr+0x1a>
  for(; *s; s++)
 162:	0505                	add	a0,a0,1
 164:	00054783          	lbu	a5,0(a0)
 168:	fbfd                	bnez	a5,15e <strchr+0xc>
      return (char*)s;
  return 0;
 16a:	4501                	li	a0,0
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	add	sp,sp,16
 170:	8082                	ret
  return 0;
 172:	4501                	li	a0,0
 174:	bfe5                	j	16c <strchr+0x1a>

0000000000000176 <gets>:

char*
gets(char *buf, int max)
{
 176:	711d                	add	sp,sp,-96
 178:	ec86                	sd	ra,88(sp)
 17a:	e8a2                	sd	s0,80(sp)
 17c:	e4a6                	sd	s1,72(sp)
 17e:	e0ca                	sd	s2,64(sp)
 180:	fc4e                	sd	s3,56(sp)
 182:	f852                	sd	s4,48(sp)
 184:	f456                	sd	s5,40(sp)
 186:	f05a                	sd	s6,32(sp)
 188:	ec5e                	sd	s7,24(sp)
 18a:	1080                	add	s0,sp,96
 18c:	8baa                	mv	s7,a0
 18e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 190:	892a                	mv	s2,a0
 192:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 194:	4aa9                	li	s5,10
 196:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 198:	89a6                	mv	s3,s1
 19a:	2485                	addw	s1,s1,1
 19c:	0344d863          	bge	s1,s4,1cc <gets+0x56>
    cc = read(0, &c, 1);
 1a0:	4605                	li	a2,1
 1a2:	faf40593          	add	a1,s0,-81
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	19a080e7          	jalr	410(ra) # 342 <read>
    if(cc < 1)
 1b0:	00a05e63          	blez	a0,1cc <gets+0x56>
    buf[i++] = c;
 1b4:	faf44783          	lbu	a5,-81(s0)
 1b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1bc:	01578763          	beq	a5,s5,1ca <gets+0x54>
 1c0:	0905                	add	s2,s2,1
 1c2:	fd679be3          	bne	a5,s6,198 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c6:	89a6                	mv	s3,s1
 1c8:	a011                	j	1cc <gets+0x56>
 1ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1cc:	99de                	add	s3,s3,s7
 1ce:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d2:	855e                	mv	a0,s7
 1d4:	60e6                	ld	ra,88(sp)
 1d6:	6446                	ld	s0,80(sp)
 1d8:	64a6                	ld	s1,72(sp)
 1da:	6906                	ld	s2,64(sp)
 1dc:	79e2                	ld	s3,56(sp)
 1de:	7a42                	ld	s4,48(sp)
 1e0:	7aa2                	ld	s5,40(sp)
 1e2:	7b02                	ld	s6,32(sp)
 1e4:	6be2                	ld	s7,24(sp)
 1e6:	6125                	add	sp,sp,96
 1e8:	8082                	ret

00000000000001ea <stat>:

int
stat(const char *n, struct stat *st)
{
 1ea:	1101                	add	sp,sp,-32
 1ec:	ec06                	sd	ra,24(sp)
 1ee:	e822                	sd	s0,16(sp)
 1f0:	e426                	sd	s1,8(sp)
 1f2:	e04a                	sd	s2,0(sp)
 1f4:	1000                	add	s0,sp,32
 1f6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f8:	4581                	li	a1,0
 1fa:	00000097          	auipc	ra,0x0
 1fe:	170080e7          	jalr	368(ra) # 36a <open>
  if(fd < 0)
 202:	02054563          	bltz	a0,22c <stat+0x42>
 206:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 208:	85ca                	mv	a1,s2
 20a:	00000097          	auipc	ra,0x0
 20e:	178080e7          	jalr	376(ra) # 382 <fstat>
 212:	892a                	mv	s2,a0
  close(fd);
 214:	8526                	mv	a0,s1
 216:	00000097          	auipc	ra,0x0
 21a:	13c080e7          	jalr	316(ra) # 352 <close>
  return r;
}
 21e:	854a                	mv	a0,s2
 220:	60e2                	ld	ra,24(sp)
 222:	6442                	ld	s0,16(sp)
 224:	64a2                	ld	s1,8(sp)
 226:	6902                	ld	s2,0(sp)
 228:	6105                	add	sp,sp,32
 22a:	8082                	ret
    return -1;
 22c:	597d                	li	s2,-1
 22e:	bfc5                	j	21e <stat+0x34>

0000000000000230 <atoi>:

int
atoi(const char *s)
{
 230:	1141                	add	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 236:	00054683          	lbu	a3,0(a0)
 23a:	fd06879b          	addw	a5,a3,-48
 23e:	0ff7f793          	zext.b	a5,a5
 242:	4625                	li	a2,9
 244:	02f66863          	bltu	a2,a5,274 <atoi+0x44>
 248:	872a                	mv	a4,a0
  n = 0;
 24a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24c:	0705                	add	a4,a4,1
 24e:	0025179b          	sllw	a5,a0,0x2
 252:	9fa9                	addw	a5,a5,a0
 254:	0017979b          	sllw	a5,a5,0x1
 258:	9fb5                	addw	a5,a5,a3
 25a:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25e:	00074683          	lbu	a3,0(a4)
 262:	fd06879b          	addw	a5,a3,-48
 266:	0ff7f793          	zext.b	a5,a5
 26a:	fef671e3          	bgeu	a2,a5,24c <atoi+0x1c>
  return n;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	add	sp,sp,16
 272:	8082                	ret
  n = 0;
 274:	4501                	li	a0,0
 276:	bfe5                	j	26e <atoi+0x3e>

0000000000000278 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 278:	1141                	add	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27e:	02b57463          	bgeu	a0,a1,2a6 <memmove+0x2e>
    while(n-- > 0)
 282:	00c05f63          	blez	a2,2a0 <memmove+0x28>
 286:	1602                	sll	a2,a2,0x20
 288:	9201                	srl	a2,a2,0x20
 28a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28e:	872a                	mv	a4,a0
      *dst++ = *src++;
 290:	0585                	add	a1,a1,1
 292:	0705                	add	a4,a4,1
 294:	fff5c683          	lbu	a3,-1(a1)
 298:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	add	sp,sp,16
 2a4:	8082                	ret
    dst += n;
 2a6:	00c50733          	add	a4,a0,a2
    src += n;
 2aa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ac:	fec05ae3          	blez	a2,2a0 <memmove+0x28>
 2b0:	fff6079b          	addw	a5,a2,-1
 2b4:	1782                	sll	a5,a5,0x20
 2b6:	9381                	srl	a5,a5,0x20
 2b8:	fff7c793          	not	a5,a5
 2bc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2be:	15fd                	add	a1,a1,-1
 2c0:	177d                	add	a4,a4,-1
 2c2:	0005c683          	lbu	a3,0(a1)
 2c6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ca:	fee79ae3          	bne	a5,a4,2be <memmove+0x46>
 2ce:	bfc9                	j	2a0 <memmove+0x28>

00000000000002d0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d0:	1141                	add	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d6:	ca05                	beqz	a2,306 <memcmp+0x36>
 2d8:	fff6069b          	addw	a3,a2,-1
 2dc:	1682                	sll	a3,a3,0x20
 2de:	9281                	srl	a3,a3,0x20
 2e0:	0685                	add	a3,a3,1
 2e2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	0005c703          	lbu	a4,0(a1)
 2ec:	00e79863          	bne	a5,a4,2fc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f0:	0505                	add	a0,a0,1
    p2++;
 2f2:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2f4:	fed518e3          	bne	a0,a3,2e4 <memcmp+0x14>
  }
  return 0;
 2f8:	4501                	li	a0,0
 2fa:	a019                	j	300 <memcmp+0x30>
      return *p1 - *p2;
 2fc:	40e7853b          	subw	a0,a5,a4
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	add	sp,sp,16
 304:	8082                	ret
  return 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <memcmp+0x30>

000000000000030a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30a:	1141                	add	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 312:	00000097          	auipc	ra,0x0
 316:	f66080e7          	jalr	-154(ra) # 278 <memmove>
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	add	sp,sp,16
 320:	8082                	ret

0000000000000322 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 322:	4885                	li	a7,1
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <exit>:
.global exit
exit:
 li a7, SYS_exit
 32a:	4889                	li	a7,2
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <wait>:
.global wait
wait:
 li a7, SYS_wait
 332:	488d                	li	a7,3
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33a:	4891                	li	a7,4
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <read>:
.global read
read:
 li a7, SYS_read
 342:	4895                	li	a7,5
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <write>:
.global write
write:
 li a7, SYS_write
 34a:	48c1                	li	a7,16
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <close>:
.global close
close:
 li a7, SYS_close
 352:	48d5                	li	a7,21
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <kill>:
.global kill
kill:
 li a7, SYS_kill
 35a:	4899                	li	a7,6
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <exec>:
.global exec
exec:
 li a7, SYS_exec
 362:	489d                	li	a7,7
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <open>:
.global open
open:
 li a7, SYS_open
 36a:	48bd                	li	a7,15
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 372:	48c5                	li	a7,17
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37a:	48c9                	li	a7,18
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 382:	48a1                	li	a7,8
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <link>:
.global link
link:
 li a7, SYS_link
 38a:	48cd                	li	a7,19
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 392:	48d1                	li	a7,20
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39a:	48a5                	li	a7,9
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a2:	48a9                	li	a7,10
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3aa:	48ad                	li	a7,11
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b2:	48b1                	li	a7,12
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ba:	48b5                	li	a7,13
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c2:	48b9                	li	a7,14
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <ringbuf>:
.global ringbuf
ringbuf:
 li a7, SYS_ringbuf
 3ca:	48d9                	li	a7,22
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d2:	1101                	add	sp,sp,-32
 3d4:	ec06                	sd	ra,24(sp)
 3d6:	e822                	sd	s0,16(sp)
 3d8:	1000                	add	s0,sp,32
 3da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3de:	4605                	li	a2,1
 3e0:	fef40593          	add	a1,s0,-17
 3e4:	00000097          	auipc	ra,0x0
 3e8:	f66080e7          	jalr	-154(ra) # 34a <write>
}
 3ec:	60e2                	ld	ra,24(sp)
 3ee:	6442                	ld	s0,16(sp)
 3f0:	6105                	add	sp,sp,32
 3f2:	8082                	ret

00000000000003f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f4:	7139                	add	sp,sp,-64
 3f6:	fc06                	sd	ra,56(sp)
 3f8:	f822                	sd	s0,48(sp)
 3fa:	f426                	sd	s1,40(sp)
 3fc:	f04a                	sd	s2,32(sp)
 3fe:	ec4e                	sd	s3,24(sp)
 400:	0080                	add	s0,sp,64
 402:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 404:	c299                	beqz	a3,40a <printint+0x16>
 406:	0805c963          	bltz	a1,498 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 40a:	2581                	sext.w	a1,a1
  neg = 0;
 40c:	4881                	li	a7,0
 40e:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 412:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 414:	2601                	sext.w	a2,a2
 416:	00000517          	auipc	a0,0x0
 41a:	4ca50513          	add	a0,a0,1226 # 8e0 <digits>
 41e:	883a                	mv	a6,a4
 420:	2705                	addw	a4,a4,1
 422:	02c5f7bb          	remuw	a5,a1,a2
 426:	1782                	sll	a5,a5,0x20
 428:	9381                	srl	a5,a5,0x20
 42a:	97aa                	add	a5,a5,a0
 42c:	0007c783          	lbu	a5,0(a5)
 430:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 434:	0005879b          	sext.w	a5,a1
 438:	02c5d5bb          	divuw	a1,a1,a2
 43c:	0685                	add	a3,a3,1
 43e:	fec7f0e3          	bgeu	a5,a2,41e <printint+0x2a>
  if(neg)
 442:	00088c63          	beqz	a7,45a <printint+0x66>
    buf[i++] = '-';
 446:	fd070793          	add	a5,a4,-48
 44a:	00878733          	add	a4,a5,s0
 44e:	02d00793          	li	a5,45
 452:	fef70823          	sb	a5,-16(a4)
 456:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 45a:	02e05863          	blez	a4,48a <printint+0x96>
 45e:	fc040793          	add	a5,s0,-64
 462:	00e78933          	add	s2,a5,a4
 466:	fff78993          	add	s3,a5,-1
 46a:	99ba                	add	s3,s3,a4
 46c:	377d                	addw	a4,a4,-1
 46e:	1702                	sll	a4,a4,0x20
 470:	9301                	srl	a4,a4,0x20
 472:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 476:	fff94583          	lbu	a1,-1(s2)
 47a:	8526                	mv	a0,s1
 47c:	00000097          	auipc	ra,0x0
 480:	f56080e7          	jalr	-170(ra) # 3d2 <putc>
  while(--i >= 0)
 484:	197d                	add	s2,s2,-1
 486:	ff3918e3          	bne	s2,s3,476 <printint+0x82>
}
 48a:	70e2                	ld	ra,56(sp)
 48c:	7442                	ld	s0,48(sp)
 48e:	74a2                	ld	s1,40(sp)
 490:	7902                	ld	s2,32(sp)
 492:	69e2                	ld	s3,24(sp)
 494:	6121                	add	sp,sp,64
 496:	8082                	ret
    x = -xx;
 498:	40b005bb          	negw	a1,a1
    neg = 1;
 49c:	4885                	li	a7,1
    x = -xx;
 49e:	bf85                	j	40e <printint+0x1a>

00000000000004a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a0:	715d                	add	sp,sp,-80
 4a2:	e486                	sd	ra,72(sp)
 4a4:	e0a2                	sd	s0,64(sp)
 4a6:	fc26                	sd	s1,56(sp)
 4a8:	f84a                	sd	s2,48(sp)
 4aa:	f44e                	sd	s3,40(sp)
 4ac:	f052                	sd	s4,32(sp)
 4ae:	ec56                	sd	s5,24(sp)
 4b0:	e85a                	sd	s6,16(sp)
 4b2:	e45e                	sd	s7,8(sp)
 4b4:	e062                	sd	s8,0(sp)
 4b6:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b8:	0005c903          	lbu	s2,0(a1)
 4bc:	18090c63          	beqz	s2,654 <vprintf+0x1b4>
 4c0:	8aaa                	mv	s5,a0
 4c2:	8bb2                	mv	s7,a2
 4c4:	00158493          	add	s1,a1,1
  state = 0;
 4c8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ca:	02500a13          	li	s4,37
 4ce:	4b55                	li	s6,21
 4d0:	a839                	j	4ee <vprintf+0x4e>
        putc(fd, c);
 4d2:	85ca                	mv	a1,s2
 4d4:	8556                	mv	a0,s5
 4d6:	00000097          	auipc	ra,0x0
 4da:	efc080e7          	jalr	-260(ra) # 3d2 <putc>
 4de:	a019                	j	4e4 <vprintf+0x44>
    } else if(state == '%'){
 4e0:	01498d63          	beq	s3,s4,4fa <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4e4:	0485                	add	s1,s1,1
 4e6:	fff4c903          	lbu	s2,-1(s1)
 4ea:	16090563          	beqz	s2,654 <vprintf+0x1b4>
    if(state == 0){
 4ee:	fe0999e3          	bnez	s3,4e0 <vprintf+0x40>
      if(c == '%'){
 4f2:	ff4910e3          	bne	s2,s4,4d2 <vprintf+0x32>
        state = '%';
 4f6:	89d2                	mv	s3,s4
 4f8:	b7f5                	j	4e4 <vprintf+0x44>
      if(c == 'd'){
 4fa:	13490263          	beq	s2,s4,61e <vprintf+0x17e>
 4fe:	f9d9079b          	addw	a5,s2,-99
 502:	0ff7f793          	zext.b	a5,a5
 506:	12fb6563          	bltu	s6,a5,630 <vprintf+0x190>
 50a:	f9d9079b          	addw	a5,s2,-99
 50e:	0ff7f713          	zext.b	a4,a5
 512:	10eb6f63          	bltu	s6,a4,630 <vprintf+0x190>
 516:	00271793          	sll	a5,a4,0x2
 51a:	00000717          	auipc	a4,0x0
 51e:	36e70713          	add	a4,a4,878 # 888 <malloc+0x136>
 522:	97ba                	add	a5,a5,a4
 524:	439c                	lw	a5,0(a5)
 526:	97ba                	add	a5,a5,a4
 528:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 52a:	008b8913          	add	s2,s7,8
 52e:	4685                	li	a3,1
 530:	4629                	li	a2,10
 532:	000ba583          	lw	a1,0(s7)
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	ebc080e7          	jalr	-324(ra) # 3f4 <printint>
 540:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 542:	4981                	li	s3,0
 544:	b745                	j	4e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 546:	008b8913          	add	s2,s7,8
 54a:	4681                	li	a3,0
 54c:	4629                	li	a2,10
 54e:	000ba583          	lw	a1,0(s7)
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	ea0080e7          	jalr	-352(ra) # 3f4 <printint>
 55c:	8bca                	mv	s7,s2
      state = 0;
 55e:	4981                	li	s3,0
 560:	b751                	j	4e4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 562:	008b8913          	add	s2,s7,8
 566:	4681                	li	a3,0
 568:	4641                	li	a2,16
 56a:	000ba583          	lw	a1,0(s7)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	e84080e7          	jalr	-380(ra) # 3f4 <printint>
 578:	8bca                	mv	s7,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b7a5                	j	4e4 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 57e:	008b8c13          	add	s8,s7,8
 582:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 586:	03000593          	li	a1,48
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	e46080e7          	jalr	-442(ra) # 3d2 <putc>
  putc(fd, 'x');
 594:	07800593          	li	a1,120
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e38080e7          	jalr	-456(ra) # 3d2 <putc>
 5a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	00000b97          	auipc	s7,0x0
 5a8:	33cb8b93          	add	s7,s7,828 # 8e0 <digits>
 5ac:	03c9d793          	srl	a5,s3,0x3c
 5b0:	97de                	add	a5,a5,s7
 5b2:	0007c583          	lbu	a1,0(a5)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e1a080e7          	jalr	-486(ra) # 3d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c0:	0992                	sll	s3,s3,0x4
 5c2:	397d                	addw	s2,s2,-1
 5c4:	fe0914e3          	bnez	s2,5ac <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5c8:	8be2                	mv	s7,s8
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	bf21                	j	4e4 <vprintf+0x44>
        s = va_arg(ap, char*);
 5ce:	008b8993          	add	s3,s7,8
 5d2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5d6:	02090163          	beqz	s2,5f8 <vprintf+0x158>
        while(*s != 0){
 5da:	00094583          	lbu	a1,0(s2)
 5de:	c9a5                	beqz	a1,64e <vprintf+0x1ae>
          putc(fd, *s);
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	df0080e7          	jalr	-528(ra) # 3d2 <putc>
          s++;
 5ea:	0905                	add	s2,s2,1
        while(*s != 0){
 5ec:	00094583          	lbu	a1,0(s2)
 5f0:	f9e5                	bnez	a1,5e0 <vprintf+0x140>
        s = va_arg(ap, char*);
 5f2:	8bce                	mv	s7,s3
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b5fd                	j	4e4 <vprintf+0x44>
          s = "(null)";
 5f8:	00000917          	auipc	s2,0x0
 5fc:	28890913          	add	s2,s2,648 # 880 <malloc+0x12e>
        while(*s != 0){
 600:	02800593          	li	a1,40
 604:	bff1                	j	5e0 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 606:	008b8913          	add	s2,s7,8
 60a:	000bc583          	lbu	a1,0(s7)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	dc2080e7          	jalr	-574(ra) # 3d2 <putc>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b5e1                	j	4e4 <vprintf+0x44>
        putc(fd, c);
 61e:	02500593          	li	a1,37
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	dae080e7          	jalr	-594(ra) # 3d2 <putc>
      state = 0;
 62c:	4981                	li	s3,0
 62e:	bd5d                	j	4e4 <vprintf+0x44>
        putc(fd, '%');
 630:	02500593          	li	a1,37
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d9c080e7          	jalr	-612(ra) # 3d2 <putc>
        putc(fd, c);
 63e:	85ca                	mv	a1,s2
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	d90080e7          	jalr	-624(ra) # 3d2 <putc>
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bd61                	j	4e4 <vprintf+0x44>
        s = va_arg(ap, char*);
 64e:	8bce                	mv	s7,s3
      state = 0;
 650:	4981                	li	s3,0
 652:	bd49                	j	4e4 <vprintf+0x44>
    }
  }
}
 654:	60a6                	ld	ra,72(sp)
 656:	6406                	ld	s0,64(sp)
 658:	74e2                	ld	s1,56(sp)
 65a:	7942                	ld	s2,48(sp)
 65c:	79a2                	ld	s3,40(sp)
 65e:	7a02                	ld	s4,32(sp)
 660:	6ae2                	ld	s5,24(sp)
 662:	6b42                	ld	s6,16(sp)
 664:	6ba2                	ld	s7,8(sp)
 666:	6c02                	ld	s8,0(sp)
 668:	6161                	add	sp,sp,80
 66a:	8082                	ret

000000000000066c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 66c:	715d                	add	sp,sp,-80
 66e:	ec06                	sd	ra,24(sp)
 670:	e822                	sd	s0,16(sp)
 672:	1000                	add	s0,sp,32
 674:	e010                	sd	a2,0(s0)
 676:	e414                	sd	a3,8(s0)
 678:	e818                	sd	a4,16(s0)
 67a:	ec1c                	sd	a5,24(s0)
 67c:	03043023          	sd	a6,32(s0)
 680:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 684:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 688:	8622                	mv	a2,s0
 68a:	00000097          	auipc	ra,0x0
 68e:	e16080e7          	jalr	-490(ra) # 4a0 <vprintf>
}
 692:	60e2                	ld	ra,24(sp)
 694:	6442                	ld	s0,16(sp)
 696:	6161                	add	sp,sp,80
 698:	8082                	ret

000000000000069a <printf>:

void
printf(const char *fmt, ...)
{
 69a:	711d                	add	sp,sp,-96
 69c:	ec06                	sd	ra,24(sp)
 69e:	e822                	sd	s0,16(sp)
 6a0:	1000                	add	s0,sp,32
 6a2:	e40c                	sd	a1,8(s0)
 6a4:	e810                	sd	a2,16(s0)
 6a6:	ec14                	sd	a3,24(s0)
 6a8:	f018                	sd	a4,32(s0)
 6aa:	f41c                	sd	a5,40(s0)
 6ac:	03043823          	sd	a6,48(s0)
 6b0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b4:	00840613          	add	a2,s0,8
 6b8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6bc:	85aa                	mv	a1,a0
 6be:	4505                	li	a0,1
 6c0:	00000097          	auipc	ra,0x0
 6c4:	de0080e7          	jalr	-544(ra) # 4a0 <vprintf>
}
 6c8:	60e2                	ld	ra,24(sp)
 6ca:	6442                	ld	s0,16(sp)
 6cc:	6125                	add	sp,sp,96
 6ce:	8082                	ret

00000000000006d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d0:	1141                	add	sp,sp,-16
 6d2:	e422                	sd	s0,8(sp)
 6d4:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d6:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6da:	00001797          	auipc	a5,0x1
 6de:	9267b783          	ld	a5,-1754(a5) # 1000 <freep>
 6e2:	a02d                	j	70c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e4:	4618                	lw	a4,8(a2)
 6e6:	9f2d                	addw	a4,a4,a1
 6e8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ec:	6398                	ld	a4,0(a5)
 6ee:	6310                	ld	a2,0(a4)
 6f0:	a83d                	j	72e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f2:	ff852703          	lw	a4,-8(a0)
 6f6:	9f31                	addw	a4,a4,a2
 6f8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6fa:	ff053683          	ld	a3,-16(a0)
 6fe:	a091                	j	742 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 700:	6398                	ld	a4,0(a5)
 702:	00e7e463          	bltu	a5,a4,70a <free+0x3a>
 706:	00e6ea63          	bltu	a3,a4,71a <free+0x4a>
{
 70a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70c:	fed7fae3          	bgeu	a5,a3,700 <free+0x30>
 710:	6398                	ld	a4,0(a5)
 712:	00e6e463          	bltu	a3,a4,71a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 716:	fee7eae3          	bltu	a5,a4,70a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 71a:	ff852583          	lw	a1,-8(a0)
 71e:	6390                	ld	a2,0(a5)
 720:	02059813          	sll	a6,a1,0x20
 724:	01c85713          	srl	a4,a6,0x1c
 728:	9736                	add	a4,a4,a3
 72a:	fae60de3          	beq	a2,a4,6e4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 72e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 732:	4790                	lw	a2,8(a5)
 734:	02061593          	sll	a1,a2,0x20
 738:	01c5d713          	srl	a4,a1,0x1c
 73c:	973e                	add	a4,a4,a5
 73e:	fae68ae3          	beq	a3,a4,6f2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 742:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 744:	00001717          	auipc	a4,0x1
 748:	8af73e23          	sd	a5,-1860(a4) # 1000 <freep>
}
 74c:	6422                	ld	s0,8(sp)
 74e:	0141                	add	sp,sp,16
 750:	8082                	ret

0000000000000752 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 752:	7139                	add	sp,sp,-64
 754:	fc06                	sd	ra,56(sp)
 756:	f822                	sd	s0,48(sp)
 758:	f426                	sd	s1,40(sp)
 75a:	f04a                	sd	s2,32(sp)
 75c:	ec4e                	sd	s3,24(sp)
 75e:	e852                	sd	s4,16(sp)
 760:	e456                	sd	s5,8(sp)
 762:	e05a                	sd	s6,0(sp)
 764:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 766:	02051493          	sll	s1,a0,0x20
 76a:	9081                	srl	s1,s1,0x20
 76c:	04bd                	add	s1,s1,15
 76e:	8091                	srl	s1,s1,0x4
 770:	0014899b          	addw	s3,s1,1
 774:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 776:	00001517          	auipc	a0,0x1
 77a:	88a53503          	ld	a0,-1910(a0) # 1000 <freep>
 77e:	c515                	beqz	a0,7aa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 780:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 782:	4798                	lw	a4,8(a5)
 784:	02977f63          	bgeu	a4,s1,7c2 <malloc+0x70>
  if(nu < 4096)
 788:	8a4e                	mv	s4,s3
 78a:	0009871b          	sext.w	a4,s3
 78e:	6685                	lui	a3,0x1
 790:	00d77363          	bgeu	a4,a3,796 <malloc+0x44>
 794:	6a05                	lui	s4,0x1
 796:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 79a:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 79e:	00001917          	auipc	s2,0x1
 7a2:	86290913          	add	s2,s2,-1950 # 1000 <freep>
  if(p == (char*)-1)
 7a6:	5afd                	li	s5,-1
 7a8:	a895                	j	81c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7aa:	00001797          	auipc	a5,0x1
 7ae:	86678793          	add	a5,a5,-1946 # 1010 <base>
 7b2:	00001717          	auipc	a4,0x1
 7b6:	84f73723          	sd	a5,-1970(a4) # 1000 <freep>
 7ba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7bc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c0:	b7e1                	j	788 <malloc+0x36>
      if(p->s.size == nunits)
 7c2:	02e48c63          	beq	s1,a4,7fa <malloc+0xa8>
        p->s.size -= nunits;
 7c6:	4137073b          	subw	a4,a4,s3
 7ca:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7cc:	02071693          	sll	a3,a4,0x20
 7d0:	01c6d713          	srl	a4,a3,0x1c
 7d4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7da:	00001717          	auipc	a4,0x1
 7de:	82a73323          	sd	a0,-2010(a4) # 1000 <freep>
      return (void*)(p + 1);
 7e2:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e6:	70e2                	ld	ra,56(sp)
 7e8:	7442                	ld	s0,48(sp)
 7ea:	74a2                	ld	s1,40(sp)
 7ec:	7902                	ld	s2,32(sp)
 7ee:	69e2                	ld	s3,24(sp)
 7f0:	6a42                	ld	s4,16(sp)
 7f2:	6aa2                	ld	s5,8(sp)
 7f4:	6b02                	ld	s6,0(sp)
 7f6:	6121                	add	sp,sp,64
 7f8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7fa:	6398                	ld	a4,0(a5)
 7fc:	e118                	sd	a4,0(a0)
 7fe:	bff1                	j	7da <malloc+0x88>
  hp->s.size = nu;
 800:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 804:	0541                	add	a0,a0,16
 806:	00000097          	auipc	ra,0x0
 80a:	eca080e7          	jalr	-310(ra) # 6d0 <free>
  return freep;
 80e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 812:	d971                	beqz	a0,7e6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 814:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 816:	4798                	lw	a4,8(a5)
 818:	fa9775e3          	bgeu	a4,s1,7c2 <malloc+0x70>
    if(p == freep)
 81c:	00093703          	ld	a4,0(s2)
 820:	853e                	mv	a0,a5
 822:	fef719e3          	bne	a4,a5,814 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 826:	8552                	mv	a0,s4
 828:	00000097          	auipc	ra,0x0
 82c:	b8a080e7          	jalr	-1142(ra) # 3b2 <sbrk>
  if(p == (char*)-1)
 830:	fd5518e3          	bne	a0,s5,800 <malloc+0xae>
        return 0;
 834:	4501                	li	a0,0
 836:	bf45                	j	7e6 <malloc+0x94>
