
user/_ringbuf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main(int argc, char *argv[])
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	add	s0,sp,48
    const char name[16] = "muteeb";
   8:	00001797          	auipc	a5,0x1
   c:	83878793          	add	a5,a5,-1992 # 840 <malloc+0x108>
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
    uint64 buf1;
    // uint64 buf2;

    ringbuf(name, 1, &buf1);
  4a:	fd840613          	add	a2,s0,-40
  4e:	4585                	li	a1,1
  50:	fe040513          	add	a0,s0,-32
  54:	00000097          	auipc	ra,0x0
  58:	35c080e7          	jalr	860(ra) # 3b0 <ringbuf>
    // ringbuf(name, 1, &buf2);

    printf("ringbuf: %p\n", (buf1));
  5c:	fd843583          	ld	a1,-40(s0)
  60:	00000517          	auipc	a0,0x0
  64:	7c050513          	add	a0,a0,1984 # 820 <malloc+0xe8>
  68:	00000097          	auipc	ra,0x0
  6c:	618080e7          	jalr	1560(ra) # 680 <printf>
    // printf("ringbuf: %s\n", (char *)buf1);
    
    
    printf("\ngoodbye\n");
  70:	00000517          	auipc	a0,0x0
  74:	7c050513          	add	a0,a0,1984 # 830 <malloc+0xf8>
  78:	00000097          	auipc	ra,0x0
  7c:	608080e7          	jalr	1544(ra) # 680 <printf>
    return 0;
  80:	4501                	li	a0,0
  82:	70a2                	ld	ra,40(sp)
  84:	7402                	ld	s0,32(sp)
  86:	6145                	add	sp,sp,48
  88:	8082                	ret

000000000000008a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8a:	1141                	add	sp,sp,-16
  8c:	e406                	sd	ra,8(sp)
  8e:	e022                	sd	s0,0(sp)
  90:	0800                	add	s0,sp,16
  extern int main();
  main();
  92:	00000097          	auipc	ra,0x0
  96:	f6e080e7          	jalr	-146(ra) # 0 <main>
  exit(0);
  9a:	4501                	li	a0,0
  9c:	00000097          	auipc	ra,0x0
  a0:	274080e7          	jalr	628(ra) # 310 <exit>

00000000000000a4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a4:	1141                	add	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  aa:	87aa                	mv	a5,a0
  ac:	0585                	add	a1,a1,1
  ae:	0785                	add	a5,a5,1
  b0:	fff5c703          	lbu	a4,-1(a1)
  b4:	fee78fa3          	sb	a4,-1(a5)
  b8:	fb75                	bnez	a4,ac <strcpy+0x8>
    ;
  return os;
}
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	add	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c0:	1141                	add	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cb91                	beqz	a5,de <strcmp+0x1e>
  cc:	0005c703          	lbu	a4,0(a1)
  d0:	00f71763          	bne	a4,a5,de <strcmp+0x1e>
    p++, q++;
  d4:	0505                	add	a0,a0,1
  d6:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	fbe5                	bnez	a5,cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  de:	0005c503          	lbu	a0,0(a1)
}
  e2:	40a7853b          	subw	a0,a5,a0
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	add	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strlen>:

uint
strlen(const char *s)
{
  ec:	1141                	add	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cf91                	beqz	a5,112 <strlen+0x26>
  f8:	0505                	add	a0,a0,1
  fa:	87aa                	mv	a5,a0
  fc:	86be                	mv	a3,a5
  fe:	0785                	add	a5,a5,1
 100:	fff7c703          	lbu	a4,-1(a5)
 104:	ff65                	bnez	a4,fc <strlen+0x10>
 106:	40a6853b          	subw	a0,a3,a0
 10a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	add	sp,sp,16
 110:	8082                	ret
  for(n = 0; s[n]; n++)
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strlen+0x20>

0000000000000116 <memset>:

void*
memset(void *dst, int c, uint n)
{
 116:	1141                	add	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11c:	ca19                	beqz	a2,132 <memset+0x1c>
 11e:	87aa                	mv	a5,a0
 120:	1602                	sll	a2,a2,0x20
 122:	9201                	srl	a2,a2,0x20
 124:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 128:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 12c:	0785                	add	a5,a5,1
 12e:	fee79de3          	bne	a5,a4,128 <memset+0x12>
  }
  return dst;
}
 132:	6422                	ld	s0,8(sp)
 134:	0141                	add	sp,sp,16
 136:	8082                	ret

0000000000000138 <strchr>:

char*
strchr(const char *s, char c)
{
 138:	1141                	add	sp,sp,-16
 13a:	e422                	sd	s0,8(sp)
 13c:	0800                	add	s0,sp,16
  for(; *s; s++)
 13e:	00054783          	lbu	a5,0(a0)
 142:	cb99                	beqz	a5,158 <strchr+0x20>
    if(*s == c)
 144:	00f58763          	beq	a1,a5,152 <strchr+0x1a>
  for(; *s; s++)
 148:	0505                	add	a0,a0,1
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbfd                	bnez	a5,144 <strchr+0xc>
      return (char*)s;
  return 0;
 150:	4501                	li	a0,0
}
 152:	6422                	ld	s0,8(sp)
 154:	0141                	add	sp,sp,16
 156:	8082                	ret
  return 0;
 158:	4501                	li	a0,0
 15a:	bfe5                	j	152 <strchr+0x1a>

000000000000015c <gets>:

char*
gets(char *buf, int max)
{
 15c:	711d                	add	sp,sp,-96
 15e:	ec86                	sd	ra,88(sp)
 160:	e8a2                	sd	s0,80(sp)
 162:	e4a6                	sd	s1,72(sp)
 164:	e0ca                	sd	s2,64(sp)
 166:	fc4e                	sd	s3,56(sp)
 168:	f852                	sd	s4,48(sp)
 16a:	f456                	sd	s5,40(sp)
 16c:	f05a                	sd	s6,32(sp)
 16e:	ec5e                	sd	s7,24(sp)
 170:	1080                	add	s0,sp,96
 172:	8baa                	mv	s7,a0
 174:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 176:	892a                	mv	s2,a0
 178:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17a:	4aa9                	li	s5,10
 17c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 17e:	89a6                	mv	s3,s1
 180:	2485                	addw	s1,s1,1
 182:	0344d863          	bge	s1,s4,1b2 <gets+0x56>
    cc = read(0, &c, 1);
 186:	4605                	li	a2,1
 188:	faf40593          	add	a1,s0,-81
 18c:	4501                	li	a0,0
 18e:	00000097          	auipc	ra,0x0
 192:	19a080e7          	jalr	410(ra) # 328 <read>
    if(cc < 1)
 196:	00a05e63          	blez	a0,1b2 <gets+0x56>
    buf[i++] = c;
 19a:	faf44783          	lbu	a5,-81(s0)
 19e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a2:	01578763          	beq	a5,s5,1b0 <gets+0x54>
 1a6:	0905                	add	s2,s2,1
 1a8:	fd679be3          	bne	a5,s6,17e <gets+0x22>
  for(i=0; i+1 < max; ){
 1ac:	89a6                	mv	s3,s1
 1ae:	a011                	j	1b2 <gets+0x56>
 1b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b2:	99de                	add	s3,s3,s7
 1b4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b8:	855e                	mv	a0,s7
 1ba:	60e6                	ld	ra,88(sp)
 1bc:	6446                	ld	s0,80(sp)
 1be:	64a6                	ld	s1,72(sp)
 1c0:	6906                	ld	s2,64(sp)
 1c2:	79e2                	ld	s3,56(sp)
 1c4:	7a42                	ld	s4,48(sp)
 1c6:	7aa2                	ld	s5,40(sp)
 1c8:	7b02                	ld	s6,32(sp)
 1ca:	6be2                	ld	s7,24(sp)
 1cc:	6125                	add	sp,sp,96
 1ce:	8082                	ret

00000000000001d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d0:	1101                	add	sp,sp,-32
 1d2:	ec06                	sd	ra,24(sp)
 1d4:	e822                	sd	s0,16(sp)
 1d6:	e426                	sd	s1,8(sp)
 1d8:	e04a                	sd	s2,0(sp)
 1da:	1000                	add	s0,sp,32
 1dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1de:	4581                	li	a1,0
 1e0:	00000097          	auipc	ra,0x0
 1e4:	170080e7          	jalr	368(ra) # 350 <open>
  if(fd < 0)
 1e8:	02054563          	bltz	a0,212 <stat+0x42>
 1ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ee:	85ca                	mv	a1,s2
 1f0:	00000097          	auipc	ra,0x0
 1f4:	178080e7          	jalr	376(ra) # 368 <fstat>
 1f8:	892a                	mv	s2,a0
  close(fd);
 1fa:	8526                	mv	a0,s1
 1fc:	00000097          	auipc	ra,0x0
 200:	13c080e7          	jalr	316(ra) # 338 <close>
  return r;
}
 204:	854a                	mv	a0,s2
 206:	60e2                	ld	ra,24(sp)
 208:	6442                	ld	s0,16(sp)
 20a:	64a2                	ld	s1,8(sp)
 20c:	6902                	ld	s2,0(sp)
 20e:	6105                	add	sp,sp,32
 210:	8082                	ret
    return -1;
 212:	597d                	li	s2,-1
 214:	bfc5                	j	204 <stat+0x34>

0000000000000216 <atoi>:

int
atoi(const char *s)
{
 216:	1141                	add	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21c:	00054683          	lbu	a3,0(a0)
 220:	fd06879b          	addw	a5,a3,-48
 224:	0ff7f793          	zext.b	a5,a5
 228:	4625                	li	a2,9
 22a:	02f66863          	bltu	a2,a5,25a <atoi+0x44>
 22e:	872a                	mv	a4,a0
  n = 0;
 230:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 232:	0705                	add	a4,a4,1
 234:	0025179b          	sllw	a5,a0,0x2
 238:	9fa9                	addw	a5,a5,a0
 23a:	0017979b          	sllw	a5,a5,0x1
 23e:	9fb5                	addw	a5,a5,a3
 240:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 244:	00074683          	lbu	a3,0(a4)
 248:	fd06879b          	addw	a5,a3,-48
 24c:	0ff7f793          	zext.b	a5,a5
 250:	fef671e3          	bgeu	a2,a5,232 <atoi+0x1c>
  return n;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	add	sp,sp,16
 258:	8082                	ret
  n = 0;
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <atoi+0x3e>

000000000000025e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25e:	1141                	add	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57463          	bgeu	a0,a1,28c <memmove+0x2e>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x28>
 26c:	1602                	sll	a2,a2,0x20
 26e:	9201                	srl	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	add	a1,a1,1
 278:	0705                	add	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	add	sp,sp,16
 28a:	8082                	ret
    dst += n;
 28c:	00c50733          	add	a4,a0,a2
    src += n;
 290:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 292:	fec05ae3          	blez	a2,286 <memmove+0x28>
 296:	fff6079b          	addw	a5,a2,-1
 29a:	1782                	sll	a5,a5,0x20
 29c:	9381                	srl	a5,a5,0x20
 29e:	fff7c793          	not	a5,a5
 2a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a4:	15fd                	add	a1,a1,-1
 2a6:	177d                	add	a4,a4,-1
 2a8:	0005c683          	lbu	a3,0(a1)
 2ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b0:	fee79ae3          	bne	a5,a4,2a4 <memmove+0x46>
 2b4:	bfc9                	j	286 <memmove+0x28>

00000000000002b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b6:	1141                	add	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2bc:	ca05                	beqz	a2,2ec <memcmp+0x36>
 2be:	fff6069b          	addw	a3,a2,-1
 2c2:	1682                	sll	a3,a3,0x20
 2c4:	9281                	srl	a3,a3,0x20
 2c6:	0685                	add	a3,a3,1
 2c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	add	a0,a0,1
    p2++;
 2d8:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x14>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x30>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	add	sp,sp,16
 2ea:	8082                	ret
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <memcmp+0x30>

00000000000002f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f0:	1141                	add	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2f8:	00000097          	auipc	ra,0x0
 2fc:	f66080e7          	jalr	-154(ra) # 25e <memmove>
}
 300:	60a2                	ld	ra,8(sp)
 302:	6402                	ld	s0,0(sp)
 304:	0141                	add	sp,sp,16
 306:	8082                	ret

0000000000000308 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 308:	4885                	li	a7,1
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <exit>:
.global exit
exit:
 li a7, SYS_exit
 310:	4889                	li	a7,2
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <wait>:
.global wait
wait:
 li a7, SYS_wait
 318:	488d                	li	a7,3
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 320:	4891                	li	a7,4
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <read>:
.global read
read:
 li a7, SYS_read
 328:	4895                	li	a7,5
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <write>:
.global write
write:
 li a7, SYS_write
 330:	48c1                	li	a7,16
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <close>:
.global close
close:
 li a7, SYS_close
 338:	48d5                	li	a7,21
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <kill>:
.global kill
kill:
 li a7, SYS_kill
 340:	4899                	li	a7,6
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <exec>:
.global exec
exec:
 li a7, SYS_exec
 348:	489d                	li	a7,7
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <open>:
.global open
open:
 li a7, SYS_open
 350:	48bd                	li	a7,15
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 358:	48c5                	li	a7,17
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 360:	48c9                	li	a7,18
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 368:	48a1                	li	a7,8
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <link>:
.global link
link:
 li a7, SYS_link
 370:	48cd                	li	a7,19
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 378:	48d1                	li	a7,20
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 380:	48a5                	li	a7,9
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <dup>:
.global dup
dup:
 li a7, SYS_dup
 388:	48a9                	li	a7,10
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 390:	48ad                	li	a7,11
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 398:	48b1                	li	a7,12
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a0:	48b5                	li	a7,13
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a8:	48b9                	li	a7,14
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <ringbuf>:
.global ringbuf
ringbuf:
 li a7, SYS_ringbuf
 3b0:	48d9                	li	a7,22
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b8:	1101                	add	sp,sp,-32
 3ba:	ec06                	sd	ra,24(sp)
 3bc:	e822                	sd	s0,16(sp)
 3be:	1000                	add	s0,sp,32
 3c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c4:	4605                	li	a2,1
 3c6:	fef40593          	add	a1,s0,-17
 3ca:	00000097          	auipc	ra,0x0
 3ce:	f66080e7          	jalr	-154(ra) # 330 <write>
}
 3d2:	60e2                	ld	ra,24(sp)
 3d4:	6442                	ld	s0,16(sp)
 3d6:	6105                	add	sp,sp,32
 3d8:	8082                	ret

00000000000003da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3da:	7139                	add	sp,sp,-64
 3dc:	fc06                	sd	ra,56(sp)
 3de:	f822                	sd	s0,48(sp)
 3e0:	f426                	sd	s1,40(sp)
 3e2:	f04a                	sd	s2,32(sp)
 3e4:	ec4e                	sd	s3,24(sp)
 3e6:	0080                	add	s0,sp,64
 3e8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ea:	c299                	beqz	a3,3f0 <printint+0x16>
 3ec:	0805c963          	bltz	a1,47e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f0:	2581                	sext.w	a1,a1
  neg = 0;
 3f2:	4881                	li	a7,0
 3f4:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3f8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3fa:	2601                	sext.w	a2,a2
 3fc:	00000517          	auipc	a0,0x0
 400:	4b450513          	add	a0,a0,1204 # 8b0 <digits>
 404:	883a                	mv	a6,a4
 406:	2705                	addw	a4,a4,1
 408:	02c5f7bb          	remuw	a5,a1,a2
 40c:	1782                	sll	a5,a5,0x20
 40e:	9381                	srl	a5,a5,0x20
 410:	97aa                	add	a5,a5,a0
 412:	0007c783          	lbu	a5,0(a5)
 416:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41a:	0005879b          	sext.w	a5,a1
 41e:	02c5d5bb          	divuw	a1,a1,a2
 422:	0685                	add	a3,a3,1
 424:	fec7f0e3          	bgeu	a5,a2,404 <printint+0x2a>
  if(neg)
 428:	00088c63          	beqz	a7,440 <printint+0x66>
    buf[i++] = '-';
 42c:	fd070793          	add	a5,a4,-48
 430:	00878733          	add	a4,a5,s0
 434:	02d00793          	li	a5,45
 438:	fef70823          	sb	a5,-16(a4)
 43c:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 440:	02e05863          	blez	a4,470 <printint+0x96>
 444:	fc040793          	add	a5,s0,-64
 448:	00e78933          	add	s2,a5,a4
 44c:	fff78993          	add	s3,a5,-1
 450:	99ba                	add	s3,s3,a4
 452:	377d                	addw	a4,a4,-1
 454:	1702                	sll	a4,a4,0x20
 456:	9301                	srl	a4,a4,0x20
 458:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45c:	fff94583          	lbu	a1,-1(s2)
 460:	8526                	mv	a0,s1
 462:	00000097          	auipc	ra,0x0
 466:	f56080e7          	jalr	-170(ra) # 3b8 <putc>
  while(--i >= 0)
 46a:	197d                	add	s2,s2,-1
 46c:	ff3918e3          	bne	s2,s3,45c <printint+0x82>
}
 470:	70e2                	ld	ra,56(sp)
 472:	7442                	ld	s0,48(sp)
 474:	74a2                	ld	s1,40(sp)
 476:	7902                	ld	s2,32(sp)
 478:	69e2                	ld	s3,24(sp)
 47a:	6121                	add	sp,sp,64
 47c:	8082                	ret
    x = -xx;
 47e:	40b005bb          	negw	a1,a1
    neg = 1;
 482:	4885                	li	a7,1
    x = -xx;
 484:	bf85                	j	3f4 <printint+0x1a>

0000000000000486 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 486:	715d                	add	sp,sp,-80
 488:	e486                	sd	ra,72(sp)
 48a:	e0a2                	sd	s0,64(sp)
 48c:	fc26                	sd	s1,56(sp)
 48e:	f84a                	sd	s2,48(sp)
 490:	f44e                	sd	s3,40(sp)
 492:	f052                	sd	s4,32(sp)
 494:	ec56                	sd	s5,24(sp)
 496:	e85a                	sd	s6,16(sp)
 498:	e45e                	sd	s7,8(sp)
 49a:	e062                	sd	s8,0(sp)
 49c:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49e:	0005c903          	lbu	s2,0(a1)
 4a2:	18090c63          	beqz	s2,63a <vprintf+0x1b4>
 4a6:	8aaa                	mv	s5,a0
 4a8:	8bb2                	mv	s7,a2
 4aa:	00158493          	add	s1,a1,1
  state = 0;
 4ae:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b0:	02500a13          	li	s4,37
 4b4:	4b55                	li	s6,21
 4b6:	a839                	j	4d4 <vprintf+0x4e>
        putc(fd, c);
 4b8:	85ca                	mv	a1,s2
 4ba:	8556                	mv	a0,s5
 4bc:	00000097          	auipc	ra,0x0
 4c0:	efc080e7          	jalr	-260(ra) # 3b8 <putc>
 4c4:	a019                	j	4ca <vprintf+0x44>
    } else if(state == '%'){
 4c6:	01498d63          	beq	s3,s4,4e0 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4ca:	0485                	add	s1,s1,1
 4cc:	fff4c903          	lbu	s2,-1(s1)
 4d0:	16090563          	beqz	s2,63a <vprintf+0x1b4>
    if(state == 0){
 4d4:	fe0999e3          	bnez	s3,4c6 <vprintf+0x40>
      if(c == '%'){
 4d8:	ff4910e3          	bne	s2,s4,4b8 <vprintf+0x32>
        state = '%';
 4dc:	89d2                	mv	s3,s4
 4de:	b7f5                	j	4ca <vprintf+0x44>
      if(c == 'd'){
 4e0:	13490263          	beq	s2,s4,604 <vprintf+0x17e>
 4e4:	f9d9079b          	addw	a5,s2,-99
 4e8:	0ff7f793          	zext.b	a5,a5
 4ec:	12fb6563          	bltu	s6,a5,616 <vprintf+0x190>
 4f0:	f9d9079b          	addw	a5,s2,-99
 4f4:	0ff7f713          	zext.b	a4,a5
 4f8:	10eb6f63          	bltu	s6,a4,616 <vprintf+0x190>
 4fc:	00271793          	sll	a5,a4,0x2
 500:	00000717          	auipc	a4,0x0
 504:	35870713          	add	a4,a4,856 # 858 <malloc+0x120>
 508:	97ba                	add	a5,a5,a4
 50a:	439c                	lw	a5,0(a5)
 50c:	97ba                	add	a5,a5,a4
 50e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 510:	008b8913          	add	s2,s7,8
 514:	4685                	li	a3,1
 516:	4629                	li	a2,10
 518:	000ba583          	lw	a1,0(s7)
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	ebc080e7          	jalr	-324(ra) # 3da <printint>
 526:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 528:	4981                	li	s3,0
 52a:	b745                	j	4ca <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 52c:	008b8913          	add	s2,s7,8
 530:	4681                	li	a3,0
 532:	4629                	li	a2,10
 534:	000ba583          	lw	a1,0(s7)
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	ea0080e7          	jalr	-352(ra) # 3da <printint>
 542:	8bca                	mv	s7,s2
      state = 0;
 544:	4981                	li	s3,0
 546:	b751                	j	4ca <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 548:	008b8913          	add	s2,s7,8
 54c:	4681                	li	a3,0
 54e:	4641                	li	a2,16
 550:	000ba583          	lw	a1,0(s7)
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e84080e7          	jalr	-380(ra) # 3da <printint>
 55e:	8bca                	mv	s7,s2
      state = 0;
 560:	4981                	li	s3,0
 562:	b7a5                	j	4ca <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 564:	008b8c13          	add	s8,s7,8
 568:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 56c:	03000593          	li	a1,48
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e46080e7          	jalr	-442(ra) # 3b8 <putc>
  putc(fd, 'x');
 57a:	07800593          	li	a1,120
 57e:	8556                	mv	a0,s5
 580:	00000097          	auipc	ra,0x0
 584:	e38080e7          	jalr	-456(ra) # 3b8 <putc>
 588:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58a:	00000b97          	auipc	s7,0x0
 58e:	326b8b93          	add	s7,s7,806 # 8b0 <digits>
 592:	03c9d793          	srl	a5,s3,0x3c
 596:	97de                	add	a5,a5,s7
 598:	0007c583          	lbu	a1,0(a5)
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e1a080e7          	jalr	-486(ra) # 3b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5a6:	0992                	sll	s3,s3,0x4
 5a8:	397d                	addw	s2,s2,-1
 5aa:	fe0914e3          	bnez	s2,592 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5ae:	8be2                	mv	s7,s8
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bf21                	j	4ca <vprintf+0x44>
        s = va_arg(ap, char*);
 5b4:	008b8993          	add	s3,s7,8
 5b8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5bc:	02090163          	beqz	s2,5de <vprintf+0x158>
        while(*s != 0){
 5c0:	00094583          	lbu	a1,0(s2)
 5c4:	c9a5                	beqz	a1,634 <vprintf+0x1ae>
          putc(fd, *s);
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	df0080e7          	jalr	-528(ra) # 3b8 <putc>
          s++;
 5d0:	0905                	add	s2,s2,1
        while(*s != 0){
 5d2:	00094583          	lbu	a1,0(s2)
 5d6:	f9e5                	bnez	a1,5c6 <vprintf+0x140>
        s = va_arg(ap, char*);
 5d8:	8bce                	mv	s7,s3
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b5fd                	j	4ca <vprintf+0x44>
          s = "(null)";
 5de:	00000917          	auipc	s2,0x0
 5e2:	27290913          	add	s2,s2,626 # 850 <malloc+0x118>
        while(*s != 0){
 5e6:	02800593          	li	a1,40
 5ea:	bff1                	j	5c6 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5ec:	008b8913          	add	s2,s7,8
 5f0:	000bc583          	lbu	a1,0(s7)
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	dc2080e7          	jalr	-574(ra) # 3b8 <putc>
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
 602:	b5e1                	j	4ca <vprintf+0x44>
        putc(fd, c);
 604:	02500593          	li	a1,37
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	dae080e7          	jalr	-594(ra) # 3b8 <putc>
      state = 0;
 612:	4981                	li	s3,0
 614:	bd5d                	j	4ca <vprintf+0x44>
        putc(fd, '%');
 616:	02500593          	li	a1,37
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	d9c080e7          	jalr	-612(ra) # 3b8 <putc>
        putc(fd, c);
 624:	85ca                	mv	a1,s2
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	d90080e7          	jalr	-624(ra) # 3b8 <putc>
      state = 0;
 630:	4981                	li	s3,0
 632:	bd61                	j	4ca <vprintf+0x44>
        s = va_arg(ap, char*);
 634:	8bce                	mv	s7,s3
      state = 0;
 636:	4981                	li	s3,0
 638:	bd49                	j	4ca <vprintf+0x44>
    }
  }
}
 63a:	60a6                	ld	ra,72(sp)
 63c:	6406                	ld	s0,64(sp)
 63e:	74e2                	ld	s1,56(sp)
 640:	7942                	ld	s2,48(sp)
 642:	79a2                	ld	s3,40(sp)
 644:	7a02                	ld	s4,32(sp)
 646:	6ae2                	ld	s5,24(sp)
 648:	6b42                	ld	s6,16(sp)
 64a:	6ba2                	ld	s7,8(sp)
 64c:	6c02                	ld	s8,0(sp)
 64e:	6161                	add	sp,sp,80
 650:	8082                	ret

0000000000000652 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 652:	715d                	add	sp,sp,-80
 654:	ec06                	sd	ra,24(sp)
 656:	e822                	sd	s0,16(sp)
 658:	1000                	add	s0,sp,32
 65a:	e010                	sd	a2,0(s0)
 65c:	e414                	sd	a3,8(s0)
 65e:	e818                	sd	a4,16(s0)
 660:	ec1c                	sd	a5,24(s0)
 662:	03043023          	sd	a6,32(s0)
 666:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 66e:	8622                	mv	a2,s0
 670:	00000097          	auipc	ra,0x0
 674:	e16080e7          	jalr	-490(ra) # 486 <vprintf>
}
 678:	60e2                	ld	ra,24(sp)
 67a:	6442                	ld	s0,16(sp)
 67c:	6161                	add	sp,sp,80
 67e:	8082                	ret

0000000000000680 <printf>:

void
printf(const char *fmt, ...)
{
 680:	711d                	add	sp,sp,-96
 682:	ec06                	sd	ra,24(sp)
 684:	e822                	sd	s0,16(sp)
 686:	1000                	add	s0,sp,32
 688:	e40c                	sd	a1,8(s0)
 68a:	e810                	sd	a2,16(s0)
 68c:	ec14                	sd	a3,24(s0)
 68e:	f018                	sd	a4,32(s0)
 690:	f41c                	sd	a5,40(s0)
 692:	03043823          	sd	a6,48(s0)
 696:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69a:	00840613          	add	a2,s0,8
 69e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a2:	85aa                	mv	a1,a0
 6a4:	4505                	li	a0,1
 6a6:	00000097          	auipc	ra,0x0
 6aa:	de0080e7          	jalr	-544(ra) # 486 <vprintf>
}
 6ae:	60e2                	ld	ra,24(sp)
 6b0:	6442                	ld	s0,16(sp)
 6b2:	6125                	add	sp,sp,96
 6b4:	8082                	ret

00000000000006b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b6:	1141                	add	sp,sp,-16
 6b8:	e422                	sd	s0,8(sp)
 6ba:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6bc:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	00001797          	auipc	a5,0x1
 6c4:	9407b783          	ld	a5,-1728(a5) # 1000 <freep>
 6c8:	a02d                	j	6f2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ca:	4618                	lw	a4,8(a2)
 6cc:	9f2d                	addw	a4,a4,a1
 6ce:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d2:	6398                	ld	a4,0(a5)
 6d4:	6310                	ld	a2,0(a4)
 6d6:	a83d                	j	714 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d8:	ff852703          	lw	a4,-8(a0)
 6dc:	9f31                	addw	a4,a4,a2
 6de:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6e0:	ff053683          	ld	a3,-16(a0)
 6e4:	a091                	j	728 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	6398                	ld	a4,0(a5)
 6e8:	00e7e463          	bltu	a5,a4,6f0 <free+0x3a>
 6ec:	00e6ea63          	bltu	a3,a4,700 <free+0x4a>
{
 6f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	fed7fae3          	bgeu	a5,a3,6e6 <free+0x30>
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e6e463          	bltu	a3,a4,700 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	fee7eae3          	bltu	a5,a4,6f0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 700:	ff852583          	lw	a1,-8(a0)
 704:	6390                	ld	a2,0(a5)
 706:	02059813          	sll	a6,a1,0x20
 70a:	01c85713          	srl	a4,a6,0x1c
 70e:	9736                	add	a4,a4,a3
 710:	fae60de3          	beq	a2,a4,6ca <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 714:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 718:	4790                	lw	a2,8(a5)
 71a:	02061593          	sll	a1,a2,0x20
 71e:	01c5d713          	srl	a4,a1,0x1c
 722:	973e                	add	a4,a4,a5
 724:	fae68ae3          	beq	a3,a4,6d8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 728:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 72a:	00001717          	auipc	a4,0x1
 72e:	8cf73b23          	sd	a5,-1834(a4) # 1000 <freep>
}
 732:	6422                	ld	s0,8(sp)
 734:	0141                	add	sp,sp,16
 736:	8082                	ret

0000000000000738 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 738:	7139                	add	sp,sp,-64
 73a:	fc06                	sd	ra,56(sp)
 73c:	f822                	sd	s0,48(sp)
 73e:	f426                	sd	s1,40(sp)
 740:	f04a                	sd	s2,32(sp)
 742:	ec4e                	sd	s3,24(sp)
 744:	e852                	sd	s4,16(sp)
 746:	e456                	sd	s5,8(sp)
 748:	e05a                	sd	s6,0(sp)
 74a:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74c:	02051493          	sll	s1,a0,0x20
 750:	9081                	srl	s1,s1,0x20
 752:	04bd                	add	s1,s1,15
 754:	8091                	srl	s1,s1,0x4
 756:	0014899b          	addw	s3,s1,1
 75a:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 75c:	00001517          	auipc	a0,0x1
 760:	8a453503          	ld	a0,-1884(a0) # 1000 <freep>
 764:	c515                	beqz	a0,790 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 766:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 768:	4798                	lw	a4,8(a5)
 76a:	02977f63          	bgeu	a4,s1,7a8 <malloc+0x70>
  if(nu < 4096)
 76e:	8a4e                	mv	s4,s3
 770:	0009871b          	sext.w	a4,s3
 774:	6685                	lui	a3,0x1
 776:	00d77363          	bgeu	a4,a3,77c <malloc+0x44>
 77a:	6a05                	lui	s4,0x1
 77c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 780:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 784:	00001917          	auipc	s2,0x1
 788:	87c90913          	add	s2,s2,-1924 # 1000 <freep>
  if(p == (char*)-1)
 78c:	5afd                	li	s5,-1
 78e:	a895                	j	802 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 790:	00001797          	auipc	a5,0x1
 794:	88078793          	add	a5,a5,-1920 # 1010 <base>
 798:	00001717          	auipc	a4,0x1
 79c:	86f73423          	sd	a5,-1944(a4) # 1000 <freep>
 7a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a6:	b7e1                	j	76e <malloc+0x36>
      if(p->s.size == nunits)
 7a8:	02e48c63          	beq	s1,a4,7e0 <malloc+0xa8>
        p->s.size -= nunits;
 7ac:	4137073b          	subw	a4,a4,s3
 7b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b2:	02071693          	sll	a3,a4,0x20
 7b6:	01c6d713          	srl	a4,a3,0x1c
 7ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c0:	00001717          	auipc	a4,0x1
 7c4:	84a73023          	sd	a0,-1984(a4) # 1000 <freep>
      return (void*)(p + 1);
 7c8:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7cc:	70e2                	ld	ra,56(sp)
 7ce:	7442                	ld	s0,48(sp)
 7d0:	74a2                	ld	s1,40(sp)
 7d2:	7902                	ld	s2,32(sp)
 7d4:	69e2                	ld	s3,24(sp)
 7d6:	6a42                	ld	s4,16(sp)
 7d8:	6aa2                	ld	s5,8(sp)
 7da:	6b02                	ld	s6,0(sp)
 7dc:	6121                	add	sp,sp,64
 7de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e0:	6398                	ld	a4,0(a5)
 7e2:	e118                	sd	a4,0(a0)
 7e4:	bff1                	j	7c0 <malloc+0x88>
  hp->s.size = nu;
 7e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ea:	0541                	add	a0,a0,16
 7ec:	00000097          	auipc	ra,0x0
 7f0:	eca080e7          	jalr	-310(ra) # 6b6 <free>
  return freep;
 7f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7f8:	d971                	beqz	a0,7cc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fc:	4798                	lw	a4,8(a5)
 7fe:	fa9775e3          	bgeu	a4,s1,7a8 <malloc+0x70>
    if(p == freep)
 802:	00093703          	ld	a4,0(s2)
 806:	853e                	mv	a0,a5
 808:	fef719e3          	bne	a4,a5,7fa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 80c:	8552                	mv	a0,s4
 80e:	00000097          	auipc	ra,0x0
 812:	b8a080e7          	jalr	-1142(ra) # 398 <sbrk>
  if(p == (char*)-1)
 816:	fd5518e3          	bne	a0,s5,7e6 <malloc+0xae>
        return 0;
 81a:	4501                	li	a0,0
 81c:	bf45                	j	7cc <malloc+0x94>
