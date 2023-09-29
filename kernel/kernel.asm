
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b7010113          	add	sp,sp,-1168 # 80008b70 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	9e070713          	add	a4,a4,-1568 # 80008a30 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	e3e78793          	add	a5,a5,-450 # 80005ea0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc307>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	382080e7          	jalr	898(ra) # 800024ac <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	9ec50513          	add	a0,a0,-1556 # 80010b70 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	9dc48493          	add	s1,s1,-1572 # 80010b70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	a6c90913          	add	s2,s2,-1428 # 80010c08 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	13a080e7          	jalr	314(ra) # 800022f6 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	e84080e7          	jalr	-380(ra) # 8000204e <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	99270713          	add	a4,a4,-1646 # 80010b70 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	246080e7          	jalr	582(ra) # 80002456 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	94850513          	add	a0,a0,-1720 # 80010b70 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	93250513          	add	a0,a0,-1742 # 80010b70 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	98f72d23          	sw	a5,-1638(a4) # 80010c08 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	8a850513          	add	a0,a0,-1880 # 80010b70 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	214080e7          	jalr	532(ra) # 80002502 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	87a50513          	add	a0,a0,-1926 # 80010b70 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	85670713          	add	a4,a4,-1962 # 80010b70 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	82c78793          	add	a5,a5,-2004 # 80010b70 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	8967a783          	lw	a5,-1898(a5) # 80010c08 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	7ea70713          	add	a4,a4,2026 # 80010b70 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	7da48493          	add	s1,s1,2010 # 80010b70 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	79e70713          	add	a4,a4,1950 # 80010b70 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	82f72423          	sw	a5,-2008(a4) # 80010c10 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	76278793          	add	a5,a5,1890 # 80010b70 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	7cc7ad23          	sw	a2,2010(a5) # 80010c0c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	7ce50513          	add	a0,a0,1998 # 80010c08 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c70080e7          	jalr	-912(ra) # 800020b2 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	71450513          	add	a0,a0,1812 # 80010b70 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	eec78793          	add	a5,a5,-276 # 80021360 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	6e07a423          	sw	zero,1768(a5) # 80010c30 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	add	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	46f72a23          	sw	a5,1140(a4) # 800089f0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	add	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	678dad83          	lw	s11,1656(s11) # 80010c30 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	62250513          	add	a0,a0,1570 # 80010c18 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	add	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	add	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	add	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	4c450513          	add	a0,a0,1220 # 80010c18 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	4a848493          	add	s1,s1,1192 # 80010c18 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	46850513          	add	a0,a0,1128 # 80010c38 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	1f47a783          	lw	a5,500(a5) # 800089f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	and	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	1c47b783          	ld	a5,452(a5) # 800089f8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	1c473703          	ld	a4,452(a4) # 80008a00 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	3daa0a13          	add	s4,s4,986 # 80010c38 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	19248493          	add	s1,s1,402 # 800089f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	19298993          	add	s3,s3,402 # 80008a00 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	822080e7          	jalr	-2014(ra) # 800020b2 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	36c50513          	add	a0,a0,876 # 80010c38 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1147a783          	lw	a5,276(a5) # 800089f0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	11a73703          	ld	a4,282(a4) # 80008a00 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	10a7b783          	ld	a5,266(a5) # 800089f8 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	33e98993          	add	s3,s3,830 # 80010c38 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	0f648493          	add	s1,s1,246 # 800089f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	0f690913          	add	s2,s2,246 # 80008a00 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	734080e7          	jalr	1844(ra) # 8000204e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	30848493          	add	s1,s1,776 # 80010c38 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	0ae7be23          	sd	a4,188(a5) # 80008a00 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	add	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	28248493          	add	s1,s1,642 # 80010c38 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	b0078793          	add	a5,a5,-1280 # 800224f8 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	25890913          	add	s2,s2,600 # 80010c70 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	1ba50513          	add	a0,a0,442 # 80010c70 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	a2e50513          	add	a0,a0,-1490 # 800224f8 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	18448493          	add	s1,s1,388 # 80010c70 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	16c50513          	add	a0,a0,364 # 80010c70 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	14050513          	add	a0,a0,320 # 80010c70 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcb09>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	b8670713          	add	a4,a4,-1146 # 80008a08 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	add	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	a96080e7          	jalr	-1386(ra) # 8000294e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	020080e7          	jalr	32(ra) # 80005ee0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fd4080e7          	jalr	-44(ra) # 80001e9c <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	add	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	add	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	9f6080e7          	jalr	-1546(ra) # 80002926 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	a16080e7          	jalr	-1514(ra) # 8000294e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	f8a080e7          	jalr	-118(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	f98080e7          	jalr	-104(ra) # 80005ee0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	18e080e7          	jalr	398(ra) # 800030de <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	82c080e7          	jalr	-2004(ra) # 80003784 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	7a2080e7          	jalr	1954(ra) # 80004702 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	080080e7          	jalr	128(ra) # 80005fe8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d0e080e7          	jalr	-754(ra) # 80001c7e <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	a8f72523          	sw	a5,-1398(a4) # 80008a08 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	add	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	a7e7b783          	ld	a5,-1410(a5) # 80008a10 <kernel_pagetable>
    80000f9a:	83b1                	srl	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	sll	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	add	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	add	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	add	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srl	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	add	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srl	a5,s1,0xc
    80001006:	07aa                	sll	a5,a5,0xa
    80001008:	0017e793          	or	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcaff>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	and	s2,s2,511
    8000101e:	090e                	sll	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	and	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srl	s1,s1,0xa
    8000102e:	04b2                	sll	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srl	a0,s3,0xc
    80001036:	1ff57513          	and	a0,a0,511
    8000103a:	050e                	sll	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	add	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srl	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	add	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	and	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	add	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srl	a5,a5,0xa
    8000108e:	00c79513          	sll	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	add	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	add	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	and	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srl	s1,s1,0xc
    800010e8:	04aa                	sll	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	or	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	add	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	add	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	add	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	add	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	add	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	add	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	add	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	add	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	add	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	add	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	sll	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	sll	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	add	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	sll	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	add	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	add	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	7ca7b123          	sd	a0,1986(a5) # 80008a10 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	add	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	add	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	sll	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	sll	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	add	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	add	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	add	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	add	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	add	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	and	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	and	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	sll	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	add	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	add	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	add	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	add	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	add	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	add	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	add	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	add	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	add	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	add	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	add	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	add	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	sll	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	add	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	and	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	and	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	add	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	add	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	add	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	add	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	add	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srl	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	add	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	add	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	and	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srl	a1,a4,0xa
    8000159e:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	add	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	add	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srl	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	add	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	add	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	and	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	add	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	add	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	add	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	add	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	add	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	add	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	add	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	add	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	add	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	add	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	add	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcb08>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	add	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	add	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	add	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	add	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	00010497          	auipc	s1,0x10
    8000184a:	ed248493          	add	s1,s1,-302 # 80011718 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	add	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00016a17          	auipc	s4,0x16
    80001864:	8b8a0a13          	add	s4,s4,-1864 # 80017118 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	sra	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addw	a1,a1,1
    80001884:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	16848493          	add	s1,s1,360
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	add	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	add	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	add	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	add	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	3ae50513          	add	a0,a0,942 # 80010c90 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	add	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	3ae50513          	add	a0,a0,942 # 80010ca8 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	00010497          	auipc	s1,0x10
    8000190e:	e0e48493          	add	s1,s1,-498 # 80011718 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	add	s6,s6,-1818 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	add	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00015997          	auipc	s3,0x15
    80001930:	7ec98993          	add	s3,s3,2028 # 80017118 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	sra	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addw	a5,a5,1
    80001954:	00d7979b          	sllw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	16848493          	add	s1,s1,360
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	add	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000197a:	1141                	add	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	add	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198a:	1141                	add	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	add	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	sll	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	32a50513          	add	a0,a0,810 # 80010cc0 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	add	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a6:	1101                	add	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	add	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	sll	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	2d270713          	add	a4,a4,722 # 80010c90 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	add	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	1141                	add	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first) {
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	faa7a783          	lw	a5,-86(a5) # 800089a0 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	f66080e7          	jalr	-154(ra) # 80002966 <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	add	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	f807a823          	sw	zero,-112(a5) # 800089a0 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	cea080e7          	jalr	-790(ra) # 80003704 <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	add	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	26090913          	add	s2,s2,608 # 80010c90 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	f6278793          	add	a5,a5,-158 # 800089a4 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	add	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	add	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	add	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	add	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	sll	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	sll	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	add	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	sll	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	add	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	add	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	sll	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	sll	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	add	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	add	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	add	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b64:	6d28                	ld	a0,88(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b74:	68a8                	ld	a0,80(s1)
    80001b76:	c511                	beqz	a0,80001b82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b78:	64ac                	ld	a1,72(s1)
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	f8c080e7          	jalr	-116(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6105                	add	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <allocproc>:
{
    80001bb0:	1101                	add	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	00010497          	auipc	s1,0x10
    80001bc0:	b5c48493          	add	s1,s1,-1188 # 80011718 <proc>
    80001bc4:	00015917          	auipc	s2,0x15
    80001bc8:	55490913          	add	s2,s2,1364 # 80017118 <tickslock>
    acquire(&p->lock);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	004080e7          	jalr	4(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bd6:	4c9c                	lw	a5,24(s1)
    80001bd8:	cf81                	beqz	a5,80001bf0 <allocproc+0x40>
      release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	0aa080e7          	jalr	170(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be4:	16848493          	add	s1,s1,360
    80001be8:	ff2492e3          	bne	s1,s2,80001bcc <allocproc+0x1c>
  return 0;
    80001bec:	4481                	li	s1,0
    80001bee:	a889                	j	80001c40 <allocproc+0x90>
  p->pid = allocpid();
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e34080e7          	jalr	-460(ra) # 80001a24 <allocpid>
    80001bf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfa:	4785                	li	a5,1
    80001bfc:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	ee4080e7          	jalr	-284(ra) # 80000ae2 <kalloc>
    80001c06:	892a                	mv	s2,a0
    80001c08:	eca8                	sd	a0,88(s1)
    80001c0a:	c131                	beqz	a0,80001c4e <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	e5c080e7          	jalr	-420(ra) # 80001a6a <proc_pagetable>
    80001c16:	892a                	mv	s2,a0
    80001c18:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c1a:	c531                	beqz	a0,80001c66 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c1c:	07000613          	li	a2,112
    80001c20:	4581                	li	a1,0
    80001c22:	06048513          	add	a0,s1,96
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	0a8080e7          	jalr	168(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c2e:	00000797          	auipc	a5,0x0
    80001c32:	db078793          	add	a5,a5,-592 # 800019de <forkret>
    80001c36:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c38:	60bc                	ld	a5,64(s1)
    80001c3a:	6705                	lui	a4,0x1
    80001c3c:	97ba                	add	a5,a5,a4
    80001c3e:	f4bc                	sd	a5,104(s1)
}
    80001c40:	8526                	mv	a0,s1
    80001c42:	60e2                	ld	ra,24(sp)
    80001c44:	6442                	ld	s0,16(sp)
    80001c46:	64a2                	ld	s1,8(sp)
    80001c48:	6902                	ld	s2,0(sp)
    80001c4a:	6105                	add	sp,sp,32
    80001c4c:	8082                	ret
    freeproc(p);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	f08080e7          	jalr	-248(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	02c080e7          	jalr	44(ra) # 80000c86 <release>
    return 0;
    80001c62:	84ca                	mv	s1,s2
    80001c64:	bff1                	j	80001c40 <allocproc+0x90>
    freeproc(p);
    80001c66:	8526                	mv	a0,s1
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	ef0080e7          	jalr	-272(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	014080e7          	jalr	20(ra) # 80000c86 <release>
    return 0;
    80001c7a:	84ca                	mv	s1,s2
    80001c7c:	b7d1                	j	80001c40 <allocproc+0x90>

0000000080001c7e <userinit>:
{
    80001c7e:	1101                	add	sp,sp,-32
    80001c80:	ec06                	sd	ra,24(sp)
    80001c82:	e822                	sd	s0,16(sp)
    80001c84:	e426                	sd	s1,8(sp)
    80001c86:	1000                	add	s0,sp,32
  p = allocproc();
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	f28080e7          	jalr	-216(ra) # 80001bb0 <allocproc>
    80001c90:	84aa                	mv	s1,a0
  initproc = p;
    80001c92:	00007797          	auipc	a5,0x7
    80001c96:	d8a7b323          	sd	a0,-634(a5) # 80008a18 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c9a:	03400613          	li	a2,52
    80001c9e:	00007597          	auipc	a1,0x7
    80001ca2:	d1258593          	add	a1,a1,-750 # 800089b0 <initcode>
    80001ca6:	6928                	ld	a0,80(a0)
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	6a8080e7          	jalr	1704(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cb0:	6785                	lui	a5,0x1
    80001cb2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cb4:	6cb8                	ld	a4,88(s1)
    80001cb6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cba:	6cb8                	ld	a4,88(s1)
    80001cbc:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cbe:	4641                	li	a2,16
    80001cc0:	00006597          	auipc	a1,0x6
    80001cc4:	54058593          	add	a1,a1,1344 # 80008200 <digits+0x1c0>
    80001cc8:	15848513          	add	a0,s1,344
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	14a080e7          	jalr	330(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cd4:	00006517          	auipc	a0,0x6
    80001cd8:	53c50513          	add	a0,a0,1340 # 80008210 <digits+0x1d0>
    80001cdc:	00002097          	auipc	ra,0x2
    80001ce0:	446080e7          	jalr	1094(ra) # 80004122 <namei>
    80001ce4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ce8:	478d                	li	a5,3
    80001cea:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cec:	8526                	mv	a0,s1
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	f98080e7          	jalr	-104(ra) # 80000c86 <release>
}
    80001cf6:	60e2                	ld	ra,24(sp)
    80001cf8:	6442                	ld	s0,16(sp)
    80001cfa:	64a2                	ld	s1,8(sp)
    80001cfc:	6105                	add	sp,sp,32
    80001cfe:	8082                	ret

0000000080001d00 <growproc>:
{
    80001d00:	1101                	add	sp,sp,-32
    80001d02:	ec06                	sd	ra,24(sp)
    80001d04:	e822                	sd	s0,16(sp)
    80001d06:	e426                	sd	s1,8(sp)
    80001d08:	e04a                	sd	s2,0(sp)
    80001d0a:	1000                	add	s0,sp,32
    80001d0c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	c98080e7          	jalr	-872(ra) # 800019a6 <myproc>
    80001d16:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d18:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d1a:	01204c63          	bgtz	s2,80001d32 <growproc+0x32>
  } else if(n < 0){
    80001d1e:	02094663          	bltz	s2,80001d4a <growproc+0x4a>
  p->sz = sz;
    80001d22:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d24:	4501                	li	a0,0
}
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6902                	ld	s2,0(sp)
    80001d2e:	6105                	add	sp,sp,32
    80001d30:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d32:	4691                	li	a3,4
    80001d34:	00b90633          	add	a2,s2,a1
    80001d38:	6928                	ld	a0,80(a0)
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	6d0080e7          	jalr	1744(ra) # 8000140a <uvmalloc>
    80001d42:	85aa                	mv	a1,a0
    80001d44:	fd79                	bnez	a0,80001d22 <growproc+0x22>
      return -1;
    80001d46:	557d                	li	a0,-1
    80001d48:	bff9                	j	80001d26 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d4a:	00b90633          	add	a2,s2,a1
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	672080e7          	jalr	1650(ra) # 800013c2 <uvmdealloc>
    80001d58:	85aa                	mv	a1,a0
    80001d5a:	b7e1                	j	80001d22 <growproc+0x22>

0000000080001d5c <fork>:
{
    80001d5c:	7139                	add	sp,sp,-64
    80001d5e:	fc06                	sd	ra,56(sp)
    80001d60:	f822                	sd	s0,48(sp)
    80001d62:	f426                	sd	s1,40(sp)
    80001d64:	f04a                	sd	s2,32(sp)
    80001d66:	ec4e                	sd	s3,24(sp)
    80001d68:	e852                	sd	s4,16(sp)
    80001d6a:	e456                	sd	s5,8(sp)
    80001d6c:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001d6e:	00000097          	auipc	ra,0x0
    80001d72:	c38080e7          	jalr	-968(ra) # 800019a6 <myproc>
    80001d76:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d78:	00000097          	auipc	ra,0x0
    80001d7c:	e38080e7          	jalr	-456(ra) # 80001bb0 <allocproc>
    80001d80:	10050c63          	beqz	a0,80001e98 <fork+0x13c>
    80001d84:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d86:	048ab603          	ld	a2,72(s5)
    80001d8a:	692c                	ld	a1,80(a0)
    80001d8c:	050ab503          	ld	a0,80(s5)
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	7d2080e7          	jalr	2002(ra) # 80001562 <uvmcopy>
    80001d98:	04054863          	bltz	a0,80001de8 <fork+0x8c>
  np->sz = p->sz;
    80001d9c:	048ab783          	ld	a5,72(s5)
    80001da0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001da4:	058ab683          	ld	a3,88(s5)
    80001da8:	87b6                	mv	a5,a3
    80001daa:	058a3703          	ld	a4,88(s4)
    80001dae:	12068693          	add	a3,a3,288
    80001db2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001db6:	6788                	ld	a0,8(a5)
    80001db8:	6b8c                	ld	a1,16(a5)
    80001dba:	6f90                	ld	a2,24(a5)
    80001dbc:	01073023          	sd	a6,0(a4)
    80001dc0:	e708                	sd	a0,8(a4)
    80001dc2:	eb0c                	sd	a1,16(a4)
    80001dc4:	ef10                	sd	a2,24(a4)
    80001dc6:	02078793          	add	a5,a5,32
    80001dca:	02070713          	add	a4,a4,32
    80001dce:	fed792e3          	bne	a5,a3,80001db2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd2:	058a3783          	ld	a5,88(s4)
    80001dd6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dda:	0d0a8493          	add	s1,s5,208
    80001dde:	0d0a0913          	add	s2,s4,208
    80001de2:	150a8993          	add	s3,s5,336
    80001de6:	a00d                	j	80001e08 <fork+0xac>
    freeproc(np);
    80001de8:	8552                	mv	a0,s4
    80001dea:	00000097          	auipc	ra,0x0
    80001dee:	d6e080e7          	jalr	-658(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001df2:	8552                	mv	a0,s4
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	e92080e7          	jalr	-366(ra) # 80000c86 <release>
    return -1;
    80001dfc:	597d                	li	s2,-1
    80001dfe:	a059                	j	80001e84 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e00:	04a1                	add	s1,s1,8
    80001e02:	0921                	add	s2,s2,8
    80001e04:	01348b63          	beq	s1,s3,80001e1a <fork+0xbe>
    if(p->ofile[i])
    80001e08:	6088                	ld	a0,0(s1)
    80001e0a:	d97d                	beqz	a0,80001e00 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e0c:	00003097          	auipc	ra,0x3
    80001e10:	988080e7          	jalr	-1656(ra) # 80004794 <filedup>
    80001e14:	00a93023          	sd	a0,0(s2)
    80001e18:	b7e5                	j	80001e00 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e1a:	150ab503          	ld	a0,336(s5)
    80001e1e:	00002097          	auipc	ra,0x2
    80001e22:	b20080e7          	jalr	-1248(ra) # 8000393e <idup>
    80001e26:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2a:	4641                	li	a2,16
    80001e2c:	158a8593          	add	a1,s5,344
    80001e30:	158a0513          	add	a0,s4,344
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	fe2080e7          	jalr	-30(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e3c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e40:	8552                	mv	a0,s4
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	e44080e7          	jalr	-444(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e4a:	0000f497          	auipc	s1,0xf
    80001e4e:	e5e48493          	add	s1,s1,-418 # 80010ca8 <wait_lock>
    80001e52:	8526                	mv	a0,s1
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	d7e080e7          	jalr	-642(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e5c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e60:	8526                	mv	a0,s1
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	e24080e7          	jalr	-476(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e6a:	8552                	mv	a0,s4
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	d66080e7          	jalr	-666(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e74:	478d                	li	a5,3
    80001e76:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0a080e7          	jalr	-502(ra) # 80000c86 <release>
}
    80001e84:	854a                	mv	a0,s2
    80001e86:	70e2                	ld	ra,56(sp)
    80001e88:	7442                	ld	s0,48(sp)
    80001e8a:	74a2                	ld	s1,40(sp)
    80001e8c:	7902                	ld	s2,32(sp)
    80001e8e:	69e2                	ld	s3,24(sp)
    80001e90:	6a42                	ld	s4,16(sp)
    80001e92:	6aa2                	ld	s5,8(sp)
    80001e94:	6121                	add	sp,sp,64
    80001e96:	8082                	ret
    return -1;
    80001e98:	597d                	li	s2,-1
    80001e9a:	b7ed                	j	80001e84 <fork+0x128>

0000000080001e9c <scheduler>:
{
    80001e9c:	7139                	add	sp,sp,-64
    80001e9e:	fc06                	sd	ra,56(sp)
    80001ea0:	f822                	sd	s0,48(sp)
    80001ea2:	f426                	sd	s1,40(sp)
    80001ea4:	f04a                	sd	s2,32(sp)
    80001ea6:	ec4e                	sd	s3,24(sp)
    80001ea8:	e852                	sd	s4,16(sp)
    80001eaa:	e456                	sd	s5,8(sp)
    80001eac:	e05a                	sd	s6,0(sp)
    80001eae:	0080                	add	s0,sp,64
    80001eb0:	8792                	mv	a5,tp
  int id = r_tp();
    80001eb2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eb4:	00779a93          	sll	s5,a5,0x7
    80001eb8:	0000f717          	auipc	a4,0xf
    80001ebc:	dd870713          	add	a4,a4,-552 # 80010c90 <pid_lock>
    80001ec0:	9756                	add	a4,a4,s5
    80001ec2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	e0270713          	add	a4,a4,-510 # 80010cc8 <cpus+0x8>
    80001ece:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed0:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed2:	4b11                	li	s6,4
        c->proc = p;
    80001ed4:	079e                	sll	a5,a5,0x7
    80001ed6:	0000fa17          	auipc	s4,0xf
    80001eda:	dbaa0a13          	add	s4,s4,-582 # 80010c90 <pid_lock>
    80001ede:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee0:	00015917          	auipc	s2,0x15
    80001ee4:	23890913          	add	s2,s2,568 # 80017118 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eec:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef0:	10079073          	csrw	sstatus,a5
    80001ef4:	00010497          	auipc	s1,0x10
    80001ef8:	82448493          	add	s1,s1,-2012 # 80011718 <proc>
    80001efc:	a811                	j	80001f10 <scheduler+0x74>
      release(&p->lock);
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	d86080e7          	jalr	-634(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f08:	16848493          	add	s1,s1,360
    80001f0c:	fd248ee3          	beq	s1,s2,80001ee8 <scheduler+0x4c>
      acquire(&p->lock);
    80001f10:	8526                	mv	a0,s1
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	cc0080e7          	jalr	-832(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f1a:	4c9c                	lw	a5,24(s1)
    80001f1c:	ff3791e3          	bne	a5,s3,80001efe <scheduler+0x62>
        p->state = RUNNING;
    80001f20:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f24:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f28:	06048593          	add	a1,s1,96
    80001f2c:	8556                	mv	a0,s5
    80001f2e:	00001097          	auipc	ra,0x1
    80001f32:	98e080e7          	jalr	-1650(ra) # 800028bc <swtch>
        c->proc = 0;
    80001f36:	020a3823          	sd	zero,48(s4)
    80001f3a:	b7d1                	j	80001efe <scheduler+0x62>

0000000080001f3c <sched>:
{
    80001f3c:	7179                	add	sp,sp,-48
    80001f3e:	f406                	sd	ra,40(sp)
    80001f40:	f022                	sd	s0,32(sp)
    80001f42:	ec26                	sd	s1,24(sp)
    80001f44:	e84a                	sd	s2,16(sp)
    80001f46:	e44e                	sd	s3,8(sp)
    80001f48:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001f4a:	00000097          	auipc	ra,0x0
    80001f4e:	a5c080e7          	jalr	-1444(ra) # 800019a6 <myproc>
    80001f52:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	c04080e7          	jalr	-1020(ra) # 80000b58 <holding>
    80001f5c:	c93d                	beqz	a0,80001fd2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f5e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f60:	2781                	sext.w	a5,a5
    80001f62:	079e                	sll	a5,a5,0x7
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	d2c70713          	add	a4,a4,-724 # 80010c90 <pid_lock>
    80001f6c:	97ba                	add	a5,a5,a4
    80001f6e:	0a87a703          	lw	a4,168(a5)
    80001f72:	4785                	li	a5,1
    80001f74:	06f71763          	bne	a4,a5,80001fe2 <sched+0xa6>
  if(p->state == RUNNING)
    80001f78:	4c98                	lw	a4,24(s1)
    80001f7a:	4791                	li	a5,4
    80001f7c:	06f70b63          	beq	a4,a5,80001ff2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f80:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f84:	8b89                	and	a5,a5,2
  if(intr_get())
    80001f86:	efb5                	bnez	a5,80002002 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f88:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f8a:	0000f917          	auipc	s2,0xf
    80001f8e:	d0690913          	add	s2,s2,-762 # 80010c90 <pid_lock>
    80001f92:	2781                	sext.w	a5,a5
    80001f94:	079e                	sll	a5,a5,0x7
    80001f96:	97ca                	add	a5,a5,s2
    80001f98:	0ac7a983          	lw	s3,172(a5)
    80001f9c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f9e:	2781                	sext.w	a5,a5
    80001fa0:	079e                	sll	a5,a5,0x7
    80001fa2:	0000f597          	auipc	a1,0xf
    80001fa6:	d2658593          	add	a1,a1,-730 # 80010cc8 <cpus+0x8>
    80001faa:	95be                	add	a1,a1,a5
    80001fac:	06048513          	add	a0,s1,96
    80001fb0:	00001097          	auipc	ra,0x1
    80001fb4:	90c080e7          	jalr	-1780(ra) # 800028bc <swtch>
    80001fb8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fba:	2781                	sext.w	a5,a5
    80001fbc:	079e                	sll	a5,a5,0x7
    80001fbe:	993e                	add	s2,s2,a5
    80001fc0:	0b392623          	sw	s3,172(s2)
}
    80001fc4:	70a2                	ld	ra,40(sp)
    80001fc6:	7402                	ld	s0,32(sp)
    80001fc8:	64e2                	ld	s1,24(sp)
    80001fca:	6942                	ld	s2,16(sp)
    80001fcc:	69a2                	ld	s3,8(sp)
    80001fce:	6145                	add	sp,sp,48
    80001fd0:	8082                	ret
    panic("sched p->lock");
    80001fd2:	00006517          	auipc	a0,0x6
    80001fd6:	24650513          	add	a0,a0,582 # 80008218 <digits+0x1d8>
    80001fda:	ffffe097          	auipc	ra,0xffffe
    80001fde:	562080e7          	jalr	1378(ra) # 8000053c <panic>
    panic("sched locks");
    80001fe2:	00006517          	auipc	a0,0x6
    80001fe6:	24650513          	add	a0,a0,582 # 80008228 <digits+0x1e8>
    80001fea:	ffffe097          	auipc	ra,0xffffe
    80001fee:	552080e7          	jalr	1362(ra) # 8000053c <panic>
    panic("sched running");
    80001ff2:	00006517          	auipc	a0,0x6
    80001ff6:	24650513          	add	a0,a0,582 # 80008238 <digits+0x1f8>
    80001ffa:	ffffe097          	auipc	ra,0xffffe
    80001ffe:	542080e7          	jalr	1346(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002002:	00006517          	auipc	a0,0x6
    80002006:	24650513          	add	a0,a0,582 # 80008248 <digits+0x208>
    8000200a:	ffffe097          	auipc	ra,0xffffe
    8000200e:	532080e7          	jalr	1330(ra) # 8000053c <panic>

0000000080002012 <yield>:
{
    80002012:	1101                	add	sp,sp,-32
    80002014:	ec06                	sd	ra,24(sp)
    80002016:	e822                	sd	s0,16(sp)
    80002018:	e426                	sd	s1,8(sp)
    8000201a:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    8000201c:	00000097          	auipc	ra,0x0
    80002020:	98a080e7          	jalr	-1654(ra) # 800019a6 <myproc>
    80002024:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	bac080e7          	jalr	-1108(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000202e:	478d                	li	a5,3
    80002030:	cc9c                	sw	a5,24(s1)
  sched();
    80002032:	00000097          	auipc	ra,0x0
    80002036:	f0a080e7          	jalr	-246(ra) # 80001f3c <sched>
  release(&p->lock);
    8000203a:	8526                	mv	a0,s1
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	c4a080e7          	jalr	-950(ra) # 80000c86 <release>
}
    80002044:	60e2                	ld	ra,24(sp)
    80002046:	6442                	ld	s0,16(sp)
    80002048:	64a2                	ld	s1,8(sp)
    8000204a:	6105                	add	sp,sp,32
    8000204c:	8082                	ret

000000008000204e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000204e:	7179                	add	sp,sp,-48
    80002050:	f406                	sd	ra,40(sp)
    80002052:	f022                	sd	s0,32(sp)
    80002054:	ec26                	sd	s1,24(sp)
    80002056:	e84a                	sd	s2,16(sp)
    80002058:	e44e                	sd	s3,8(sp)
    8000205a:	1800                	add	s0,sp,48
    8000205c:	89aa                	mv	s3,a0
    8000205e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002060:	00000097          	auipc	ra,0x0
    80002064:	946080e7          	jalr	-1722(ra) # 800019a6 <myproc>
    80002068:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	b68080e7          	jalr	-1176(ra) # 80000bd2 <acquire>
  release(lk);
    80002072:	854a                	mv	a0,s2
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	c12080e7          	jalr	-1006(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000207c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002080:	4789                	li	a5,2
    80002082:	cc9c                	sw	a5,24(s1)

  sched();
    80002084:	00000097          	auipc	ra,0x0
    80002088:	eb8080e7          	jalr	-328(ra) # 80001f3c <sched>

  // Tidy up.
  p->chan = 0;
    8000208c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	bf4080e7          	jalr	-1036(ra) # 80000c86 <release>
  acquire(lk);
    8000209a:	854a                	mv	a0,s2
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	b36080e7          	jalr	-1226(ra) # 80000bd2 <acquire>
}
    800020a4:	70a2                	ld	ra,40(sp)
    800020a6:	7402                	ld	s0,32(sp)
    800020a8:	64e2                	ld	s1,24(sp)
    800020aa:	6942                	ld	s2,16(sp)
    800020ac:	69a2                	ld	s3,8(sp)
    800020ae:	6145                	add	sp,sp,48
    800020b0:	8082                	ret

00000000800020b2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020b2:	7139                	add	sp,sp,-64
    800020b4:	fc06                	sd	ra,56(sp)
    800020b6:	f822                	sd	s0,48(sp)
    800020b8:	f426                	sd	s1,40(sp)
    800020ba:	f04a                	sd	s2,32(sp)
    800020bc:	ec4e                	sd	s3,24(sp)
    800020be:	e852                	sd	s4,16(sp)
    800020c0:	e456                	sd	s5,8(sp)
    800020c2:	0080                	add	s0,sp,64
    800020c4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020c6:	0000f497          	auipc	s1,0xf
    800020ca:	65248493          	add	s1,s1,1618 # 80011718 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ce:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d2:	00015917          	auipc	s2,0x15
    800020d6:	04690913          	add	s2,s2,70 # 80017118 <tickslock>
    800020da:	a811                	j	800020ee <wakeup+0x3c>
      }
      release(&p->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	ba8080e7          	jalr	-1112(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e6:	16848493          	add	s1,s1,360
    800020ea:	03248663          	beq	s1,s2,80002116 <wakeup+0x64>
    if(p != myproc()){
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	8b8080e7          	jalr	-1864(ra) # 800019a6 <myproc>
    800020f6:	fea488e3          	beq	s1,a0,800020e6 <wakeup+0x34>
      acquire(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ad6080e7          	jalr	-1322(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002104:	4c9c                	lw	a5,24(s1)
    80002106:	fd379be3          	bne	a5,s3,800020dc <wakeup+0x2a>
    8000210a:	709c                	ld	a5,32(s1)
    8000210c:	fd4798e3          	bne	a5,s4,800020dc <wakeup+0x2a>
        p->state = RUNNABLE;
    80002110:	0154ac23          	sw	s5,24(s1)
    80002114:	b7e1                	j	800020dc <wakeup+0x2a>
    }
  }
}
    80002116:	70e2                	ld	ra,56(sp)
    80002118:	7442                	ld	s0,48(sp)
    8000211a:	74a2                	ld	s1,40(sp)
    8000211c:	7902                	ld	s2,32(sp)
    8000211e:	69e2                	ld	s3,24(sp)
    80002120:	6a42                	ld	s4,16(sp)
    80002122:	6aa2                	ld	s5,8(sp)
    80002124:	6121                	add	sp,sp,64
    80002126:	8082                	ret

0000000080002128 <reparent>:
{
    80002128:	7179                	add	sp,sp,-48
    8000212a:	f406                	sd	ra,40(sp)
    8000212c:	f022                	sd	s0,32(sp)
    8000212e:	ec26                	sd	s1,24(sp)
    80002130:	e84a                	sd	s2,16(sp)
    80002132:	e44e                	sd	s3,8(sp)
    80002134:	e052                	sd	s4,0(sp)
    80002136:	1800                	add	s0,sp,48
    80002138:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000213a:	0000f497          	auipc	s1,0xf
    8000213e:	5de48493          	add	s1,s1,1502 # 80011718 <proc>
      pp->parent = initproc;
    80002142:	00007a17          	auipc	s4,0x7
    80002146:	8d6a0a13          	add	s4,s4,-1834 # 80008a18 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000214a:	00015997          	auipc	s3,0x15
    8000214e:	fce98993          	add	s3,s3,-50 # 80017118 <tickslock>
    80002152:	a029                	j	8000215c <reparent+0x34>
    80002154:	16848493          	add	s1,s1,360
    80002158:	01348d63          	beq	s1,s3,80002172 <reparent+0x4a>
    if(pp->parent == p){
    8000215c:	7c9c                	ld	a5,56(s1)
    8000215e:	ff279be3          	bne	a5,s2,80002154 <reparent+0x2c>
      pp->parent = initproc;
    80002162:	000a3503          	ld	a0,0(s4)
    80002166:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002168:	00000097          	auipc	ra,0x0
    8000216c:	f4a080e7          	jalr	-182(ra) # 800020b2 <wakeup>
    80002170:	b7d5                	j	80002154 <reparent+0x2c>
}
    80002172:	70a2                	ld	ra,40(sp)
    80002174:	7402                	ld	s0,32(sp)
    80002176:	64e2                	ld	s1,24(sp)
    80002178:	6942                	ld	s2,16(sp)
    8000217a:	69a2                	ld	s3,8(sp)
    8000217c:	6a02                	ld	s4,0(sp)
    8000217e:	6145                	add	sp,sp,48
    80002180:	8082                	ret

0000000080002182 <exit>:
{
    80002182:	7179                	add	sp,sp,-48
    80002184:	f406                	sd	ra,40(sp)
    80002186:	f022                	sd	s0,32(sp)
    80002188:	ec26                	sd	s1,24(sp)
    8000218a:	e84a                	sd	s2,16(sp)
    8000218c:	e44e                	sd	s3,8(sp)
    8000218e:	e052                	sd	s4,0(sp)
    80002190:	1800                	add	s0,sp,48
    80002192:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002194:	00000097          	auipc	ra,0x0
    80002198:	812080e7          	jalr	-2030(ra) # 800019a6 <myproc>
    8000219c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000219e:	00007797          	auipc	a5,0x7
    800021a2:	87a7b783          	ld	a5,-1926(a5) # 80008a18 <initproc>
    800021a6:	0d050493          	add	s1,a0,208
    800021aa:	15050913          	add	s2,a0,336
    800021ae:	02a79363          	bne	a5,a0,800021d4 <exit+0x52>
    panic("init exiting");
    800021b2:	00006517          	auipc	a0,0x6
    800021b6:	0ae50513          	add	a0,a0,174 # 80008260 <digits+0x220>
    800021ba:	ffffe097          	auipc	ra,0xffffe
    800021be:	382080e7          	jalr	898(ra) # 8000053c <panic>
      fileclose(f);
    800021c2:	00002097          	auipc	ra,0x2
    800021c6:	624080e7          	jalr	1572(ra) # 800047e6 <fileclose>
      p->ofile[fd] = 0;
    800021ca:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021ce:	04a1                	add	s1,s1,8
    800021d0:	01248563          	beq	s1,s2,800021da <exit+0x58>
    if(p->ofile[fd]){
    800021d4:	6088                	ld	a0,0(s1)
    800021d6:	f575                	bnez	a0,800021c2 <exit+0x40>
    800021d8:	bfdd                	j	800021ce <exit+0x4c>
  begin_op();
    800021da:	00002097          	auipc	ra,0x2
    800021de:	148080e7          	jalr	328(ra) # 80004322 <begin_op>
  iput(p->cwd);
    800021e2:	1509b503          	ld	a0,336(s3)
    800021e6:	00002097          	auipc	ra,0x2
    800021ea:	950080e7          	jalr	-1712(ra) # 80003b36 <iput>
  end_op();
    800021ee:	00002097          	auipc	ra,0x2
    800021f2:	1ae080e7          	jalr	430(ra) # 8000439c <end_op>
  p->cwd = 0;
    800021f6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021fa:	0000f497          	auipc	s1,0xf
    800021fe:	aae48493          	add	s1,s1,-1362 # 80010ca8 <wait_lock>
    80002202:	8526                	mv	a0,s1
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	9ce080e7          	jalr	-1586(ra) # 80000bd2 <acquire>
  reparent(p);
    8000220c:	854e                	mv	a0,s3
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	f1a080e7          	jalr	-230(ra) # 80002128 <reparent>
  wakeup(p->parent);
    80002216:	0389b503          	ld	a0,56(s3)
    8000221a:	00000097          	auipc	ra,0x0
    8000221e:	e98080e7          	jalr	-360(ra) # 800020b2 <wakeup>
  acquire(&p->lock);
    80002222:	854e                	mv	a0,s3
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	9ae080e7          	jalr	-1618(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000222c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002230:	4795                	li	a5,5
    80002232:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	a4e080e7          	jalr	-1458(ra) # 80000c86 <release>
  sched();
    80002240:	00000097          	auipc	ra,0x0
    80002244:	cfc080e7          	jalr	-772(ra) # 80001f3c <sched>
  panic("zombie exit");
    80002248:	00006517          	auipc	a0,0x6
    8000224c:	02850513          	add	a0,a0,40 # 80008270 <digits+0x230>
    80002250:	ffffe097          	auipc	ra,0xffffe
    80002254:	2ec080e7          	jalr	748(ra) # 8000053c <panic>

0000000080002258 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002258:	7179                	add	sp,sp,-48
    8000225a:	f406                	sd	ra,40(sp)
    8000225c:	f022                	sd	s0,32(sp)
    8000225e:	ec26                	sd	s1,24(sp)
    80002260:	e84a                	sd	s2,16(sp)
    80002262:	e44e                	sd	s3,8(sp)
    80002264:	1800                	add	s0,sp,48
    80002266:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002268:	0000f497          	auipc	s1,0xf
    8000226c:	4b048493          	add	s1,s1,1200 # 80011718 <proc>
    80002270:	00015997          	auipc	s3,0x15
    80002274:	ea898993          	add	s3,s3,-344 # 80017118 <tickslock>
    acquire(&p->lock);
    80002278:	8526                	mv	a0,s1
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	958080e7          	jalr	-1704(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    80002282:	589c                	lw	a5,48(s1)
    80002284:	01278d63          	beq	a5,s2,8000229e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002288:	8526                	mv	a0,s1
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	9fc080e7          	jalr	-1540(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002292:	16848493          	add	s1,s1,360
    80002296:	ff3491e3          	bne	s1,s3,80002278 <kill+0x20>
  }
  return -1;
    8000229a:	557d                	li	a0,-1
    8000229c:	a829                	j	800022b6 <kill+0x5e>
      p->killed = 1;
    8000229e:	4785                	li	a5,1
    800022a0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022a2:	4c98                	lw	a4,24(s1)
    800022a4:	4789                	li	a5,2
    800022a6:	00f70f63          	beq	a4,a5,800022c4 <kill+0x6c>
      release(&p->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	9da080e7          	jalr	-1574(ra) # 80000c86 <release>
      return 0;
    800022b4:	4501                	li	a0,0
}
    800022b6:	70a2                	ld	ra,40(sp)
    800022b8:	7402                	ld	s0,32(sp)
    800022ba:	64e2                	ld	s1,24(sp)
    800022bc:	6942                	ld	s2,16(sp)
    800022be:	69a2                	ld	s3,8(sp)
    800022c0:	6145                	add	sp,sp,48
    800022c2:	8082                	ret
        p->state = RUNNABLE;
    800022c4:	478d                	li	a5,3
    800022c6:	cc9c                	sw	a5,24(s1)
    800022c8:	b7cd                	j	800022aa <kill+0x52>

00000000800022ca <setkilled>:

void
setkilled(struct proc *p)
{
    800022ca:	1101                	add	sp,sp,-32
    800022cc:	ec06                	sd	ra,24(sp)
    800022ce:	e822                	sd	s0,16(sp)
    800022d0:	e426                	sd	s1,8(sp)
    800022d2:	1000                	add	s0,sp,32
    800022d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	8fc080e7          	jalr	-1796(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800022de:	4785                	li	a5,1
    800022e0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	9a2080e7          	jalr	-1630(ra) # 80000c86 <release>
}
    800022ec:	60e2                	ld	ra,24(sp)
    800022ee:	6442                	ld	s0,16(sp)
    800022f0:	64a2                	ld	s1,8(sp)
    800022f2:	6105                	add	sp,sp,32
    800022f4:	8082                	ret

00000000800022f6 <killed>:

int
killed(struct proc *p)
{
    800022f6:	1101                	add	sp,sp,-32
    800022f8:	ec06                	sd	ra,24(sp)
    800022fa:	e822                	sd	s0,16(sp)
    800022fc:	e426                	sd	s1,8(sp)
    800022fe:	e04a                	sd	s2,0(sp)
    80002300:	1000                	add	s0,sp,32
    80002302:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	8ce080e7          	jalr	-1842(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000230c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	974080e7          	jalr	-1676(ra) # 80000c86 <release>
  return k;
}
    8000231a:	854a                	mv	a0,s2
    8000231c:	60e2                	ld	ra,24(sp)
    8000231e:	6442                	ld	s0,16(sp)
    80002320:	64a2                	ld	s1,8(sp)
    80002322:	6902                	ld	s2,0(sp)
    80002324:	6105                	add	sp,sp,32
    80002326:	8082                	ret

0000000080002328 <wait>:
{
    80002328:	715d                	add	sp,sp,-80
    8000232a:	e486                	sd	ra,72(sp)
    8000232c:	e0a2                	sd	s0,64(sp)
    8000232e:	fc26                	sd	s1,56(sp)
    80002330:	f84a                	sd	s2,48(sp)
    80002332:	f44e                	sd	s3,40(sp)
    80002334:	f052                	sd	s4,32(sp)
    80002336:	ec56                	sd	s5,24(sp)
    80002338:	e85a                	sd	s6,16(sp)
    8000233a:	e45e                	sd	s7,8(sp)
    8000233c:	e062                	sd	s8,0(sp)
    8000233e:	0880                	add	s0,sp,80
    80002340:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	664080e7          	jalr	1636(ra) # 800019a6 <myproc>
    8000234a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000234c:	0000f517          	auipc	a0,0xf
    80002350:	95c50513          	add	a0,a0,-1700 # 80010ca8 <wait_lock>
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	87e080e7          	jalr	-1922(ra) # 80000bd2 <acquire>
    havekids = 0;
    8000235c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000235e:	4a15                	li	s4,5
        havekids = 1;
    80002360:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002362:	00015997          	auipc	s3,0x15
    80002366:	db698993          	add	s3,s3,-586 # 80017118 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000236a:	0000fc17          	auipc	s8,0xf
    8000236e:	93ec0c13          	add	s8,s8,-1730 # 80010ca8 <wait_lock>
    80002372:	a0d1                	j	80002436 <wait+0x10e>
          pid = pp->pid;
    80002374:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002378:	000b0e63          	beqz	s6,80002394 <wait+0x6c>
    8000237c:	4691                	li	a3,4
    8000237e:	02c48613          	add	a2,s1,44
    80002382:	85da                	mv	a1,s6
    80002384:	05093503          	ld	a0,80(s2)
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	2de080e7          	jalr	734(ra) # 80001666 <copyout>
    80002390:	04054163          	bltz	a0,800023d2 <wait+0xaa>
          freeproc(pp);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	7c2080e7          	jalr	1986(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	8e6080e7          	jalr	-1818(ra) # 80000c86 <release>
          release(&wait_lock);
    800023a8:	0000f517          	auipc	a0,0xf
    800023ac:	90050513          	add	a0,a0,-1792 # 80010ca8 <wait_lock>
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8d6080e7          	jalr	-1834(ra) # 80000c86 <release>
}
    800023b8:	854e                	mv	a0,s3
    800023ba:	60a6                	ld	ra,72(sp)
    800023bc:	6406                	ld	s0,64(sp)
    800023be:	74e2                	ld	s1,56(sp)
    800023c0:	7942                	ld	s2,48(sp)
    800023c2:	79a2                	ld	s3,40(sp)
    800023c4:	7a02                	ld	s4,32(sp)
    800023c6:	6ae2                	ld	s5,24(sp)
    800023c8:	6b42                	ld	s6,16(sp)
    800023ca:	6ba2                	ld	s7,8(sp)
    800023cc:	6c02                	ld	s8,0(sp)
    800023ce:	6161                	add	sp,sp,80
    800023d0:	8082                	ret
            release(&pp->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8b2080e7          	jalr	-1870(ra) # 80000c86 <release>
            release(&wait_lock);
    800023dc:	0000f517          	auipc	a0,0xf
    800023e0:	8cc50513          	add	a0,a0,-1844 # 80010ca8 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a2080e7          	jalr	-1886(ra) # 80000c86 <release>
            return -1;
    800023ec:	59fd                	li	s3,-1
    800023ee:	b7e9                	j	800023b8 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f0:	16848493          	add	s1,s1,360
    800023f4:	03348463          	beq	s1,s3,8000241c <wait+0xf4>
      if(pp->parent == p){
    800023f8:	7c9c                	ld	a5,56(s1)
    800023fa:	ff279be3          	bne	a5,s2,800023f0 <wait+0xc8>
        acquire(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d2080e7          	jalr	2002(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	f74785e3          	beq	a5,s4,80002374 <wait+0x4c>
        release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	876080e7          	jalr	-1930(ra) # 80000c86 <release>
        havekids = 1;
    80002418:	8756                	mv	a4,s5
    8000241a:	bfd9                	j	800023f0 <wait+0xc8>
    if(!havekids || killed(p)){
    8000241c:	c31d                	beqz	a4,80002442 <wait+0x11a>
    8000241e:	854a                	mv	a0,s2
    80002420:	00000097          	auipc	ra,0x0
    80002424:	ed6080e7          	jalr	-298(ra) # 800022f6 <killed>
    80002428:	ed09                	bnez	a0,80002442 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000242a:	85e2                	mv	a1,s8
    8000242c:	854a                	mv	a0,s2
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	c20080e7          	jalr	-992(ra) # 8000204e <sleep>
    havekids = 0;
    80002436:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002438:	0000f497          	auipc	s1,0xf
    8000243c:	2e048493          	add	s1,s1,736 # 80011718 <proc>
    80002440:	bf65                	j	800023f8 <wait+0xd0>
      release(&wait_lock);
    80002442:	0000f517          	auipc	a0,0xf
    80002446:	86650513          	add	a0,a0,-1946 # 80010ca8 <wait_lock>
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	83c080e7          	jalr	-1988(ra) # 80000c86 <release>
      return -1;
    80002452:	59fd                	li	s3,-1
    80002454:	b795                	j	800023b8 <wait+0x90>

0000000080002456 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002456:	7179                	add	sp,sp,-48
    80002458:	f406                	sd	ra,40(sp)
    8000245a:	f022                	sd	s0,32(sp)
    8000245c:	ec26                	sd	s1,24(sp)
    8000245e:	e84a                	sd	s2,16(sp)
    80002460:	e44e                	sd	s3,8(sp)
    80002462:	e052                	sd	s4,0(sp)
    80002464:	1800                	add	s0,sp,48
    80002466:	84aa                	mv	s1,a0
    80002468:	892e                	mv	s2,a1
    8000246a:	89b2                	mv	s3,a2
    8000246c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	538080e7          	jalr	1336(ra) # 800019a6 <myproc>
  if(user_dst){
    80002476:	c08d                	beqz	s1,80002498 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002478:	86d2                	mv	a3,s4
    8000247a:	864e                	mv	a2,s3
    8000247c:	85ca                	mv	a1,s2
    8000247e:	6928                	ld	a0,80(a0)
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	1e6080e7          	jalr	486(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002488:	70a2                	ld	ra,40(sp)
    8000248a:	7402                	ld	s0,32(sp)
    8000248c:	64e2                	ld	s1,24(sp)
    8000248e:	6942                	ld	s2,16(sp)
    80002490:	69a2                	ld	s3,8(sp)
    80002492:	6a02                	ld	s4,0(sp)
    80002494:	6145                	add	sp,sp,48
    80002496:	8082                	ret
    memmove((char *)dst, src, len);
    80002498:	000a061b          	sext.w	a2,s4
    8000249c:	85ce                	mv	a1,s3
    8000249e:	854a                	mv	a0,s2
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	88a080e7          	jalr	-1910(ra) # 80000d2a <memmove>
    return 0;
    800024a8:	8526                	mv	a0,s1
    800024aa:	bff9                	j	80002488 <either_copyout+0x32>

00000000800024ac <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ac:	7179                	add	sp,sp,-48
    800024ae:	f406                	sd	ra,40(sp)
    800024b0:	f022                	sd	s0,32(sp)
    800024b2:	ec26                	sd	s1,24(sp)
    800024b4:	e84a                	sd	s2,16(sp)
    800024b6:	e44e                	sd	s3,8(sp)
    800024b8:	e052                	sd	s4,0(sp)
    800024ba:	1800                	add	s0,sp,48
    800024bc:	892a                	mv	s2,a0
    800024be:	84ae                	mv	s1,a1
    800024c0:	89b2                	mv	s3,a2
    800024c2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	4e2080e7          	jalr	1250(ra) # 800019a6 <myproc>
  if(user_src){
    800024cc:	c08d                	beqz	s1,800024ee <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ce:	86d2                	mv	a3,s4
    800024d0:	864e                	mv	a2,s3
    800024d2:	85ca                	mv	a1,s2
    800024d4:	6928                	ld	a0,80(a0)
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	21c080e7          	jalr	540(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024de:	70a2                	ld	ra,40(sp)
    800024e0:	7402                	ld	s0,32(sp)
    800024e2:	64e2                	ld	s1,24(sp)
    800024e4:	6942                	ld	s2,16(sp)
    800024e6:	69a2                	ld	s3,8(sp)
    800024e8:	6a02                	ld	s4,0(sp)
    800024ea:	6145                	add	sp,sp,48
    800024ec:	8082                	ret
    memmove(dst, (char*)src, len);
    800024ee:	000a061b          	sext.w	a2,s4
    800024f2:	85ce                	mv	a1,s3
    800024f4:	854a                	mv	a0,s2
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	834080e7          	jalr	-1996(ra) # 80000d2a <memmove>
    return 0;
    800024fe:	8526                	mv	a0,s1
    80002500:	bff9                	j	800024de <either_copyin+0x32>

0000000080002502 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002502:	715d                	add	sp,sp,-80
    80002504:	e486                	sd	ra,72(sp)
    80002506:	e0a2                	sd	s0,64(sp)
    80002508:	fc26                	sd	s1,56(sp)
    8000250a:	f84a                	sd	s2,48(sp)
    8000250c:	f44e                	sd	s3,40(sp)
    8000250e:	f052                	sd	s4,32(sp)
    80002510:	ec56                	sd	s5,24(sp)
    80002512:	e85a                	sd	s6,16(sp)
    80002514:	e45e                	sd	s7,8(sp)
    80002516:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002518:	00006517          	auipc	a0,0x6
    8000251c:	bb050513          	add	a0,a0,-1104 # 800080c8 <digits+0x88>
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	066080e7          	jalr	102(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002528:	0000f497          	auipc	s1,0xf
    8000252c:	34848493          	add	s1,s1,840 # 80011870 <proc+0x158>
    80002530:	00015917          	auipc	s2,0x15
    80002534:	d4090913          	add	s2,s2,-704 # 80017270 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002538:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000253a:	00006997          	auipc	s3,0x6
    8000253e:	d4698993          	add	s3,s3,-698 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002542:	00006a97          	auipc	s5,0x6
    80002546:	d46a8a93          	add	s5,s5,-698 # 80008288 <digits+0x248>
    printf("\n");
    8000254a:	00006a17          	auipc	s4,0x6
    8000254e:	b7ea0a13          	add	s4,s4,-1154 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002552:	00006b97          	auipc	s7,0x6
    80002556:	eceb8b93          	add	s7,s7,-306 # 80008420 <states.0>
    8000255a:	a00d                	j	8000257c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000255c:	ed86a583          	lw	a1,-296(a3)
    80002560:	8556                	mv	a0,s5
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	024080e7          	jalr	36(ra) # 80000586 <printf>
    printf("\n");
    8000256a:	8552                	mv	a0,s4
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	01a080e7          	jalr	26(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002574:	16848493          	add	s1,s1,360
    80002578:	03248263          	beq	s1,s2,8000259c <procdump+0x9a>
    if(p->state == UNUSED)
    8000257c:	86a6                	mv	a3,s1
    8000257e:	ec04a783          	lw	a5,-320(s1)
    80002582:	dbed                	beqz	a5,80002574 <procdump+0x72>
      state = "???";
    80002584:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002586:	fcfb6be3          	bltu	s6,a5,8000255c <procdump+0x5a>
    8000258a:	02079713          	sll	a4,a5,0x20
    8000258e:	01d75793          	srl	a5,a4,0x1d
    80002592:	97de                	add	a5,a5,s7
    80002594:	6390                	ld	a2,0(a5)
    80002596:	f279                	bnez	a2,8000255c <procdump+0x5a>
      state = "???";
    80002598:	864e                	mv	a2,s3
    8000259a:	b7c9                	j	8000255c <procdump+0x5a>
  }
}
    8000259c:	60a6                	ld	ra,72(sp)
    8000259e:	6406                	ld	s0,64(sp)
    800025a0:	74e2                	ld	s1,56(sp)
    800025a2:	7942                	ld	s2,48(sp)
    800025a4:	79a2                	ld	s3,40(sp)
    800025a6:	7a02                	ld	s4,32(sp)
    800025a8:	6ae2                	ld	s5,24(sp)
    800025aa:	6b42                	ld	s6,16(sp)
    800025ac:	6ba2                	ld	s7,8(sp)
    800025ae:	6161                	add	sp,sp,80
    800025b0:	8082                	ret

00000000800025b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    800025b2:	1141                	add	sp,sp,-16
    800025b4:	e422                	sd	s0,8(sp)
    800025b6:	0800                	add	s0,sp,16
  while(*p && *p == *q)
    800025b8:	00054783          	lbu	a5,0(a0)
    800025bc:	cb91                	beqz	a5,800025d0 <strcmp+0x1e>
    800025be:	0005c703          	lbu	a4,0(a1)
    800025c2:	00f71763          	bne	a4,a5,800025d0 <strcmp+0x1e>
    p++, q++;
    800025c6:	0505                	add	a0,a0,1
    800025c8:	0585                	add	a1,a1,1
  while(*p && *p == *q)
    800025ca:	00054783          	lbu	a5,0(a0)
    800025ce:	fbe5                	bnez	a5,800025be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    800025d0:	0005c503          	lbu	a0,0(a1)
}
    800025d4:	40a7853b          	subw	a0,a5,a0
    800025d8:	6422                	ld	s0,8(sp)
    800025da:	0141                	add	sp,sp,16
    800025dc:	8082                	ret

00000000800025de <strcpy>:

char*
strcpy(char *s, const char *t)
{
    800025de:	1141                	add	sp,sp,-16
    800025e0:	e422                	sd	s0,8(sp)
    800025e2:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    800025e4:	87aa                	mv	a5,a0
    800025e6:	0585                	add	a1,a1,1
    800025e8:	0785                	add	a5,a5,1
    800025ea:	fff5c703          	lbu	a4,-1(a1)
    800025ee:	fee78fa3          	sb	a4,-1(a5)
    800025f2:	fb75                	bnez	a4,800025e6 <strcpy+0x8>
    ;
  return os;
}
    800025f4:	6422                	ld	s0,8(sp)
    800025f6:	0141                	add	sp,sp,16
    800025f8:	8082                	ret

00000000800025fa <ringbuf>:

int
ringbuf(const char *name, int open, void **addr)
{
    800025fa:	7129                	add	sp,sp,-320
    800025fc:	fe06                	sd	ra,312(sp)
    800025fe:	fa22                	sd	s0,304(sp)
    80002600:	f626                	sd	s1,296(sp)
    80002602:	f24a                	sd	s2,288(sp)
    80002604:	ee4e                	sd	s3,280(sp)
    80002606:	ea52                	sd	s4,272(sp)
    80002608:	e656                	sd	s5,264(sp)
    8000260a:	e25a                	sd	s6,256(sp)
    8000260c:	fdde                	sd	s7,248(sp)
    8000260e:	f9e2                	sd	s8,240(sp)
    80002610:	f5e6                	sd	s9,232(sp)
    80002612:	f1ea                	sd	s10,224(sp)
    80002614:	edee                	sd	s11,216(sp)
    80002616:	0280                	add	s0,sp,320
    80002618:	8aaa                	mv	s5,a0
    8000261a:	8b2e                	mv	s6,a1
    8000261c:	84b2                	mv	s1,a2
  printf("my addr (uint64 *) : %p\n", (uint64 *)addr);
    8000261e:	85b2                	mv	a1,a2
    80002620:	00006517          	auipc	a0,0x6
    80002624:	c7850513          	add	a0,a0,-904 # 80008298 <digits+0x258>
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	f5e080e7          	jalr	-162(ra) # 80000586 <printf>
  printf("my addr (uint64 **): %p\n", (uint64 **)addr);
    80002630:	85a6                	mv	a1,s1
    80002632:	00006517          	auipc	a0,0x6
    80002636:	c8650513          	add	a0,a0,-890 # 800082b8 <digits+0x278>
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	f4c080e7          	jalr	-180(ra) # 80000586 <printf>
  struct ringbuf *rb;
  int ringbuf_exists = 0, ringbuf_count = 0;

  // Step 1: Check if maximum ringbuf allocated.
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    80002642:	0000f917          	auipc	s2,0xf
    80002646:	a8290913          	add	s2,s2,-1406 # 800110c4 <ringbufs+0x4>
    8000264a:	0000f997          	auipc	s3,0xf
    8000264e:	0ba98993          	add	s3,s3,186 # 80011704 <ringbuf_lock+0x4>
  printf("my addr (uint64 **): %p\n", (uint64 **)addr);
    80002652:	84ca                	mv	s1,s2
  int ringbuf_exists = 0, ringbuf_count = 0;
    80002654:	4a01                	li	s4,0
    if(strcmp(rb->name, "")) ringbuf_count++; // Ringbuf has name then it is allocated.
    80002656:	00006b97          	auipc	s7,0x6
    8000265a:	e6ab8b93          	add	s7,s7,-406 # 800084c0 <states.0+0xa0>
    8000265e:	a029                	j	80002668 <ringbuf+0x6e>
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    80002660:	0a048493          	add	s1,s1,160
    80002664:	01348b63          	beq	s1,s3,8000267a <ringbuf+0x80>
    if(strcmp(rb->name, "")) ringbuf_count++; // Ringbuf has name then it is allocated.
    80002668:	85de                	mv	a1,s7
    8000266a:	8526                	mv	a0,s1
    8000266c:	00000097          	auipc	ra,0x0
    80002670:	f46080e7          	jalr	-186(ra) # 800025b2 <strcmp>
    80002674:	d575                	beqz	a0,80002660 <ringbuf+0x66>
    80002676:	2a05                	addw	s4,s4,1
    80002678:	b7e5                	j	80002660 <ringbuf+0x66>
  }

  if (ringbuf_count >= MAX_RINGBUFS) {
    8000267a:	47a5                	li	a5,9
    8000267c:	0747c363          	blt	a5,s4,800026e2 <ringbuf+0xe8>
    return -1;
  }

  // Step 2: Check if ringbuf already exists else create and append ringbufs.
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    if (strcmp(rb->name, name) == 0) {
    80002680:	85d6                	mv	a1,s5
    80002682:	854a                	mv	a0,s2
    80002684:	00000097          	auipc	ra,0x0
    80002688:	f2e080e7          	jalr	-210(ra) # 800025b2 <strcmp>
    8000268c:	1e050463          	beqz	a0,80002874 <ringbuf+0x27a>
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    80002690:	0a090913          	add	s2,s2,160
    80002694:	ff3916e3          	bne	s2,s3,80002680 <ringbuf+0x86>
    }
  }
  
  if (!ringbuf_exists) {
    // Does not exists create and append.
    printf("creating new ringbuf: %s\n", name);
    80002698:	85d6                	mv	a1,s5
    8000269a:	00006517          	auipc	a0,0x6
    8000269e:	d1650513          	add	a0,a0,-746 # 800083b0 <digits+0x370>
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	ee4080e7          	jalr	-284(ra) # 80000586 <printf>
    struct ringbuf new_ringbuf;
    new_ringbuf.refcount = 0;
    800026aa:	ee042823          	sw	zero,-272(s0)
    memmove( (void *) new_ringbuf.name, (const void*) name, 16); // copy name
    800026ae:	4641                	li	a2,16
    800026b0:	85d6                	mv	a1,s5
    800026b2:	ef440513          	add	a0,s0,-268
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	674080e7          	jalr	1652(ra) # 80000d2a <memmove>

    char *mem;
    int count = 0;
    uint64 a, pg, base, va0;
    uint64 ** ptr;
    struct proc *pr = myproc();
    800026be:	fffff097          	auipc	ra,0xfffff
    800026c2:	2e8080e7          	jalr	744(ra) # 800019a6 <myproc>
    800026c6:	89aa                	mv	s3,a0

    // MAX virtual address - trampoline - trapframe - gurad page.
    //base = MAXVA - PGSIZE - PGSIZE - PGSIZE;
    base = TRAPFRAME - PGSIZE;
    va0 = PGROUNDUP(base);
    800026c8:	040004b7          	lui	s1,0x4000
    800026cc:	14f5                	add	s1,s1,-3 # 3fffffd <_entry-0x7c000003>
    800026ce:	04b2                	sll	s1,s1,0xc
    800026d0:	ee943423          	sd	s1,-280(s0)
    int count = 0;
    800026d4:	4901                	li	s2,0
        if (count == 18) {
          printf("found %d pages end: %p\n", count, a);
          break;
        }
      } else {
        count = 0;
    800026d6:	4d01                	li	s10,0
        if (count == 18) {
    800026d8:	4cc9                	li	s9,18
    for (a = va0; a > KERNBASE; a -= PGSIZE) {
    800026da:	7c7d                	lui	s8,0xfffff
    800026dc:	4b85                	li	s7,1
    800026de:	0bfe                	sll	s7,s7,0x1f
    800026e0:	a099                	j	80002726 <ringbuf+0x12c>
    printf("Maximum ringbuf allocated. # ringbufs: %d",  ringbuf_lock);
    800026e2:	0000f797          	auipc	a5,0xf
    800026e6:	5ae78793          	add	a5,a5,1454 # 80011c90 <proc+0x578>
    800026ea:	a707b703          	ld	a4,-1424(a5)
    800026ee:	ece43023          	sd	a4,-320(s0)
    800026f2:	a787b703          	ld	a4,-1416(a5)
    800026f6:	ece43423          	sd	a4,-312(s0)
    800026fa:	a807b783          	ld	a5,-1408(a5)
    800026fe:	ecf43823          	sd	a5,-304(s0)
    80002702:	ec040593          	add	a1,s0,-320
    80002706:	00006517          	auipc	a0,0x6
    8000270a:	bd250513          	add	a0,a0,-1070 # 800082d8 <digits+0x298>
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	e78080e7          	jalr	-392(ra) # 80000586 <printf>
    return -1;
    80002716:	557d                	li	a0,-1
    80002718:	a259                	j	8000289e <ringbuf+0x2a4>
        va0 = a;
    8000271a:	ee943423          	sd	s1,-280(s0)
        count = 0;
    8000271e:	896a                	mv	s2,s10
    for (a = va0; a > KERNBASE; a -= PGSIZE) {
    80002720:	94e2                	add	s1,s1,s8
    80002722:	03748763          	beq	s1,s7,80002750 <ringbuf+0x156>
      pg = walkaddr(pr->pagetable, a);
    80002726:	85a6                	mv	a1,s1
    80002728:	0509b503          	ld	a0,80(s3)
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	92a080e7          	jalr	-1750(ra) # 80001056 <walkaddr>
      if (pg == 0) {
    80002734:	f17d                	bnez	a0,8000271a <ringbuf+0x120>
        count++;
    80002736:	2905                	addw	s2,s2,1
        if (count == 18) {
    80002738:	ff9914e3          	bne	s2,s9,80002720 <ringbuf+0x126>
          printf("found %d pages end: %p\n", count, a);
    8000273c:	8626                	mv	a2,s1
    8000273e:	45c9                	li	a1,18
    80002740:	00006517          	auipc	a0,0x6
    80002744:	bc850513          	add	a0,a0,-1080 # 80008308 <digits+0x2c8>
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	e3e080e7          	jalr	-450(ra) # 80000586 <printf>
      }
    }

    printf("base of %d pages: %p\n", count, base);
    80002750:	04000637          	lui	a2,0x4000
    80002754:	1675                	add	a2,a2,-3 # 3fffffd <_entry-0x7c000003>
    80002756:	0632                	sll	a2,a2,0xc
    80002758:	85ca                	mv	a1,s2
    8000275a:	00006517          	auipc	a0,0x6
    8000275e:	bc650513          	add	a0,a0,-1082 # 80008320 <digits+0x2e0>
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	e24080e7          	jalr	-476(ra) # 80000586 <printf>
    // start from 1 because allocate gurad page at top
    for (int i = 1 ; i <= 16; i++ ) {
    8000276a:	f0840b93          	add	s7,s0,-248
    printf("base of %d pages: %p\n", count, base);
    8000276e:	4905                	li	s2,1
        uvmdealloc(pr->pagetable, a, PGSIZE);
        return -1;
      }

      memset(mem, 0, PGSIZE);
      printf("allocated page i: %d, va: %p\n", i, a);
    80002770:	00006c97          	auipc	s9,0x6
    80002774:	bc8c8c93          	add	s9,s9,-1080 # 80008338 <digits+0x2f8>

      }
      
      // I do not have to touch the buffer.
      // I think i need because we need it to reallocate same pages for new process.
      new_ringbuf.buf[i-1] = &mem; 
    80002778:	ee040d93          	add	s11,s0,-288
    for (int i = 1 ; i <= 16; i++ ) {
    8000277c:	4d45                	li	s10,17
    8000277e:	00090c1b          	sext.w	s8,s2
      a = va0 - (i * PGSIZE);
    80002782:	00c91793          	sll	a5,s2,0xc
    80002786:	ee843483          	ld	s1,-280(s0)
    8000278a:	8c9d                	sub	s1,s1,a5
      mem = kalloc(); // Physcall address
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	356080e7          	jalr	854(ra) # 80000ae2 <kalloc>
    80002794:	eea43023          	sd	a0,-288(s0)
      if(mem == 0){
    80002798:	c54d                	beqz	a0,80002842 <ringbuf+0x248>
      memset(mem, 0, PGSIZE);
    8000279a:	6605                	lui	a2,0x1
    8000279c:	4581                	li	a1,0
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	530080e7          	jalr	1328(ra) # 80000cce <memset>
      printf("allocated page i: %d, va: %p\n", i, a);
    800027a6:	8626                	mv	a2,s1
    800027a8:	85e2                	mv	a1,s8
    800027aa:	8566                	mv	a0,s9
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	dda080e7          	jalr	-550(ra) # 80000586 <printf>
      if(mappages(pr->pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_W) != 0){
    800027b4:	4719                	li	a4,6
    800027b6:	ee043683          	ld	a3,-288(s0)
    800027ba:	6605                	lui	a2,0x1
    800027bc:	85a6                	mv	a1,s1
    800027be:	0509b503          	ld	a0,80(s3)
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	8d6080e7          	jalr	-1834(ra) # 80001098 <mappages>
    800027ca:	e551                	bnez	a0,80002856 <ringbuf+0x25c>
      new_ringbuf.buf[i-1] = &mem; 
    800027cc:	01bbb023          	sd	s11,0(s7)
    for (int i = 1 ; i <= 16; i++ ) {
    800027d0:	0905                	add	s2,s2,1
    800027d2:	0ba1                	add	s7,s7,8
    800027d4:	fba915e3          	bne	s2,s10,8000277e <ringbuf+0x184>
    }

    new_ringbuf.book = &va0 - (17 * PGSIZE);
    800027d8:	fff787b7          	lui	a5,0xfff78
    800027dc:	ee840713          	add	a4,s0,-280
    800027e0:	00f705b3          	add	a1,a4,a5
    800027e4:	f8b43423          	sd	a1,-120(s0)
    // Question:  we need to send physical address to userspace?
    // Question:  in buf of ringbuf struct we need to store physical addr of pages? If so for transimitting data we need to use PA right?
    // Question:  how to map twice? Is it two 32 byte chunks or 64 chunks?
    // Question:  user process panics at the return.

    printf("book: %p, base: %p, addr: %p\n", new_ringbuf.book, base, ptr);
    800027e8:	76fd                	lui	a3,0xfffff
    800027ea:	ee843783          	ld	a5,-280(s0)
    800027ee:	96be                	add	a3,a3,a5
    800027f0:	04000637          	lui	a2,0x4000
    800027f4:	1675                	add	a2,a2,-3 # 3fffffd <_entry-0x7c000003>
    800027f6:	0632                	sll	a2,a2,0xc
    800027f8:	00006517          	auipc	a0,0x6
    800027fc:	b6050513          	add	a0,a0,-1184 # 80008358 <digits+0x318>
    80002800:	ffffe097          	auipc	ra,0xffffe
    80002804:	d86080e7          	jalr	-634(ra) # 80000586 <printf>
    ringbufs[++ringbuf_count] = new_ringbuf;
    80002808:	2a05                	addw	s4,s4,1
    8000280a:	002a1793          	sll	a5,s4,0x2
    8000280e:	97d2                	add	a5,a5,s4
    80002810:	0796                	sll	a5,a5,0x5
    80002812:	ef040713          	add	a4,s0,-272
    80002816:	0000f697          	auipc	a3,0xf
    8000281a:	8aa68693          	add	a3,a3,-1878 # 800110c0 <ringbufs>
    8000281e:	97b6                	add	a5,a5,a3
    80002820:	f9040813          	add	a6,s0,-112
    80002824:	6308                	ld	a0,0(a4)
    80002826:	670c                	ld	a1,8(a4)
    80002828:	6b10                	ld	a2,16(a4)
    8000282a:	6f14                	ld	a3,24(a4)
    8000282c:	e388                	sd	a0,0(a5)
    8000282e:	e78c                	sd	a1,8(a5)
    80002830:	eb90                	sd	a2,16(a5)
    80002832:	ef94                	sd	a3,24(a5)
    80002834:	02070713          	add	a4,a4,32
    80002838:	02078793          	add	a5,a5,32 # fffffffffff78020 <end+0xffffffff7ff55b28>
    8000283c:	ff0714e3          	bne	a4,a6,80002824 <ringbuf+0x22a>
    80002840:	a099                	j	80002886 <ringbuf+0x28c>
        uvmdealloc(pr->pagetable, a, PGSIZE);
    80002842:	6605                	lui	a2,0x1
    80002844:	85a6                	mv	a1,s1
    80002846:	0509b503          	ld	a0,80(s3)
    8000284a:	fffff097          	auipc	ra,0xfffff
    8000284e:	b78080e7          	jalr	-1160(ra) # 800013c2 <uvmdealloc>
        return -1;
    80002852:	557d                	li	a0,-1
    80002854:	a0a9                	j	8000289e <ringbuf+0x2a4>
        kfree(mem);
    80002856:	ee043503          	ld	a0,-288(s0)
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	18a080e7          	jalr	394(ra) # 800009e4 <kfree>
        uvmdealloc(pr->pagetable, a, PGSIZE);
    80002862:	6605                	lui	a2,0x1
    80002864:	85a6                	mv	a1,s1
    80002866:	0509b503          	ld	a0,80(s3)
    8000286a:	fffff097          	auipc	ra,0xfffff
    8000286e:	b58080e7          	jalr	-1192(ra) # 800013c2 <uvmdealloc>
        return -1;
    80002872:	b7c5                	j	80002852 <ringbuf+0x258>
  } else {
    // Already exists return the already mapped address space.
    printf("already exists ringbuf: %s\n", name);
    80002874:	85d6                	mv	a1,s5
    80002876:	00006517          	auipc	a0,0x6
    8000287a:	b5a50513          	add	a0,a0,-1190 # 800083d0 <digits+0x390>
    8000287e:	ffffe097          	auipc	ra,0xffffe
    80002882:	d08080e7          	jalr	-760(ra) # 80000586 <printf>
  }

  printf("recieved name: %s, open: %d, current ringbuf_count: %d\n", name, open, ringbuf_count);
    80002886:	86d2                	mv	a3,s4
    80002888:	865a                	mv	a2,s6
    8000288a:	85d6                	mv	a1,s5
    8000288c:	00006517          	auipc	a0,0x6
    80002890:	aec50513          	add	a0,a0,-1300 # 80008378 <digits+0x338>
    80002894:	ffffe097          	auipc	ra,0xffffe
    80002898:	cf2080e7          	jalr	-782(ra) # 80000586 <printf>
  return 0;
    8000289c:	4501                	li	a0,0
    8000289e:	70f2                	ld	ra,312(sp)
    800028a0:	7452                	ld	s0,304(sp)
    800028a2:	74b2                	ld	s1,296(sp)
    800028a4:	7912                	ld	s2,288(sp)
    800028a6:	69f2                	ld	s3,280(sp)
    800028a8:	6a52                	ld	s4,272(sp)
    800028aa:	6ab2                	ld	s5,264(sp)
    800028ac:	6b12                	ld	s6,256(sp)
    800028ae:	7bee                	ld	s7,248(sp)
    800028b0:	7c4e                	ld	s8,240(sp)
    800028b2:	7cae                	ld	s9,232(sp)
    800028b4:	7d0e                	ld	s10,224(sp)
    800028b6:	6dee                	ld	s11,216(sp)
    800028b8:	6131                	add	sp,sp,320
    800028ba:	8082                	ret

00000000800028bc <swtch>:
    800028bc:	00153023          	sd	ra,0(a0)
    800028c0:	00253423          	sd	sp,8(a0)
    800028c4:	e900                	sd	s0,16(a0)
    800028c6:	ed04                	sd	s1,24(a0)
    800028c8:	03253023          	sd	s2,32(a0)
    800028cc:	03353423          	sd	s3,40(a0)
    800028d0:	03453823          	sd	s4,48(a0)
    800028d4:	03553c23          	sd	s5,56(a0)
    800028d8:	05653023          	sd	s6,64(a0)
    800028dc:	05753423          	sd	s7,72(a0)
    800028e0:	05853823          	sd	s8,80(a0)
    800028e4:	05953c23          	sd	s9,88(a0)
    800028e8:	07a53023          	sd	s10,96(a0)
    800028ec:	07b53423          	sd	s11,104(a0)
    800028f0:	0005b083          	ld	ra,0(a1)
    800028f4:	0085b103          	ld	sp,8(a1)
    800028f8:	6980                	ld	s0,16(a1)
    800028fa:	6d84                	ld	s1,24(a1)
    800028fc:	0205b903          	ld	s2,32(a1)
    80002900:	0285b983          	ld	s3,40(a1)
    80002904:	0305ba03          	ld	s4,48(a1)
    80002908:	0385ba83          	ld	s5,56(a1)
    8000290c:	0405bb03          	ld	s6,64(a1)
    80002910:	0485bb83          	ld	s7,72(a1)
    80002914:	0505bc03          	ld	s8,80(a1)
    80002918:	0585bc83          	ld	s9,88(a1)
    8000291c:	0605bd03          	ld	s10,96(a1)
    80002920:	0685bd83          	ld	s11,104(a1)
    80002924:	8082                	ret

0000000080002926 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002926:	1141                	add	sp,sp,-16
    80002928:	e406                	sd	ra,8(sp)
    8000292a:	e022                	sd	s0,0(sp)
    8000292c:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000292e:	00006597          	auipc	a1,0x6
    80002932:	b2258593          	add	a1,a1,-1246 # 80008450 <states.0+0x30>
    80002936:	00014517          	auipc	a0,0x14
    8000293a:	7e250513          	add	a0,a0,2018 # 80017118 <tickslock>
    8000293e:	ffffe097          	auipc	ra,0xffffe
    80002942:	204080e7          	jalr	516(ra) # 80000b42 <initlock>
}
    80002946:	60a2                	ld	ra,8(sp)
    80002948:	6402                	ld	s0,0(sp)
    8000294a:	0141                	add	sp,sp,16
    8000294c:	8082                	ret

000000008000294e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000294e:	1141                	add	sp,sp,-16
    80002950:	e422                	sd	s0,8(sp)
    80002952:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002954:	00003797          	auipc	a5,0x3
    80002958:	4bc78793          	add	a5,a5,1212 # 80005e10 <kernelvec>
    8000295c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002960:	6422                	ld	s0,8(sp)
    80002962:	0141                	add	sp,sp,16
    80002964:	8082                	ret

0000000080002966 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002966:	1141                	add	sp,sp,-16
    80002968:	e406                	sd	ra,8(sp)
    8000296a:	e022                	sd	s0,0(sp)
    8000296c:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    8000296e:	fffff097          	auipc	ra,0xfffff
    80002972:	038080e7          	jalr	56(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002976:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000297a:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002980:	00004697          	auipc	a3,0x4
    80002984:	68068693          	add	a3,a3,1664 # 80007000 <_trampoline>
    80002988:	00004717          	auipc	a4,0x4
    8000298c:	67870713          	add	a4,a4,1656 # 80007000 <_trampoline>
    80002990:	8f15                	sub	a4,a4,a3
    80002992:	040007b7          	lui	a5,0x4000
    80002996:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002998:	07b2                	sll	a5,a5,0xc
    8000299a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000299c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029a0:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029a2:	18002673          	csrr	a2,satp
    800029a6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029a8:	6d30                	ld	a2,88(a0)
    800029aa:	6138                	ld	a4,64(a0)
    800029ac:	6585                	lui	a1,0x1
    800029ae:	972e                	add	a4,a4,a1
    800029b0:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029b2:	6d38                	ld	a4,88(a0)
    800029b4:	00000617          	auipc	a2,0x0
    800029b8:	13460613          	add	a2,a2,308 # 80002ae8 <usertrap>
    800029bc:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029be:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029c0:	8612                	mv	a2,tp
    800029c2:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029c8:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029cc:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029d4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029d6:	6f18                	ld	a4,24(a4)
    800029d8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029dc:	6928                	ld	a0,80(a0)
    800029de:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029e0:	00004717          	auipc	a4,0x4
    800029e4:	6bc70713          	add	a4,a4,1724 # 8000709c <userret>
    800029e8:	8f15                	sub	a4,a4,a3
    800029ea:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800029ec:	577d                	li	a4,-1
    800029ee:	177e                	sll	a4,a4,0x3f
    800029f0:	8d59                	or	a0,a0,a4
    800029f2:	9782                	jalr	a5
}
    800029f4:	60a2                	ld	ra,8(sp)
    800029f6:	6402                	ld	s0,0(sp)
    800029f8:	0141                	add	sp,sp,16
    800029fa:	8082                	ret

00000000800029fc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029fc:	1101                	add	sp,sp,-32
    800029fe:	ec06                	sd	ra,24(sp)
    80002a00:	e822                	sd	s0,16(sp)
    80002a02:	e426                	sd	s1,8(sp)
    80002a04:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002a06:	00014497          	auipc	s1,0x14
    80002a0a:	71248493          	add	s1,s1,1810 # 80017118 <tickslock>
    80002a0e:	8526                	mv	a0,s1
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	1c2080e7          	jalr	450(ra) # 80000bd2 <acquire>
  ticks++;
    80002a18:	00006517          	auipc	a0,0x6
    80002a1c:	00850513          	add	a0,a0,8 # 80008a20 <ticks>
    80002a20:	411c                	lw	a5,0(a0)
    80002a22:	2785                	addw	a5,a5,1
    80002a24:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	68c080e7          	jalr	1676(ra) # 800020b2 <wakeup>
  release(&tickslock);
    80002a2e:	8526                	mv	a0,s1
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	256080e7          	jalr	598(ra) # 80000c86 <release>
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6105                	add	sp,sp,32
    80002a40:	8082                	ret

0000000080002a42 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a42:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a46:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002a48:	0807df63          	bgez	a5,80002ae6 <devintr+0xa4>
{
    80002a4c:	1101                	add	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	e426                	sd	s1,8(sp)
    80002a54:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002a56:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002a5a:	46a5                	li	a3,9
    80002a5c:	00d70d63          	beq	a4,a3,80002a76 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002a60:	577d                	li	a4,-1
    80002a62:	177e                	sll	a4,a4,0x3f
    80002a64:	0705                	add	a4,a4,1
    return 0;
    80002a66:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a68:	04e78e63          	beq	a5,a4,80002ac4 <devintr+0x82>
  }
}
    80002a6c:	60e2                	ld	ra,24(sp)
    80002a6e:	6442                	ld	s0,16(sp)
    80002a70:	64a2                	ld	s1,8(sp)
    80002a72:	6105                	add	sp,sp,32
    80002a74:	8082                	ret
    int irq = plic_claim();
    80002a76:	00003097          	auipc	ra,0x3
    80002a7a:	4a2080e7          	jalr	1186(ra) # 80005f18 <plic_claim>
    80002a7e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a80:	47a9                	li	a5,10
    80002a82:	02f50763          	beq	a0,a5,80002ab0 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002a86:	4785                	li	a5,1
    80002a88:	02f50963          	beq	a0,a5,80002aba <devintr+0x78>
    return 1;
    80002a8c:	4505                	li	a0,1
    } else if(irq){
    80002a8e:	dcf9                	beqz	s1,80002a6c <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a90:	85a6                	mv	a1,s1
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	9c650513          	add	a0,a0,-1594 # 80008458 <states.0+0x38>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	aec080e7          	jalr	-1300(ra) # 80000586 <printf>
      plic_complete(irq);
    80002aa2:	8526                	mv	a0,s1
    80002aa4:	00003097          	auipc	ra,0x3
    80002aa8:	498080e7          	jalr	1176(ra) # 80005f3c <plic_complete>
    return 1;
    80002aac:	4505                	li	a0,1
    80002aae:	bf7d                	j	80002a6c <devintr+0x2a>
      uartintr();
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	ee4080e7          	jalr	-284(ra) # 80000994 <uartintr>
    if(irq)
    80002ab8:	b7ed                	j	80002aa2 <devintr+0x60>
      virtio_disk_intr();
    80002aba:	00004097          	auipc	ra,0x4
    80002abe:	948080e7          	jalr	-1720(ra) # 80006402 <virtio_disk_intr>
    if(irq)
    80002ac2:	b7c5                	j	80002aa2 <devintr+0x60>
    if(cpuid() == 0){
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	eb6080e7          	jalr	-330(ra) # 8000197a <cpuid>
    80002acc:	c901                	beqz	a0,80002adc <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ace:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ad2:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ad4:	14479073          	csrw	sip,a5
    return 2;
    80002ad8:	4509                	li	a0,2
    80002ada:	bf49                	j	80002a6c <devintr+0x2a>
      clockintr();
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	f20080e7          	jalr	-224(ra) # 800029fc <clockintr>
    80002ae4:	b7ed                	j	80002ace <devintr+0x8c>
}
    80002ae6:	8082                	ret

0000000080002ae8 <usertrap>:
{
    80002ae8:	1101                	add	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	e04a                	sd	s2,0(sp)
    80002af2:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002af8:	1007f793          	and	a5,a5,256
    80002afc:	e3b1                	bnez	a5,80002b40 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002afe:	00003797          	auipc	a5,0x3
    80002b02:	31278793          	add	a5,a5,786 # 80005e10 <kernelvec>
    80002b06:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	e9c080e7          	jalr	-356(ra) # 800019a6 <myproc>
    80002b12:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b14:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b16:	14102773          	csrr	a4,sepc
    80002b1a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b20:	47a1                	li	a5,8
    80002b22:	02f70763          	beq	a4,a5,80002b50 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002b26:	00000097          	auipc	ra,0x0
    80002b2a:	f1c080e7          	jalr	-228(ra) # 80002a42 <devintr>
    80002b2e:	892a                	mv	s2,a0
    80002b30:	c151                	beqz	a0,80002bb4 <usertrap+0xcc>
  if(killed(p))
    80002b32:	8526                	mv	a0,s1
    80002b34:	fffff097          	auipc	ra,0xfffff
    80002b38:	7c2080e7          	jalr	1986(ra) # 800022f6 <killed>
    80002b3c:	c929                	beqz	a0,80002b8e <usertrap+0xa6>
    80002b3e:	a099                	j	80002b84 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002b40:	00006517          	auipc	a0,0x6
    80002b44:	93850513          	add	a0,a0,-1736 # 80008478 <states.0+0x58>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	9f4080e7          	jalr	-1548(ra) # 8000053c <panic>
    if(killed(p))
    80002b50:	fffff097          	auipc	ra,0xfffff
    80002b54:	7a6080e7          	jalr	1958(ra) # 800022f6 <killed>
    80002b58:	e921                	bnez	a0,80002ba8 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002b5a:	6cb8                	ld	a4,88(s1)
    80002b5c:	6f1c                	ld	a5,24(a4)
    80002b5e:	0791                	add	a5,a5,4
    80002b60:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b66:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b6a:	10079073          	csrw	sstatus,a5
    syscall();
    80002b6e:	00000097          	auipc	ra,0x0
    80002b72:	2d4080e7          	jalr	724(ra) # 80002e42 <syscall>
  if(killed(p))
    80002b76:	8526                	mv	a0,s1
    80002b78:	fffff097          	auipc	ra,0xfffff
    80002b7c:	77e080e7          	jalr	1918(ra) # 800022f6 <killed>
    80002b80:	c911                	beqz	a0,80002b94 <usertrap+0xac>
    80002b82:	4901                	li	s2,0
    exit(-1);
    80002b84:	557d                	li	a0,-1
    80002b86:	fffff097          	auipc	ra,0xfffff
    80002b8a:	5fc080e7          	jalr	1532(ra) # 80002182 <exit>
  if(which_dev == 2)
    80002b8e:	4789                	li	a5,2
    80002b90:	04f90f63          	beq	s2,a5,80002bee <usertrap+0x106>
  usertrapret();
    80002b94:	00000097          	auipc	ra,0x0
    80002b98:	dd2080e7          	jalr	-558(ra) # 80002966 <usertrapret>
}
    80002b9c:	60e2                	ld	ra,24(sp)
    80002b9e:	6442                	ld	s0,16(sp)
    80002ba0:	64a2                	ld	s1,8(sp)
    80002ba2:	6902                	ld	s2,0(sp)
    80002ba4:	6105                	add	sp,sp,32
    80002ba6:	8082                	ret
      exit(-1);
    80002ba8:	557d                	li	a0,-1
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	5d8080e7          	jalr	1496(ra) # 80002182 <exit>
    80002bb2:	b765                	j	80002b5a <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bb8:	5890                	lw	a2,48(s1)
    80002bba:	00006517          	auipc	a0,0x6
    80002bbe:	8de50513          	add	a0,a0,-1826 # 80008498 <states.0+0x78>
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	9c4080e7          	jalr	-1596(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bce:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bd2:	00006517          	auipc	a0,0x6
    80002bd6:	8f650513          	add	a0,a0,-1802 # 800084c8 <states.0+0xa8>
    80002bda:	ffffe097          	auipc	ra,0xffffe
    80002bde:	9ac080e7          	jalr	-1620(ra) # 80000586 <printf>
    setkilled(p);
    80002be2:	8526                	mv	a0,s1
    80002be4:	fffff097          	auipc	ra,0xfffff
    80002be8:	6e6080e7          	jalr	1766(ra) # 800022ca <setkilled>
    80002bec:	b769                	j	80002b76 <usertrap+0x8e>
    yield();
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	424080e7          	jalr	1060(ra) # 80002012 <yield>
    80002bf6:	bf79                	j	80002b94 <usertrap+0xac>

0000000080002bf8 <kerneltrap>:
{
    80002bf8:	7179                	add	sp,sp,-48
    80002bfa:	f406                	sd	ra,40(sp)
    80002bfc:	f022                	sd	s0,32(sp)
    80002bfe:	ec26                	sd	s1,24(sp)
    80002c00:	e84a                	sd	s2,16(sp)
    80002c02:	e44e                	sd	s3,8(sp)
    80002c04:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c06:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c0a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c12:	1004f793          	and	a5,s1,256
    80002c16:	cb85                	beqz	a5,80002c46 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c18:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c1c:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002c1e:	ef85                	bnez	a5,80002c56 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	e22080e7          	jalr	-478(ra) # 80002a42 <devintr>
    80002c28:	cd1d                	beqz	a0,80002c66 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c2a:	4789                	li	a5,2
    80002c2c:	06f50a63          	beq	a0,a5,80002ca0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c30:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c34:	10049073          	csrw	sstatus,s1
}
    80002c38:	70a2                	ld	ra,40(sp)
    80002c3a:	7402                	ld	s0,32(sp)
    80002c3c:	64e2                	ld	s1,24(sp)
    80002c3e:	6942                	ld	s2,16(sp)
    80002c40:	69a2                	ld	s3,8(sp)
    80002c42:	6145                	add	sp,sp,48
    80002c44:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c46:	00006517          	auipc	a0,0x6
    80002c4a:	8a250513          	add	a0,a0,-1886 # 800084e8 <states.0+0xc8>
    80002c4e:	ffffe097          	auipc	ra,0xffffe
    80002c52:	8ee080e7          	jalr	-1810(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002c56:	00006517          	auipc	a0,0x6
    80002c5a:	8ba50513          	add	a0,a0,-1862 # 80008510 <states.0+0xf0>
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	8de080e7          	jalr	-1826(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002c66:	85ce                	mv	a1,s3
    80002c68:	00006517          	auipc	a0,0x6
    80002c6c:	8c850513          	add	a0,a0,-1848 # 80008530 <states.0+0x110>
    80002c70:	ffffe097          	auipc	ra,0xffffe
    80002c74:	916080e7          	jalr	-1770(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c78:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c7c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c80:	00006517          	auipc	a0,0x6
    80002c84:	8c050513          	add	a0,a0,-1856 # 80008540 <states.0+0x120>
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	8fe080e7          	jalr	-1794(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002c90:	00006517          	auipc	a0,0x6
    80002c94:	8c850513          	add	a0,a0,-1848 # 80008558 <states.0+0x138>
    80002c98:	ffffe097          	auipc	ra,0xffffe
    80002c9c:	8a4080e7          	jalr	-1884(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ca0:	fffff097          	auipc	ra,0xfffff
    80002ca4:	d06080e7          	jalr	-762(ra) # 800019a6 <myproc>
    80002ca8:	d541                	beqz	a0,80002c30 <kerneltrap+0x38>
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	cfc080e7          	jalr	-772(ra) # 800019a6 <myproc>
    80002cb2:	4d18                	lw	a4,24(a0)
    80002cb4:	4791                	li	a5,4
    80002cb6:	f6f71de3          	bne	a4,a5,80002c30 <kerneltrap+0x38>
    yield();
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	358080e7          	jalr	856(ra) # 80002012 <yield>
    80002cc2:	b7bd                	j	80002c30 <kerneltrap+0x38>

0000000080002cc4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cc4:	1101                	add	sp,sp,-32
    80002cc6:	ec06                	sd	ra,24(sp)
    80002cc8:	e822                	sd	s0,16(sp)
    80002cca:	e426                	sd	s1,8(sp)
    80002ccc:	1000                	add	s0,sp,32
    80002cce:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	cd6080e7          	jalr	-810(ra) # 800019a6 <myproc>
  switch (n) {
    80002cd8:	4795                	li	a5,5
    80002cda:	0497e163          	bltu	a5,s1,80002d1c <argraw+0x58>
    80002cde:	048a                	sll	s1,s1,0x2
    80002ce0:	00006717          	auipc	a4,0x6
    80002ce4:	8b070713          	add	a4,a4,-1872 # 80008590 <states.0+0x170>
    80002ce8:	94ba                	add	s1,s1,a4
    80002cea:	409c                	lw	a5,0(s1)
    80002cec:	97ba                	add	a5,a5,a4
    80002cee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cf0:	6d3c                	ld	a5,88(a0)
    80002cf2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cf4:	60e2                	ld	ra,24(sp)
    80002cf6:	6442                	ld	s0,16(sp)
    80002cf8:	64a2                	ld	s1,8(sp)
    80002cfa:	6105                	add	sp,sp,32
    80002cfc:	8082                	ret
    return p->trapframe->a1;
    80002cfe:	6d3c                	ld	a5,88(a0)
    80002d00:	7fa8                	ld	a0,120(a5)
    80002d02:	bfcd                	j	80002cf4 <argraw+0x30>
    return p->trapframe->a2;
    80002d04:	6d3c                	ld	a5,88(a0)
    80002d06:	63c8                	ld	a0,128(a5)
    80002d08:	b7f5                	j	80002cf4 <argraw+0x30>
    return p->trapframe->a3;
    80002d0a:	6d3c                	ld	a5,88(a0)
    80002d0c:	67c8                	ld	a0,136(a5)
    80002d0e:	b7dd                	j	80002cf4 <argraw+0x30>
    return p->trapframe->a4;
    80002d10:	6d3c                	ld	a5,88(a0)
    80002d12:	6bc8                	ld	a0,144(a5)
    80002d14:	b7c5                	j	80002cf4 <argraw+0x30>
    return p->trapframe->a5;
    80002d16:	6d3c                	ld	a5,88(a0)
    80002d18:	6fc8                	ld	a0,152(a5)
    80002d1a:	bfe9                	j	80002cf4 <argraw+0x30>
  panic("argraw");
    80002d1c:	00006517          	auipc	a0,0x6
    80002d20:	84c50513          	add	a0,a0,-1972 # 80008568 <states.0+0x148>
    80002d24:	ffffe097          	auipc	ra,0xffffe
    80002d28:	818080e7          	jalr	-2024(ra) # 8000053c <panic>

0000000080002d2c <fetchaddr>:
{
    80002d2c:	1101                	add	sp,sp,-32
    80002d2e:	ec06                	sd	ra,24(sp)
    80002d30:	e822                	sd	s0,16(sp)
    80002d32:	e426                	sd	s1,8(sp)
    80002d34:	e04a                	sd	s2,0(sp)
    80002d36:	1000                	add	s0,sp,32
    80002d38:	84aa                	mv	s1,a0
    80002d3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	c6a080e7          	jalr	-918(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d44:	653c                	ld	a5,72(a0)
    80002d46:	02f4f863          	bgeu	s1,a5,80002d76 <fetchaddr+0x4a>
    80002d4a:	00848713          	add	a4,s1,8
    80002d4e:	02e7e663          	bltu	a5,a4,80002d7a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d52:	46a1                	li	a3,8
    80002d54:	8626                	mv	a2,s1
    80002d56:	85ca                	mv	a1,s2
    80002d58:	6928                	ld	a0,80(a0)
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	998080e7          	jalr	-1640(ra) # 800016f2 <copyin>
    80002d62:	00a03533          	snez	a0,a0
    80002d66:	40a00533          	neg	a0,a0
}
    80002d6a:	60e2                	ld	ra,24(sp)
    80002d6c:	6442                	ld	s0,16(sp)
    80002d6e:	64a2                	ld	s1,8(sp)
    80002d70:	6902                	ld	s2,0(sp)
    80002d72:	6105                	add	sp,sp,32
    80002d74:	8082                	ret
    return -1;
    80002d76:	557d                	li	a0,-1
    80002d78:	bfcd                	j	80002d6a <fetchaddr+0x3e>
    80002d7a:	557d                	li	a0,-1
    80002d7c:	b7fd                	j	80002d6a <fetchaddr+0x3e>

0000000080002d7e <fetchstr>:
{
    80002d7e:	7179                	add	sp,sp,-48
    80002d80:	f406                	sd	ra,40(sp)
    80002d82:	f022                	sd	s0,32(sp)
    80002d84:	ec26                	sd	s1,24(sp)
    80002d86:	e84a                	sd	s2,16(sp)
    80002d88:	e44e                	sd	s3,8(sp)
    80002d8a:	1800                	add	s0,sp,48
    80002d8c:	892a                	mv	s2,a0
    80002d8e:	84ae                	mv	s1,a1
    80002d90:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	c14080e7          	jalr	-1004(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d9a:	86ce                	mv	a3,s3
    80002d9c:	864a                	mv	a2,s2
    80002d9e:	85a6                	mv	a1,s1
    80002da0:	6928                	ld	a0,80(a0)
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	9de080e7          	jalr	-1570(ra) # 80001780 <copyinstr>
    80002daa:	00054e63          	bltz	a0,80002dc6 <fetchstr+0x48>
  return strlen(buf);
    80002dae:	8526                	mv	a0,s1
    80002db0:	ffffe097          	auipc	ra,0xffffe
    80002db4:	098080e7          	jalr	152(ra) # 80000e48 <strlen>
}
    80002db8:	70a2                	ld	ra,40(sp)
    80002dba:	7402                	ld	s0,32(sp)
    80002dbc:	64e2                	ld	s1,24(sp)
    80002dbe:	6942                	ld	s2,16(sp)
    80002dc0:	69a2                	ld	s3,8(sp)
    80002dc2:	6145                	add	sp,sp,48
    80002dc4:	8082                	ret
    return -1;
    80002dc6:	557d                	li	a0,-1
    80002dc8:	bfc5                	j	80002db8 <fetchstr+0x3a>

0000000080002dca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dca:	1101                	add	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	1000                	add	s0,sp,32
    80002dd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	eee080e7          	jalr	-274(ra) # 80002cc4 <argraw>
    80002dde:	c088                	sw	a0,0(s1)
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	64a2                	ld	s1,8(sp)
    80002de6:	6105                	add	sp,sp,32
    80002de8:	8082                	ret

0000000080002dea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002dea:	1101                	add	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	1000                	add	s0,sp,32
    80002df4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df6:	00000097          	auipc	ra,0x0
    80002dfa:	ece080e7          	jalr	-306(ra) # 80002cc4 <argraw>
    80002dfe:	e088                	sd	a0,0(s1)
}
    80002e00:	60e2                	ld	ra,24(sp)
    80002e02:	6442                	ld	s0,16(sp)
    80002e04:	64a2                	ld	s1,8(sp)
    80002e06:	6105                	add	sp,sp,32
    80002e08:	8082                	ret

0000000080002e0a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e0a:	7179                	add	sp,sp,-48
    80002e0c:	f406                	sd	ra,40(sp)
    80002e0e:	f022                	sd	s0,32(sp)
    80002e10:	ec26                	sd	s1,24(sp)
    80002e12:	e84a                	sd	s2,16(sp)
    80002e14:	1800                	add	s0,sp,48
    80002e16:	84ae                	mv	s1,a1
    80002e18:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e1a:	fd840593          	add	a1,s0,-40
    80002e1e:	00000097          	auipc	ra,0x0
    80002e22:	fcc080e7          	jalr	-52(ra) # 80002dea <argaddr>
  return fetchstr(addr, buf, max);
    80002e26:	864a                	mv	a2,s2
    80002e28:	85a6                	mv	a1,s1
    80002e2a:	fd843503          	ld	a0,-40(s0)
    80002e2e:	00000097          	auipc	ra,0x0
    80002e32:	f50080e7          	jalr	-176(ra) # 80002d7e <fetchstr>
}
    80002e36:	70a2                	ld	ra,40(sp)
    80002e38:	7402                	ld	s0,32(sp)
    80002e3a:	64e2                	ld	s1,24(sp)
    80002e3c:	6942                	ld	s2,16(sp)
    80002e3e:	6145                	add	sp,sp,48
    80002e40:	8082                	ret

0000000080002e42 <syscall>:
[SYS_ringbuf]  sys_ringbuf,
};

void
syscall(void)
{
    80002e42:	1101                	add	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	e426                	sd	s1,8(sp)
    80002e4a:	e04a                	sd	s2,0(sp)
    80002e4c:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	b58080e7          	jalr	-1192(ra) # 800019a6 <myproc>
    80002e56:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e58:	05853903          	ld	s2,88(a0)
    80002e5c:	0a893783          	ld	a5,168(s2)
    80002e60:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e64:	37fd                	addw	a5,a5,-1
    80002e66:	4755                	li	a4,21
    80002e68:	00f76f63          	bltu	a4,a5,80002e86 <syscall+0x44>
    80002e6c:	00369713          	sll	a4,a3,0x3
    80002e70:	00005797          	auipc	a5,0x5
    80002e74:	73878793          	add	a5,a5,1848 # 800085a8 <syscalls>
    80002e78:	97ba                	add	a5,a5,a4
    80002e7a:	639c                	ld	a5,0(a5)
    80002e7c:	c789                	beqz	a5,80002e86 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e7e:	9782                	jalr	a5
    80002e80:	06a93823          	sd	a0,112(s2)
    80002e84:	a839                	j	80002ea2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e86:	15848613          	add	a2,s1,344
    80002e8a:	588c                	lw	a1,48(s1)
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	6e450513          	add	a0,a0,1764 # 80008570 <states.0+0x150>
    80002e94:	ffffd097          	auipc	ra,0xffffd
    80002e98:	6f2080e7          	jalr	1778(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e9c:	6cbc                	ld	a5,88(s1)
    80002e9e:	577d                	li	a4,-1
    80002ea0:	fbb8                	sd	a4,112(a5)
  }
}
    80002ea2:	60e2                	ld	ra,24(sp)
    80002ea4:	6442                	ld	s0,16(sp)
    80002ea6:	64a2                	ld	s1,8(sp)
    80002ea8:	6902                	ld	s2,0(sp)
    80002eaa:	6105                	add	sp,sp,32
    80002eac:	8082                	ret

0000000080002eae <sys_ringbuf>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_ringbuf(void)
{
    80002eae:	7179                	add	sp,sp,-48
    80002eb0:	f406                	sd	ra,40(sp)
    80002eb2:	f022                	sd	s0,32(sp)
    80002eb4:	1800                	add	s0,sp,48
  int open;
  char name[16];
  uint64 addr;
  // uint64 *addr;
  
  argstr(0, name, 16);
    80002eb6:	4641                	li	a2,16
    80002eb8:	fd840593          	add	a1,s0,-40
    80002ebc:	4501                	li	a0,0
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	f4c080e7          	jalr	-180(ra) # 80002e0a <argstr>
  argint(1, &open);
    80002ec6:	fec40593          	add	a1,s0,-20
    80002eca:	4505                	li	a0,1
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	efe080e7          	jalr	-258(ra) # 80002dca <argint>
  argaddr(2, &addr);
    80002ed4:	fd040593          	add	a1,s0,-48
    80002ed8:	4509                	li	a0,2
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	f10080e7          	jalr	-240(ra) # 80002dea <argaddr>
  // argaddr(2, addr);

  return ringbuf(name, open, (void**) addr);
    80002ee2:	fd043603          	ld	a2,-48(s0)
    80002ee6:	fec42583          	lw	a1,-20(s0)
    80002eea:	fd840513          	add	a0,s0,-40
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	70c080e7          	jalr	1804(ra) # 800025fa <ringbuf>
}
    80002ef6:	70a2                	ld	ra,40(sp)
    80002ef8:	7402                	ld	s0,32(sp)
    80002efa:	6145                	add	sp,sp,48
    80002efc:	8082                	ret

0000000080002efe <sys_exit>:

uint64
sys_exit(void)
{
    80002efe:	1101                	add	sp,sp,-32
    80002f00:	ec06                	sd	ra,24(sp)
    80002f02:	e822                	sd	s0,16(sp)
    80002f04:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002f06:	fec40593          	add	a1,s0,-20
    80002f0a:	4501                	li	a0,0
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	ebe080e7          	jalr	-322(ra) # 80002dca <argint>
  exit(n);
    80002f14:	fec42503          	lw	a0,-20(s0)
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	26a080e7          	jalr	618(ra) # 80002182 <exit>
  return 0;  // not reached
}
    80002f20:	4501                	li	a0,0
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	6105                	add	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f2a:	1141                	add	sp,sp,-16
    80002f2c:	e406                	sd	ra,8(sp)
    80002f2e:	e022                	sd	s0,0(sp)
    80002f30:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	a74080e7          	jalr	-1420(ra) # 800019a6 <myproc>
}
    80002f3a:	5908                	lw	a0,48(a0)
    80002f3c:	60a2                	ld	ra,8(sp)
    80002f3e:	6402                	ld	s0,0(sp)
    80002f40:	0141                	add	sp,sp,16
    80002f42:	8082                	ret

0000000080002f44 <sys_fork>:

uint64
sys_fork(void)
{
    80002f44:	1141                	add	sp,sp,-16
    80002f46:	e406                	sd	ra,8(sp)
    80002f48:	e022                	sd	s0,0(sp)
    80002f4a:	0800                	add	s0,sp,16
  return fork();
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	e10080e7          	jalr	-496(ra) # 80001d5c <fork>
}
    80002f54:	60a2                	ld	ra,8(sp)
    80002f56:	6402                	ld	s0,0(sp)
    80002f58:	0141                	add	sp,sp,16
    80002f5a:	8082                	ret

0000000080002f5c <sys_wait>:

uint64
sys_wait(void)
{
    80002f5c:	1101                	add	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f64:	fe840593          	add	a1,s0,-24
    80002f68:	4501                	li	a0,0
    80002f6a:	00000097          	auipc	ra,0x0
    80002f6e:	e80080e7          	jalr	-384(ra) # 80002dea <argaddr>
  return wait(p);
    80002f72:	fe843503          	ld	a0,-24(s0)
    80002f76:	fffff097          	auipc	ra,0xfffff
    80002f7a:	3b2080e7          	jalr	946(ra) # 80002328 <wait>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	6105                	add	sp,sp,32
    80002f84:	8082                	ret

0000000080002f86 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f86:	7179                	add	sp,sp,-48
    80002f88:	f406                	sd	ra,40(sp)
    80002f8a:	f022                	sd	s0,32(sp)
    80002f8c:	ec26                	sd	s1,24(sp)
    80002f8e:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f90:	fdc40593          	add	a1,s0,-36
    80002f94:	4501                	li	a0,0
    80002f96:	00000097          	auipc	ra,0x0
    80002f9a:	e34080e7          	jalr	-460(ra) # 80002dca <argint>
  addr = myproc()->sz;
    80002f9e:	fffff097          	auipc	ra,0xfffff
    80002fa2:	a08080e7          	jalr	-1528(ra) # 800019a6 <myproc>
    80002fa6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002fa8:	fdc42503          	lw	a0,-36(s0)
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	d54080e7          	jalr	-684(ra) # 80001d00 <growproc>
    80002fb4:	00054863          	bltz	a0,80002fc4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002fb8:	8526                	mv	a0,s1
    80002fba:	70a2                	ld	ra,40(sp)
    80002fbc:	7402                	ld	s0,32(sp)
    80002fbe:	64e2                	ld	s1,24(sp)
    80002fc0:	6145                	add	sp,sp,48
    80002fc2:	8082                	ret
    return -1;
    80002fc4:	54fd                	li	s1,-1
    80002fc6:	bfcd                	j	80002fb8 <sys_sbrk+0x32>

0000000080002fc8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fc8:	7139                	add	sp,sp,-64
    80002fca:	fc06                	sd	ra,56(sp)
    80002fcc:	f822                	sd	s0,48(sp)
    80002fce:	f426                	sd	s1,40(sp)
    80002fd0:	f04a                	sd	s2,32(sp)
    80002fd2:	ec4e                	sd	s3,24(sp)
    80002fd4:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002fd6:	fcc40593          	add	a1,s0,-52
    80002fda:	4501                	li	a0,0
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	dee080e7          	jalr	-530(ra) # 80002dca <argint>
  acquire(&tickslock);
    80002fe4:	00014517          	auipc	a0,0x14
    80002fe8:	13450513          	add	a0,a0,308 # 80017118 <tickslock>
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	be6080e7          	jalr	-1050(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002ff4:	00006917          	auipc	s2,0x6
    80002ff8:	a2c92903          	lw	s2,-1492(s2) # 80008a20 <ticks>
  while(ticks - ticks0 < n){
    80002ffc:	fcc42783          	lw	a5,-52(s0)
    80003000:	cf9d                	beqz	a5,8000303e <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003002:	00014997          	auipc	s3,0x14
    80003006:	11698993          	add	s3,s3,278 # 80017118 <tickslock>
    8000300a:	00006497          	auipc	s1,0x6
    8000300e:	a1648493          	add	s1,s1,-1514 # 80008a20 <ticks>
    if(killed(myproc())){
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	994080e7          	jalr	-1644(ra) # 800019a6 <myproc>
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	2dc080e7          	jalr	732(ra) # 800022f6 <killed>
    80003022:	ed15                	bnez	a0,8000305e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003024:	85ce                	mv	a1,s3
    80003026:	8526                	mv	a0,s1
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	026080e7          	jalr	38(ra) # 8000204e <sleep>
  while(ticks - ticks0 < n){
    80003030:	409c                	lw	a5,0(s1)
    80003032:	412787bb          	subw	a5,a5,s2
    80003036:	fcc42703          	lw	a4,-52(s0)
    8000303a:	fce7ece3          	bltu	a5,a4,80003012 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000303e:	00014517          	auipc	a0,0x14
    80003042:	0da50513          	add	a0,a0,218 # 80017118 <tickslock>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	c40080e7          	jalr	-960(ra) # 80000c86 <release>
  return 0;
    8000304e:	4501                	li	a0,0
}
    80003050:	70e2                	ld	ra,56(sp)
    80003052:	7442                	ld	s0,48(sp)
    80003054:	74a2                	ld	s1,40(sp)
    80003056:	7902                	ld	s2,32(sp)
    80003058:	69e2                	ld	s3,24(sp)
    8000305a:	6121                	add	sp,sp,64
    8000305c:	8082                	ret
      release(&tickslock);
    8000305e:	00014517          	auipc	a0,0x14
    80003062:	0ba50513          	add	a0,a0,186 # 80017118 <tickslock>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	c20080e7          	jalr	-992(ra) # 80000c86 <release>
      return -1;
    8000306e:	557d                	li	a0,-1
    80003070:	b7c5                	j	80003050 <sys_sleep+0x88>

0000000080003072 <sys_kill>:

uint64
sys_kill(void)
{
    80003072:	1101                	add	sp,sp,-32
    80003074:	ec06                	sd	ra,24(sp)
    80003076:	e822                	sd	s0,16(sp)
    80003078:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    8000307a:	fec40593          	add	a1,s0,-20
    8000307e:	4501                	li	a0,0
    80003080:	00000097          	auipc	ra,0x0
    80003084:	d4a080e7          	jalr	-694(ra) # 80002dca <argint>
  return kill(pid);
    80003088:	fec42503          	lw	a0,-20(s0)
    8000308c:	fffff097          	auipc	ra,0xfffff
    80003090:	1cc080e7          	jalr	460(ra) # 80002258 <kill>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	6105                	add	sp,sp,32
    8000309a:	8082                	ret

000000008000309c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000309c:	1101                	add	sp,sp,-32
    8000309e:	ec06                	sd	ra,24(sp)
    800030a0:	e822                	sd	s0,16(sp)
    800030a2:	e426                	sd	s1,8(sp)
    800030a4:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030a6:	00014517          	auipc	a0,0x14
    800030aa:	07250513          	add	a0,a0,114 # 80017118 <tickslock>
    800030ae:	ffffe097          	auipc	ra,0xffffe
    800030b2:	b24080e7          	jalr	-1244(ra) # 80000bd2 <acquire>
  xticks = ticks;
    800030b6:	00006497          	auipc	s1,0x6
    800030ba:	96a4a483          	lw	s1,-1686(s1) # 80008a20 <ticks>
  release(&tickslock);
    800030be:	00014517          	auipc	a0,0x14
    800030c2:	05a50513          	add	a0,a0,90 # 80017118 <tickslock>
    800030c6:	ffffe097          	auipc	ra,0xffffe
    800030ca:	bc0080e7          	jalr	-1088(ra) # 80000c86 <release>
  return xticks;
}
    800030ce:	02049513          	sll	a0,s1,0x20
    800030d2:	9101                	srl	a0,a0,0x20
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6105                	add	sp,sp,32
    800030dc:	8082                	ret

00000000800030de <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030de:	7179                	add	sp,sp,-48
    800030e0:	f406                	sd	ra,40(sp)
    800030e2:	f022                	sd	s0,32(sp)
    800030e4:	ec26                	sd	s1,24(sp)
    800030e6:	e84a                	sd	s2,16(sp)
    800030e8:	e44e                	sd	s3,8(sp)
    800030ea:	e052                	sd	s4,0(sp)
    800030ec:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030ee:	00005597          	auipc	a1,0x5
    800030f2:	57258593          	add	a1,a1,1394 # 80008660 <syscalls+0xb8>
    800030f6:	00014517          	auipc	a0,0x14
    800030fa:	03a50513          	add	a0,a0,58 # 80017130 <bcache>
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	a44080e7          	jalr	-1468(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003106:	0001c797          	auipc	a5,0x1c
    8000310a:	02a78793          	add	a5,a5,42 # 8001f130 <bcache+0x8000>
    8000310e:	0001c717          	auipc	a4,0x1c
    80003112:	28a70713          	add	a4,a4,650 # 8001f398 <bcache+0x8268>
    80003116:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000311a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000311e:	00014497          	auipc	s1,0x14
    80003122:	02a48493          	add	s1,s1,42 # 80017148 <bcache+0x18>
    b->next = bcache.head.next;
    80003126:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003128:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000312a:	00005a17          	auipc	s4,0x5
    8000312e:	53ea0a13          	add	s4,s4,1342 # 80008668 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003132:	2b893783          	ld	a5,696(s2)
    80003136:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003138:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000313c:	85d2                	mv	a1,s4
    8000313e:	01048513          	add	a0,s1,16
    80003142:	00001097          	auipc	ra,0x1
    80003146:	496080e7          	jalr	1174(ra) # 800045d8 <initsleeplock>
    bcache.head.next->prev = b;
    8000314a:	2b893783          	ld	a5,696(s2)
    8000314e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003150:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003154:	45848493          	add	s1,s1,1112
    80003158:	fd349de3          	bne	s1,s3,80003132 <binit+0x54>
  }
}
    8000315c:	70a2                	ld	ra,40(sp)
    8000315e:	7402                	ld	s0,32(sp)
    80003160:	64e2                	ld	s1,24(sp)
    80003162:	6942                	ld	s2,16(sp)
    80003164:	69a2                	ld	s3,8(sp)
    80003166:	6a02                	ld	s4,0(sp)
    80003168:	6145                	add	sp,sp,48
    8000316a:	8082                	ret

000000008000316c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000316c:	7179                	add	sp,sp,-48
    8000316e:	f406                	sd	ra,40(sp)
    80003170:	f022                	sd	s0,32(sp)
    80003172:	ec26                	sd	s1,24(sp)
    80003174:	e84a                	sd	s2,16(sp)
    80003176:	e44e                	sd	s3,8(sp)
    80003178:	1800                	add	s0,sp,48
    8000317a:	892a                	mv	s2,a0
    8000317c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000317e:	00014517          	auipc	a0,0x14
    80003182:	fb250513          	add	a0,a0,-78 # 80017130 <bcache>
    80003186:	ffffe097          	auipc	ra,0xffffe
    8000318a:	a4c080e7          	jalr	-1460(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000318e:	0001c497          	auipc	s1,0x1c
    80003192:	25a4b483          	ld	s1,602(s1) # 8001f3e8 <bcache+0x82b8>
    80003196:	0001c797          	auipc	a5,0x1c
    8000319a:	20278793          	add	a5,a5,514 # 8001f398 <bcache+0x8268>
    8000319e:	02f48f63          	beq	s1,a5,800031dc <bread+0x70>
    800031a2:	873e                	mv	a4,a5
    800031a4:	a021                	j	800031ac <bread+0x40>
    800031a6:	68a4                	ld	s1,80(s1)
    800031a8:	02e48a63          	beq	s1,a4,800031dc <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031ac:	449c                	lw	a5,8(s1)
    800031ae:	ff279ce3          	bne	a5,s2,800031a6 <bread+0x3a>
    800031b2:	44dc                	lw	a5,12(s1)
    800031b4:	ff3799e3          	bne	a5,s3,800031a6 <bread+0x3a>
      b->refcnt++;
    800031b8:	40bc                	lw	a5,64(s1)
    800031ba:	2785                	addw	a5,a5,1
    800031bc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031be:	00014517          	auipc	a0,0x14
    800031c2:	f7250513          	add	a0,a0,-142 # 80017130 <bcache>
    800031c6:	ffffe097          	auipc	ra,0xffffe
    800031ca:	ac0080e7          	jalr	-1344(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800031ce:	01048513          	add	a0,s1,16
    800031d2:	00001097          	auipc	ra,0x1
    800031d6:	440080e7          	jalr	1088(ra) # 80004612 <acquiresleep>
      return b;
    800031da:	a8b9                	j	80003238 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031dc:	0001c497          	auipc	s1,0x1c
    800031e0:	2044b483          	ld	s1,516(s1) # 8001f3e0 <bcache+0x82b0>
    800031e4:	0001c797          	auipc	a5,0x1c
    800031e8:	1b478793          	add	a5,a5,436 # 8001f398 <bcache+0x8268>
    800031ec:	00f48863          	beq	s1,a5,800031fc <bread+0x90>
    800031f0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031f2:	40bc                	lw	a5,64(s1)
    800031f4:	cf81                	beqz	a5,8000320c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031f6:	64a4                	ld	s1,72(s1)
    800031f8:	fee49de3          	bne	s1,a4,800031f2 <bread+0x86>
  panic("bget: no buffers");
    800031fc:	00005517          	auipc	a0,0x5
    80003200:	47450513          	add	a0,a0,1140 # 80008670 <syscalls+0xc8>
    80003204:	ffffd097          	auipc	ra,0xffffd
    80003208:	338080e7          	jalr	824(ra) # 8000053c <panic>
      b->dev = dev;
    8000320c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003210:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003214:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003218:	4785                	li	a5,1
    8000321a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000321c:	00014517          	auipc	a0,0x14
    80003220:	f1450513          	add	a0,a0,-236 # 80017130 <bcache>
    80003224:	ffffe097          	auipc	ra,0xffffe
    80003228:	a62080e7          	jalr	-1438(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000322c:	01048513          	add	a0,s1,16
    80003230:	00001097          	auipc	ra,0x1
    80003234:	3e2080e7          	jalr	994(ra) # 80004612 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003238:	409c                	lw	a5,0(s1)
    8000323a:	cb89                	beqz	a5,8000324c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000323c:	8526                	mv	a0,s1
    8000323e:	70a2                	ld	ra,40(sp)
    80003240:	7402                	ld	s0,32(sp)
    80003242:	64e2                	ld	s1,24(sp)
    80003244:	6942                	ld	s2,16(sp)
    80003246:	69a2                	ld	s3,8(sp)
    80003248:	6145                	add	sp,sp,48
    8000324a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000324c:	4581                	li	a1,0
    8000324e:	8526                	mv	a0,s1
    80003250:	00003097          	auipc	ra,0x3
    80003254:	f82080e7          	jalr	-126(ra) # 800061d2 <virtio_disk_rw>
    b->valid = 1;
    80003258:	4785                	li	a5,1
    8000325a:	c09c                	sw	a5,0(s1)
  return b;
    8000325c:	b7c5                	j	8000323c <bread+0xd0>

000000008000325e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000325e:	1101                	add	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	1000                	add	s0,sp,32
    80003268:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000326a:	0541                	add	a0,a0,16
    8000326c:	00001097          	auipc	ra,0x1
    80003270:	440080e7          	jalr	1088(ra) # 800046ac <holdingsleep>
    80003274:	cd01                	beqz	a0,8000328c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003276:	4585                	li	a1,1
    80003278:	8526                	mv	a0,s1
    8000327a:	00003097          	auipc	ra,0x3
    8000327e:	f58080e7          	jalr	-168(ra) # 800061d2 <virtio_disk_rw>
}
    80003282:	60e2                	ld	ra,24(sp)
    80003284:	6442                	ld	s0,16(sp)
    80003286:	64a2                	ld	s1,8(sp)
    80003288:	6105                	add	sp,sp,32
    8000328a:	8082                	ret
    panic("bwrite");
    8000328c:	00005517          	auipc	a0,0x5
    80003290:	3fc50513          	add	a0,a0,1020 # 80008688 <syscalls+0xe0>
    80003294:	ffffd097          	auipc	ra,0xffffd
    80003298:	2a8080e7          	jalr	680(ra) # 8000053c <panic>

000000008000329c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000329c:	1101                	add	sp,sp,-32
    8000329e:	ec06                	sd	ra,24(sp)
    800032a0:	e822                	sd	s0,16(sp)
    800032a2:	e426                	sd	s1,8(sp)
    800032a4:	e04a                	sd	s2,0(sp)
    800032a6:	1000                	add	s0,sp,32
    800032a8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032aa:	01050913          	add	s2,a0,16
    800032ae:	854a                	mv	a0,s2
    800032b0:	00001097          	auipc	ra,0x1
    800032b4:	3fc080e7          	jalr	1020(ra) # 800046ac <holdingsleep>
    800032b8:	c925                	beqz	a0,80003328 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800032ba:	854a                	mv	a0,s2
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	3ac080e7          	jalr	940(ra) # 80004668 <releasesleep>

  acquire(&bcache.lock);
    800032c4:	00014517          	auipc	a0,0x14
    800032c8:	e6c50513          	add	a0,a0,-404 # 80017130 <bcache>
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	906080e7          	jalr	-1786(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800032d4:	40bc                	lw	a5,64(s1)
    800032d6:	37fd                	addw	a5,a5,-1
    800032d8:	0007871b          	sext.w	a4,a5
    800032dc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032de:	e71d                	bnez	a4,8000330c <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032e0:	68b8                	ld	a4,80(s1)
    800032e2:	64bc                	ld	a5,72(s1)
    800032e4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800032e6:	68b8                	ld	a4,80(s1)
    800032e8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032ea:	0001c797          	auipc	a5,0x1c
    800032ee:	e4678793          	add	a5,a5,-442 # 8001f130 <bcache+0x8000>
    800032f2:	2b87b703          	ld	a4,696(a5)
    800032f6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032f8:	0001c717          	auipc	a4,0x1c
    800032fc:	0a070713          	add	a4,a4,160 # 8001f398 <bcache+0x8268>
    80003300:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003302:	2b87b703          	ld	a4,696(a5)
    80003306:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003308:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000330c:	00014517          	auipc	a0,0x14
    80003310:	e2450513          	add	a0,a0,-476 # 80017130 <bcache>
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	972080e7          	jalr	-1678(ra) # 80000c86 <release>
}
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	64a2                	ld	s1,8(sp)
    80003322:	6902                	ld	s2,0(sp)
    80003324:	6105                	add	sp,sp,32
    80003326:	8082                	ret
    panic("brelse");
    80003328:	00005517          	auipc	a0,0x5
    8000332c:	36850513          	add	a0,a0,872 # 80008690 <syscalls+0xe8>
    80003330:	ffffd097          	auipc	ra,0xffffd
    80003334:	20c080e7          	jalr	524(ra) # 8000053c <panic>

0000000080003338 <bpin>:

void
bpin(struct buf *b) {
    80003338:	1101                	add	sp,sp,-32
    8000333a:	ec06                	sd	ra,24(sp)
    8000333c:	e822                	sd	s0,16(sp)
    8000333e:	e426                	sd	s1,8(sp)
    80003340:	1000                	add	s0,sp,32
    80003342:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003344:	00014517          	auipc	a0,0x14
    80003348:	dec50513          	add	a0,a0,-532 # 80017130 <bcache>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	886080e7          	jalr	-1914(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003354:	40bc                	lw	a5,64(s1)
    80003356:	2785                	addw	a5,a5,1
    80003358:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000335a:	00014517          	auipc	a0,0x14
    8000335e:	dd650513          	add	a0,a0,-554 # 80017130 <bcache>
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	924080e7          	jalr	-1756(ra) # 80000c86 <release>
}
    8000336a:	60e2                	ld	ra,24(sp)
    8000336c:	6442                	ld	s0,16(sp)
    8000336e:	64a2                	ld	s1,8(sp)
    80003370:	6105                	add	sp,sp,32
    80003372:	8082                	ret

0000000080003374 <bunpin>:

void
bunpin(struct buf *b) {
    80003374:	1101                	add	sp,sp,-32
    80003376:	ec06                	sd	ra,24(sp)
    80003378:	e822                	sd	s0,16(sp)
    8000337a:	e426                	sd	s1,8(sp)
    8000337c:	1000                	add	s0,sp,32
    8000337e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003380:	00014517          	auipc	a0,0x14
    80003384:	db050513          	add	a0,a0,-592 # 80017130 <bcache>
    80003388:	ffffe097          	auipc	ra,0xffffe
    8000338c:	84a080e7          	jalr	-1974(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003390:	40bc                	lw	a5,64(s1)
    80003392:	37fd                	addw	a5,a5,-1
    80003394:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003396:	00014517          	auipc	a0,0x14
    8000339a:	d9a50513          	add	a0,a0,-614 # 80017130 <bcache>
    8000339e:	ffffe097          	auipc	ra,0xffffe
    800033a2:	8e8080e7          	jalr	-1816(ra) # 80000c86 <release>
}
    800033a6:	60e2                	ld	ra,24(sp)
    800033a8:	6442                	ld	s0,16(sp)
    800033aa:	64a2                	ld	s1,8(sp)
    800033ac:	6105                	add	sp,sp,32
    800033ae:	8082                	ret

00000000800033b0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033b0:	1101                	add	sp,sp,-32
    800033b2:	ec06                	sd	ra,24(sp)
    800033b4:	e822                	sd	s0,16(sp)
    800033b6:	e426                	sd	s1,8(sp)
    800033b8:	e04a                	sd	s2,0(sp)
    800033ba:	1000                	add	s0,sp,32
    800033bc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033be:	00d5d59b          	srlw	a1,a1,0xd
    800033c2:	0001c797          	auipc	a5,0x1c
    800033c6:	44a7a783          	lw	a5,1098(a5) # 8001f80c <sb+0x1c>
    800033ca:	9dbd                	addw	a1,a1,a5
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	da0080e7          	jalr	-608(ra) # 8000316c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033d4:	0074f713          	and	a4,s1,7
    800033d8:	4785                	li	a5,1
    800033da:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033de:	14ce                	sll	s1,s1,0x33
    800033e0:	90d9                	srl	s1,s1,0x36
    800033e2:	00950733          	add	a4,a0,s1
    800033e6:	05874703          	lbu	a4,88(a4)
    800033ea:	00e7f6b3          	and	a3,a5,a4
    800033ee:	c69d                	beqz	a3,8000341c <bfree+0x6c>
    800033f0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033f2:	94aa                	add	s1,s1,a0
    800033f4:	fff7c793          	not	a5,a5
    800033f8:	8f7d                	and	a4,a4,a5
    800033fa:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800033fe:	00001097          	auipc	ra,0x1
    80003402:	0f6080e7          	jalr	246(ra) # 800044f4 <log_write>
  brelse(bp);
    80003406:	854a                	mv	a0,s2
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	e94080e7          	jalr	-364(ra) # 8000329c <brelse>
}
    80003410:	60e2                	ld	ra,24(sp)
    80003412:	6442                	ld	s0,16(sp)
    80003414:	64a2                	ld	s1,8(sp)
    80003416:	6902                	ld	s2,0(sp)
    80003418:	6105                	add	sp,sp,32
    8000341a:	8082                	ret
    panic("freeing free block");
    8000341c:	00005517          	auipc	a0,0x5
    80003420:	27c50513          	add	a0,a0,636 # 80008698 <syscalls+0xf0>
    80003424:	ffffd097          	auipc	ra,0xffffd
    80003428:	118080e7          	jalr	280(ra) # 8000053c <panic>

000000008000342c <balloc>:
{
    8000342c:	711d                	add	sp,sp,-96
    8000342e:	ec86                	sd	ra,88(sp)
    80003430:	e8a2                	sd	s0,80(sp)
    80003432:	e4a6                	sd	s1,72(sp)
    80003434:	e0ca                	sd	s2,64(sp)
    80003436:	fc4e                	sd	s3,56(sp)
    80003438:	f852                	sd	s4,48(sp)
    8000343a:	f456                	sd	s5,40(sp)
    8000343c:	f05a                	sd	s6,32(sp)
    8000343e:	ec5e                	sd	s7,24(sp)
    80003440:	e862                	sd	s8,16(sp)
    80003442:	e466                	sd	s9,8(sp)
    80003444:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003446:	0001c797          	auipc	a5,0x1c
    8000344a:	3ae7a783          	lw	a5,942(a5) # 8001f7f4 <sb+0x4>
    8000344e:	cff5                	beqz	a5,8000354a <balloc+0x11e>
    80003450:	8baa                	mv	s7,a0
    80003452:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003454:	0001cb17          	auipc	s6,0x1c
    80003458:	39cb0b13          	add	s6,s6,924 # 8001f7f0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000345c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000345e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003460:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003462:	6c89                	lui	s9,0x2
    80003464:	a061                	j	800034ec <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003466:	97ca                	add	a5,a5,s2
    80003468:	8e55                	or	a2,a2,a3
    8000346a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	00001097          	auipc	ra,0x1
    80003474:	084080e7          	jalr	132(ra) # 800044f4 <log_write>
        brelse(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	e22080e7          	jalr	-478(ra) # 8000329c <brelse>
  bp = bread(dev, bno);
    80003482:	85a6                	mv	a1,s1
    80003484:	855e                	mv	a0,s7
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	ce6080e7          	jalr	-794(ra) # 8000316c <bread>
    8000348e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003490:	40000613          	li	a2,1024
    80003494:	4581                	li	a1,0
    80003496:	05850513          	add	a0,a0,88
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	834080e7          	jalr	-1996(ra) # 80000cce <memset>
  log_write(bp);
    800034a2:	854a                	mv	a0,s2
    800034a4:	00001097          	auipc	ra,0x1
    800034a8:	050080e7          	jalr	80(ra) # 800044f4 <log_write>
  brelse(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	dee080e7          	jalr	-530(ra) # 8000329c <brelse>
}
    800034b6:	8526                	mv	a0,s1
    800034b8:	60e6                	ld	ra,88(sp)
    800034ba:	6446                	ld	s0,80(sp)
    800034bc:	64a6                	ld	s1,72(sp)
    800034be:	6906                	ld	s2,64(sp)
    800034c0:	79e2                	ld	s3,56(sp)
    800034c2:	7a42                	ld	s4,48(sp)
    800034c4:	7aa2                	ld	s5,40(sp)
    800034c6:	7b02                	ld	s6,32(sp)
    800034c8:	6be2                	ld	s7,24(sp)
    800034ca:	6c42                	ld	s8,16(sp)
    800034cc:	6ca2                	ld	s9,8(sp)
    800034ce:	6125                	add	sp,sp,96
    800034d0:	8082                	ret
    brelse(bp);
    800034d2:	854a                	mv	a0,s2
    800034d4:	00000097          	auipc	ra,0x0
    800034d8:	dc8080e7          	jalr	-568(ra) # 8000329c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034dc:	015c87bb          	addw	a5,s9,s5
    800034e0:	00078a9b          	sext.w	s5,a5
    800034e4:	004b2703          	lw	a4,4(s6)
    800034e8:	06eaf163          	bgeu	s5,a4,8000354a <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800034ec:	41fad79b          	sraw	a5,s5,0x1f
    800034f0:	0137d79b          	srlw	a5,a5,0x13
    800034f4:	015787bb          	addw	a5,a5,s5
    800034f8:	40d7d79b          	sraw	a5,a5,0xd
    800034fc:	01cb2583          	lw	a1,28(s6)
    80003500:	9dbd                	addw	a1,a1,a5
    80003502:	855e                	mv	a0,s7
    80003504:	00000097          	auipc	ra,0x0
    80003508:	c68080e7          	jalr	-920(ra) # 8000316c <bread>
    8000350c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000350e:	004b2503          	lw	a0,4(s6)
    80003512:	000a849b          	sext.w	s1,s5
    80003516:	8762                	mv	a4,s8
    80003518:	faa4fde3          	bgeu	s1,a0,800034d2 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000351c:	00777693          	and	a3,a4,7
    80003520:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003524:	41f7579b          	sraw	a5,a4,0x1f
    80003528:	01d7d79b          	srlw	a5,a5,0x1d
    8000352c:	9fb9                	addw	a5,a5,a4
    8000352e:	4037d79b          	sraw	a5,a5,0x3
    80003532:	00f90633          	add	a2,s2,a5
    80003536:	05864603          	lbu	a2,88(a2)
    8000353a:	00c6f5b3          	and	a1,a3,a2
    8000353e:	d585                	beqz	a1,80003466 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003540:	2705                	addw	a4,a4,1
    80003542:	2485                	addw	s1,s1,1
    80003544:	fd471ae3          	bne	a4,s4,80003518 <balloc+0xec>
    80003548:	b769                	j	800034d2 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000354a:	00005517          	auipc	a0,0x5
    8000354e:	16650513          	add	a0,a0,358 # 800086b0 <syscalls+0x108>
    80003552:	ffffd097          	auipc	ra,0xffffd
    80003556:	034080e7          	jalr	52(ra) # 80000586 <printf>
  return 0;
    8000355a:	4481                	li	s1,0
    8000355c:	bfa9                	j	800034b6 <balloc+0x8a>

000000008000355e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000355e:	7179                	add	sp,sp,-48
    80003560:	f406                	sd	ra,40(sp)
    80003562:	f022                	sd	s0,32(sp)
    80003564:	ec26                	sd	s1,24(sp)
    80003566:	e84a                	sd	s2,16(sp)
    80003568:	e44e                	sd	s3,8(sp)
    8000356a:	e052                	sd	s4,0(sp)
    8000356c:	1800                	add	s0,sp,48
    8000356e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003570:	47ad                	li	a5,11
    80003572:	02b7e863          	bltu	a5,a1,800035a2 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003576:	02059793          	sll	a5,a1,0x20
    8000357a:	01e7d593          	srl	a1,a5,0x1e
    8000357e:	00b504b3          	add	s1,a0,a1
    80003582:	0504a903          	lw	s2,80(s1)
    80003586:	06091e63          	bnez	s2,80003602 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000358a:	4108                	lw	a0,0(a0)
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	ea0080e7          	jalr	-352(ra) # 8000342c <balloc>
    80003594:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003598:	06090563          	beqz	s2,80003602 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000359c:	0524a823          	sw	s2,80(s1)
    800035a0:	a08d                	j	80003602 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035a2:	ff45849b          	addw	s1,a1,-12
    800035a6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035aa:	0ff00793          	li	a5,255
    800035ae:	08e7e563          	bltu	a5,a4,80003638 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035b2:	08052903          	lw	s2,128(a0)
    800035b6:	00091d63          	bnez	s2,800035d0 <bmap+0x72>
      addr = balloc(ip->dev);
    800035ba:	4108                	lw	a0,0(a0)
    800035bc:	00000097          	auipc	ra,0x0
    800035c0:	e70080e7          	jalr	-400(ra) # 8000342c <balloc>
    800035c4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035c8:	02090d63          	beqz	s2,80003602 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035cc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800035d0:	85ca                	mv	a1,s2
    800035d2:	0009a503          	lw	a0,0(s3)
    800035d6:	00000097          	auipc	ra,0x0
    800035da:	b96080e7          	jalr	-1130(ra) # 8000316c <bread>
    800035de:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035e0:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    800035e4:	02049713          	sll	a4,s1,0x20
    800035e8:	01e75593          	srl	a1,a4,0x1e
    800035ec:	00b784b3          	add	s1,a5,a1
    800035f0:	0004a903          	lw	s2,0(s1)
    800035f4:	02090063          	beqz	s2,80003614 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035f8:	8552                	mv	a0,s4
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	ca2080e7          	jalr	-862(ra) # 8000329c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003602:	854a                	mv	a0,s2
    80003604:	70a2                	ld	ra,40(sp)
    80003606:	7402                	ld	s0,32(sp)
    80003608:	64e2                	ld	s1,24(sp)
    8000360a:	6942                	ld	s2,16(sp)
    8000360c:	69a2                	ld	s3,8(sp)
    8000360e:	6a02                	ld	s4,0(sp)
    80003610:	6145                	add	sp,sp,48
    80003612:	8082                	ret
      addr = balloc(ip->dev);
    80003614:	0009a503          	lw	a0,0(s3)
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	e14080e7          	jalr	-492(ra) # 8000342c <balloc>
    80003620:	0005091b          	sext.w	s2,a0
      if(addr){
    80003624:	fc090ae3          	beqz	s2,800035f8 <bmap+0x9a>
        a[bn] = addr;
    80003628:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000362c:	8552                	mv	a0,s4
    8000362e:	00001097          	auipc	ra,0x1
    80003632:	ec6080e7          	jalr	-314(ra) # 800044f4 <log_write>
    80003636:	b7c9                	j	800035f8 <bmap+0x9a>
  panic("bmap: out of range");
    80003638:	00005517          	auipc	a0,0x5
    8000363c:	09050513          	add	a0,a0,144 # 800086c8 <syscalls+0x120>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	efc080e7          	jalr	-260(ra) # 8000053c <panic>

0000000080003648 <iget>:
{
    80003648:	7179                	add	sp,sp,-48
    8000364a:	f406                	sd	ra,40(sp)
    8000364c:	f022                	sd	s0,32(sp)
    8000364e:	ec26                	sd	s1,24(sp)
    80003650:	e84a                	sd	s2,16(sp)
    80003652:	e44e                	sd	s3,8(sp)
    80003654:	e052                	sd	s4,0(sp)
    80003656:	1800                	add	s0,sp,48
    80003658:	89aa                	mv	s3,a0
    8000365a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000365c:	0001c517          	auipc	a0,0x1c
    80003660:	1b450513          	add	a0,a0,436 # 8001f810 <itable>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	56e080e7          	jalr	1390(ra) # 80000bd2 <acquire>
  empty = 0;
    8000366c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000366e:	0001c497          	auipc	s1,0x1c
    80003672:	1ba48493          	add	s1,s1,442 # 8001f828 <itable+0x18>
    80003676:	0001e697          	auipc	a3,0x1e
    8000367a:	c4268693          	add	a3,a3,-958 # 800212b8 <log>
    8000367e:	a039                	j	8000368c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003680:	02090b63          	beqz	s2,800036b6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003684:	08848493          	add	s1,s1,136
    80003688:	02d48a63          	beq	s1,a3,800036bc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000368c:	449c                	lw	a5,8(s1)
    8000368e:	fef059e3          	blez	a5,80003680 <iget+0x38>
    80003692:	4098                	lw	a4,0(s1)
    80003694:	ff3716e3          	bne	a4,s3,80003680 <iget+0x38>
    80003698:	40d8                	lw	a4,4(s1)
    8000369a:	ff4713e3          	bne	a4,s4,80003680 <iget+0x38>
      ip->ref++;
    8000369e:	2785                	addw	a5,a5,1
    800036a0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036a2:	0001c517          	auipc	a0,0x1c
    800036a6:	16e50513          	add	a0,a0,366 # 8001f810 <itable>
    800036aa:	ffffd097          	auipc	ra,0xffffd
    800036ae:	5dc080e7          	jalr	1500(ra) # 80000c86 <release>
      return ip;
    800036b2:	8926                	mv	s2,s1
    800036b4:	a03d                	j	800036e2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036b6:	f7f9                	bnez	a5,80003684 <iget+0x3c>
    800036b8:	8926                	mv	s2,s1
    800036ba:	b7e9                	j	80003684 <iget+0x3c>
  if(empty == 0)
    800036bc:	02090c63          	beqz	s2,800036f4 <iget+0xac>
  ip->dev = dev;
    800036c0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036c4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036c8:	4785                	li	a5,1
    800036ca:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036ce:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036d2:	0001c517          	auipc	a0,0x1c
    800036d6:	13e50513          	add	a0,a0,318 # 8001f810 <itable>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	5ac080e7          	jalr	1452(ra) # 80000c86 <release>
}
    800036e2:	854a                	mv	a0,s2
    800036e4:	70a2                	ld	ra,40(sp)
    800036e6:	7402                	ld	s0,32(sp)
    800036e8:	64e2                	ld	s1,24(sp)
    800036ea:	6942                	ld	s2,16(sp)
    800036ec:	69a2                	ld	s3,8(sp)
    800036ee:	6a02                	ld	s4,0(sp)
    800036f0:	6145                	add	sp,sp,48
    800036f2:	8082                	ret
    panic("iget: no inodes");
    800036f4:	00005517          	auipc	a0,0x5
    800036f8:	fec50513          	add	a0,a0,-20 # 800086e0 <syscalls+0x138>
    800036fc:	ffffd097          	auipc	ra,0xffffd
    80003700:	e40080e7          	jalr	-448(ra) # 8000053c <panic>

0000000080003704 <fsinit>:
fsinit(int dev) {
    80003704:	7179                	add	sp,sp,-48
    80003706:	f406                	sd	ra,40(sp)
    80003708:	f022                	sd	s0,32(sp)
    8000370a:	ec26                	sd	s1,24(sp)
    8000370c:	e84a                	sd	s2,16(sp)
    8000370e:	e44e                	sd	s3,8(sp)
    80003710:	1800                	add	s0,sp,48
    80003712:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003714:	4585                	li	a1,1
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	a56080e7          	jalr	-1450(ra) # 8000316c <bread>
    8000371e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003720:	0001c997          	auipc	s3,0x1c
    80003724:	0d098993          	add	s3,s3,208 # 8001f7f0 <sb>
    80003728:	02000613          	li	a2,32
    8000372c:	05850593          	add	a1,a0,88
    80003730:	854e                	mv	a0,s3
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	5f8080e7          	jalr	1528(ra) # 80000d2a <memmove>
  brelse(bp);
    8000373a:	8526                	mv	a0,s1
    8000373c:	00000097          	auipc	ra,0x0
    80003740:	b60080e7          	jalr	-1184(ra) # 8000329c <brelse>
  if(sb.magic != FSMAGIC)
    80003744:	0009a703          	lw	a4,0(s3)
    80003748:	102037b7          	lui	a5,0x10203
    8000374c:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003750:	02f71263          	bne	a4,a5,80003774 <fsinit+0x70>
  initlog(dev, &sb);
    80003754:	0001c597          	auipc	a1,0x1c
    80003758:	09c58593          	add	a1,a1,156 # 8001f7f0 <sb>
    8000375c:	854a                	mv	a0,s2
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	b2c080e7          	jalr	-1236(ra) # 8000428a <initlog>
}
    80003766:	70a2                	ld	ra,40(sp)
    80003768:	7402                	ld	s0,32(sp)
    8000376a:	64e2                	ld	s1,24(sp)
    8000376c:	6942                	ld	s2,16(sp)
    8000376e:	69a2                	ld	s3,8(sp)
    80003770:	6145                	add	sp,sp,48
    80003772:	8082                	ret
    panic("invalid file system");
    80003774:	00005517          	auipc	a0,0x5
    80003778:	f7c50513          	add	a0,a0,-132 # 800086f0 <syscalls+0x148>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	dc0080e7          	jalr	-576(ra) # 8000053c <panic>

0000000080003784 <iinit>:
{
    80003784:	7179                	add	sp,sp,-48
    80003786:	f406                	sd	ra,40(sp)
    80003788:	f022                	sd	s0,32(sp)
    8000378a:	ec26                	sd	s1,24(sp)
    8000378c:	e84a                	sd	s2,16(sp)
    8000378e:	e44e                	sd	s3,8(sp)
    80003790:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003792:	00005597          	auipc	a1,0x5
    80003796:	f7658593          	add	a1,a1,-138 # 80008708 <syscalls+0x160>
    8000379a:	0001c517          	auipc	a0,0x1c
    8000379e:	07650513          	add	a0,a0,118 # 8001f810 <itable>
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	3a0080e7          	jalr	928(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037aa:	0001c497          	auipc	s1,0x1c
    800037ae:	08e48493          	add	s1,s1,142 # 8001f838 <itable+0x28>
    800037b2:	0001e997          	auipc	s3,0x1e
    800037b6:	b1698993          	add	s3,s3,-1258 # 800212c8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037ba:	00005917          	auipc	s2,0x5
    800037be:	f5690913          	add	s2,s2,-170 # 80008710 <syscalls+0x168>
    800037c2:	85ca                	mv	a1,s2
    800037c4:	8526                	mv	a0,s1
    800037c6:	00001097          	auipc	ra,0x1
    800037ca:	e12080e7          	jalr	-494(ra) # 800045d8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037ce:	08848493          	add	s1,s1,136
    800037d2:	ff3498e3          	bne	s1,s3,800037c2 <iinit+0x3e>
}
    800037d6:	70a2                	ld	ra,40(sp)
    800037d8:	7402                	ld	s0,32(sp)
    800037da:	64e2                	ld	s1,24(sp)
    800037dc:	6942                	ld	s2,16(sp)
    800037de:	69a2                	ld	s3,8(sp)
    800037e0:	6145                	add	sp,sp,48
    800037e2:	8082                	ret

00000000800037e4 <ialloc>:
{
    800037e4:	7139                	add	sp,sp,-64
    800037e6:	fc06                	sd	ra,56(sp)
    800037e8:	f822                	sd	s0,48(sp)
    800037ea:	f426                	sd	s1,40(sp)
    800037ec:	f04a                	sd	s2,32(sp)
    800037ee:	ec4e                	sd	s3,24(sp)
    800037f0:	e852                	sd	s4,16(sp)
    800037f2:	e456                	sd	s5,8(sp)
    800037f4:	e05a                	sd	s6,0(sp)
    800037f6:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800037f8:	0001c717          	auipc	a4,0x1c
    800037fc:	00472703          	lw	a4,4(a4) # 8001f7fc <sb+0xc>
    80003800:	4785                	li	a5,1
    80003802:	04e7f863          	bgeu	a5,a4,80003852 <ialloc+0x6e>
    80003806:	8aaa                	mv	s5,a0
    80003808:	8b2e                	mv	s6,a1
    8000380a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000380c:	0001ca17          	auipc	s4,0x1c
    80003810:	fe4a0a13          	add	s4,s4,-28 # 8001f7f0 <sb>
    80003814:	00495593          	srl	a1,s2,0x4
    80003818:	018a2783          	lw	a5,24(s4)
    8000381c:	9dbd                	addw	a1,a1,a5
    8000381e:	8556                	mv	a0,s5
    80003820:	00000097          	auipc	ra,0x0
    80003824:	94c080e7          	jalr	-1716(ra) # 8000316c <bread>
    80003828:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000382a:	05850993          	add	s3,a0,88
    8000382e:	00f97793          	and	a5,s2,15
    80003832:	079a                	sll	a5,a5,0x6
    80003834:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003836:	00099783          	lh	a5,0(s3)
    8000383a:	cf9d                	beqz	a5,80003878 <ialloc+0x94>
    brelse(bp);
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	a60080e7          	jalr	-1440(ra) # 8000329c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003844:	0905                	add	s2,s2,1
    80003846:	00ca2703          	lw	a4,12(s4)
    8000384a:	0009079b          	sext.w	a5,s2
    8000384e:	fce7e3e3          	bltu	a5,a4,80003814 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003852:	00005517          	auipc	a0,0x5
    80003856:	ec650513          	add	a0,a0,-314 # 80008718 <syscalls+0x170>
    8000385a:	ffffd097          	auipc	ra,0xffffd
    8000385e:	d2c080e7          	jalr	-724(ra) # 80000586 <printf>
  return 0;
    80003862:	4501                	li	a0,0
}
    80003864:	70e2                	ld	ra,56(sp)
    80003866:	7442                	ld	s0,48(sp)
    80003868:	74a2                	ld	s1,40(sp)
    8000386a:	7902                	ld	s2,32(sp)
    8000386c:	69e2                	ld	s3,24(sp)
    8000386e:	6a42                	ld	s4,16(sp)
    80003870:	6aa2                	ld	s5,8(sp)
    80003872:	6b02                	ld	s6,0(sp)
    80003874:	6121                	add	sp,sp,64
    80003876:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003878:	04000613          	li	a2,64
    8000387c:	4581                	li	a1,0
    8000387e:	854e                	mv	a0,s3
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	44e080e7          	jalr	1102(ra) # 80000cce <memset>
      dip->type = type;
    80003888:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000388c:	8526                	mv	a0,s1
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	c66080e7          	jalr	-922(ra) # 800044f4 <log_write>
      brelse(bp);
    80003896:	8526                	mv	a0,s1
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	a04080e7          	jalr	-1532(ra) # 8000329c <brelse>
      return iget(dev, inum);
    800038a0:	0009059b          	sext.w	a1,s2
    800038a4:	8556                	mv	a0,s5
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	da2080e7          	jalr	-606(ra) # 80003648 <iget>
    800038ae:	bf5d                	j	80003864 <ialloc+0x80>

00000000800038b0 <iupdate>:
{
    800038b0:	1101                	add	sp,sp,-32
    800038b2:	ec06                	sd	ra,24(sp)
    800038b4:	e822                	sd	s0,16(sp)
    800038b6:	e426                	sd	s1,8(sp)
    800038b8:	e04a                	sd	s2,0(sp)
    800038ba:	1000                	add	s0,sp,32
    800038bc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038be:	415c                	lw	a5,4(a0)
    800038c0:	0047d79b          	srlw	a5,a5,0x4
    800038c4:	0001c597          	auipc	a1,0x1c
    800038c8:	f445a583          	lw	a1,-188(a1) # 8001f808 <sb+0x18>
    800038cc:	9dbd                	addw	a1,a1,a5
    800038ce:	4108                	lw	a0,0(a0)
    800038d0:	00000097          	auipc	ra,0x0
    800038d4:	89c080e7          	jalr	-1892(ra) # 8000316c <bread>
    800038d8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038da:	05850793          	add	a5,a0,88
    800038de:	40d8                	lw	a4,4(s1)
    800038e0:	8b3d                	and	a4,a4,15
    800038e2:	071a                	sll	a4,a4,0x6
    800038e4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800038e6:	04449703          	lh	a4,68(s1)
    800038ea:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800038ee:	04649703          	lh	a4,70(s1)
    800038f2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800038f6:	04849703          	lh	a4,72(s1)
    800038fa:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800038fe:	04a49703          	lh	a4,74(s1)
    80003902:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003906:	44f8                	lw	a4,76(s1)
    80003908:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000390a:	03400613          	li	a2,52
    8000390e:	05048593          	add	a1,s1,80
    80003912:	00c78513          	add	a0,a5,12
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	414080e7          	jalr	1044(ra) # 80000d2a <memmove>
  log_write(bp);
    8000391e:	854a                	mv	a0,s2
    80003920:	00001097          	auipc	ra,0x1
    80003924:	bd4080e7          	jalr	-1068(ra) # 800044f4 <log_write>
  brelse(bp);
    80003928:	854a                	mv	a0,s2
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	972080e7          	jalr	-1678(ra) # 8000329c <brelse>
}
    80003932:	60e2                	ld	ra,24(sp)
    80003934:	6442                	ld	s0,16(sp)
    80003936:	64a2                	ld	s1,8(sp)
    80003938:	6902                	ld	s2,0(sp)
    8000393a:	6105                	add	sp,sp,32
    8000393c:	8082                	ret

000000008000393e <idup>:
{
    8000393e:	1101                	add	sp,sp,-32
    80003940:	ec06                	sd	ra,24(sp)
    80003942:	e822                	sd	s0,16(sp)
    80003944:	e426                	sd	s1,8(sp)
    80003946:	1000                	add	s0,sp,32
    80003948:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000394a:	0001c517          	auipc	a0,0x1c
    8000394e:	ec650513          	add	a0,a0,-314 # 8001f810 <itable>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	280080e7          	jalr	640(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000395a:	449c                	lw	a5,8(s1)
    8000395c:	2785                	addw	a5,a5,1
    8000395e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003960:	0001c517          	auipc	a0,0x1c
    80003964:	eb050513          	add	a0,a0,-336 # 8001f810 <itable>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	31e080e7          	jalr	798(ra) # 80000c86 <release>
}
    80003970:	8526                	mv	a0,s1
    80003972:	60e2                	ld	ra,24(sp)
    80003974:	6442                	ld	s0,16(sp)
    80003976:	64a2                	ld	s1,8(sp)
    80003978:	6105                	add	sp,sp,32
    8000397a:	8082                	ret

000000008000397c <ilock>:
{
    8000397c:	1101                	add	sp,sp,-32
    8000397e:	ec06                	sd	ra,24(sp)
    80003980:	e822                	sd	s0,16(sp)
    80003982:	e426                	sd	s1,8(sp)
    80003984:	e04a                	sd	s2,0(sp)
    80003986:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003988:	c115                	beqz	a0,800039ac <ilock+0x30>
    8000398a:	84aa                	mv	s1,a0
    8000398c:	451c                	lw	a5,8(a0)
    8000398e:	00f05f63          	blez	a5,800039ac <ilock+0x30>
  acquiresleep(&ip->lock);
    80003992:	0541                	add	a0,a0,16
    80003994:	00001097          	auipc	ra,0x1
    80003998:	c7e080e7          	jalr	-898(ra) # 80004612 <acquiresleep>
  if(ip->valid == 0){
    8000399c:	40bc                	lw	a5,64(s1)
    8000399e:	cf99                	beqz	a5,800039bc <ilock+0x40>
}
    800039a0:	60e2                	ld	ra,24(sp)
    800039a2:	6442                	ld	s0,16(sp)
    800039a4:	64a2                	ld	s1,8(sp)
    800039a6:	6902                	ld	s2,0(sp)
    800039a8:	6105                	add	sp,sp,32
    800039aa:	8082                	ret
    panic("ilock");
    800039ac:	00005517          	auipc	a0,0x5
    800039b0:	d8450513          	add	a0,a0,-636 # 80008730 <syscalls+0x188>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	b88080e7          	jalr	-1144(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039bc:	40dc                	lw	a5,4(s1)
    800039be:	0047d79b          	srlw	a5,a5,0x4
    800039c2:	0001c597          	auipc	a1,0x1c
    800039c6:	e465a583          	lw	a1,-442(a1) # 8001f808 <sb+0x18>
    800039ca:	9dbd                	addw	a1,a1,a5
    800039cc:	4088                	lw	a0,0(s1)
    800039ce:	fffff097          	auipc	ra,0xfffff
    800039d2:	79e080e7          	jalr	1950(ra) # 8000316c <bread>
    800039d6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039d8:	05850593          	add	a1,a0,88
    800039dc:	40dc                	lw	a5,4(s1)
    800039de:	8bbd                	and	a5,a5,15
    800039e0:	079a                	sll	a5,a5,0x6
    800039e2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039e4:	00059783          	lh	a5,0(a1)
    800039e8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039ec:	00259783          	lh	a5,2(a1)
    800039f0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039f4:	00459783          	lh	a5,4(a1)
    800039f8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039fc:	00659783          	lh	a5,6(a1)
    80003a00:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a04:	459c                	lw	a5,8(a1)
    80003a06:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a08:	03400613          	li	a2,52
    80003a0c:	05b1                	add	a1,a1,12
    80003a0e:	05048513          	add	a0,s1,80
    80003a12:	ffffd097          	auipc	ra,0xffffd
    80003a16:	318080e7          	jalr	792(ra) # 80000d2a <memmove>
    brelse(bp);
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	880080e7          	jalr	-1920(ra) # 8000329c <brelse>
    ip->valid = 1;
    80003a24:	4785                	li	a5,1
    80003a26:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a28:	04449783          	lh	a5,68(s1)
    80003a2c:	fbb5                	bnez	a5,800039a0 <ilock+0x24>
      panic("ilock: no type");
    80003a2e:	00005517          	auipc	a0,0x5
    80003a32:	d0a50513          	add	a0,a0,-758 # 80008738 <syscalls+0x190>
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	b06080e7          	jalr	-1274(ra) # 8000053c <panic>

0000000080003a3e <iunlock>:
{
    80003a3e:	1101                	add	sp,sp,-32
    80003a40:	ec06                	sd	ra,24(sp)
    80003a42:	e822                	sd	s0,16(sp)
    80003a44:	e426                	sd	s1,8(sp)
    80003a46:	e04a                	sd	s2,0(sp)
    80003a48:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a4a:	c905                	beqz	a0,80003a7a <iunlock+0x3c>
    80003a4c:	84aa                	mv	s1,a0
    80003a4e:	01050913          	add	s2,a0,16
    80003a52:	854a                	mv	a0,s2
    80003a54:	00001097          	auipc	ra,0x1
    80003a58:	c58080e7          	jalr	-936(ra) # 800046ac <holdingsleep>
    80003a5c:	cd19                	beqz	a0,80003a7a <iunlock+0x3c>
    80003a5e:	449c                	lw	a5,8(s1)
    80003a60:	00f05d63          	blez	a5,80003a7a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a64:	854a                	mv	a0,s2
    80003a66:	00001097          	auipc	ra,0x1
    80003a6a:	c02080e7          	jalr	-1022(ra) # 80004668 <releasesleep>
}
    80003a6e:	60e2                	ld	ra,24(sp)
    80003a70:	6442                	ld	s0,16(sp)
    80003a72:	64a2                	ld	s1,8(sp)
    80003a74:	6902                	ld	s2,0(sp)
    80003a76:	6105                	add	sp,sp,32
    80003a78:	8082                	ret
    panic("iunlock");
    80003a7a:	00005517          	auipc	a0,0x5
    80003a7e:	cce50513          	add	a0,a0,-818 # 80008748 <syscalls+0x1a0>
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	aba080e7          	jalr	-1350(ra) # 8000053c <panic>

0000000080003a8a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a8a:	7179                	add	sp,sp,-48
    80003a8c:	f406                	sd	ra,40(sp)
    80003a8e:	f022                	sd	s0,32(sp)
    80003a90:	ec26                	sd	s1,24(sp)
    80003a92:	e84a                	sd	s2,16(sp)
    80003a94:	e44e                	sd	s3,8(sp)
    80003a96:	e052                	sd	s4,0(sp)
    80003a98:	1800                	add	s0,sp,48
    80003a9a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a9c:	05050493          	add	s1,a0,80
    80003aa0:	08050913          	add	s2,a0,128
    80003aa4:	a021                	j	80003aac <itrunc+0x22>
    80003aa6:	0491                	add	s1,s1,4
    80003aa8:	01248d63          	beq	s1,s2,80003ac2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003aac:	408c                	lw	a1,0(s1)
    80003aae:	dde5                	beqz	a1,80003aa6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ab0:	0009a503          	lw	a0,0(s3)
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	8fc080e7          	jalr	-1796(ra) # 800033b0 <bfree>
      ip->addrs[i] = 0;
    80003abc:	0004a023          	sw	zero,0(s1)
    80003ac0:	b7dd                	j	80003aa6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ac2:	0809a583          	lw	a1,128(s3)
    80003ac6:	e185                	bnez	a1,80003ae6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ac8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003acc:	854e                	mv	a0,s3
    80003ace:	00000097          	auipc	ra,0x0
    80003ad2:	de2080e7          	jalr	-542(ra) # 800038b0 <iupdate>
}
    80003ad6:	70a2                	ld	ra,40(sp)
    80003ad8:	7402                	ld	s0,32(sp)
    80003ada:	64e2                	ld	s1,24(sp)
    80003adc:	6942                	ld	s2,16(sp)
    80003ade:	69a2                	ld	s3,8(sp)
    80003ae0:	6a02                	ld	s4,0(sp)
    80003ae2:	6145                	add	sp,sp,48
    80003ae4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ae6:	0009a503          	lw	a0,0(s3)
    80003aea:	fffff097          	auipc	ra,0xfffff
    80003aee:	682080e7          	jalr	1666(ra) # 8000316c <bread>
    80003af2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003af4:	05850493          	add	s1,a0,88
    80003af8:	45850913          	add	s2,a0,1112
    80003afc:	a021                	j	80003b04 <itrunc+0x7a>
    80003afe:	0491                	add	s1,s1,4
    80003b00:	01248b63          	beq	s1,s2,80003b16 <itrunc+0x8c>
      if(a[j])
    80003b04:	408c                	lw	a1,0(s1)
    80003b06:	dde5                	beqz	a1,80003afe <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b08:	0009a503          	lw	a0,0(s3)
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	8a4080e7          	jalr	-1884(ra) # 800033b0 <bfree>
    80003b14:	b7ed                	j	80003afe <itrunc+0x74>
    brelse(bp);
    80003b16:	8552                	mv	a0,s4
    80003b18:	fffff097          	auipc	ra,0xfffff
    80003b1c:	784080e7          	jalr	1924(ra) # 8000329c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b20:	0809a583          	lw	a1,128(s3)
    80003b24:	0009a503          	lw	a0,0(s3)
    80003b28:	00000097          	auipc	ra,0x0
    80003b2c:	888080e7          	jalr	-1912(ra) # 800033b0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b30:	0809a023          	sw	zero,128(s3)
    80003b34:	bf51                	j	80003ac8 <itrunc+0x3e>

0000000080003b36 <iput>:
{
    80003b36:	1101                	add	sp,sp,-32
    80003b38:	ec06                	sd	ra,24(sp)
    80003b3a:	e822                	sd	s0,16(sp)
    80003b3c:	e426                	sd	s1,8(sp)
    80003b3e:	e04a                	sd	s2,0(sp)
    80003b40:	1000                	add	s0,sp,32
    80003b42:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b44:	0001c517          	auipc	a0,0x1c
    80003b48:	ccc50513          	add	a0,a0,-820 # 8001f810 <itable>
    80003b4c:	ffffd097          	auipc	ra,0xffffd
    80003b50:	086080e7          	jalr	134(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b54:	4498                	lw	a4,8(s1)
    80003b56:	4785                	li	a5,1
    80003b58:	02f70363          	beq	a4,a5,80003b7e <iput+0x48>
  ip->ref--;
    80003b5c:	449c                	lw	a5,8(s1)
    80003b5e:	37fd                	addw	a5,a5,-1
    80003b60:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b62:	0001c517          	auipc	a0,0x1c
    80003b66:	cae50513          	add	a0,a0,-850 # 8001f810 <itable>
    80003b6a:	ffffd097          	auipc	ra,0xffffd
    80003b6e:	11c080e7          	jalr	284(ra) # 80000c86 <release>
}
    80003b72:	60e2                	ld	ra,24(sp)
    80003b74:	6442                	ld	s0,16(sp)
    80003b76:	64a2                	ld	s1,8(sp)
    80003b78:	6902                	ld	s2,0(sp)
    80003b7a:	6105                	add	sp,sp,32
    80003b7c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b7e:	40bc                	lw	a5,64(s1)
    80003b80:	dff1                	beqz	a5,80003b5c <iput+0x26>
    80003b82:	04a49783          	lh	a5,74(s1)
    80003b86:	fbf9                	bnez	a5,80003b5c <iput+0x26>
    acquiresleep(&ip->lock);
    80003b88:	01048913          	add	s2,s1,16
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	00001097          	auipc	ra,0x1
    80003b92:	a84080e7          	jalr	-1404(ra) # 80004612 <acquiresleep>
    release(&itable.lock);
    80003b96:	0001c517          	auipc	a0,0x1c
    80003b9a:	c7a50513          	add	a0,a0,-902 # 8001f810 <itable>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	0e8080e7          	jalr	232(ra) # 80000c86 <release>
    itrunc(ip);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	ee2080e7          	jalr	-286(ra) # 80003a8a <itrunc>
    ip->type = 0;
    80003bb0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	00000097          	auipc	ra,0x0
    80003bba:	cfa080e7          	jalr	-774(ra) # 800038b0 <iupdate>
    ip->valid = 0;
    80003bbe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bc2:	854a                	mv	a0,s2
    80003bc4:	00001097          	auipc	ra,0x1
    80003bc8:	aa4080e7          	jalr	-1372(ra) # 80004668 <releasesleep>
    acquire(&itable.lock);
    80003bcc:	0001c517          	auipc	a0,0x1c
    80003bd0:	c4450513          	add	a0,a0,-956 # 8001f810 <itable>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	ffe080e7          	jalr	-2(ra) # 80000bd2 <acquire>
    80003bdc:	b741                	j	80003b5c <iput+0x26>

0000000080003bde <iunlockput>:
{
    80003bde:	1101                	add	sp,sp,-32
    80003be0:	ec06                	sd	ra,24(sp)
    80003be2:	e822                	sd	s0,16(sp)
    80003be4:	e426                	sd	s1,8(sp)
    80003be6:	1000                	add	s0,sp,32
    80003be8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	e54080e7          	jalr	-428(ra) # 80003a3e <iunlock>
  iput(ip);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	f42080e7          	jalr	-190(ra) # 80003b36 <iput>
}
    80003bfc:	60e2                	ld	ra,24(sp)
    80003bfe:	6442                	ld	s0,16(sp)
    80003c00:	64a2                	ld	s1,8(sp)
    80003c02:	6105                	add	sp,sp,32
    80003c04:	8082                	ret

0000000080003c06 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c06:	1141                	add	sp,sp,-16
    80003c08:	e422                	sd	s0,8(sp)
    80003c0a:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003c0c:	411c                	lw	a5,0(a0)
    80003c0e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c10:	415c                	lw	a5,4(a0)
    80003c12:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c14:	04451783          	lh	a5,68(a0)
    80003c18:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c1c:	04a51783          	lh	a5,74(a0)
    80003c20:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c24:	04c56783          	lwu	a5,76(a0)
    80003c28:	e99c                	sd	a5,16(a1)
}
    80003c2a:	6422                	ld	s0,8(sp)
    80003c2c:	0141                	add	sp,sp,16
    80003c2e:	8082                	ret

0000000080003c30 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c30:	457c                	lw	a5,76(a0)
    80003c32:	0ed7e963          	bltu	a5,a3,80003d24 <readi+0xf4>
{
    80003c36:	7159                	add	sp,sp,-112
    80003c38:	f486                	sd	ra,104(sp)
    80003c3a:	f0a2                	sd	s0,96(sp)
    80003c3c:	eca6                	sd	s1,88(sp)
    80003c3e:	e8ca                	sd	s2,80(sp)
    80003c40:	e4ce                	sd	s3,72(sp)
    80003c42:	e0d2                	sd	s4,64(sp)
    80003c44:	fc56                	sd	s5,56(sp)
    80003c46:	f85a                	sd	s6,48(sp)
    80003c48:	f45e                	sd	s7,40(sp)
    80003c4a:	f062                	sd	s8,32(sp)
    80003c4c:	ec66                	sd	s9,24(sp)
    80003c4e:	e86a                	sd	s10,16(sp)
    80003c50:	e46e                	sd	s11,8(sp)
    80003c52:	1880                	add	s0,sp,112
    80003c54:	8b2a                	mv	s6,a0
    80003c56:	8bae                	mv	s7,a1
    80003c58:	8a32                	mv	s4,a2
    80003c5a:	84b6                	mv	s1,a3
    80003c5c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c5e:	9f35                	addw	a4,a4,a3
    return 0;
    80003c60:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c62:	0ad76063          	bltu	a4,a3,80003d02 <readi+0xd2>
  if(off + n > ip->size)
    80003c66:	00e7f463          	bgeu	a5,a4,80003c6e <readi+0x3e>
    n = ip->size - off;
    80003c6a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c6e:	0a0a8963          	beqz	s5,80003d20 <readi+0xf0>
    80003c72:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c74:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c78:	5c7d                	li	s8,-1
    80003c7a:	a82d                	j	80003cb4 <readi+0x84>
    80003c7c:	020d1d93          	sll	s11,s10,0x20
    80003c80:	020ddd93          	srl	s11,s11,0x20
    80003c84:	05890613          	add	a2,s2,88
    80003c88:	86ee                	mv	a3,s11
    80003c8a:	963a                	add	a2,a2,a4
    80003c8c:	85d2                	mv	a1,s4
    80003c8e:	855e                	mv	a0,s7
    80003c90:	ffffe097          	auipc	ra,0xffffe
    80003c94:	7c6080e7          	jalr	1990(ra) # 80002456 <either_copyout>
    80003c98:	05850d63          	beq	a0,s8,80003cf2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c9c:	854a                	mv	a0,s2
    80003c9e:	fffff097          	auipc	ra,0xfffff
    80003ca2:	5fe080e7          	jalr	1534(ra) # 8000329c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ca6:	013d09bb          	addw	s3,s10,s3
    80003caa:	009d04bb          	addw	s1,s10,s1
    80003cae:	9a6e                	add	s4,s4,s11
    80003cb0:	0559f763          	bgeu	s3,s5,80003cfe <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cb4:	00a4d59b          	srlw	a1,s1,0xa
    80003cb8:	855a                	mv	a0,s6
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	8a4080e7          	jalr	-1884(ra) # 8000355e <bmap>
    80003cc2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003cc6:	cd85                	beqz	a1,80003cfe <readi+0xce>
    bp = bread(ip->dev, addr);
    80003cc8:	000b2503          	lw	a0,0(s6)
    80003ccc:	fffff097          	auipc	ra,0xfffff
    80003cd0:	4a0080e7          	jalr	1184(ra) # 8000316c <bread>
    80003cd4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd6:	3ff4f713          	and	a4,s1,1023
    80003cda:	40ec87bb          	subw	a5,s9,a4
    80003cde:	413a86bb          	subw	a3,s5,s3
    80003ce2:	8d3e                	mv	s10,a5
    80003ce4:	2781                	sext.w	a5,a5
    80003ce6:	0006861b          	sext.w	a2,a3
    80003cea:	f8f679e3          	bgeu	a2,a5,80003c7c <readi+0x4c>
    80003cee:	8d36                	mv	s10,a3
    80003cf0:	b771                	j	80003c7c <readi+0x4c>
      brelse(bp);
    80003cf2:	854a                	mv	a0,s2
    80003cf4:	fffff097          	auipc	ra,0xfffff
    80003cf8:	5a8080e7          	jalr	1448(ra) # 8000329c <brelse>
      tot = -1;
    80003cfc:	59fd                	li	s3,-1
  }
  return tot;
    80003cfe:	0009851b          	sext.w	a0,s3
}
    80003d02:	70a6                	ld	ra,104(sp)
    80003d04:	7406                	ld	s0,96(sp)
    80003d06:	64e6                	ld	s1,88(sp)
    80003d08:	6946                	ld	s2,80(sp)
    80003d0a:	69a6                	ld	s3,72(sp)
    80003d0c:	6a06                	ld	s4,64(sp)
    80003d0e:	7ae2                	ld	s5,56(sp)
    80003d10:	7b42                	ld	s6,48(sp)
    80003d12:	7ba2                	ld	s7,40(sp)
    80003d14:	7c02                	ld	s8,32(sp)
    80003d16:	6ce2                	ld	s9,24(sp)
    80003d18:	6d42                	ld	s10,16(sp)
    80003d1a:	6da2                	ld	s11,8(sp)
    80003d1c:	6165                	add	sp,sp,112
    80003d1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d20:	89d6                	mv	s3,s5
    80003d22:	bff1                	j	80003cfe <readi+0xce>
    return 0;
    80003d24:	4501                	li	a0,0
}
    80003d26:	8082                	ret

0000000080003d28 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d28:	457c                	lw	a5,76(a0)
    80003d2a:	10d7e863          	bltu	a5,a3,80003e3a <writei+0x112>
{
    80003d2e:	7159                	add	sp,sp,-112
    80003d30:	f486                	sd	ra,104(sp)
    80003d32:	f0a2                	sd	s0,96(sp)
    80003d34:	eca6                	sd	s1,88(sp)
    80003d36:	e8ca                	sd	s2,80(sp)
    80003d38:	e4ce                	sd	s3,72(sp)
    80003d3a:	e0d2                	sd	s4,64(sp)
    80003d3c:	fc56                	sd	s5,56(sp)
    80003d3e:	f85a                	sd	s6,48(sp)
    80003d40:	f45e                	sd	s7,40(sp)
    80003d42:	f062                	sd	s8,32(sp)
    80003d44:	ec66                	sd	s9,24(sp)
    80003d46:	e86a                	sd	s10,16(sp)
    80003d48:	e46e                	sd	s11,8(sp)
    80003d4a:	1880                	add	s0,sp,112
    80003d4c:	8aaa                	mv	s5,a0
    80003d4e:	8bae                	mv	s7,a1
    80003d50:	8a32                	mv	s4,a2
    80003d52:	8936                	mv	s2,a3
    80003d54:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d56:	00e687bb          	addw	a5,a3,a4
    80003d5a:	0ed7e263          	bltu	a5,a3,80003e3e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d5e:	00043737          	lui	a4,0x43
    80003d62:	0ef76063          	bltu	a4,a5,80003e42 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d66:	0c0b0863          	beqz	s6,80003e36 <writei+0x10e>
    80003d6a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d6c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d70:	5c7d                	li	s8,-1
    80003d72:	a091                	j	80003db6 <writei+0x8e>
    80003d74:	020d1d93          	sll	s11,s10,0x20
    80003d78:	020ddd93          	srl	s11,s11,0x20
    80003d7c:	05848513          	add	a0,s1,88
    80003d80:	86ee                	mv	a3,s11
    80003d82:	8652                	mv	a2,s4
    80003d84:	85de                	mv	a1,s7
    80003d86:	953a                	add	a0,a0,a4
    80003d88:	ffffe097          	auipc	ra,0xffffe
    80003d8c:	724080e7          	jalr	1828(ra) # 800024ac <either_copyin>
    80003d90:	07850263          	beq	a0,s8,80003df4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d94:	8526                	mv	a0,s1
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	75e080e7          	jalr	1886(ra) # 800044f4 <log_write>
    brelse(bp);
    80003d9e:	8526                	mv	a0,s1
    80003da0:	fffff097          	auipc	ra,0xfffff
    80003da4:	4fc080e7          	jalr	1276(ra) # 8000329c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da8:	013d09bb          	addw	s3,s10,s3
    80003dac:	012d093b          	addw	s2,s10,s2
    80003db0:	9a6e                	add	s4,s4,s11
    80003db2:	0569f663          	bgeu	s3,s6,80003dfe <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003db6:	00a9559b          	srlw	a1,s2,0xa
    80003dba:	8556                	mv	a0,s5
    80003dbc:	fffff097          	auipc	ra,0xfffff
    80003dc0:	7a2080e7          	jalr	1954(ra) # 8000355e <bmap>
    80003dc4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dc8:	c99d                	beqz	a1,80003dfe <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003dca:	000aa503          	lw	a0,0(s5)
    80003dce:	fffff097          	auipc	ra,0xfffff
    80003dd2:	39e080e7          	jalr	926(ra) # 8000316c <bread>
    80003dd6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dd8:	3ff97713          	and	a4,s2,1023
    80003ddc:	40ec87bb          	subw	a5,s9,a4
    80003de0:	413b06bb          	subw	a3,s6,s3
    80003de4:	8d3e                	mv	s10,a5
    80003de6:	2781                	sext.w	a5,a5
    80003de8:	0006861b          	sext.w	a2,a3
    80003dec:	f8f674e3          	bgeu	a2,a5,80003d74 <writei+0x4c>
    80003df0:	8d36                	mv	s10,a3
    80003df2:	b749                	j	80003d74 <writei+0x4c>
      brelse(bp);
    80003df4:	8526                	mv	a0,s1
    80003df6:	fffff097          	auipc	ra,0xfffff
    80003dfa:	4a6080e7          	jalr	1190(ra) # 8000329c <brelse>
  }

  if(off > ip->size)
    80003dfe:	04caa783          	lw	a5,76(s5)
    80003e02:	0127f463          	bgeu	a5,s2,80003e0a <writei+0xe2>
    ip->size = off;
    80003e06:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e0a:	8556                	mv	a0,s5
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	aa4080e7          	jalr	-1372(ra) # 800038b0 <iupdate>

  return tot;
    80003e14:	0009851b          	sext.w	a0,s3
}
    80003e18:	70a6                	ld	ra,104(sp)
    80003e1a:	7406                	ld	s0,96(sp)
    80003e1c:	64e6                	ld	s1,88(sp)
    80003e1e:	6946                	ld	s2,80(sp)
    80003e20:	69a6                	ld	s3,72(sp)
    80003e22:	6a06                	ld	s4,64(sp)
    80003e24:	7ae2                	ld	s5,56(sp)
    80003e26:	7b42                	ld	s6,48(sp)
    80003e28:	7ba2                	ld	s7,40(sp)
    80003e2a:	7c02                	ld	s8,32(sp)
    80003e2c:	6ce2                	ld	s9,24(sp)
    80003e2e:	6d42                	ld	s10,16(sp)
    80003e30:	6da2                	ld	s11,8(sp)
    80003e32:	6165                	add	sp,sp,112
    80003e34:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e36:	89da                	mv	s3,s6
    80003e38:	bfc9                	j	80003e0a <writei+0xe2>
    return -1;
    80003e3a:	557d                	li	a0,-1
}
    80003e3c:	8082                	ret
    return -1;
    80003e3e:	557d                	li	a0,-1
    80003e40:	bfe1                	j	80003e18 <writei+0xf0>
    return -1;
    80003e42:	557d                	li	a0,-1
    80003e44:	bfd1                	j	80003e18 <writei+0xf0>

0000000080003e46 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e46:	1141                	add	sp,sp,-16
    80003e48:	e406                	sd	ra,8(sp)
    80003e4a:	e022                	sd	s0,0(sp)
    80003e4c:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e4e:	4639                	li	a2,14
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	f4e080e7          	jalr	-178(ra) # 80000d9e <strncmp>
}
    80003e58:	60a2                	ld	ra,8(sp)
    80003e5a:	6402                	ld	s0,0(sp)
    80003e5c:	0141                	add	sp,sp,16
    80003e5e:	8082                	ret

0000000080003e60 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e60:	7139                	add	sp,sp,-64
    80003e62:	fc06                	sd	ra,56(sp)
    80003e64:	f822                	sd	s0,48(sp)
    80003e66:	f426                	sd	s1,40(sp)
    80003e68:	f04a                	sd	s2,32(sp)
    80003e6a:	ec4e                	sd	s3,24(sp)
    80003e6c:	e852                	sd	s4,16(sp)
    80003e6e:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e70:	04451703          	lh	a4,68(a0)
    80003e74:	4785                	li	a5,1
    80003e76:	00f71a63          	bne	a4,a5,80003e8a <dirlookup+0x2a>
    80003e7a:	892a                	mv	s2,a0
    80003e7c:	89ae                	mv	s3,a1
    80003e7e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e80:	457c                	lw	a5,76(a0)
    80003e82:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e84:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e86:	e79d                	bnez	a5,80003eb4 <dirlookup+0x54>
    80003e88:	a8a5                	j	80003f00 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e8a:	00005517          	auipc	a0,0x5
    80003e8e:	8c650513          	add	a0,a0,-1850 # 80008750 <syscalls+0x1a8>
    80003e92:	ffffc097          	auipc	ra,0xffffc
    80003e96:	6aa080e7          	jalr	1706(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003e9a:	00005517          	auipc	a0,0x5
    80003e9e:	8ce50513          	add	a0,a0,-1842 # 80008768 <syscalls+0x1c0>
    80003ea2:	ffffc097          	auipc	ra,0xffffc
    80003ea6:	69a080e7          	jalr	1690(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eaa:	24c1                	addw	s1,s1,16
    80003eac:	04c92783          	lw	a5,76(s2)
    80003eb0:	04f4f763          	bgeu	s1,a5,80003efe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eb4:	4741                	li	a4,16
    80003eb6:	86a6                	mv	a3,s1
    80003eb8:	fc040613          	add	a2,s0,-64
    80003ebc:	4581                	li	a1,0
    80003ebe:	854a                	mv	a0,s2
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	d70080e7          	jalr	-656(ra) # 80003c30 <readi>
    80003ec8:	47c1                	li	a5,16
    80003eca:	fcf518e3          	bne	a0,a5,80003e9a <dirlookup+0x3a>
    if(de.inum == 0)
    80003ece:	fc045783          	lhu	a5,-64(s0)
    80003ed2:	dfe1                	beqz	a5,80003eaa <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ed4:	fc240593          	add	a1,s0,-62
    80003ed8:	854e                	mv	a0,s3
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	f6c080e7          	jalr	-148(ra) # 80003e46 <namecmp>
    80003ee2:	f561                	bnez	a0,80003eaa <dirlookup+0x4a>
      if(poff)
    80003ee4:	000a0463          	beqz	s4,80003eec <dirlookup+0x8c>
        *poff = off;
    80003ee8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003eec:	fc045583          	lhu	a1,-64(s0)
    80003ef0:	00092503          	lw	a0,0(s2)
    80003ef4:	fffff097          	auipc	ra,0xfffff
    80003ef8:	754080e7          	jalr	1876(ra) # 80003648 <iget>
    80003efc:	a011                	j	80003f00 <dirlookup+0xa0>
  return 0;
    80003efe:	4501                	li	a0,0
}
    80003f00:	70e2                	ld	ra,56(sp)
    80003f02:	7442                	ld	s0,48(sp)
    80003f04:	74a2                	ld	s1,40(sp)
    80003f06:	7902                	ld	s2,32(sp)
    80003f08:	69e2                	ld	s3,24(sp)
    80003f0a:	6a42                	ld	s4,16(sp)
    80003f0c:	6121                	add	sp,sp,64
    80003f0e:	8082                	ret

0000000080003f10 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f10:	711d                	add	sp,sp,-96
    80003f12:	ec86                	sd	ra,88(sp)
    80003f14:	e8a2                	sd	s0,80(sp)
    80003f16:	e4a6                	sd	s1,72(sp)
    80003f18:	e0ca                	sd	s2,64(sp)
    80003f1a:	fc4e                	sd	s3,56(sp)
    80003f1c:	f852                	sd	s4,48(sp)
    80003f1e:	f456                	sd	s5,40(sp)
    80003f20:	f05a                	sd	s6,32(sp)
    80003f22:	ec5e                	sd	s7,24(sp)
    80003f24:	e862                	sd	s8,16(sp)
    80003f26:	e466                	sd	s9,8(sp)
    80003f28:	1080                	add	s0,sp,96
    80003f2a:	84aa                	mv	s1,a0
    80003f2c:	8b2e                	mv	s6,a1
    80003f2e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f30:	00054703          	lbu	a4,0(a0)
    80003f34:	02f00793          	li	a5,47
    80003f38:	02f70263          	beq	a4,a5,80003f5c <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f3c:	ffffe097          	auipc	ra,0xffffe
    80003f40:	a6a080e7          	jalr	-1430(ra) # 800019a6 <myproc>
    80003f44:	15053503          	ld	a0,336(a0)
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	9f6080e7          	jalr	-1546(ra) # 8000393e <idup>
    80003f50:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003f52:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003f56:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f58:	4b85                	li	s7,1
    80003f5a:	a875                	j	80004016 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003f5c:	4585                	li	a1,1
    80003f5e:	4505                	li	a0,1
    80003f60:	fffff097          	auipc	ra,0xfffff
    80003f64:	6e8080e7          	jalr	1768(ra) # 80003648 <iget>
    80003f68:	8a2a                	mv	s4,a0
    80003f6a:	b7e5                	j	80003f52 <namex+0x42>
      iunlockput(ip);
    80003f6c:	8552                	mv	a0,s4
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	c70080e7          	jalr	-912(ra) # 80003bde <iunlockput>
      return 0;
    80003f76:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f78:	8552                	mv	a0,s4
    80003f7a:	60e6                	ld	ra,88(sp)
    80003f7c:	6446                	ld	s0,80(sp)
    80003f7e:	64a6                	ld	s1,72(sp)
    80003f80:	6906                	ld	s2,64(sp)
    80003f82:	79e2                	ld	s3,56(sp)
    80003f84:	7a42                	ld	s4,48(sp)
    80003f86:	7aa2                	ld	s5,40(sp)
    80003f88:	7b02                	ld	s6,32(sp)
    80003f8a:	6be2                	ld	s7,24(sp)
    80003f8c:	6c42                	ld	s8,16(sp)
    80003f8e:	6ca2                	ld	s9,8(sp)
    80003f90:	6125                	add	sp,sp,96
    80003f92:	8082                	ret
      iunlock(ip);
    80003f94:	8552                	mv	a0,s4
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	aa8080e7          	jalr	-1368(ra) # 80003a3e <iunlock>
      return ip;
    80003f9e:	bfe9                	j	80003f78 <namex+0x68>
      iunlockput(ip);
    80003fa0:	8552                	mv	a0,s4
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	c3c080e7          	jalr	-964(ra) # 80003bde <iunlockput>
      return 0;
    80003faa:	8a4e                	mv	s4,s3
    80003fac:	b7f1                	j	80003f78 <namex+0x68>
  len = path - s;
    80003fae:	40998633          	sub	a2,s3,s1
    80003fb2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fb6:	099c5863          	bge	s8,s9,80004046 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003fba:	4639                	li	a2,14
    80003fbc:	85a6                	mv	a1,s1
    80003fbe:	8556                	mv	a0,s5
    80003fc0:	ffffd097          	auipc	ra,0xffffd
    80003fc4:	d6a080e7          	jalr	-662(ra) # 80000d2a <memmove>
    80003fc8:	84ce                	mv	s1,s3
  while(*path == '/')
    80003fca:	0004c783          	lbu	a5,0(s1)
    80003fce:	01279763          	bne	a5,s2,80003fdc <namex+0xcc>
    path++;
    80003fd2:	0485                	add	s1,s1,1
  while(*path == '/')
    80003fd4:	0004c783          	lbu	a5,0(s1)
    80003fd8:	ff278de3          	beq	a5,s2,80003fd2 <namex+0xc2>
    ilock(ip);
    80003fdc:	8552                	mv	a0,s4
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	99e080e7          	jalr	-1634(ra) # 8000397c <ilock>
    if(ip->type != T_DIR){
    80003fe6:	044a1783          	lh	a5,68(s4)
    80003fea:	f97791e3          	bne	a5,s7,80003f6c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003fee:	000b0563          	beqz	s6,80003ff8 <namex+0xe8>
    80003ff2:	0004c783          	lbu	a5,0(s1)
    80003ff6:	dfd9                	beqz	a5,80003f94 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ff8:	4601                	li	a2,0
    80003ffa:	85d6                	mv	a1,s5
    80003ffc:	8552                	mv	a0,s4
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	e62080e7          	jalr	-414(ra) # 80003e60 <dirlookup>
    80004006:	89aa                	mv	s3,a0
    80004008:	dd41                	beqz	a0,80003fa0 <namex+0x90>
    iunlockput(ip);
    8000400a:	8552                	mv	a0,s4
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	bd2080e7          	jalr	-1070(ra) # 80003bde <iunlockput>
    ip = next;
    80004014:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004016:	0004c783          	lbu	a5,0(s1)
    8000401a:	01279763          	bne	a5,s2,80004028 <namex+0x118>
    path++;
    8000401e:	0485                	add	s1,s1,1
  while(*path == '/')
    80004020:	0004c783          	lbu	a5,0(s1)
    80004024:	ff278de3          	beq	a5,s2,8000401e <namex+0x10e>
  if(*path == 0)
    80004028:	cb9d                	beqz	a5,8000405e <namex+0x14e>
  while(*path != '/' && *path != 0)
    8000402a:	0004c783          	lbu	a5,0(s1)
    8000402e:	89a6                	mv	s3,s1
  len = path - s;
    80004030:	4c81                	li	s9,0
    80004032:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004034:	01278963          	beq	a5,s2,80004046 <namex+0x136>
    80004038:	dbbd                	beqz	a5,80003fae <namex+0x9e>
    path++;
    8000403a:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    8000403c:	0009c783          	lbu	a5,0(s3)
    80004040:	ff279ce3          	bne	a5,s2,80004038 <namex+0x128>
    80004044:	b7ad                	j	80003fae <namex+0x9e>
    memmove(name, s, len);
    80004046:	2601                	sext.w	a2,a2
    80004048:	85a6                	mv	a1,s1
    8000404a:	8556                	mv	a0,s5
    8000404c:	ffffd097          	auipc	ra,0xffffd
    80004050:	cde080e7          	jalr	-802(ra) # 80000d2a <memmove>
    name[len] = 0;
    80004054:	9cd6                	add	s9,s9,s5
    80004056:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000405a:	84ce                	mv	s1,s3
    8000405c:	b7bd                	j	80003fca <namex+0xba>
  if(nameiparent){
    8000405e:	f00b0de3          	beqz	s6,80003f78 <namex+0x68>
    iput(ip);
    80004062:	8552                	mv	a0,s4
    80004064:	00000097          	auipc	ra,0x0
    80004068:	ad2080e7          	jalr	-1326(ra) # 80003b36 <iput>
    return 0;
    8000406c:	4a01                	li	s4,0
    8000406e:	b729                	j	80003f78 <namex+0x68>

0000000080004070 <dirlink>:
{
    80004070:	7139                	add	sp,sp,-64
    80004072:	fc06                	sd	ra,56(sp)
    80004074:	f822                	sd	s0,48(sp)
    80004076:	f426                	sd	s1,40(sp)
    80004078:	f04a                	sd	s2,32(sp)
    8000407a:	ec4e                	sd	s3,24(sp)
    8000407c:	e852                	sd	s4,16(sp)
    8000407e:	0080                	add	s0,sp,64
    80004080:	892a                	mv	s2,a0
    80004082:	8a2e                	mv	s4,a1
    80004084:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004086:	4601                	li	a2,0
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	dd8080e7          	jalr	-552(ra) # 80003e60 <dirlookup>
    80004090:	e93d                	bnez	a0,80004106 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004092:	04c92483          	lw	s1,76(s2)
    80004096:	c49d                	beqz	s1,800040c4 <dirlink+0x54>
    80004098:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000409a:	4741                	li	a4,16
    8000409c:	86a6                	mv	a3,s1
    8000409e:	fc040613          	add	a2,s0,-64
    800040a2:	4581                	li	a1,0
    800040a4:	854a                	mv	a0,s2
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	b8a080e7          	jalr	-1142(ra) # 80003c30 <readi>
    800040ae:	47c1                	li	a5,16
    800040b0:	06f51163          	bne	a0,a5,80004112 <dirlink+0xa2>
    if(de.inum == 0)
    800040b4:	fc045783          	lhu	a5,-64(s0)
    800040b8:	c791                	beqz	a5,800040c4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ba:	24c1                	addw	s1,s1,16
    800040bc:	04c92783          	lw	a5,76(s2)
    800040c0:	fcf4ede3          	bltu	s1,a5,8000409a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040c4:	4639                	li	a2,14
    800040c6:	85d2                	mv	a1,s4
    800040c8:	fc240513          	add	a0,s0,-62
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	d0e080e7          	jalr	-754(ra) # 80000dda <strncpy>
  de.inum = inum;
    800040d4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040d8:	4741                	li	a4,16
    800040da:	86a6                	mv	a3,s1
    800040dc:	fc040613          	add	a2,s0,-64
    800040e0:	4581                	li	a1,0
    800040e2:	854a                	mv	a0,s2
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	c44080e7          	jalr	-956(ra) # 80003d28 <writei>
    800040ec:	1541                	add	a0,a0,-16
    800040ee:	00a03533          	snez	a0,a0
    800040f2:	40a00533          	neg	a0,a0
}
    800040f6:	70e2                	ld	ra,56(sp)
    800040f8:	7442                	ld	s0,48(sp)
    800040fa:	74a2                	ld	s1,40(sp)
    800040fc:	7902                	ld	s2,32(sp)
    800040fe:	69e2                	ld	s3,24(sp)
    80004100:	6a42                	ld	s4,16(sp)
    80004102:	6121                	add	sp,sp,64
    80004104:	8082                	ret
    iput(ip);
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	a30080e7          	jalr	-1488(ra) # 80003b36 <iput>
    return -1;
    8000410e:	557d                	li	a0,-1
    80004110:	b7dd                	j	800040f6 <dirlink+0x86>
      panic("dirlink read");
    80004112:	00004517          	auipc	a0,0x4
    80004116:	66650513          	add	a0,a0,1638 # 80008778 <syscalls+0x1d0>
    8000411a:	ffffc097          	auipc	ra,0xffffc
    8000411e:	422080e7          	jalr	1058(ra) # 8000053c <panic>

0000000080004122 <namei>:

struct inode*
namei(char *path)
{
    80004122:	1101                	add	sp,sp,-32
    80004124:	ec06                	sd	ra,24(sp)
    80004126:	e822                	sd	s0,16(sp)
    80004128:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000412a:	fe040613          	add	a2,s0,-32
    8000412e:	4581                	li	a1,0
    80004130:	00000097          	auipc	ra,0x0
    80004134:	de0080e7          	jalr	-544(ra) # 80003f10 <namex>
}
    80004138:	60e2                	ld	ra,24(sp)
    8000413a:	6442                	ld	s0,16(sp)
    8000413c:	6105                	add	sp,sp,32
    8000413e:	8082                	ret

0000000080004140 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004140:	1141                	add	sp,sp,-16
    80004142:	e406                	sd	ra,8(sp)
    80004144:	e022                	sd	s0,0(sp)
    80004146:	0800                	add	s0,sp,16
    80004148:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000414a:	4585                	li	a1,1
    8000414c:	00000097          	auipc	ra,0x0
    80004150:	dc4080e7          	jalr	-572(ra) # 80003f10 <namex>
}
    80004154:	60a2                	ld	ra,8(sp)
    80004156:	6402                	ld	s0,0(sp)
    80004158:	0141                	add	sp,sp,16
    8000415a:	8082                	ret

000000008000415c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000415c:	1101                	add	sp,sp,-32
    8000415e:	ec06                	sd	ra,24(sp)
    80004160:	e822                	sd	s0,16(sp)
    80004162:	e426                	sd	s1,8(sp)
    80004164:	e04a                	sd	s2,0(sp)
    80004166:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004168:	0001d917          	auipc	s2,0x1d
    8000416c:	15090913          	add	s2,s2,336 # 800212b8 <log>
    80004170:	01892583          	lw	a1,24(s2)
    80004174:	02892503          	lw	a0,40(s2)
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	ff4080e7          	jalr	-12(ra) # 8000316c <bread>
    80004180:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004182:	02c92603          	lw	a2,44(s2)
    80004186:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004188:	00c05f63          	blez	a2,800041a6 <write_head+0x4a>
    8000418c:	0001d717          	auipc	a4,0x1d
    80004190:	15c70713          	add	a4,a4,348 # 800212e8 <log+0x30>
    80004194:	87aa                	mv	a5,a0
    80004196:	060a                	sll	a2,a2,0x2
    80004198:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000419a:	4314                	lw	a3,0(a4)
    8000419c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000419e:	0711                	add	a4,a4,4
    800041a0:	0791                	add	a5,a5,4
    800041a2:	fec79ce3          	bne	a5,a2,8000419a <write_head+0x3e>
  }
  bwrite(buf);
    800041a6:	8526                	mv	a0,s1
    800041a8:	fffff097          	auipc	ra,0xfffff
    800041ac:	0b6080e7          	jalr	182(ra) # 8000325e <bwrite>
  brelse(buf);
    800041b0:	8526                	mv	a0,s1
    800041b2:	fffff097          	auipc	ra,0xfffff
    800041b6:	0ea080e7          	jalr	234(ra) # 8000329c <brelse>
}
    800041ba:	60e2                	ld	ra,24(sp)
    800041bc:	6442                	ld	s0,16(sp)
    800041be:	64a2                	ld	s1,8(sp)
    800041c0:	6902                	ld	s2,0(sp)
    800041c2:	6105                	add	sp,sp,32
    800041c4:	8082                	ret

00000000800041c6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c6:	0001d797          	auipc	a5,0x1d
    800041ca:	11e7a783          	lw	a5,286(a5) # 800212e4 <log+0x2c>
    800041ce:	0af05d63          	blez	a5,80004288 <install_trans+0xc2>
{
    800041d2:	7139                	add	sp,sp,-64
    800041d4:	fc06                	sd	ra,56(sp)
    800041d6:	f822                	sd	s0,48(sp)
    800041d8:	f426                	sd	s1,40(sp)
    800041da:	f04a                	sd	s2,32(sp)
    800041dc:	ec4e                	sd	s3,24(sp)
    800041de:	e852                	sd	s4,16(sp)
    800041e0:	e456                	sd	s5,8(sp)
    800041e2:	e05a                	sd	s6,0(sp)
    800041e4:	0080                	add	s0,sp,64
    800041e6:	8b2a                	mv	s6,a0
    800041e8:	0001da97          	auipc	s5,0x1d
    800041ec:	100a8a93          	add	s5,s5,256 # 800212e8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041f2:	0001d997          	auipc	s3,0x1d
    800041f6:	0c698993          	add	s3,s3,198 # 800212b8 <log>
    800041fa:	a00d                	j	8000421c <install_trans+0x56>
    brelse(lbuf);
    800041fc:	854a                	mv	a0,s2
    800041fe:	fffff097          	auipc	ra,0xfffff
    80004202:	09e080e7          	jalr	158(ra) # 8000329c <brelse>
    brelse(dbuf);
    80004206:	8526                	mv	a0,s1
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	094080e7          	jalr	148(ra) # 8000329c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004210:	2a05                	addw	s4,s4,1
    80004212:	0a91                	add	s5,s5,4
    80004214:	02c9a783          	lw	a5,44(s3)
    80004218:	04fa5e63          	bge	s4,a5,80004274 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000421c:	0189a583          	lw	a1,24(s3)
    80004220:	014585bb          	addw	a1,a1,s4
    80004224:	2585                	addw	a1,a1,1
    80004226:	0289a503          	lw	a0,40(s3)
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	f42080e7          	jalr	-190(ra) # 8000316c <bread>
    80004232:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004234:	000aa583          	lw	a1,0(s5)
    80004238:	0289a503          	lw	a0,40(s3)
    8000423c:	fffff097          	auipc	ra,0xfffff
    80004240:	f30080e7          	jalr	-208(ra) # 8000316c <bread>
    80004244:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004246:	40000613          	li	a2,1024
    8000424a:	05890593          	add	a1,s2,88
    8000424e:	05850513          	add	a0,a0,88
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	ad8080e7          	jalr	-1320(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000425a:	8526                	mv	a0,s1
    8000425c:	fffff097          	auipc	ra,0xfffff
    80004260:	002080e7          	jalr	2(ra) # 8000325e <bwrite>
    if(recovering == 0)
    80004264:	f80b1ce3          	bnez	s6,800041fc <install_trans+0x36>
      bunpin(dbuf);
    80004268:	8526                	mv	a0,s1
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	10a080e7          	jalr	266(ra) # 80003374 <bunpin>
    80004272:	b769                	j	800041fc <install_trans+0x36>
}
    80004274:	70e2                	ld	ra,56(sp)
    80004276:	7442                	ld	s0,48(sp)
    80004278:	74a2                	ld	s1,40(sp)
    8000427a:	7902                	ld	s2,32(sp)
    8000427c:	69e2                	ld	s3,24(sp)
    8000427e:	6a42                	ld	s4,16(sp)
    80004280:	6aa2                	ld	s5,8(sp)
    80004282:	6b02                	ld	s6,0(sp)
    80004284:	6121                	add	sp,sp,64
    80004286:	8082                	ret
    80004288:	8082                	ret

000000008000428a <initlog>:
{
    8000428a:	7179                	add	sp,sp,-48
    8000428c:	f406                	sd	ra,40(sp)
    8000428e:	f022                	sd	s0,32(sp)
    80004290:	ec26                	sd	s1,24(sp)
    80004292:	e84a                	sd	s2,16(sp)
    80004294:	e44e                	sd	s3,8(sp)
    80004296:	1800                	add	s0,sp,48
    80004298:	892a                	mv	s2,a0
    8000429a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000429c:	0001d497          	auipc	s1,0x1d
    800042a0:	01c48493          	add	s1,s1,28 # 800212b8 <log>
    800042a4:	00004597          	auipc	a1,0x4
    800042a8:	4e458593          	add	a1,a1,1252 # 80008788 <syscalls+0x1e0>
    800042ac:	8526                	mv	a0,s1
    800042ae:	ffffd097          	auipc	ra,0xffffd
    800042b2:	894080e7          	jalr	-1900(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800042b6:	0149a583          	lw	a1,20(s3)
    800042ba:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042bc:	0109a783          	lw	a5,16(s3)
    800042c0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042c2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042c6:	854a                	mv	a0,s2
    800042c8:	fffff097          	auipc	ra,0xfffff
    800042cc:	ea4080e7          	jalr	-348(ra) # 8000316c <bread>
  log.lh.n = lh->n;
    800042d0:	4d30                	lw	a2,88(a0)
    800042d2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042d4:	00c05f63          	blez	a2,800042f2 <initlog+0x68>
    800042d8:	87aa                	mv	a5,a0
    800042da:	0001d717          	auipc	a4,0x1d
    800042de:	00e70713          	add	a4,a4,14 # 800212e8 <log+0x30>
    800042e2:	060a                	sll	a2,a2,0x2
    800042e4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800042e6:	4ff4                	lw	a3,92(a5)
    800042e8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042ea:	0791                	add	a5,a5,4
    800042ec:	0711                	add	a4,a4,4
    800042ee:	fec79ce3          	bne	a5,a2,800042e6 <initlog+0x5c>
  brelse(buf);
    800042f2:	fffff097          	auipc	ra,0xfffff
    800042f6:	faa080e7          	jalr	-86(ra) # 8000329c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042fa:	4505                	li	a0,1
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	eca080e7          	jalr	-310(ra) # 800041c6 <install_trans>
  log.lh.n = 0;
    80004304:	0001d797          	auipc	a5,0x1d
    80004308:	fe07a023          	sw	zero,-32(a5) # 800212e4 <log+0x2c>
  write_head(); // clear the log
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	e50080e7          	jalr	-432(ra) # 8000415c <write_head>
}
    80004314:	70a2                	ld	ra,40(sp)
    80004316:	7402                	ld	s0,32(sp)
    80004318:	64e2                	ld	s1,24(sp)
    8000431a:	6942                	ld	s2,16(sp)
    8000431c:	69a2                	ld	s3,8(sp)
    8000431e:	6145                	add	sp,sp,48
    80004320:	8082                	ret

0000000080004322 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004322:	1101                	add	sp,sp,-32
    80004324:	ec06                	sd	ra,24(sp)
    80004326:	e822                	sd	s0,16(sp)
    80004328:	e426                	sd	s1,8(sp)
    8000432a:	e04a                	sd	s2,0(sp)
    8000432c:	1000                	add	s0,sp,32
  acquire(&log.lock);
    8000432e:	0001d517          	auipc	a0,0x1d
    80004332:	f8a50513          	add	a0,a0,-118 # 800212b8 <log>
    80004336:	ffffd097          	auipc	ra,0xffffd
    8000433a:	89c080e7          	jalr	-1892(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000433e:	0001d497          	auipc	s1,0x1d
    80004342:	f7a48493          	add	s1,s1,-134 # 800212b8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004346:	4979                	li	s2,30
    80004348:	a039                	j	80004356 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000434a:	85a6                	mv	a1,s1
    8000434c:	8526                	mv	a0,s1
    8000434e:	ffffe097          	auipc	ra,0xffffe
    80004352:	d00080e7          	jalr	-768(ra) # 8000204e <sleep>
    if(log.committing){
    80004356:	50dc                	lw	a5,36(s1)
    80004358:	fbed                	bnez	a5,8000434a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000435a:	5098                	lw	a4,32(s1)
    8000435c:	2705                	addw	a4,a4,1
    8000435e:	0027179b          	sllw	a5,a4,0x2
    80004362:	9fb9                	addw	a5,a5,a4
    80004364:	0017979b          	sllw	a5,a5,0x1
    80004368:	54d4                	lw	a3,44(s1)
    8000436a:	9fb5                	addw	a5,a5,a3
    8000436c:	00f95963          	bge	s2,a5,8000437e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004370:	85a6                	mv	a1,s1
    80004372:	8526                	mv	a0,s1
    80004374:	ffffe097          	auipc	ra,0xffffe
    80004378:	cda080e7          	jalr	-806(ra) # 8000204e <sleep>
    8000437c:	bfe9                	j	80004356 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000437e:	0001d517          	auipc	a0,0x1d
    80004382:	f3a50513          	add	a0,a0,-198 # 800212b8 <log>
    80004386:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	8fe080e7          	jalr	-1794(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004390:	60e2                	ld	ra,24(sp)
    80004392:	6442                	ld	s0,16(sp)
    80004394:	64a2                	ld	s1,8(sp)
    80004396:	6902                	ld	s2,0(sp)
    80004398:	6105                	add	sp,sp,32
    8000439a:	8082                	ret

000000008000439c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000439c:	7139                	add	sp,sp,-64
    8000439e:	fc06                	sd	ra,56(sp)
    800043a0:	f822                	sd	s0,48(sp)
    800043a2:	f426                	sd	s1,40(sp)
    800043a4:	f04a                	sd	s2,32(sp)
    800043a6:	ec4e                	sd	s3,24(sp)
    800043a8:	e852                	sd	s4,16(sp)
    800043aa:	e456                	sd	s5,8(sp)
    800043ac:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043ae:	0001d497          	auipc	s1,0x1d
    800043b2:	f0a48493          	add	s1,s1,-246 # 800212b8 <log>
    800043b6:	8526                	mv	a0,s1
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	81a080e7          	jalr	-2022(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800043c0:	509c                	lw	a5,32(s1)
    800043c2:	37fd                	addw	a5,a5,-1
    800043c4:	0007891b          	sext.w	s2,a5
    800043c8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043ca:	50dc                	lw	a5,36(s1)
    800043cc:	e7b9                	bnez	a5,8000441a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043ce:	04091e63          	bnez	s2,8000442a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043d2:	0001d497          	auipc	s1,0x1d
    800043d6:	ee648493          	add	s1,s1,-282 # 800212b8 <log>
    800043da:	4785                	li	a5,1
    800043dc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043de:	8526                	mv	a0,s1
    800043e0:	ffffd097          	auipc	ra,0xffffd
    800043e4:	8a6080e7          	jalr	-1882(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043e8:	54dc                	lw	a5,44(s1)
    800043ea:	06f04763          	bgtz	a5,80004458 <end_op+0xbc>
    acquire(&log.lock);
    800043ee:	0001d497          	auipc	s1,0x1d
    800043f2:	eca48493          	add	s1,s1,-310 # 800212b8 <log>
    800043f6:	8526                	mv	a0,s1
    800043f8:	ffffc097          	auipc	ra,0xffffc
    800043fc:	7da080e7          	jalr	2010(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004400:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004404:	8526                	mv	a0,s1
    80004406:	ffffe097          	auipc	ra,0xffffe
    8000440a:	cac080e7          	jalr	-852(ra) # 800020b2 <wakeup>
    release(&log.lock);
    8000440e:	8526                	mv	a0,s1
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	876080e7          	jalr	-1930(ra) # 80000c86 <release>
}
    80004418:	a03d                	j	80004446 <end_op+0xaa>
    panic("log.committing");
    8000441a:	00004517          	auipc	a0,0x4
    8000441e:	37650513          	add	a0,a0,886 # 80008790 <syscalls+0x1e8>
    80004422:	ffffc097          	auipc	ra,0xffffc
    80004426:	11a080e7          	jalr	282(ra) # 8000053c <panic>
    wakeup(&log);
    8000442a:	0001d497          	auipc	s1,0x1d
    8000442e:	e8e48493          	add	s1,s1,-370 # 800212b8 <log>
    80004432:	8526                	mv	a0,s1
    80004434:	ffffe097          	auipc	ra,0xffffe
    80004438:	c7e080e7          	jalr	-898(ra) # 800020b2 <wakeup>
  release(&log.lock);
    8000443c:	8526                	mv	a0,s1
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	848080e7          	jalr	-1976(ra) # 80000c86 <release>
}
    80004446:	70e2                	ld	ra,56(sp)
    80004448:	7442                	ld	s0,48(sp)
    8000444a:	74a2                	ld	s1,40(sp)
    8000444c:	7902                	ld	s2,32(sp)
    8000444e:	69e2                	ld	s3,24(sp)
    80004450:	6a42                	ld	s4,16(sp)
    80004452:	6aa2                	ld	s5,8(sp)
    80004454:	6121                	add	sp,sp,64
    80004456:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004458:	0001da97          	auipc	s5,0x1d
    8000445c:	e90a8a93          	add	s5,s5,-368 # 800212e8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004460:	0001da17          	auipc	s4,0x1d
    80004464:	e58a0a13          	add	s4,s4,-424 # 800212b8 <log>
    80004468:	018a2583          	lw	a1,24(s4)
    8000446c:	012585bb          	addw	a1,a1,s2
    80004470:	2585                	addw	a1,a1,1
    80004472:	028a2503          	lw	a0,40(s4)
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	cf6080e7          	jalr	-778(ra) # 8000316c <bread>
    8000447e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004480:	000aa583          	lw	a1,0(s5)
    80004484:	028a2503          	lw	a0,40(s4)
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	ce4080e7          	jalr	-796(ra) # 8000316c <bread>
    80004490:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004492:	40000613          	li	a2,1024
    80004496:	05850593          	add	a1,a0,88
    8000449a:	05848513          	add	a0,s1,88
    8000449e:	ffffd097          	auipc	ra,0xffffd
    800044a2:	88c080e7          	jalr	-1908(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800044a6:	8526                	mv	a0,s1
    800044a8:	fffff097          	auipc	ra,0xfffff
    800044ac:	db6080e7          	jalr	-586(ra) # 8000325e <bwrite>
    brelse(from);
    800044b0:	854e                	mv	a0,s3
    800044b2:	fffff097          	auipc	ra,0xfffff
    800044b6:	dea080e7          	jalr	-534(ra) # 8000329c <brelse>
    brelse(to);
    800044ba:	8526                	mv	a0,s1
    800044bc:	fffff097          	auipc	ra,0xfffff
    800044c0:	de0080e7          	jalr	-544(ra) # 8000329c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c4:	2905                	addw	s2,s2,1
    800044c6:	0a91                	add	s5,s5,4
    800044c8:	02ca2783          	lw	a5,44(s4)
    800044cc:	f8f94ee3          	blt	s2,a5,80004468 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044d0:	00000097          	auipc	ra,0x0
    800044d4:	c8c080e7          	jalr	-884(ra) # 8000415c <write_head>
    install_trans(0); // Now install writes to home locations
    800044d8:	4501                	li	a0,0
    800044da:	00000097          	auipc	ra,0x0
    800044de:	cec080e7          	jalr	-788(ra) # 800041c6 <install_trans>
    log.lh.n = 0;
    800044e2:	0001d797          	auipc	a5,0x1d
    800044e6:	e007a123          	sw	zero,-510(a5) # 800212e4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044ea:	00000097          	auipc	ra,0x0
    800044ee:	c72080e7          	jalr	-910(ra) # 8000415c <write_head>
    800044f2:	bdf5                	j	800043ee <end_op+0x52>

00000000800044f4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044f4:	1101                	add	sp,sp,-32
    800044f6:	ec06                	sd	ra,24(sp)
    800044f8:	e822                	sd	s0,16(sp)
    800044fa:	e426                	sd	s1,8(sp)
    800044fc:	e04a                	sd	s2,0(sp)
    800044fe:	1000                	add	s0,sp,32
    80004500:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004502:	0001d917          	auipc	s2,0x1d
    80004506:	db690913          	add	s2,s2,-586 # 800212b8 <log>
    8000450a:	854a                	mv	a0,s2
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	6c6080e7          	jalr	1734(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004514:	02c92603          	lw	a2,44(s2)
    80004518:	47f5                	li	a5,29
    8000451a:	06c7c563          	blt	a5,a2,80004584 <log_write+0x90>
    8000451e:	0001d797          	auipc	a5,0x1d
    80004522:	db67a783          	lw	a5,-586(a5) # 800212d4 <log+0x1c>
    80004526:	37fd                	addw	a5,a5,-1
    80004528:	04f65e63          	bge	a2,a5,80004584 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000452c:	0001d797          	auipc	a5,0x1d
    80004530:	dac7a783          	lw	a5,-596(a5) # 800212d8 <log+0x20>
    80004534:	06f05063          	blez	a5,80004594 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004538:	4781                	li	a5,0
    8000453a:	06c05563          	blez	a2,800045a4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000453e:	44cc                	lw	a1,12(s1)
    80004540:	0001d717          	auipc	a4,0x1d
    80004544:	da870713          	add	a4,a4,-600 # 800212e8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004548:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000454a:	4314                	lw	a3,0(a4)
    8000454c:	04b68c63          	beq	a3,a1,800045a4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004550:	2785                	addw	a5,a5,1
    80004552:	0711                	add	a4,a4,4
    80004554:	fef61be3          	bne	a2,a5,8000454a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004558:	0621                	add	a2,a2,8
    8000455a:	060a                	sll	a2,a2,0x2
    8000455c:	0001d797          	auipc	a5,0x1d
    80004560:	d5c78793          	add	a5,a5,-676 # 800212b8 <log>
    80004564:	97b2                	add	a5,a5,a2
    80004566:	44d8                	lw	a4,12(s1)
    80004568:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000456a:	8526                	mv	a0,s1
    8000456c:	fffff097          	auipc	ra,0xfffff
    80004570:	dcc080e7          	jalr	-564(ra) # 80003338 <bpin>
    log.lh.n++;
    80004574:	0001d717          	auipc	a4,0x1d
    80004578:	d4470713          	add	a4,a4,-700 # 800212b8 <log>
    8000457c:	575c                	lw	a5,44(a4)
    8000457e:	2785                	addw	a5,a5,1
    80004580:	d75c                	sw	a5,44(a4)
    80004582:	a82d                	j	800045bc <log_write+0xc8>
    panic("too big a transaction");
    80004584:	00004517          	auipc	a0,0x4
    80004588:	21c50513          	add	a0,a0,540 # 800087a0 <syscalls+0x1f8>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	fb0080e7          	jalr	-80(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004594:	00004517          	auipc	a0,0x4
    80004598:	22450513          	add	a0,a0,548 # 800087b8 <syscalls+0x210>
    8000459c:	ffffc097          	auipc	ra,0xffffc
    800045a0:	fa0080e7          	jalr	-96(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800045a4:	00878693          	add	a3,a5,8
    800045a8:	068a                	sll	a3,a3,0x2
    800045aa:	0001d717          	auipc	a4,0x1d
    800045ae:	d0e70713          	add	a4,a4,-754 # 800212b8 <log>
    800045b2:	9736                	add	a4,a4,a3
    800045b4:	44d4                	lw	a3,12(s1)
    800045b6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045b8:	faf609e3          	beq	a2,a5,8000456a <log_write+0x76>
  }
  release(&log.lock);
    800045bc:	0001d517          	auipc	a0,0x1d
    800045c0:	cfc50513          	add	a0,a0,-772 # 800212b8 <log>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	6c2080e7          	jalr	1730(ra) # 80000c86 <release>
}
    800045cc:	60e2                	ld	ra,24(sp)
    800045ce:	6442                	ld	s0,16(sp)
    800045d0:	64a2                	ld	s1,8(sp)
    800045d2:	6902                	ld	s2,0(sp)
    800045d4:	6105                	add	sp,sp,32
    800045d6:	8082                	ret

00000000800045d8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045d8:	1101                	add	sp,sp,-32
    800045da:	ec06                	sd	ra,24(sp)
    800045dc:	e822                	sd	s0,16(sp)
    800045de:	e426                	sd	s1,8(sp)
    800045e0:	e04a                	sd	s2,0(sp)
    800045e2:	1000                	add	s0,sp,32
    800045e4:	84aa                	mv	s1,a0
    800045e6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045e8:	00004597          	auipc	a1,0x4
    800045ec:	1f058593          	add	a1,a1,496 # 800087d8 <syscalls+0x230>
    800045f0:	0521                	add	a0,a0,8
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	550080e7          	jalr	1360(ra) # 80000b42 <initlock>
  lk->name = name;
    800045fa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004602:	0204a423          	sw	zero,40(s1)
}
    80004606:	60e2                	ld	ra,24(sp)
    80004608:	6442                	ld	s0,16(sp)
    8000460a:	64a2                	ld	s1,8(sp)
    8000460c:	6902                	ld	s2,0(sp)
    8000460e:	6105                	add	sp,sp,32
    80004610:	8082                	ret

0000000080004612 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004612:	1101                	add	sp,sp,-32
    80004614:	ec06                	sd	ra,24(sp)
    80004616:	e822                	sd	s0,16(sp)
    80004618:	e426                	sd	s1,8(sp)
    8000461a:	e04a                	sd	s2,0(sp)
    8000461c:	1000                	add	s0,sp,32
    8000461e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004620:	00850913          	add	s2,a0,8
    80004624:	854a                	mv	a0,s2
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	5ac080e7          	jalr	1452(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000462e:	409c                	lw	a5,0(s1)
    80004630:	cb89                	beqz	a5,80004642 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004632:	85ca                	mv	a1,s2
    80004634:	8526                	mv	a0,s1
    80004636:	ffffe097          	auipc	ra,0xffffe
    8000463a:	a18080e7          	jalr	-1512(ra) # 8000204e <sleep>
  while (lk->locked) {
    8000463e:	409c                	lw	a5,0(s1)
    80004640:	fbed                	bnez	a5,80004632 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004642:	4785                	li	a5,1
    80004644:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004646:	ffffd097          	auipc	ra,0xffffd
    8000464a:	360080e7          	jalr	864(ra) # 800019a6 <myproc>
    8000464e:	591c                	lw	a5,48(a0)
    80004650:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004652:	854a                	mv	a0,s2
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	632080e7          	jalr	1586(ra) # 80000c86 <release>
}
    8000465c:	60e2                	ld	ra,24(sp)
    8000465e:	6442                	ld	s0,16(sp)
    80004660:	64a2                	ld	s1,8(sp)
    80004662:	6902                	ld	s2,0(sp)
    80004664:	6105                	add	sp,sp,32
    80004666:	8082                	ret

0000000080004668 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004668:	1101                	add	sp,sp,-32
    8000466a:	ec06                	sd	ra,24(sp)
    8000466c:	e822                	sd	s0,16(sp)
    8000466e:	e426                	sd	s1,8(sp)
    80004670:	e04a                	sd	s2,0(sp)
    80004672:	1000                	add	s0,sp,32
    80004674:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004676:	00850913          	add	s2,a0,8
    8000467a:	854a                	mv	a0,s2
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	556080e7          	jalr	1366(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004684:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004688:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000468c:	8526                	mv	a0,s1
    8000468e:	ffffe097          	auipc	ra,0xffffe
    80004692:	a24080e7          	jalr	-1500(ra) # 800020b2 <wakeup>
  release(&lk->lk);
    80004696:	854a                	mv	a0,s2
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	5ee080e7          	jalr	1518(ra) # 80000c86 <release>
}
    800046a0:	60e2                	ld	ra,24(sp)
    800046a2:	6442                	ld	s0,16(sp)
    800046a4:	64a2                	ld	s1,8(sp)
    800046a6:	6902                	ld	s2,0(sp)
    800046a8:	6105                	add	sp,sp,32
    800046aa:	8082                	ret

00000000800046ac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046ac:	7179                	add	sp,sp,-48
    800046ae:	f406                	sd	ra,40(sp)
    800046b0:	f022                	sd	s0,32(sp)
    800046b2:	ec26                	sd	s1,24(sp)
    800046b4:	e84a                	sd	s2,16(sp)
    800046b6:	e44e                	sd	s3,8(sp)
    800046b8:	1800                	add	s0,sp,48
    800046ba:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046bc:	00850913          	add	s2,a0,8
    800046c0:	854a                	mv	a0,s2
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	510080e7          	jalr	1296(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046ca:	409c                	lw	a5,0(s1)
    800046cc:	ef99                	bnez	a5,800046ea <holdingsleep+0x3e>
    800046ce:	4481                	li	s1,0
  release(&lk->lk);
    800046d0:	854a                	mv	a0,s2
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	5b4080e7          	jalr	1460(ra) # 80000c86 <release>
  return r;
}
    800046da:	8526                	mv	a0,s1
    800046dc:	70a2                	ld	ra,40(sp)
    800046de:	7402                	ld	s0,32(sp)
    800046e0:	64e2                	ld	s1,24(sp)
    800046e2:	6942                	ld	s2,16(sp)
    800046e4:	69a2                	ld	s3,8(sp)
    800046e6:	6145                	add	sp,sp,48
    800046e8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046ea:	0284a983          	lw	s3,40(s1)
    800046ee:	ffffd097          	auipc	ra,0xffffd
    800046f2:	2b8080e7          	jalr	696(ra) # 800019a6 <myproc>
    800046f6:	5904                	lw	s1,48(a0)
    800046f8:	413484b3          	sub	s1,s1,s3
    800046fc:	0014b493          	seqz	s1,s1
    80004700:	bfc1                	j	800046d0 <holdingsleep+0x24>

0000000080004702 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004702:	1141                	add	sp,sp,-16
    80004704:	e406                	sd	ra,8(sp)
    80004706:	e022                	sd	s0,0(sp)
    80004708:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000470a:	00004597          	auipc	a1,0x4
    8000470e:	0de58593          	add	a1,a1,222 # 800087e8 <syscalls+0x240>
    80004712:	0001d517          	auipc	a0,0x1d
    80004716:	cee50513          	add	a0,a0,-786 # 80021400 <ftable>
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	428080e7          	jalr	1064(ra) # 80000b42 <initlock>
}
    80004722:	60a2                	ld	ra,8(sp)
    80004724:	6402                	ld	s0,0(sp)
    80004726:	0141                	add	sp,sp,16
    80004728:	8082                	ret

000000008000472a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000472a:	1101                	add	sp,sp,-32
    8000472c:	ec06                	sd	ra,24(sp)
    8000472e:	e822                	sd	s0,16(sp)
    80004730:	e426                	sd	s1,8(sp)
    80004732:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004734:	0001d517          	auipc	a0,0x1d
    80004738:	ccc50513          	add	a0,a0,-820 # 80021400 <ftable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	496080e7          	jalr	1174(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004744:	0001d497          	auipc	s1,0x1d
    80004748:	cd448493          	add	s1,s1,-812 # 80021418 <ftable+0x18>
    8000474c:	0001e717          	auipc	a4,0x1e
    80004750:	c6c70713          	add	a4,a4,-916 # 800223b8 <disk>
    if(f->ref == 0){
    80004754:	40dc                	lw	a5,4(s1)
    80004756:	cf99                	beqz	a5,80004774 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004758:	02848493          	add	s1,s1,40
    8000475c:	fee49ce3          	bne	s1,a4,80004754 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004760:	0001d517          	auipc	a0,0x1d
    80004764:	ca050513          	add	a0,a0,-864 # 80021400 <ftable>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	51e080e7          	jalr	1310(ra) # 80000c86 <release>
  return 0;
    80004770:	4481                	li	s1,0
    80004772:	a819                	j	80004788 <filealloc+0x5e>
      f->ref = 1;
    80004774:	4785                	li	a5,1
    80004776:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004778:	0001d517          	auipc	a0,0x1d
    8000477c:	c8850513          	add	a0,a0,-888 # 80021400 <ftable>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	506080e7          	jalr	1286(ra) # 80000c86 <release>
}
    80004788:	8526                	mv	a0,s1
    8000478a:	60e2                	ld	ra,24(sp)
    8000478c:	6442                	ld	s0,16(sp)
    8000478e:	64a2                	ld	s1,8(sp)
    80004790:	6105                	add	sp,sp,32
    80004792:	8082                	ret

0000000080004794 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004794:	1101                	add	sp,sp,-32
    80004796:	ec06                	sd	ra,24(sp)
    80004798:	e822                	sd	s0,16(sp)
    8000479a:	e426                	sd	s1,8(sp)
    8000479c:	1000                	add	s0,sp,32
    8000479e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047a0:	0001d517          	auipc	a0,0x1d
    800047a4:	c6050513          	add	a0,a0,-928 # 80021400 <ftable>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	42a080e7          	jalr	1066(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800047b0:	40dc                	lw	a5,4(s1)
    800047b2:	02f05263          	blez	a5,800047d6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047b6:	2785                	addw	a5,a5,1
    800047b8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047ba:	0001d517          	auipc	a0,0x1d
    800047be:	c4650513          	add	a0,a0,-954 # 80021400 <ftable>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	4c4080e7          	jalr	1220(ra) # 80000c86 <release>
  return f;
}
    800047ca:	8526                	mv	a0,s1
    800047cc:	60e2                	ld	ra,24(sp)
    800047ce:	6442                	ld	s0,16(sp)
    800047d0:	64a2                	ld	s1,8(sp)
    800047d2:	6105                	add	sp,sp,32
    800047d4:	8082                	ret
    panic("filedup");
    800047d6:	00004517          	auipc	a0,0x4
    800047da:	01a50513          	add	a0,a0,26 # 800087f0 <syscalls+0x248>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	d5e080e7          	jalr	-674(ra) # 8000053c <panic>

00000000800047e6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047e6:	7139                	add	sp,sp,-64
    800047e8:	fc06                	sd	ra,56(sp)
    800047ea:	f822                	sd	s0,48(sp)
    800047ec:	f426                	sd	s1,40(sp)
    800047ee:	f04a                	sd	s2,32(sp)
    800047f0:	ec4e                	sd	s3,24(sp)
    800047f2:	e852                	sd	s4,16(sp)
    800047f4:	e456                	sd	s5,8(sp)
    800047f6:	0080                	add	s0,sp,64
    800047f8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047fa:	0001d517          	auipc	a0,0x1d
    800047fe:	c0650513          	add	a0,a0,-1018 # 80021400 <ftable>
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	3d0080e7          	jalr	976(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000480a:	40dc                	lw	a5,4(s1)
    8000480c:	06f05163          	blez	a5,8000486e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004810:	37fd                	addw	a5,a5,-1
    80004812:	0007871b          	sext.w	a4,a5
    80004816:	c0dc                	sw	a5,4(s1)
    80004818:	06e04363          	bgtz	a4,8000487e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000481c:	0004a903          	lw	s2,0(s1)
    80004820:	0094ca83          	lbu	s5,9(s1)
    80004824:	0104ba03          	ld	s4,16(s1)
    80004828:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000482c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004830:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004834:	0001d517          	auipc	a0,0x1d
    80004838:	bcc50513          	add	a0,a0,-1076 # 80021400 <ftable>
    8000483c:	ffffc097          	auipc	ra,0xffffc
    80004840:	44a080e7          	jalr	1098(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004844:	4785                	li	a5,1
    80004846:	04f90d63          	beq	s2,a5,800048a0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000484a:	3979                	addw	s2,s2,-2
    8000484c:	4785                	li	a5,1
    8000484e:	0527e063          	bltu	a5,s2,8000488e <fileclose+0xa8>
    begin_op();
    80004852:	00000097          	auipc	ra,0x0
    80004856:	ad0080e7          	jalr	-1328(ra) # 80004322 <begin_op>
    iput(ff.ip);
    8000485a:	854e                	mv	a0,s3
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	2da080e7          	jalr	730(ra) # 80003b36 <iput>
    end_op();
    80004864:	00000097          	auipc	ra,0x0
    80004868:	b38080e7          	jalr	-1224(ra) # 8000439c <end_op>
    8000486c:	a00d                	j	8000488e <fileclose+0xa8>
    panic("fileclose");
    8000486e:	00004517          	auipc	a0,0x4
    80004872:	f8a50513          	add	a0,a0,-118 # 800087f8 <syscalls+0x250>
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	cc6080e7          	jalr	-826(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000487e:	0001d517          	auipc	a0,0x1d
    80004882:	b8250513          	add	a0,a0,-1150 # 80021400 <ftable>
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	400080e7          	jalr	1024(ra) # 80000c86 <release>
  }
}
    8000488e:	70e2                	ld	ra,56(sp)
    80004890:	7442                	ld	s0,48(sp)
    80004892:	74a2                	ld	s1,40(sp)
    80004894:	7902                	ld	s2,32(sp)
    80004896:	69e2                	ld	s3,24(sp)
    80004898:	6a42                	ld	s4,16(sp)
    8000489a:	6aa2                	ld	s5,8(sp)
    8000489c:	6121                	add	sp,sp,64
    8000489e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048a0:	85d6                	mv	a1,s5
    800048a2:	8552                	mv	a0,s4
    800048a4:	00000097          	auipc	ra,0x0
    800048a8:	348080e7          	jalr	840(ra) # 80004bec <pipeclose>
    800048ac:	b7cd                	j	8000488e <fileclose+0xa8>

00000000800048ae <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048ae:	715d                	add	sp,sp,-80
    800048b0:	e486                	sd	ra,72(sp)
    800048b2:	e0a2                	sd	s0,64(sp)
    800048b4:	fc26                	sd	s1,56(sp)
    800048b6:	f84a                	sd	s2,48(sp)
    800048b8:	f44e                	sd	s3,40(sp)
    800048ba:	0880                	add	s0,sp,80
    800048bc:	84aa                	mv	s1,a0
    800048be:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048c0:	ffffd097          	auipc	ra,0xffffd
    800048c4:	0e6080e7          	jalr	230(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048c8:	409c                	lw	a5,0(s1)
    800048ca:	37f9                	addw	a5,a5,-2
    800048cc:	4705                	li	a4,1
    800048ce:	04f76763          	bltu	a4,a5,8000491c <filestat+0x6e>
    800048d2:	892a                	mv	s2,a0
    ilock(f->ip);
    800048d4:	6c88                	ld	a0,24(s1)
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	0a6080e7          	jalr	166(ra) # 8000397c <ilock>
    stati(f->ip, &st);
    800048de:	fb840593          	add	a1,s0,-72
    800048e2:	6c88                	ld	a0,24(s1)
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	322080e7          	jalr	802(ra) # 80003c06 <stati>
    iunlock(f->ip);
    800048ec:	6c88                	ld	a0,24(s1)
    800048ee:	fffff097          	auipc	ra,0xfffff
    800048f2:	150080e7          	jalr	336(ra) # 80003a3e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048f6:	46e1                	li	a3,24
    800048f8:	fb840613          	add	a2,s0,-72
    800048fc:	85ce                	mv	a1,s3
    800048fe:	05093503          	ld	a0,80(s2)
    80004902:	ffffd097          	auipc	ra,0xffffd
    80004906:	d64080e7          	jalr	-668(ra) # 80001666 <copyout>
    8000490a:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000490e:	60a6                	ld	ra,72(sp)
    80004910:	6406                	ld	s0,64(sp)
    80004912:	74e2                	ld	s1,56(sp)
    80004914:	7942                	ld	s2,48(sp)
    80004916:	79a2                	ld	s3,40(sp)
    80004918:	6161                	add	sp,sp,80
    8000491a:	8082                	ret
  return -1;
    8000491c:	557d                	li	a0,-1
    8000491e:	bfc5                	j	8000490e <filestat+0x60>

0000000080004920 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004920:	7179                	add	sp,sp,-48
    80004922:	f406                	sd	ra,40(sp)
    80004924:	f022                	sd	s0,32(sp)
    80004926:	ec26                	sd	s1,24(sp)
    80004928:	e84a                	sd	s2,16(sp)
    8000492a:	e44e                	sd	s3,8(sp)
    8000492c:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000492e:	00854783          	lbu	a5,8(a0)
    80004932:	c3d5                	beqz	a5,800049d6 <fileread+0xb6>
    80004934:	84aa                	mv	s1,a0
    80004936:	89ae                	mv	s3,a1
    80004938:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000493a:	411c                	lw	a5,0(a0)
    8000493c:	4705                	li	a4,1
    8000493e:	04e78963          	beq	a5,a4,80004990 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004942:	470d                	li	a4,3
    80004944:	04e78d63          	beq	a5,a4,8000499e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004948:	4709                	li	a4,2
    8000494a:	06e79e63          	bne	a5,a4,800049c6 <fileread+0xa6>
    ilock(f->ip);
    8000494e:	6d08                	ld	a0,24(a0)
    80004950:	fffff097          	auipc	ra,0xfffff
    80004954:	02c080e7          	jalr	44(ra) # 8000397c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004958:	874a                	mv	a4,s2
    8000495a:	5094                	lw	a3,32(s1)
    8000495c:	864e                	mv	a2,s3
    8000495e:	4585                	li	a1,1
    80004960:	6c88                	ld	a0,24(s1)
    80004962:	fffff097          	auipc	ra,0xfffff
    80004966:	2ce080e7          	jalr	718(ra) # 80003c30 <readi>
    8000496a:	892a                	mv	s2,a0
    8000496c:	00a05563          	blez	a0,80004976 <fileread+0x56>
      f->off += r;
    80004970:	509c                	lw	a5,32(s1)
    80004972:	9fa9                	addw	a5,a5,a0
    80004974:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004976:	6c88                	ld	a0,24(s1)
    80004978:	fffff097          	auipc	ra,0xfffff
    8000497c:	0c6080e7          	jalr	198(ra) # 80003a3e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004980:	854a                	mv	a0,s2
    80004982:	70a2                	ld	ra,40(sp)
    80004984:	7402                	ld	s0,32(sp)
    80004986:	64e2                	ld	s1,24(sp)
    80004988:	6942                	ld	s2,16(sp)
    8000498a:	69a2                	ld	s3,8(sp)
    8000498c:	6145                	add	sp,sp,48
    8000498e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004990:	6908                	ld	a0,16(a0)
    80004992:	00000097          	auipc	ra,0x0
    80004996:	3c2080e7          	jalr	962(ra) # 80004d54 <piperead>
    8000499a:	892a                	mv	s2,a0
    8000499c:	b7d5                	j	80004980 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000499e:	02451783          	lh	a5,36(a0)
    800049a2:	03079693          	sll	a3,a5,0x30
    800049a6:	92c1                	srl	a3,a3,0x30
    800049a8:	4725                	li	a4,9
    800049aa:	02d76863          	bltu	a4,a3,800049da <fileread+0xba>
    800049ae:	0792                	sll	a5,a5,0x4
    800049b0:	0001d717          	auipc	a4,0x1d
    800049b4:	9b070713          	add	a4,a4,-1616 # 80021360 <devsw>
    800049b8:	97ba                	add	a5,a5,a4
    800049ba:	639c                	ld	a5,0(a5)
    800049bc:	c38d                	beqz	a5,800049de <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049be:	4505                	li	a0,1
    800049c0:	9782                	jalr	a5
    800049c2:	892a                	mv	s2,a0
    800049c4:	bf75                	j	80004980 <fileread+0x60>
    panic("fileread");
    800049c6:	00004517          	auipc	a0,0x4
    800049ca:	e4250513          	add	a0,a0,-446 # 80008808 <syscalls+0x260>
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	b6e080e7          	jalr	-1170(ra) # 8000053c <panic>
    return -1;
    800049d6:	597d                	li	s2,-1
    800049d8:	b765                	j	80004980 <fileread+0x60>
      return -1;
    800049da:	597d                	li	s2,-1
    800049dc:	b755                	j	80004980 <fileread+0x60>
    800049de:	597d                	li	s2,-1
    800049e0:	b745                	j	80004980 <fileread+0x60>

00000000800049e2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049e2:	00954783          	lbu	a5,9(a0)
    800049e6:	10078e63          	beqz	a5,80004b02 <filewrite+0x120>
{
    800049ea:	715d                	add	sp,sp,-80
    800049ec:	e486                	sd	ra,72(sp)
    800049ee:	e0a2                	sd	s0,64(sp)
    800049f0:	fc26                	sd	s1,56(sp)
    800049f2:	f84a                	sd	s2,48(sp)
    800049f4:	f44e                	sd	s3,40(sp)
    800049f6:	f052                	sd	s4,32(sp)
    800049f8:	ec56                	sd	s5,24(sp)
    800049fa:	e85a                	sd	s6,16(sp)
    800049fc:	e45e                	sd	s7,8(sp)
    800049fe:	e062                	sd	s8,0(sp)
    80004a00:	0880                	add	s0,sp,80
    80004a02:	892a                	mv	s2,a0
    80004a04:	8b2e                	mv	s6,a1
    80004a06:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a08:	411c                	lw	a5,0(a0)
    80004a0a:	4705                	li	a4,1
    80004a0c:	02e78263          	beq	a5,a4,80004a30 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a10:	470d                	li	a4,3
    80004a12:	02e78563          	beq	a5,a4,80004a3c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a16:	4709                	li	a4,2
    80004a18:	0ce79d63          	bne	a5,a4,80004af2 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a1c:	0ac05b63          	blez	a2,80004ad2 <filewrite+0xf0>
    int i = 0;
    80004a20:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004a22:	6b85                	lui	s7,0x1
    80004a24:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a28:	6c05                	lui	s8,0x1
    80004a2a:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004a2e:	a851                	j	80004ac2 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a30:	6908                	ld	a0,16(a0)
    80004a32:	00000097          	auipc	ra,0x0
    80004a36:	22a080e7          	jalr	554(ra) # 80004c5c <pipewrite>
    80004a3a:	a045                	j	80004ada <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a3c:	02451783          	lh	a5,36(a0)
    80004a40:	03079693          	sll	a3,a5,0x30
    80004a44:	92c1                	srl	a3,a3,0x30
    80004a46:	4725                	li	a4,9
    80004a48:	0ad76f63          	bltu	a4,a3,80004b06 <filewrite+0x124>
    80004a4c:	0792                	sll	a5,a5,0x4
    80004a4e:	0001d717          	auipc	a4,0x1d
    80004a52:	91270713          	add	a4,a4,-1774 # 80021360 <devsw>
    80004a56:	97ba                	add	a5,a5,a4
    80004a58:	679c                	ld	a5,8(a5)
    80004a5a:	cbc5                	beqz	a5,80004b0a <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004a5c:	4505                	li	a0,1
    80004a5e:	9782                	jalr	a5
    80004a60:	a8ad                	j	80004ada <filewrite+0xf8>
      if(n1 > max)
    80004a62:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004a66:	00000097          	auipc	ra,0x0
    80004a6a:	8bc080e7          	jalr	-1860(ra) # 80004322 <begin_op>
      ilock(f->ip);
    80004a6e:	01893503          	ld	a0,24(s2)
    80004a72:	fffff097          	auipc	ra,0xfffff
    80004a76:	f0a080e7          	jalr	-246(ra) # 8000397c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a7a:	8756                	mv	a4,s5
    80004a7c:	02092683          	lw	a3,32(s2)
    80004a80:	01698633          	add	a2,s3,s6
    80004a84:	4585                	li	a1,1
    80004a86:	01893503          	ld	a0,24(s2)
    80004a8a:	fffff097          	auipc	ra,0xfffff
    80004a8e:	29e080e7          	jalr	670(ra) # 80003d28 <writei>
    80004a92:	84aa                	mv	s1,a0
    80004a94:	00a05763          	blez	a0,80004aa2 <filewrite+0xc0>
        f->off += r;
    80004a98:	02092783          	lw	a5,32(s2)
    80004a9c:	9fa9                	addw	a5,a5,a0
    80004a9e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004aa2:	01893503          	ld	a0,24(s2)
    80004aa6:	fffff097          	auipc	ra,0xfffff
    80004aaa:	f98080e7          	jalr	-104(ra) # 80003a3e <iunlock>
      end_op();
    80004aae:	00000097          	auipc	ra,0x0
    80004ab2:	8ee080e7          	jalr	-1810(ra) # 8000439c <end_op>

      if(r != n1){
    80004ab6:	009a9f63          	bne	s5,s1,80004ad4 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004aba:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004abe:	0149db63          	bge	s3,s4,80004ad4 <filewrite+0xf2>
      int n1 = n - i;
    80004ac2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004ac6:	0004879b          	sext.w	a5,s1
    80004aca:	f8fbdce3          	bge	s7,a5,80004a62 <filewrite+0x80>
    80004ace:	84e2                	mv	s1,s8
    80004ad0:	bf49                	j	80004a62 <filewrite+0x80>
    int i = 0;
    80004ad2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ad4:	033a1d63          	bne	s4,s3,80004b0e <filewrite+0x12c>
    80004ad8:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ada:	60a6                	ld	ra,72(sp)
    80004adc:	6406                	ld	s0,64(sp)
    80004ade:	74e2                	ld	s1,56(sp)
    80004ae0:	7942                	ld	s2,48(sp)
    80004ae2:	79a2                	ld	s3,40(sp)
    80004ae4:	7a02                	ld	s4,32(sp)
    80004ae6:	6ae2                	ld	s5,24(sp)
    80004ae8:	6b42                	ld	s6,16(sp)
    80004aea:	6ba2                	ld	s7,8(sp)
    80004aec:	6c02                	ld	s8,0(sp)
    80004aee:	6161                	add	sp,sp,80
    80004af0:	8082                	ret
    panic("filewrite");
    80004af2:	00004517          	auipc	a0,0x4
    80004af6:	d2650513          	add	a0,a0,-730 # 80008818 <syscalls+0x270>
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	a42080e7          	jalr	-1470(ra) # 8000053c <panic>
    return -1;
    80004b02:	557d                	li	a0,-1
}
    80004b04:	8082                	ret
      return -1;
    80004b06:	557d                	li	a0,-1
    80004b08:	bfc9                	j	80004ada <filewrite+0xf8>
    80004b0a:	557d                	li	a0,-1
    80004b0c:	b7f9                	j	80004ada <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004b0e:	557d                	li	a0,-1
    80004b10:	b7e9                	j	80004ada <filewrite+0xf8>

0000000080004b12 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b12:	7179                	add	sp,sp,-48
    80004b14:	f406                	sd	ra,40(sp)
    80004b16:	f022                	sd	s0,32(sp)
    80004b18:	ec26                	sd	s1,24(sp)
    80004b1a:	e84a                	sd	s2,16(sp)
    80004b1c:	e44e                	sd	s3,8(sp)
    80004b1e:	e052                	sd	s4,0(sp)
    80004b20:	1800                	add	s0,sp,48
    80004b22:	84aa                	mv	s1,a0
    80004b24:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b26:	0005b023          	sd	zero,0(a1)
    80004b2a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b2e:	00000097          	auipc	ra,0x0
    80004b32:	bfc080e7          	jalr	-1028(ra) # 8000472a <filealloc>
    80004b36:	e088                	sd	a0,0(s1)
    80004b38:	c551                	beqz	a0,80004bc4 <pipealloc+0xb2>
    80004b3a:	00000097          	auipc	ra,0x0
    80004b3e:	bf0080e7          	jalr	-1040(ra) # 8000472a <filealloc>
    80004b42:	00aa3023          	sd	a0,0(s4)
    80004b46:	c92d                	beqz	a0,80004bb8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	f9a080e7          	jalr	-102(ra) # 80000ae2 <kalloc>
    80004b50:	892a                	mv	s2,a0
    80004b52:	c125                	beqz	a0,80004bb2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b54:	4985                	li	s3,1
    80004b56:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b5a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b5e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b62:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b66:	00004597          	auipc	a1,0x4
    80004b6a:	cc258593          	add	a1,a1,-830 # 80008828 <syscalls+0x280>
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	fd4080e7          	jalr	-44(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004b76:	609c                	ld	a5,0(s1)
    80004b78:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b7c:	609c                	ld	a5,0(s1)
    80004b7e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b82:	609c                	ld	a5,0(s1)
    80004b84:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b88:	609c                	ld	a5,0(s1)
    80004b8a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b8e:	000a3783          	ld	a5,0(s4)
    80004b92:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b96:	000a3783          	ld	a5,0(s4)
    80004b9a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b9e:	000a3783          	ld	a5,0(s4)
    80004ba2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ba6:	000a3783          	ld	a5,0(s4)
    80004baa:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bae:	4501                	li	a0,0
    80004bb0:	a025                	j	80004bd8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bb2:	6088                	ld	a0,0(s1)
    80004bb4:	e501                	bnez	a0,80004bbc <pipealloc+0xaa>
    80004bb6:	a039                	j	80004bc4 <pipealloc+0xb2>
    80004bb8:	6088                	ld	a0,0(s1)
    80004bba:	c51d                	beqz	a0,80004be8 <pipealloc+0xd6>
    fileclose(*f0);
    80004bbc:	00000097          	auipc	ra,0x0
    80004bc0:	c2a080e7          	jalr	-982(ra) # 800047e6 <fileclose>
  if(*f1)
    80004bc4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bc8:	557d                	li	a0,-1
  if(*f1)
    80004bca:	c799                	beqz	a5,80004bd8 <pipealloc+0xc6>
    fileclose(*f1);
    80004bcc:	853e                	mv	a0,a5
    80004bce:	00000097          	auipc	ra,0x0
    80004bd2:	c18080e7          	jalr	-1000(ra) # 800047e6 <fileclose>
  return -1;
    80004bd6:	557d                	li	a0,-1
}
    80004bd8:	70a2                	ld	ra,40(sp)
    80004bda:	7402                	ld	s0,32(sp)
    80004bdc:	64e2                	ld	s1,24(sp)
    80004bde:	6942                	ld	s2,16(sp)
    80004be0:	69a2                	ld	s3,8(sp)
    80004be2:	6a02                	ld	s4,0(sp)
    80004be4:	6145                	add	sp,sp,48
    80004be6:	8082                	ret
  return -1;
    80004be8:	557d                	li	a0,-1
    80004bea:	b7fd                	j	80004bd8 <pipealloc+0xc6>

0000000080004bec <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bec:	1101                	add	sp,sp,-32
    80004bee:	ec06                	sd	ra,24(sp)
    80004bf0:	e822                	sd	s0,16(sp)
    80004bf2:	e426                	sd	s1,8(sp)
    80004bf4:	e04a                	sd	s2,0(sp)
    80004bf6:	1000                	add	s0,sp,32
    80004bf8:	84aa                	mv	s1,a0
    80004bfa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bfc:	ffffc097          	auipc	ra,0xffffc
    80004c00:	fd6080e7          	jalr	-42(ra) # 80000bd2 <acquire>
  if(writable){
    80004c04:	02090d63          	beqz	s2,80004c3e <pipeclose+0x52>
    pi->writeopen = 0;
    80004c08:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c0c:	21848513          	add	a0,s1,536
    80004c10:	ffffd097          	auipc	ra,0xffffd
    80004c14:	4a2080e7          	jalr	1186(ra) # 800020b2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c18:	2204b783          	ld	a5,544(s1)
    80004c1c:	eb95                	bnez	a5,80004c50 <pipeclose+0x64>
    release(&pi->lock);
    80004c1e:	8526                	mv	a0,s1
    80004c20:	ffffc097          	auipc	ra,0xffffc
    80004c24:	066080e7          	jalr	102(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	dba080e7          	jalr	-582(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004c32:	60e2                	ld	ra,24(sp)
    80004c34:	6442                	ld	s0,16(sp)
    80004c36:	64a2                	ld	s1,8(sp)
    80004c38:	6902                	ld	s2,0(sp)
    80004c3a:	6105                	add	sp,sp,32
    80004c3c:	8082                	ret
    pi->readopen = 0;
    80004c3e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c42:	21c48513          	add	a0,s1,540
    80004c46:	ffffd097          	auipc	ra,0xffffd
    80004c4a:	46c080e7          	jalr	1132(ra) # 800020b2 <wakeup>
    80004c4e:	b7e9                	j	80004c18 <pipeclose+0x2c>
    release(&pi->lock);
    80004c50:	8526                	mv	a0,s1
    80004c52:	ffffc097          	auipc	ra,0xffffc
    80004c56:	034080e7          	jalr	52(ra) # 80000c86 <release>
}
    80004c5a:	bfe1                	j	80004c32 <pipeclose+0x46>

0000000080004c5c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c5c:	711d                	add	sp,sp,-96
    80004c5e:	ec86                	sd	ra,88(sp)
    80004c60:	e8a2                	sd	s0,80(sp)
    80004c62:	e4a6                	sd	s1,72(sp)
    80004c64:	e0ca                	sd	s2,64(sp)
    80004c66:	fc4e                	sd	s3,56(sp)
    80004c68:	f852                	sd	s4,48(sp)
    80004c6a:	f456                	sd	s5,40(sp)
    80004c6c:	f05a                	sd	s6,32(sp)
    80004c6e:	ec5e                	sd	s7,24(sp)
    80004c70:	e862                	sd	s8,16(sp)
    80004c72:	1080                	add	s0,sp,96
    80004c74:	84aa                	mv	s1,a0
    80004c76:	8aae                	mv	s5,a1
    80004c78:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	d2c080e7          	jalr	-724(ra) # 800019a6 <myproc>
    80004c82:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	f4c080e7          	jalr	-180(ra) # 80000bd2 <acquire>
  while(i < n){
    80004c8e:	0b405663          	blez	s4,80004d3a <pipewrite+0xde>
  int i = 0;
    80004c92:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c94:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c96:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c9a:	21c48b93          	add	s7,s1,540
    80004c9e:	a089                	j	80004ce0 <pipewrite+0x84>
      release(&pi->lock);
    80004ca0:	8526                	mv	a0,s1
    80004ca2:	ffffc097          	auipc	ra,0xffffc
    80004ca6:	fe4080e7          	jalr	-28(ra) # 80000c86 <release>
      return -1;
    80004caa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cac:	854a                	mv	a0,s2
    80004cae:	60e6                	ld	ra,88(sp)
    80004cb0:	6446                	ld	s0,80(sp)
    80004cb2:	64a6                	ld	s1,72(sp)
    80004cb4:	6906                	ld	s2,64(sp)
    80004cb6:	79e2                	ld	s3,56(sp)
    80004cb8:	7a42                	ld	s4,48(sp)
    80004cba:	7aa2                	ld	s5,40(sp)
    80004cbc:	7b02                	ld	s6,32(sp)
    80004cbe:	6be2                	ld	s7,24(sp)
    80004cc0:	6c42                	ld	s8,16(sp)
    80004cc2:	6125                	add	sp,sp,96
    80004cc4:	8082                	ret
      wakeup(&pi->nread);
    80004cc6:	8562                	mv	a0,s8
    80004cc8:	ffffd097          	auipc	ra,0xffffd
    80004ccc:	3ea080e7          	jalr	1002(ra) # 800020b2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cd0:	85a6                	mv	a1,s1
    80004cd2:	855e                	mv	a0,s7
    80004cd4:	ffffd097          	auipc	ra,0xffffd
    80004cd8:	37a080e7          	jalr	890(ra) # 8000204e <sleep>
  while(i < n){
    80004cdc:	07495063          	bge	s2,s4,80004d3c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ce0:	2204a783          	lw	a5,544(s1)
    80004ce4:	dfd5                	beqz	a5,80004ca0 <pipewrite+0x44>
    80004ce6:	854e                	mv	a0,s3
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	60e080e7          	jalr	1550(ra) # 800022f6 <killed>
    80004cf0:	f945                	bnez	a0,80004ca0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cf2:	2184a783          	lw	a5,536(s1)
    80004cf6:	21c4a703          	lw	a4,540(s1)
    80004cfa:	2007879b          	addw	a5,a5,512
    80004cfe:	fcf704e3          	beq	a4,a5,80004cc6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d02:	4685                	li	a3,1
    80004d04:	01590633          	add	a2,s2,s5
    80004d08:	faf40593          	add	a1,s0,-81
    80004d0c:	0509b503          	ld	a0,80(s3)
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	9e2080e7          	jalr	-1566(ra) # 800016f2 <copyin>
    80004d18:	03650263          	beq	a0,s6,80004d3c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d1c:	21c4a783          	lw	a5,540(s1)
    80004d20:	0017871b          	addw	a4,a5,1
    80004d24:	20e4ae23          	sw	a4,540(s1)
    80004d28:	1ff7f793          	and	a5,a5,511
    80004d2c:	97a6                	add	a5,a5,s1
    80004d2e:	faf44703          	lbu	a4,-81(s0)
    80004d32:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d36:	2905                	addw	s2,s2,1
    80004d38:	b755                	j	80004cdc <pipewrite+0x80>
  int i = 0;
    80004d3a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d3c:	21848513          	add	a0,s1,536
    80004d40:	ffffd097          	auipc	ra,0xffffd
    80004d44:	372080e7          	jalr	882(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	f3c080e7          	jalr	-196(ra) # 80000c86 <release>
  return i;
    80004d52:	bfa9                	j	80004cac <pipewrite+0x50>

0000000080004d54 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d54:	715d                	add	sp,sp,-80
    80004d56:	e486                	sd	ra,72(sp)
    80004d58:	e0a2                	sd	s0,64(sp)
    80004d5a:	fc26                	sd	s1,56(sp)
    80004d5c:	f84a                	sd	s2,48(sp)
    80004d5e:	f44e                	sd	s3,40(sp)
    80004d60:	f052                	sd	s4,32(sp)
    80004d62:	ec56                	sd	s5,24(sp)
    80004d64:	e85a                	sd	s6,16(sp)
    80004d66:	0880                	add	s0,sp,80
    80004d68:	84aa                	mv	s1,a0
    80004d6a:	892e                	mv	s2,a1
    80004d6c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	c38080e7          	jalr	-968(ra) # 800019a6 <myproc>
    80004d76:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d78:	8526                	mv	a0,s1
    80004d7a:	ffffc097          	auipc	ra,0xffffc
    80004d7e:	e58080e7          	jalr	-424(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d82:	2184a703          	lw	a4,536(s1)
    80004d86:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d8a:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d8e:	02f71763          	bne	a4,a5,80004dbc <piperead+0x68>
    80004d92:	2244a783          	lw	a5,548(s1)
    80004d96:	c39d                	beqz	a5,80004dbc <piperead+0x68>
    if(killed(pr)){
    80004d98:	8552                	mv	a0,s4
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	55c080e7          	jalr	1372(ra) # 800022f6 <killed>
    80004da2:	e949                	bnez	a0,80004e34 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004da4:	85a6                	mv	a1,s1
    80004da6:	854e                	mv	a0,s3
    80004da8:	ffffd097          	auipc	ra,0xffffd
    80004dac:	2a6080e7          	jalr	678(ra) # 8000204e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004db0:	2184a703          	lw	a4,536(s1)
    80004db4:	21c4a783          	lw	a5,540(s1)
    80004db8:	fcf70de3          	beq	a4,a5,80004d92 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dbc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dbe:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dc0:	05505463          	blez	s5,80004e08 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004dc4:	2184a783          	lw	a5,536(s1)
    80004dc8:	21c4a703          	lw	a4,540(s1)
    80004dcc:	02f70e63          	beq	a4,a5,80004e08 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dd0:	0017871b          	addw	a4,a5,1
    80004dd4:	20e4ac23          	sw	a4,536(s1)
    80004dd8:	1ff7f793          	and	a5,a5,511
    80004ddc:	97a6                	add	a5,a5,s1
    80004dde:	0187c783          	lbu	a5,24(a5)
    80004de2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004de6:	4685                	li	a3,1
    80004de8:	fbf40613          	add	a2,s0,-65
    80004dec:	85ca                	mv	a1,s2
    80004dee:	050a3503          	ld	a0,80(s4)
    80004df2:	ffffd097          	auipc	ra,0xffffd
    80004df6:	874080e7          	jalr	-1932(ra) # 80001666 <copyout>
    80004dfa:	01650763          	beq	a0,s6,80004e08 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dfe:	2985                	addw	s3,s3,1
    80004e00:	0905                	add	s2,s2,1
    80004e02:	fd3a91e3          	bne	s5,s3,80004dc4 <piperead+0x70>
    80004e06:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e08:	21c48513          	add	a0,s1,540
    80004e0c:	ffffd097          	auipc	ra,0xffffd
    80004e10:	2a6080e7          	jalr	678(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004e14:	8526                	mv	a0,s1
    80004e16:	ffffc097          	auipc	ra,0xffffc
    80004e1a:	e70080e7          	jalr	-400(ra) # 80000c86 <release>
  return i;
}
    80004e1e:	854e                	mv	a0,s3
    80004e20:	60a6                	ld	ra,72(sp)
    80004e22:	6406                	ld	s0,64(sp)
    80004e24:	74e2                	ld	s1,56(sp)
    80004e26:	7942                	ld	s2,48(sp)
    80004e28:	79a2                	ld	s3,40(sp)
    80004e2a:	7a02                	ld	s4,32(sp)
    80004e2c:	6ae2                	ld	s5,24(sp)
    80004e2e:	6b42                	ld	s6,16(sp)
    80004e30:	6161                	add	sp,sp,80
    80004e32:	8082                	ret
      release(&pi->lock);
    80004e34:	8526                	mv	a0,s1
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	e50080e7          	jalr	-432(ra) # 80000c86 <release>
      return -1;
    80004e3e:	59fd                	li	s3,-1
    80004e40:	bff9                	j	80004e1e <piperead+0xca>

0000000080004e42 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e42:	1141                	add	sp,sp,-16
    80004e44:	e422                	sd	s0,8(sp)
    80004e46:	0800                	add	s0,sp,16
    80004e48:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e4a:	8905                	and	a0,a0,1
    80004e4c:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e4e:	8b89                	and	a5,a5,2
    80004e50:	c399                	beqz	a5,80004e56 <flags2perm+0x14>
      perm |= PTE_W;
    80004e52:	00456513          	or	a0,a0,4
    return perm;
}
    80004e56:	6422                	ld	s0,8(sp)
    80004e58:	0141                	add	sp,sp,16
    80004e5a:	8082                	ret

0000000080004e5c <exec>:

int
exec(char *path, char **argv)
{
    80004e5c:	df010113          	add	sp,sp,-528
    80004e60:	20113423          	sd	ra,520(sp)
    80004e64:	20813023          	sd	s0,512(sp)
    80004e68:	ffa6                	sd	s1,504(sp)
    80004e6a:	fbca                	sd	s2,496(sp)
    80004e6c:	f7ce                	sd	s3,488(sp)
    80004e6e:	f3d2                	sd	s4,480(sp)
    80004e70:	efd6                	sd	s5,472(sp)
    80004e72:	ebda                	sd	s6,464(sp)
    80004e74:	e7de                	sd	s7,456(sp)
    80004e76:	e3e2                	sd	s8,448(sp)
    80004e78:	ff66                	sd	s9,440(sp)
    80004e7a:	fb6a                	sd	s10,432(sp)
    80004e7c:	f76e                	sd	s11,424(sp)
    80004e7e:	0c00                	add	s0,sp,528
    80004e80:	892a                	mv	s2,a0
    80004e82:	dea43c23          	sd	a0,-520(s0)
    80004e86:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	b1c080e7          	jalr	-1252(ra) # 800019a6 <myproc>
    80004e92:	84aa                	mv	s1,a0

  begin_op();
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	48e080e7          	jalr	1166(ra) # 80004322 <begin_op>

  if((ip = namei(path)) == 0){
    80004e9c:	854a                	mv	a0,s2
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	284080e7          	jalr	644(ra) # 80004122 <namei>
    80004ea6:	c92d                	beqz	a0,80004f18 <exec+0xbc>
    80004ea8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	ad2080e7          	jalr	-1326(ra) # 8000397c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004eb2:	04000713          	li	a4,64
    80004eb6:	4681                	li	a3,0
    80004eb8:	e5040613          	add	a2,s0,-432
    80004ebc:	4581                	li	a1,0
    80004ebe:	8552                	mv	a0,s4
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	d70080e7          	jalr	-656(ra) # 80003c30 <readi>
    80004ec8:	04000793          	li	a5,64
    80004ecc:	00f51a63          	bne	a0,a5,80004ee0 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ed0:	e5042703          	lw	a4,-432(s0)
    80004ed4:	464c47b7          	lui	a5,0x464c4
    80004ed8:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004edc:	04f70463          	beq	a4,a5,80004f24 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ee0:	8552                	mv	a0,s4
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	cfc080e7          	jalr	-772(ra) # 80003bde <iunlockput>
    end_op();
    80004eea:	fffff097          	auipc	ra,0xfffff
    80004eee:	4b2080e7          	jalr	1202(ra) # 8000439c <end_op>
  }
  return -1;
    80004ef2:	557d                	li	a0,-1
}
    80004ef4:	20813083          	ld	ra,520(sp)
    80004ef8:	20013403          	ld	s0,512(sp)
    80004efc:	74fe                	ld	s1,504(sp)
    80004efe:	795e                	ld	s2,496(sp)
    80004f00:	79be                	ld	s3,488(sp)
    80004f02:	7a1e                	ld	s4,480(sp)
    80004f04:	6afe                	ld	s5,472(sp)
    80004f06:	6b5e                	ld	s6,464(sp)
    80004f08:	6bbe                	ld	s7,456(sp)
    80004f0a:	6c1e                	ld	s8,448(sp)
    80004f0c:	7cfa                	ld	s9,440(sp)
    80004f0e:	7d5a                	ld	s10,432(sp)
    80004f10:	7dba                	ld	s11,424(sp)
    80004f12:	21010113          	add	sp,sp,528
    80004f16:	8082                	ret
    end_op();
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	484080e7          	jalr	1156(ra) # 8000439c <end_op>
    return -1;
    80004f20:	557d                	li	a0,-1
    80004f22:	bfc9                	j	80004ef4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f24:	8526                	mv	a0,s1
    80004f26:	ffffd097          	auipc	ra,0xffffd
    80004f2a:	b44080e7          	jalr	-1212(ra) # 80001a6a <proc_pagetable>
    80004f2e:	8b2a                	mv	s6,a0
    80004f30:	d945                	beqz	a0,80004ee0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f32:	e7042d03          	lw	s10,-400(s0)
    80004f36:	e8845783          	lhu	a5,-376(s0)
    80004f3a:	10078463          	beqz	a5,80005042 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f3e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f40:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004f42:	6c85                	lui	s9,0x1
    80004f44:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f48:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f4c:	6a85                	lui	s5,0x1
    80004f4e:	a0b5                	j	80004fba <exec+0x15e>
      panic("loadseg: address should exist");
    80004f50:	00004517          	auipc	a0,0x4
    80004f54:	8e050513          	add	a0,a0,-1824 # 80008830 <syscalls+0x288>
    80004f58:	ffffb097          	auipc	ra,0xffffb
    80004f5c:	5e4080e7          	jalr	1508(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004f60:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f62:	8726                	mv	a4,s1
    80004f64:	012c06bb          	addw	a3,s8,s2
    80004f68:	4581                	li	a1,0
    80004f6a:	8552                	mv	a0,s4
    80004f6c:	fffff097          	auipc	ra,0xfffff
    80004f70:	cc4080e7          	jalr	-828(ra) # 80003c30 <readi>
    80004f74:	2501                	sext.w	a0,a0
    80004f76:	24a49863          	bne	s1,a0,800051c6 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004f7a:	012a893b          	addw	s2,s5,s2
    80004f7e:	03397563          	bgeu	s2,s3,80004fa8 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004f82:	02091593          	sll	a1,s2,0x20
    80004f86:	9181                	srl	a1,a1,0x20
    80004f88:	95de                	add	a1,a1,s7
    80004f8a:	855a                	mv	a0,s6
    80004f8c:	ffffc097          	auipc	ra,0xffffc
    80004f90:	0ca080e7          	jalr	202(ra) # 80001056 <walkaddr>
    80004f94:	862a                	mv	a2,a0
    if(pa == 0)
    80004f96:	dd4d                	beqz	a0,80004f50 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004f98:	412984bb          	subw	s1,s3,s2
    80004f9c:	0004879b          	sext.w	a5,s1
    80004fa0:	fcfcf0e3          	bgeu	s9,a5,80004f60 <exec+0x104>
    80004fa4:	84d6                	mv	s1,s5
    80004fa6:	bf6d                	j	80004f60 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fa8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fac:	2d85                	addw	s11,s11,1
    80004fae:	038d0d1b          	addw	s10,s10,56
    80004fb2:	e8845783          	lhu	a5,-376(s0)
    80004fb6:	08fdd763          	bge	s11,a5,80005044 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fba:	2d01                	sext.w	s10,s10
    80004fbc:	03800713          	li	a4,56
    80004fc0:	86ea                	mv	a3,s10
    80004fc2:	e1840613          	add	a2,s0,-488
    80004fc6:	4581                	li	a1,0
    80004fc8:	8552                	mv	a0,s4
    80004fca:	fffff097          	auipc	ra,0xfffff
    80004fce:	c66080e7          	jalr	-922(ra) # 80003c30 <readi>
    80004fd2:	03800793          	li	a5,56
    80004fd6:	1ef51663          	bne	a0,a5,800051c2 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004fda:	e1842783          	lw	a5,-488(s0)
    80004fde:	4705                	li	a4,1
    80004fe0:	fce796e3          	bne	a5,a4,80004fac <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004fe4:	e4043483          	ld	s1,-448(s0)
    80004fe8:	e3843783          	ld	a5,-456(s0)
    80004fec:	1ef4e863          	bltu	s1,a5,800051dc <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ff0:	e2843783          	ld	a5,-472(s0)
    80004ff4:	94be                	add	s1,s1,a5
    80004ff6:	1ef4e663          	bltu	s1,a5,800051e2 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004ffa:	df043703          	ld	a4,-528(s0)
    80004ffe:	8ff9                	and	a5,a5,a4
    80005000:	1e079463          	bnez	a5,800051e8 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005004:	e1c42503          	lw	a0,-484(s0)
    80005008:	00000097          	auipc	ra,0x0
    8000500c:	e3a080e7          	jalr	-454(ra) # 80004e42 <flags2perm>
    80005010:	86aa                	mv	a3,a0
    80005012:	8626                	mv	a2,s1
    80005014:	85ca                	mv	a1,s2
    80005016:	855a                	mv	a0,s6
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	3f2080e7          	jalr	1010(ra) # 8000140a <uvmalloc>
    80005020:	e0a43423          	sd	a0,-504(s0)
    80005024:	1c050563          	beqz	a0,800051ee <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005028:	e2843b83          	ld	s7,-472(s0)
    8000502c:	e2042c03          	lw	s8,-480(s0)
    80005030:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005034:	00098463          	beqz	s3,8000503c <exec+0x1e0>
    80005038:	4901                	li	s2,0
    8000503a:	b7a1                	j	80004f82 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000503c:	e0843903          	ld	s2,-504(s0)
    80005040:	b7b5                	j	80004fac <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005042:	4901                	li	s2,0
  iunlockput(ip);
    80005044:	8552                	mv	a0,s4
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	b98080e7          	jalr	-1128(ra) # 80003bde <iunlockput>
  end_op();
    8000504e:	fffff097          	auipc	ra,0xfffff
    80005052:	34e080e7          	jalr	846(ra) # 8000439c <end_op>
  p = myproc();
    80005056:	ffffd097          	auipc	ra,0xffffd
    8000505a:	950080e7          	jalr	-1712(ra) # 800019a6 <myproc>
    8000505e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005060:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005064:	6985                	lui	s3,0x1
    80005066:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005068:	99ca                	add	s3,s3,s2
    8000506a:	77fd                	lui	a5,0xfffff
    8000506c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005070:	4691                	li	a3,4
    80005072:	6609                	lui	a2,0x2
    80005074:	964e                	add	a2,a2,s3
    80005076:	85ce                	mv	a1,s3
    80005078:	855a                	mv	a0,s6
    8000507a:	ffffc097          	auipc	ra,0xffffc
    8000507e:	390080e7          	jalr	912(ra) # 8000140a <uvmalloc>
    80005082:	892a                	mv	s2,a0
    80005084:	e0a43423          	sd	a0,-504(s0)
    80005088:	e509                	bnez	a0,80005092 <exec+0x236>
  if(pagetable)
    8000508a:	e1343423          	sd	s3,-504(s0)
    8000508e:	4a01                	li	s4,0
    80005090:	aa1d                	j	800051c6 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005092:	75f9                	lui	a1,0xffffe
    80005094:	95aa                	add	a1,a1,a0
    80005096:	855a                	mv	a0,s6
    80005098:	ffffc097          	auipc	ra,0xffffc
    8000509c:	59c080e7          	jalr	1436(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    800050a0:	7bfd                	lui	s7,0xfffff
    800050a2:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800050a4:	e0043783          	ld	a5,-512(s0)
    800050a8:	6388                	ld	a0,0(a5)
    800050aa:	c52d                	beqz	a0,80005114 <exec+0x2b8>
    800050ac:	e9040993          	add	s3,s0,-368
    800050b0:	f9040c13          	add	s8,s0,-112
    800050b4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	d92080e7          	jalr	-622(ra) # 80000e48 <strlen>
    800050be:	0015079b          	addw	a5,a0,1
    800050c2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050c6:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    800050ca:	13796563          	bltu	s2,s7,800051f4 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050ce:	e0043d03          	ld	s10,-512(s0)
    800050d2:	000d3a03          	ld	s4,0(s10)
    800050d6:	8552                	mv	a0,s4
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	d70080e7          	jalr	-656(ra) # 80000e48 <strlen>
    800050e0:	0015069b          	addw	a3,a0,1
    800050e4:	8652                	mv	a2,s4
    800050e6:	85ca                	mv	a1,s2
    800050e8:	855a                	mv	a0,s6
    800050ea:	ffffc097          	auipc	ra,0xffffc
    800050ee:	57c080e7          	jalr	1404(ra) # 80001666 <copyout>
    800050f2:	10054363          	bltz	a0,800051f8 <exec+0x39c>
    ustack[argc] = sp;
    800050f6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050fa:	0485                	add	s1,s1,1
    800050fc:	008d0793          	add	a5,s10,8
    80005100:	e0f43023          	sd	a5,-512(s0)
    80005104:	008d3503          	ld	a0,8(s10)
    80005108:	c909                	beqz	a0,8000511a <exec+0x2be>
    if(argc >= MAXARG)
    8000510a:	09a1                	add	s3,s3,8
    8000510c:	fb8995e3          	bne	s3,s8,800050b6 <exec+0x25a>
  ip = 0;
    80005110:	4a01                	li	s4,0
    80005112:	a855                	j	800051c6 <exec+0x36a>
  sp = sz;
    80005114:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005118:	4481                	li	s1,0
  ustack[argc] = 0;
    8000511a:	00349793          	sll	a5,s1,0x3
    8000511e:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdca98>
    80005122:	97a2                	add	a5,a5,s0
    80005124:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005128:	00148693          	add	a3,s1,1
    8000512c:	068e                	sll	a3,a3,0x3
    8000512e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005132:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005136:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000513a:	f57968e3          	bltu	s2,s7,8000508a <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000513e:	e9040613          	add	a2,s0,-368
    80005142:	85ca                	mv	a1,s2
    80005144:	855a                	mv	a0,s6
    80005146:	ffffc097          	auipc	ra,0xffffc
    8000514a:	520080e7          	jalr	1312(ra) # 80001666 <copyout>
    8000514e:	0a054763          	bltz	a0,800051fc <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005152:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005156:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000515a:	df843783          	ld	a5,-520(s0)
    8000515e:	0007c703          	lbu	a4,0(a5)
    80005162:	cf11                	beqz	a4,8000517e <exec+0x322>
    80005164:	0785                	add	a5,a5,1
    if(*s == '/')
    80005166:	02f00693          	li	a3,47
    8000516a:	a039                	j	80005178 <exec+0x31c>
      last = s+1;
    8000516c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005170:	0785                	add	a5,a5,1
    80005172:	fff7c703          	lbu	a4,-1(a5)
    80005176:	c701                	beqz	a4,8000517e <exec+0x322>
    if(*s == '/')
    80005178:	fed71ce3          	bne	a4,a3,80005170 <exec+0x314>
    8000517c:	bfc5                	j	8000516c <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    8000517e:	4641                	li	a2,16
    80005180:	df843583          	ld	a1,-520(s0)
    80005184:	158a8513          	add	a0,s5,344
    80005188:	ffffc097          	auipc	ra,0xffffc
    8000518c:	c8e080e7          	jalr	-882(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80005190:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005194:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005198:	e0843783          	ld	a5,-504(s0)
    8000519c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051a0:	058ab783          	ld	a5,88(s5)
    800051a4:	e6843703          	ld	a4,-408(s0)
    800051a8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051aa:	058ab783          	ld	a5,88(s5)
    800051ae:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051b2:	85e6                	mv	a1,s9
    800051b4:	ffffd097          	auipc	ra,0xffffd
    800051b8:	952080e7          	jalr	-1710(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051bc:	0004851b          	sext.w	a0,s1
    800051c0:	bb15                	j	80004ef4 <exec+0x98>
    800051c2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800051c6:	e0843583          	ld	a1,-504(s0)
    800051ca:	855a                	mv	a0,s6
    800051cc:	ffffd097          	auipc	ra,0xffffd
    800051d0:	93a080e7          	jalr	-1734(ra) # 80001b06 <proc_freepagetable>
  return -1;
    800051d4:	557d                	li	a0,-1
  if(ip){
    800051d6:	d00a0fe3          	beqz	s4,80004ef4 <exec+0x98>
    800051da:	b319                	j	80004ee0 <exec+0x84>
    800051dc:	e1243423          	sd	s2,-504(s0)
    800051e0:	b7dd                	j	800051c6 <exec+0x36a>
    800051e2:	e1243423          	sd	s2,-504(s0)
    800051e6:	b7c5                	j	800051c6 <exec+0x36a>
    800051e8:	e1243423          	sd	s2,-504(s0)
    800051ec:	bfe9                	j	800051c6 <exec+0x36a>
    800051ee:	e1243423          	sd	s2,-504(s0)
    800051f2:	bfd1                	j	800051c6 <exec+0x36a>
  ip = 0;
    800051f4:	4a01                	li	s4,0
    800051f6:	bfc1                	j	800051c6 <exec+0x36a>
    800051f8:	4a01                	li	s4,0
  if(pagetable)
    800051fa:	b7f1                	j	800051c6 <exec+0x36a>
  sz = sz1;
    800051fc:	e0843983          	ld	s3,-504(s0)
    80005200:	b569                	j	8000508a <exec+0x22e>

0000000080005202 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005202:	7179                	add	sp,sp,-48
    80005204:	f406                	sd	ra,40(sp)
    80005206:	f022                	sd	s0,32(sp)
    80005208:	ec26                	sd	s1,24(sp)
    8000520a:	e84a                	sd	s2,16(sp)
    8000520c:	1800                	add	s0,sp,48
    8000520e:	892e                	mv	s2,a1
    80005210:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005212:	fdc40593          	add	a1,s0,-36
    80005216:	ffffe097          	auipc	ra,0xffffe
    8000521a:	bb4080e7          	jalr	-1100(ra) # 80002dca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000521e:	fdc42703          	lw	a4,-36(s0)
    80005222:	47bd                	li	a5,15
    80005224:	02e7eb63          	bltu	a5,a4,8000525a <argfd+0x58>
    80005228:	ffffc097          	auipc	ra,0xffffc
    8000522c:	77e080e7          	jalr	1918(ra) # 800019a6 <myproc>
    80005230:	fdc42703          	lw	a4,-36(s0)
    80005234:	01a70793          	add	a5,a4,26
    80005238:	078e                	sll	a5,a5,0x3
    8000523a:	953e                	add	a0,a0,a5
    8000523c:	611c                	ld	a5,0(a0)
    8000523e:	c385                	beqz	a5,8000525e <argfd+0x5c>
    return -1;
  if(pfd)
    80005240:	00090463          	beqz	s2,80005248 <argfd+0x46>
    *pfd = fd;
    80005244:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005248:	4501                	li	a0,0
  if(pf)
    8000524a:	c091                	beqz	s1,8000524e <argfd+0x4c>
    *pf = f;
    8000524c:	e09c                	sd	a5,0(s1)
}
    8000524e:	70a2                	ld	ra,40(sp)
    80005250:	7402                	ld	s0,32(sp)
    80005252:	64e2                	ld	s1,24(sp)
    80005254:	6942                	ld	s2,16(sp)
    80005256:	6145                	add	sp,sp,48
    80005258:	8082                	ret
    return -1;
    8000525a:	557d                	li	a0,-1
    8000525c:	bfcd                	j	8000524e <argfd+0x4c>
    8000525e:	557d                	li	a0,-1
    80005260:	b7fd                	j	8000524e <argfd+0x4c>

0000000080005262 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005262:	1101                	add	sp,sp,-32
    80005264:	ec06                	sd	ra,24(sp)
    80005266:	e822                	sd	s0,16(sp)
    80005268:	e426                	sd	s1,8(sp)
    8000526a:	1000                	add	s0,sp,32
    8000526c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000526e:	ffffc097          	auipc	ra,0xffffc
    80005272:	738080e7          	jalr	1848(ra) # 800019a6 <myproc>
    80005276:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005278:	0d050793          	add	a5,a0,208
    8000527c:	4501                	li	a0,0
    8000527e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005280:	6398                	ld	a4,0(a5)
    80005282:	cb19                	beqz	a4,80005298 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005284:	2505                	addw	a0,a0,1
    80005286:	07a1                	add	a5,a5,8
    80005288:	fed51ce3          	bne	a0,a3,80005280 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000528c:	557d                	li	a0,-1
}
    8000528e:	60e2                	ld	ra,24(sp)
    80005290:	6442                	ld	s0,16(sp)
    80005292:	64a2                	ld	s1,8(sp)
    80005294:	6105                	add	sp,sp,32
    80005296:	8082                	ret
      p->ofile[fd] = f;
    80005298:	01a50793          	add	a5,a0,26
    8000529c:	078e                	sll	a5,a5,0x3
    8000529e:	963e                	add	a2,a2,a5
    800052a0:	e204                	sd	s1,0(a2)
      return fd;
    800052a2:	b7f5                	j	8000528e <fdalloc+0x2c>

00000000800052a4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052a4:	715d                	add	sp,sp,-80
    800052a6:	e486                	sd	ra,72(sp)
    800052a8:	e0a2                	sd	s0,64(sp)
    800052aa:	fc26                	sd	s1,56(sp)
    800052ac:	f84a                	sd	s2,48(sp)
    800052ae:	f44e                	sd	s3,40(sp)
    800052b0:	f052                	sd	s4,32(sp)
    800052b2:	ec56                	sd	s5,24(sp)
    800052b4:	e85a                	sd	s6,16(sp)
    800052b6:	0880                	add	s0,sp,80
    800052b8:	8b2e                	mv	s6,a1
    800052ba:	89b2                	mv	s3,a2
    800052bc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052be:	fb040593          	add	a1,s0,-80
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	e7e080e7          	jalr	-386(ra) # 80004140 <nameiparent>
    800052ca:	84aa                	mv	s1,a0
    800052cc:	14050b63          	beqz	a0,80005422 <create+0x17e>
    return 0;

  ilock(dp);
    800052d0:	ffffe097          	auipc	ra,0xffffe
    800052d4:	6ac080e7          	jalr	1708(ra) # 8000397c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052d8:	4601                	li	a2,0
    800052da:	fb040593          	add	a1,s0,-80
    800052de:	8526                	mv	a0,s1
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	b80080e7          	jalr	-1152(ra) # 80003e60 <dirlookup>
    800052e8:	8aaa                	mv	s5,a0
    800052ea:	c921                	beqz	a0,8000533a <create+0x96>
    iunlockput(dp);
    800052ec:	8526                	mv	a0,s1
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	8f0080e7          	jalr	-1808(ra) # 80003bde <iunlockput>
    ilock(ip);
    800052f6:	8556                	mv	a0,s5
    800052f8:	ffffe097          	auipc	ra,0xffffe
    800052fc:	684080e7          	jalr	1668(ra) # 8000397c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005300:	4789                	li	a5,2
    80005302:	02fb1563          	bne	s6,a5,8000532c <create+0x88>
    80005306:	044ad783          	lhu	a5,68(s5)
    8000530a:	37f9                	addw	a5,a5,-2
    8000530c:	17c2                	sll	a5,a5,0x30
    8000530e:	93c1                	srl	a5,a5,0x30
    80005310:	4705                	li	a4,1
    80005312:	00f76d63          	bltu	a4,a5,8000532c <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005316:	8556                	mv	a0,s5
    80005318:	60a6                	ld	ra,72(sp)
    8000531a:	6406                	ld	s0,64(sp)
    8000531c:	74e2                	ld	s1,56(sp)
    8000531e:	7942                	ld	s2,48(sp)
    80005320:	79a2                	ld	s3,40(sp)
    80005322:	7a02                	ld	s4,32(sp)
    80005324:	6ae2                	ld	s5,24(sp)
    80005326:	6b42                	ld	s6,16(sp)
    80005328:	6161                	add	sp,sp,80
    8000532a:	8082                	ret
    iunlockput(ip);
    8000532c:	8556                	mv	a0,s5
    8000532e:	fffff097          	auipc	ra,0xfffff
    80005332:	8b0080e7          	jalr	-1872(ra) # 80003bde <iunlockput>
    return 0;
    80005336:	4a81                	li	s5,0
    80005338:	bff9                	j	80005316 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000533a:	85da                	mv	a1,s6
    8000533c:	4088                	lw	a0,0(s1)
    8000533e:	ffffe097          	auipc	ra,0xffffe
    80005342:	4a6080e7          	jalr	1190(ra) # 800037e4 <ialloc>
    80005346:	8a2a                	mv	s4,a0
    80005348:	c529                	beqz	a0,80005392 <create+0xee>
  ilock(ip);
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	632080e7          	jalr	1586(ra) # 8000397c <ilock>
  ip->major = major;
    80005352:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005356:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000535a:	4905                	li	s2,1
    8000535c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005360:	8552                	mv	a0,s4
    80005362:	ffffe097          	auipc	ra,0xffffe
    80005366:	54e080e7          	jalr	1358(ra) # 800038b0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000536a:	032b0b63          	beq	s6,s2,800053a0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000536e:	004a2603          	lw	a2,4(s4)
    80005372:	fb040593          	add	a1,s0,-80
    80005376:	8526                	mv	a0,s1
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	cf8080e7          	jalr	-776(ra) # 80004070 <dirlink>
    80005380:	06054f63          	bltz	a0,800053fe <create+0x15a>
  iunlockput(dp);
    80005384:	8526                	mv	a0,s1
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	858080e7          	jalr	-1960(ra) # 80003bde <iunlockput>
  return ip;
    8000538e:	8ad2                	mv	s5,s4
    80005390:	b759                	j	80005316 <create+0x72>
    iunlockput(dp);
    80005392:	8526                	mv	a0,s1
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	84a080e7          	jalr	-1974(ra) # 80003bde <iunlockput>
    return 0;
    8000539c:	8ad2                	mv	s5,s4
    8000539e:	bfa5                	j	80005316 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053a0:	004a2603          	lw	a2,4(s4)
    800053a4:	00003597          	auipc	a1,0x3
    800053a8:	4ac58593          	add	a1,a1,1196 # 80008850 <syscalls+0x2a8>
    800053ac:	8552                	mv	a0,s4
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	cc2080e7          	jalr	-830(ra) # 80004070 <dirlink>
    800053b6:	04054463          	bltz	a0,800053fe <create+0x15a>
    800053ba:	40d0                	lw	a2,4(s1)
    800053bc:	00003597          	auipc	a1,0x3
    800053c0:	49c58593          	add	a1,a1,1180 # 80008858 <syscalls+0x2b0>
    800053c4:	8552                	mv	a0,s4
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	caa080e7          	jalr	-854(ra) # 80004070 <dirlink>
    800053ce:	02054863          	bltz	a0,800053fe <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800053d2:	004a2603          	lw	a2,4(s4)
    800053d6:	fb040593          	add	a1,s0,-80
    800053da:	8526                	mv	a0,s1
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	c94080e7          	jalr	-876(ra) # 80004070 <dirlink>
    800053e4:	00054d63          	bltz	a0,800053fe <create+0x15a>
    dp->nlink++;  // for ".."
    800053e8:	04a4d783          	lhu	a5,74(s1)
    800053ec:	2785                	addw	a5,a5,1
    800053ee:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053f2:	8526                	mv	a0,s1
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	4bc080e7          	jalr	1212(ra) # 800038b0 <iupdate>
    800053fc:	b761                	j	80005384 <create+0xe0>
  ip->nlink = 0;
    800053fe:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005402:	8552                	mv	a0,s4
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	4ac080e7          	jalr	1196(ra) # 800038b0 <iupdate>
  iunlockput(ip);
    8000540c:	8552                	mv	a0,s4
    8000540e:	ffffe097          	auipc	ra,0xffffe
    80005412:	7d0080e7          	jalr	2000(ra) # 80003bde <iunlockput>
  iunlockput(dp);
    80005416:	8526                	mv	a0,s1
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	7c6080e7          	jalr	1990(ra) # 80003bde <iunlockput>
  return 0;
    80005420:	bddd                	j	80005316 <create+0x72>
    return 0;
    80005422:	8aaa                	mv	s5,a0
    80005424:	bdcd                	j	80005316 <create+0x72>

0000000080005426 <sys_dup>:
{
    80005426:	7179                	add	sp,sp,-48
    80005428:	f406                	sd	ra,40(sp)
    8000542a:	f022                	sd	s0,32(sp)
    8000542c:	ec26                	sd	s1,24(sp)
    8000542e:	e84a                	sd	s2,16(sp)
    80005430:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005432:	fd840613          	add	a2,s0,-40
    80005436:	4581                	li	a1,0
    80005438:	4501                	li	a0,0
    8000543a:	00000097          	auipc	ra,0x0
    8000543e:	dc8080e7          	jalr	-568(ra) # 80005202 <argfd>
    return -1;
    80005442:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005444:	02054363          	bltz	a0,8000546a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005448:	fd843903          	ld	s2,-40(s0)
    8000544c:	854a                	mv	a0,s2
    8000544e:	00000097          	auipc	ra,0x0
    80005452:	e14080e7          	jalr	-492(ra) # 80005262 <fdalloc>
    80005456:	84aa                	mv	s1,a0
    return -1;
    80005458:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000545a:	00054863          	bltz	a0,8000546a <sys_dup+0x44>
  filedup(f);
    8000545e:	854a                	mv	a0,s2
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	334080e7          	jalr	820(ra) # 80004794 <filedup>
  return fd;
    80005468:	87a6                	mv	a5,s1
}
    8000546a:	853e                	mv	a0,a5
    8000546c:	70a2                	ld	ra,40(sp)
    8000546e:	7402                	ld	s0,32(sp)
    80005470:	64e2                	ld	s1,24(sp)
    80005472:	6942                	ld	s2,16(sp)
    80005474:	6145                	add	sp,sp,48
    80005476:	8082                	ret

0000000080005478 <sys_read>:
{
    80005478:	7179                	add	sp,sp,-48
    8000547a:	f406                	sd	ra,40(sp)
    8000547c:	f022                	sd	s0,32(sp)
    8000547e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005480:	fd840593          	add	a1,s0,-40
    80005484:	4505                	li	a0,1
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	964080e7          	jalr	-1692(ra) # 80002dea <argaddr>
  argint(2, &n);
    8000548e:	fe440593          	add	a1,s0,-28
    80005492:	4509                	li	a0,2
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	936080e7          	jalr	-1738(ra) # 80002dca <argint>
  if(argfd(0, 0, &f) < 0)
    8000549c:	fe840613          	add	a2,s0,-24
    800054a0:	4581                	li	a1,0
    800054a2:	4501                	li	a0,0
    800054a4:	00000097          	auipc	ra,0x0
    800054a8:	d5e080e7          	jalr	-674(ra) # 80005202 <argfd>
    800054ac:	87aa                	mv	a5,a0
    return -1;
    800054ae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054b0:	0007cc63          	bltz	a5,800054c8 <sys_read+0x50>
  return fileread(f, p, n);
    800054b4:	fe442603          	lw	a2,-28(s0)
    800054b8:	fd843583          	ld	a1,-40(s0)
    800054bc:	fe843503          	ld	a0,-24(s0)
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	460080e7          	jalr	1120(ra) # 80004920 <fileread>
}
    800054c8:	70a2                	ld	ra,40(sp)
    800054ca:	7402                	ld	s0,32(sp)
    800054cc:	6145                	add	sp,sp,48
    800054ce:	8082                	ret

00000000800054d0 <sys_write>:
{
    800054d0:	7179                	add	sp,sp,-48
    800054d2:	f406                	sd	ra,40(sp)
    800054d4:	f022                	sd	s0,32(sp)
    800054d6:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800054d8:	fd840593          	add	a1,s0,-40
    800054dc:	4505                	li	a0,1
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	90c080e7          	jalr	-1780(ra) # 80002dea <argaddr>
  argint(2, &n);
    800054e6:	fe440593          	add	a1,s0,-28
    800054ea:	4509                	li	a0,2
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	8de080e7          	jalr	-1826(ra) # 80002dca <argint>
  if(argfd(0, 0, &f) < 0)
    800054f4:	fe840613          	add	a2,s0,-24
    800054f8:	4581                	li	a1,0
    800054fa:	4501                	li	a0,0
    800054fc:	00000097          	auipc	ra,0x0
    80005500:	d06080e7          	jalr	-762(ra) # 80005202 <argfd>
    80005504:	87aa                	mv	a5,a0
    return -1;
    80005506:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005508:	0007cc63          	bltz	a5,80005520 <sys_write+0x50>
  return filewrite(f, p, n);
    8000550c:	fe442603          	lw	a2,-28(s0)
    80005510:	fd843583          	ld	a1,-40(s0)
    80005514:	fe843503          	ld	a0,-24(s0)
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	4ca080e7          	jalr	1226(ra) # 800049e2 <filewrite>
}
    80005520:	70a2                	ld	ra,40(sp)
    80005522:	7402                	ld	s0,32(sp)
    80005524:	6145                	add	sp,sp,48
    80005526:	8082                	ret

0000000080005528 <sys_close>:
{
    80005528:	1101                	add	sp,sp,-32
    8000552a:	ec06                	sd	ra,24(sp)
    8000552c:	e822                	sd	s0,16(sp)
    8000552e:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005530:	fe040613          	add	a2,s0,-32
    80005534:	fec40593          	add	a1,s0,-20
    80005538:	4501                	li	a0,0
    8000553a:	00000097          	auipc	ra,0x0
    8000553e:	cc8080e7          	jalr	-824(ra) # 80005202 <argfd>
    return -1;
    80005542:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005544:	02054463          	bltz	a0,8000556c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005548:	ffffc097          	auipc	ra,0xffffc
    8000554c:	45e080e7          	jalr	1118(ra) # 800019a6 <myproc>
    80005550:	fec42783          	lw	a5,-20(s0)
    80005554:	07e9                	add	a5,a5,26
    80005556:	078e                	sll	a5,a5,0x3
    80005558:	953e                	add	a0,a0,a5
    8000555a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000555e:	fe043503          	ld	a0,-32(s0)
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	284080e7          	jalr	644(ra) # 800047e6 <fileclose>
  return 0;
    8000556a:	4781                	li	a5,0
}
    8000556c:	853e                	mv	a0,a5
    8000556e:	60e2                	ld	ra,24(sp)
    80005570:	6442                	ld	s0,16(sp)
    80005572:	6105                	add	sp,sp,32
    80005574:	8082                	ret

0000000080005576 <sys_fstat>:
{
    80005576:	1101                	add	sp,sp,-32
    80005578:	ec06                	sd	ra,24(sp)
    8000557a:	e822                	sd	s0,16(sp)
    8000557c:	1000                	add	s0,sp,32
  argaddr(1, &st);
    8000557e:	fe040593          	add	a1,s0,-32
    80005582:	4505                	li	a0,1
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	866080e7          	jalr	-1946(ra) # 80002dea <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000558c:	fe840613          	add	a2,s0,-24
    80005590:	4581                	li	a1,0
    80005592:	4501                	li	a0,0
    80005594:	00000097          	auipc	ra,0x0
    80005598:	c6e080e7          	jalr	-914(ra) # 80005202 <argfd>
    8000559c:	87aa                	mv	a5,a0
    return -1;
    8000559e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055a0:	0007ca63          	bltz	a5,800055b4 <sys_fstat+0x3e>
  return filestat(f, st);
    800055a4:	fe043583          	ld	a1,-32(s0)
    800055a8:	fe843503          	ld	a0,-24(s0)
    800055ac:	fffff097          	auipc	ra,0xfffff
    800055b0:	302080e7          	jalr	770(ra) # 800048ae <filestat>
}
    800055b4:	60e2                	ld	ra,24(sp)
    800055b6:	6442                	ld	s0,16(sp)
    800055b8:	6105                	add	sp,sp,32
    800055ba:	8082                	ret

00000000800055bc <sys_link>:
{
    800055bc:	7169                	add	sp,sp,-304
    800055be:	f606                	sd	ra,296(sp)
    800055c0:	f222                	sd	s0,288(sp)
    800055c2:	ee26                	sd	s1,280(sp)
    800055c4:	ea4a                	sd	s2,272(sp)
    800055c6:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055c8:	08000613          	li	a2,128
    800055cc:	ed040593          	add	a1,s0,-304
    800055d0:	4501                	li	a0,0
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	838080e7          	jalr	-1992(ra) # 80002e0a <argstr>
    return -1;
    800055da:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055dc:	10054e63          	bltz	a0,800056f8 <sys_link+0x13c>
    800055e0:	08000613          	li	a2,128
    800055e4:	f5040593          	add	a1,s0,-176
    800055e8:	4505                	li	a0,1
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	820080e7          	jalr	-2016(ra) # 80002e0a <argstr>
    return -1;
    800055f2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055f4:	10054263          	bltz	a0,800056f8 <sys_link+0x13c>
  begin_op();
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	d2a080e7          	jalr	-726(ra) # 80004322 <begin_op>
  if((ip = namei(old)) == 0){
    80005600:	ed040513          	add	a0,s0,-304
    80005604:	fffff097          	auipc	ra,0xfffff
    80005608:	b1e080e7          	jalr	-1250(ra) # 80004122 <namei>
    8000560c:	84aa                	mv	s1,a0
    8000560e:	c551                	beqz	a0,8000569a <sys_link+0xde>
  ilock(ip);
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	36c080e7          	jalr	876(ra) # 8000397c <ilock>
  if(ip->type == T_DIR){
    80005618:	04449703          	lh	a4,68(s1)
    8000561c:	4785                	li	a5,1
    8000561e:	08f70463          	beq	a4,a5,800056a6 <sys_link+0xea>
  ip->nlink++;
    80005622:	04a4d783          	lhu	a5,74(s1)
    80005626:	2785                	addw	a5,a5,1
    80005628:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000562c:	8526                	mv	a0,s1
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	282080e7          	jalr	642(ra) # 800038b0 <iupdate>
  iunlock(ip);
    80005636:	8526                	mv	a0,s1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	406080e7          	jalr	1030(ra) # 80003a3e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005640:	fd040593          	add	a1,s0,-48
    80005644:	f5040513          	add	a0,s0,-176
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	af8080e7          	jalr	-1288(ra) # 80004140 <nameiparent>
    80005650:	892a                	mv	s2,a0
    80005652:	c935                	beqz	a0,800056c6 <sys_link+0x10a>
  ilock(dp);
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	328080e7          	jalr	808(ra) # 8000397c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000565c:	00092703          	lw	a4,0(s2)
    80005660:	409c                	lw	a5,0(s1)
    80005662:	04f71d63          	bne	a4,a5,800056bc <sys_link+0x100>
    80005666:	40d0                	lw	a2,4(s1)
    80005668:	fd040593          	add	a1,s0,-48
    8000566c:	854a                	mv	a0,s2
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	a02080e7          	jalr	-1534(ra) # 80004070 <dirlink>
    80005676:	04054363          	bltz	a0,800056bc <sys_link+0x100>
  iunlockput(dp);
    8000567a:	854a                	mv	a0,s2
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	562080e7          	jalr	1378(ra) # 80003bde <iunlockput>
  iput(ip);
    80005684:	8526                	mv	a0,s1
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	4b0080e7          	jalr	1200(ra) # 80003b36 <iput>
  end_op();
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	d0e080e7          	jalr	-754(ra) # 8000439c <end_op>
  return 0;
    80005696:	4781                	li	a5,0
    80005698:	a085                	j	800056f8 <sys_link+0x13c>
    end_op();
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	d02080e7          	jalr	-766(ra) # 8000439c <end_op>
    return -1;
    800056a2:	57fd                	li	a5,-1
    800056a4:	a891                	j	800056f8 <sys_link+0x13c>
    iunlockput(ip);
    800056a6:	8526                	mv	a0,s1
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	536080e7          	jalr	1334(ra) # 80003bde <iunlockput>
    end_op();
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	cec080e7          	jalr	-788(ra) # 8000439c <end_op>
    return -1;
    800056b8:	57fd                	li	a5,-1
    800056ba:	a83d                	j	800056f8 <sys_link+0x13c>
    iunlockput(dp);
    800056bc:	854a                	mv	a0,s2
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	520080e7          	jalr	1312(ra) # 80003bde <iunlockput>
  ilock(ip);
    800056c6:	8526                	mv	a0,s1
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	2b4080e7          	jalr	692(ra) # 8000397c <ilock>
  ip->nlink--;
    800056d0:	04a4d783          	lhu	a5,74(s1)
    800056d4:	37fd                	addw	a5,a5,-1
    800056d6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056da:	8526                	mv	a0,s1
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	1d4080e7          	jalr	468(ra) # 800038b0 <iupdate>
  iunlockput(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	4f8080e7          	jalr	1272(ra) # 80003bde <iunlockput>
  end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	cae080e7          	jalr	-850(ra) # 8000439c <end_op>
  return -1;
    800056f6:	57fd                	li	a5,-1
}
    800056f8:	853e                	mv	a0,a5
    800056fa:	70b2                	ld	ra,296(sp)
    800056fc:	7412                	ld	s0,288(sp)
    800056fe:	64f2                	ld	s1,280(sp)
    80005700:	6952                	ld	s2,272(sp)
    80005702:	6155                	add	sp,sp,304
    80005704:	8082                	ret

0000000080005706 <sys_unlink>:
{
    80005706:	7151                	add	sp,sp,-240
    80005708:	f586                	sd	ra,232(sp)
    8000570a:	f1a2                	sd	s0,224(sp)
    8000570c:	eda6                	sd	s1,216(sp)
    8000570e:	e9ca                	sd	s2,208(sp)
    80005710:	e5ce                	sd	s3,200(sp)
    80005712:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005714:	08000613          	li	a2,128
    80005718:	f3040593          	add	a1,s0,-208
    8000571c:	4501                	li	a0,0
    8000571e:	ffffd097          	auipc	ra,0xffffd
    80005722:	6ec080e7          	jalr	1772(ra) # 80002e0a <argstr>
    80005726:	18054163          	bltz	a0,800058a8 <sys_unlink+0x1a2>
  begin_op();
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	bf8080e7          	jalr	-1032(ra) # 80004322 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005732:	fb040593          	add	a1,s0,-80
    80005736:	f3040513          	add	a0,s0,-208
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	a06080e7          	jalr	-1530(ra) # 80004140 <nameiparent>
    80005742:	84aa                	mv	s1,a0
    80005744:	c979                	beqz	a0,8000581a <sys_unlink+0x114>
  ilock(dp);
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	236080e7          	jalr	566(ra) # 8000397c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000574e:	00003597          	auipc	a1,0x3
    80005752:	10258593          	add	a1,a1,258 # 80008850 <syscalls+0x2a8>
    80005756:	fb040513          	add	a0,s0,-80
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	6ec080e7          	jalr	1772(ra) # 80003e46 <namecmp>
    80005762:	14050a63          	beqz	a0,800058b6 <sys_unlink+0x1b0>
    80005766:	00003597          	auipc	a1,0x3
    8000576a:	0f258593          	add	a1,a1,242 # 80008858 <syscalls+0x2b0>
    8000576e:	fb040513          	add	a0,s0,-80
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	6d4080e7          	jalr	1748(ra) # 80003e46 <namecmp>
    8000577a:	12050e63          	beqz	a0,800058b6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000577e:	f2c40613          	add	a2,s0,-212
    80005782:	fb040593          	add	a1,s0,-80
    80005786:	8526                	mv	a0,s1
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	6d8080e7          	jalr	1752(ra) # 80003e60 <dirlookup>
    80005790:	892a                	mv	s2,a0
    80005792:	12050263          	beqz	a0,800058b6 <sys_unlink+0x1b0>
  ilock(ip);
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	1e6080e7          	jalr	486(ra) # 8000397c <ilock>
  if(ip->nlink < 1)
    8000579e:	04a91783          	lh	a5,74(s2)
    800057a2:	08f05263          	blez	a5,80005826 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057a6:	04491703          	lh	a4,68(s2)
    800057aa:	4785                	li	a5,1
    800057ac:	08f70563          	beq	a4,a5,80005836 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057b0:	4641                	li	a2,16
    800057b2:	4581                	li	a1,0
    800057b4:	fc040513          	add	a0,s0,-64
    800057b8:	ffffb097          	auipc	ra,0xffffb
    800057bc:	516080e7          	jalr	1302(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057c0:	4741                	li	a4,16
    800057c2:	f2c42683          	lw	a3,-212(s0)
    800057c6:	fc040613          	add	a2,s0,-64
    800057ca:	4581                	li	a1,0
    800057cc:	8526                	mv	a0,s1
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	55a080e7          	jalr	1370(ra) # 80003d28 <writei>
    800057d6:	47c1                	li	a5,16
    800057d8:	0af51563          	bne	a0,a5,80005882 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057dc:	04491703          	lh	a4,68(s2)
    800057e0:	4785                	li	a5,1
    800057e2:	0af70863          	beq	a4,a5,80005892 <sys_unlink+0x18c>
  iunlockput(dp);
    800057e6:	8526                	mv	a0,s1
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	3f6080e7          	jalr	1014(ra) # 80003bde <iunlockput>
  ip->nlink--;
    800057f0:	04a95783          	lhu	a5,74(s2)
    800057f4:	37fd                	addw	a5,a5,-1
    800057f6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057fa:	854a                	mv	a0,s2
    800057fc:	ffffe097          	auipc	ra,0xffffe
    80005800:	0b4080e7          	jalr	180(ra) # 800038b0 <iupdate>
  iunlockput(ip);
    80005804:	854a                	mv	a0,s2
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	3d8080e7          	jalr	984(ra) # 80003bde <iunlockput>
  end_op();
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	b8e080e7          	jalr	-1138(ra) # 8000439c <end_op>
  return 0;
    80005816:	4501                	li	a0,0
    80005818:	a84d                	j	800058ca <sys_unlink+0x1c4>
    end_op();
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	b82080e7          	jalr	-1150(ra) # 8000439c <end_op>
    return -1;
    80005822:	557d                	li	a0,-1
    80005824:	a05d                	j	800058ca <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005826:	00003517          	auipc	a0,0x3
    8000582a:	03a50513          	add	a0,a0,58 # 80008860 <syscalls+0x2b8>
    8000582e:	ffffb097          	auipc	ra,0xffffb
    80005832:	d0e080e7          	jalr	-754(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005836:	04c92703          	lw	a4,76(s2)
    8000583a:	02000793          	li	a5,32
    8000583e:	f6e7f9e3          	bgeu	a5,a4,800057b0 <sys_unlink+0xaa>
    80005842:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005846:	4741                	li	a4,16
    80005848:	86ce                	mv	a3,s3
    8000584a:	f1840613          	add	a2,s0,-232
    8000584e:	4581                	li	a1,0
    80005850:	854a                	mv	a0,s2
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	3de080e7          	jalr	990(ra) # 80003c30 <readi>
    8000585a:	47c1                	li	a5,16
    8000585c:	00f51b63          	bne	a0,a5,80005872 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005860:	f1845783          	lhu	a5,-232(s0)
    80005864:	e7a1                	bnez	a5,800058ac <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005866:	29c1                	addw	s3,s3,16
    80005868:	04c92783          	lw	a5,76(s2)
    8000586c:	fcf9ede3          	bltu	s3,a5,80005846 <sys_unlink+0x140>
    80005870:	b781                	j	800057b0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005872:	00003517          	auipc	a0,0x3
    80005876:	00650513          	add	a0,a0,6 # 80008878 <syscalls+0x2d0>
    8000587a:	ffffb097          	auipc	ra,0xffffb
    8000587e:	cc2080e7          	jalr	-830(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005882:	00003517          	auipc	a0,0x3
    80005886:	00e50513          	add	a0,a0,14 # 80008890 <syscalls+0x2e8>
    8000588a:	ffffb097          	auipc	ra,0xffffb
    8000588e:	cb2080e7          	jalr	-846(ra) # 8000053c <panic>
    dp->nlink--;
    80005892:	04a4d783          	lhu	a5,74(s1)
    80005896:	37fd                	addw	a5,a5,-1
    80005898:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000589c:	8526                	mv	a0,s1
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	012080e7          	jalr	18(ra) # 800038b0 <iupdate>
    800058a6:	b781                	j	800057e6 <sys_unlink+0xe0>
    return -1;
    800058a8:	557d                	li	a0,-1
    800058aa:	a005                	j	800058ca <sys_unlink+0x1c4>
    iunlockput(ip);
    800058ac:	854a                	mv	a0,s2
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	330080e7          	jalr	816(ra) # 80003bde <iunlockput>
  iunlockput(dp);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	326080e7          	jalr	806(ra) # 80003bde <iunlockput>
  end_op();
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	adc080e7          	jalr	-1316(ra) # 8000439c <end_op>
  return -1;
    800058c8:	557d                	li	a0,-1
}
    800058ca:	70ae                	ld	ra,232(sp)
    800058cc:	740e                	ld	s0,224(sp)
    800058ce:	64ee                	ld	s1,216(sp)
    800058d0:	694e                	ld	s2,208(sp)
    800058d2:	69ae                	ld	s3,200(sp)
    800058d4:	616d                	add	sp,sp,240
    800058d6:	8082                	ret

00000000800058d8 <sys_open>:

uint64
sys_open(void)
{
    800058d8:	7131                	add	sp,sp,-192
    800058da:	fd06                	sd	ra,184(sp)
    800058dc:	f922                	sd	s0,176(sp)
    800058de:	f526                	sd	s1,168(sp)
    800058e0:	f14a                	sd	s2,160(sp)
    800058e2:	ed4e                	sd	s3,152(sp)
    800058e4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058e6:	f4c40593          	add	a1,s0,-180
    800058ea:	4505                	li	a0,1
    800058ec:	ffffd097          	auipc	ra,0xffffd
    800058f0:	4de080e7          	jalr	1246(ra) # 80002dca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058f4:	08000613          	li	a2,128
    800058f8:	f5040593          	add	a1,s0,-176
    800058fc:	4501                	li	a0,0
    800058fe:	ffffd097          	auipc	ra,0xffffd
    80005902:	50c080e7          	jalr	1292(ra) # 80002e0a <argstr>
    80005906:	87aa                	mv	a5,a0
    return -1;
    80005908:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000590a:	0a07c863          	bltz	a5,800059ba <sys_open+0xe2>

  begin_op();
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	a14080e7          	jalr	-1516(ra) # 80004322 <begin_op>

  if(omode & O_CREATE){
    80005916:	f4c42783          	lw	a5,-180(s0)
    8000591a:	2007f793          	and	a5,a5,512
    8000591e:	cbdd                	beqz	a5,800059d4 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005920:	4681                	li	a3,0
    80005922:	4601                	li	a2,0
    80005924:	4589                	li	a1,2
    80005926:	f5040513          	add	a0,s0,-176
    8000592a:	00000097          	auipc	ra,0x0
    8000592e:	97a080e7          	jalr	-1670(ra) # 800052a4 <create>
    80005932:	84aa                	mv	s1,a0
    if(ip == 0){
    80005934:	c951                	beqz	a0,800059c8 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005936:	04449703          	lh	a4,68(s1)
    8000593a:	478d                	li	a5,3
    8000593c:	00f71763          	bne	a4,a5,8000594a <sys_open+0x72>
    80005940:	0464d703          	lhu	a4,70(s1)
    80005944:	47a5                	li	a5,9
    80005946:	0ce7ec63          	bltu	a5,a4,80005a1e <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	de0080e7          	jalr	-544(ra) # 8000472a <filealloc>
    80005952:	892a                	mv	s2,a0
    80005954:	c56d                	beqz	a0,80005a3e <sys_open+0x166>
    80005956:	00000097          	auipc	ra,0x0
    8000595a:	90c080e7          	jalr	-1780(ra) # 80005262 <fdalloc>
    8000595e:	89aa                	mv	s3,a0
    80005960:	0c054a63          	bltz	a0,80005a34 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005964:	04449703          	lh	a4,68(s1)
    80005968:	478d                	li	a5,3
    8000596a:	0ef70563          	beq	a4,a5,80005a54 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000596e:	4789                	li	a5,2
    80005970:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005974:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005978:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000597c:	f4c42783          	lw	a5,-180(s0)
    80005980:	0017c713          	xor	a4,a5,1
    80005984:	8b05                	and	a4,a4,1
    80005986:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000598a:	0037f713          	and	a4,a5,3
    8000598e:	00e03733          	snez	a4,a4
    80005992:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005996:	4007f793          	and	a5,a5,1024
    8000599a:	c791                	beqz	a5,800059a6 <sys_open+0xce>
    8000599c:	04449703          	lh	a4,68(s1)
    800059a0:	4789                	li	a5,2
    800059a2:	0cf70063          	beq	a4,a5,80005a62 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800059a6:	8526                	mv	a0,s1
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	096080e7          	jalr	150(ra) # 80003a3e <iunlock>
  end_op();
    800059b0:	fffff097          	auipc	ra,0xfffff
    800059b4:	9ec080e7          	jalr	-1556(ra) # 8000439c <end_op>

  return fd;
    800059b8:	854e                	mv	a0,s3
}
    800059ba:	70ea                	ld	ra,184(sp)
    800059bc:	744a                	ld	s0,176(sp)
    800059be:	74aa                	ld	s1,168(sp)
    800059c0:	790a                	ld	s2,160(sp)
    800059c2:	69ea                	ld	s3,152(sp)
    800059c4:	6129                	add	sp,sp,192
    800059c6:	8082                	ret
      end_op();
    800059c8:	fffff097          	auipc	ra,0xfffff
    800059cc:	9d4080e7          	jalr	-1580(ra) # 8000439c <end_op>
      return -1;
    800059d0:	557d                	li	a0,-1
    800059d2:	b7e5                	j	800059ba <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800059d4:	f5040513          	add	a0,s0,-176
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	74a080e7          	jalr	1866(ra) # 80004122 <namei>
    800059e0:	84aa                	mv	s1,a0
    800059e2:	c905                	beqz	a0,80005a12 <sys_open+0x13a>
    ilock(ip);
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	f98080e7          	jalr	-104(ra) # 8000397c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059ec:	04449703          	lh	a4,68(s1)
    800059f0:	4785                	li	a5,1
    800059f2:	f4f712e3          	bne	a4,a5,80005936 <sys_open+0x5e>
    800059f6:	f4c42783          	lw	a5,-180(s0)
    800059fa:	dba1                	beqz	a5,8000594a <sys_open+0x72>
      iunlockput(ip);
    800059fc:	8526                	mv	a0,s1
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	1e0080e7          	jalr	480(ra) # 80003bde <iunlockput>
      end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	996080e7          	jalr	-1642(ra) # 8000439c <end_op>
      return -1;
    80005a0e:	557d                	li	a0,-1
    80005a10:	b76d                	j	800059ba <sys_open+0xe2>
      end_op();
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	98a080e7          	jalr	-1654(ra) # 8000439c <end_op>
      return -1;
    80005a1a:	557d                	li	a0,-1
    80005a1c:	bf79                	j	800059ba <sys_open+0xe2>
    iunlockput(ip);
    80005a1e:	8526                	mv	a0,s1
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	1be080e7          	jalr	446(ra) # 80003bde <iunlockput>
    end_op();
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	974080e7          	jalr	-1676(ra) # 8000439c <end_op>
    return -1;
    80005a30:	557d                	li	a0,-1
    80005a32:	b761                	j	800059ba <sys_open+0xe2>
      fileclose(f);
    80005a34:	854a                	mv	a0,s2
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	db0080e7          	jalr	-592(ra) # 800047e6 <fileclose>
    iunlockput(ip);
    80005a3e:	8526                	mv	a0,s1
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	19e080e7          	jalr	414(ra) # 80003bde <iunlockput>
    end_op();
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	954080e7          	jalr	-1708(ra) # 8000439c <end_op>
    return -1;
    80005a50:	557d                	li	a0,-1
    80005a52:	b7a5                	j	800059ba <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005a54:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005a58:	04649783          	lh	a5,70(s1)
    80005a5c:	02f91223          	sh	a5,36(s2)
    80005a60:	bf21                	j	80005978 <sys_open+0xa0>
    itrunc(ip);
    80005a62:	8526                	mv	a0,s1
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	026080e7          	jalr	38(ra) # 80003a8a <itrunc>
    80005a6c:	bf2d                	j	800059a6 <sys_open+0xce>

0000000080005a6e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a6e:	7175                	add	sp,sp,-144
    80005a70:	e506                	sd	ra,136(sp)
    80005a72:	e122                	sd	s0,128(sp)
    80005a74:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	8ac080e7          	jalr	-1876(ra) # 80004322 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a7e:	08000613          	li	a2,128
    80005a82:	f7040593          	add	a1,s0,-144
    80005a86:	4501                	li	a0,0
    80005a88:	ffffd097          	auipc	ra,0xffffd
    80005a8c:	382080e7          	jalr	898(ra) # 80002e0a <argstr>
    80005a90:	02054963          	bltz	a0,80005ac2 <sys_mkdir+0x54>
    80005a94:	4681                	li	a3,0
    80005a96:	4601                	li	a2,0
    80005a98:	4585                	li	a1,1
    80005a9a:	f7040513          	add	a0,s0,-144
    80005a9e:	00000097          	auipc	ra,0x0
    80005aa2:	806080e7          	jalr	-2042(ra) # 800052a4 <create>
    80005aa6:	cd11                	beqz	a0,80005ac2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	136080e7          	jalr	310(ra) # 80003bde <iunlockput>
  end_op();
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	8ec080e7          	jalr	-1812(ra) # 8000439c <end_op>
  return 0;
    80005ab8:	4501                	li	a0,0
}
    80005aba:	60aa                	ld	ra,136(sp)
    80005abc:	640a                	ld	s0,128(sp)
    80005abe:	6149                	add	sp,sp,144
    80005ac0:	8082                	ret
    end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	8da080e7          	jalr	-1830(ra) # 8000439c <end_op>
    return -1;
    80005aca:	557d                	li	a0,-1
    80005acc:	b7fd                	j	80005aba <sys_mkdir+0x4c>

0000000080005ace <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ace:	7135                	add	sp,sp,-160
    80005ad0:	ed06                	sd	ra,152(sp)
    80005ad2:	e922                	sd	s0,144(sp)
    80005ad4:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ad6:	fffff097          	auipc	ra,0xfffff
    80005ada:	84c080e7          	jalr	-1972(ra) # 80004322 <begin_op>
  argint(1, &major);
    80005ade:	f6c40593          	add	a1,s0,-148
    80005ae2:	4505                	li	a0,1
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	2e6080e7          	jalr	742(ra) # 80002dca <argint>
  argint(2, &minor);
    80005aec:	f6840593          	add	a1,s0,-152
    80005af0:	4509                	li	a0,2
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	2d8080e7          	jalr	728(ra) # 80002dca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005afa:	08000613          	li	a2,128
    80005afe:	f7040593          	add	a1,s0,-144
    80005b02:	4501                	li	a0,0
    80005b04:	ffffd097          	auipc	ra,0xffffd
    80005b08:	306080e7          	jalr	774(ra) # 80002e0a <argstr>
    80005b0c:	02054b63          	bltz	a0,80005b42 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b10:	f6841683          	lh	a3,-152(s0)
    80005b14:	f6c41603          	lh	a2,-148(s0)
    80005b18:	458d                	li	a1,3
    80005b1a:	f7040513          	add	a0,s0,-144
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	786080e7          	jalr	1926(ra) # 800052a4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b26:	cd11                	beqz	a0,80005b42 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	0b6080e7          	jalr	182(ra) # 80003bde <iunlockput>
  end_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	86c080e7          	jalr	-1940(ra) # 8000439c <end_op>
  return 0;
    80005b38:	4501                	li	a0,0
}
    80005b3a:	60ea                	ld	ra,152(sp)
    80005b3c:	644a                	ld	s0,144(sp)
    80005b3e:	610d                	add	sp,sp,160
    80005b40:	8082                	ret
    end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	85a080e7          	jalr	-1958(ra) # 8000439c <end_op>
    return -1;
    80005b4a:	557d                	li	a0,-1
    80005b4c:	b7fd                	j	80005b3a <sys_mknod+0x6c>

0000000080005b4e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b4e:	7135                	add	sp,sp,-160
    80005b50:	ed06                	sd	ra,152(sp)
    80005b52:	e922                	sd	s0,144(sp)
    80005b54:	e526                	sd	s1,136(sp)
    80005b56:	e14a                	sd	s2,128(sp)
    80005b58:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b5a:	ffffc097          	auipc	ra,0xffffc
    80005b5e:	e4c080e7          	jalr	-436(ra) # 800019a6 <myproc>
    80005b62:	892a                	mv	s2,a0
  
  begin_op();
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	7be080e7          	jalr	1982(ra) # 80004322 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b6c:	08000613          	li	a2,128
    80005b70:	f6040593          	add	a1,s0,-160
    80005b74:	4501                	li	a0,0
    80005b76:	ffffd097          	auipc	ra,0xffffd
    80005b7a:	294080e7          	jalr	660(ra) # 80002e0a <argstr>
    80005b7e:	04054b63          	bltz	a0,80005bd4 <sys_chdir+0x86>
    80005b82:	f6040513          	add	a0,s0,-160
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	59c080e7          	jalr	1436(ra) # 80004122 <namei>
    80005b8e:	84aa                	mv	s1,a0
    80005b90:	c131                	beqz	a0,80005bd4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	dea080e7          	jalr	-534(ra) # 8000397c <ilock>
  if(ip->type != T_DIR){
    80005b9a:	04449703          	lh	a4,68(s1)
    80005b9e:	4785                	li	a5,1
    80005ba0:	04f71063          	bne	a4,a5,80005be0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ba4:	8526                	mv	a0,s1
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	e98080e7          	jalr	-360(ra) # 80003a3e <iunlock>
  iput(p->cwd);
    80005bae:	15093503          	ld	a0,336(s2)
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	f84080e7          	jalr	-124(ra) # 80003b36 <iput>
  end_op();
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	7e2080e7          	jalr	2018(ra) # 8000439c <end_op>
  p->cwd = ip;
    80005bc2:	14993823          	sd	s1,336(s2)
  return 0;
    80005bc6:	4501                	li	a0,0
}
    80005bc8:	60ea                	ld	ra,152(sp)
    80005bca:	644a                	ld	s0,144(sp)
    80005bcc:	64aa                	ld	s1,136(sp)
    80005bce:	690a                	ld	s2,128(sp)
    80005bd0:	610d                	add	sp,sp,160
    80005bd2:	8082                	ret
    end_op();
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	7c8080e7          	jalr	1992(ra) # 8000439c <end_op>
    return -1;
    80005bdc:	557d                	li	a0,-1
    80005bde:	b7ed                	j	80005bc8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005be0:	8526                	mv	a0,s1
    80005be2:	ffffe097          	auipc	ra,0xffffe
    80005be6:	ffc080e7          	jalr	-4(ra) # 80003bde <iunlockput>
    end_op();
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	7b2080e7          	jalr	1970(ra) # 8000439c <end_op>
    return -1;
    80005bf2:	557d                	li	a0,-1
    80005bf4:	bfd1                	j	80005bc8 <sys_chdir+0x7a>

0000000080005bf6 <sys_exec>:

uint64
sys_exec(void)
{
    80005bf6:	7121                	add	sp,sp,-448
    80005bf8:	ff06                	sd	ra,440(sp)
    80005bfa:	fb22                	sd	s0,432(sp)
    80005bfc:	f726                	sd	s1,424(sp)
    80005bfe:	f34a                	sd	s2,416(sp)
    80005c00:	ef4e                	sd	s3,408(sp)
    80005c02:	eb52                	sd	s4,400(sp)
    80005c04:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c06:	e4840593          	add	a1,s0,-440
    80005c0a:	4505                	li	a0,1
    80005c0c:	ffffd097          	auipc	ra,0xffffd
    80005c10:	1de080e7          	jalr	478(ra) # 80002dea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c14:	08000613          	li	a2,128
    80005c18:	f5040593          	add	a1,s0,-176
    80005c1c:	4501                	li	a0,0
    80005c1e:	ffffd097          	auipc	ra,0xffffd
    80005c22:	1ec080e7          	jalr	492(ra) # 80002e0a <argstr>
    80005c26:	87aa                	mv	a5,a0
    return -1;
    80005c28:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c2a:	0c07c263          	bltz	a5,80005cee <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005c2e:	10000613          	li	a2,256
    80005c32:	4581                	li	a1,0
    80005c34:	e5040513          	add	a0,s0,-432
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	096080e7          	jalr	150(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c40:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005c44:	89a6                	mv	s3,s1
    80005c46:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c48:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c4c:	00391513          	sll	a0,s2,0x3
    80005c50:	e4040593          	add	a1,s0,-448
    80005c54:	e4843783          	ld	a5,-440(s0)
    80005c58:	953e                	add	a0,a0,a5
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	0d2080e7          	jalr	210(ra) # 80002d2c <fetchaddr>
    80005c62:	02054a63          	bltz	a0,80005c96 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005c66:	e4043783          	ld	a5,-448(s0)
    80005c6a:	c3b9                	beqz	a5,80005cb0 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c6c:	ffffb097          	auipc	ra,0xffffb
    80005c70:	e76080e7          	jalr	-394(ra) # 80000ae2 <kalloc>
    80005c74:	85aa                	mv	a1,a0
    80005c76:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c7a:	cd11                	beqz	a0,80005c96 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c7c:	6605                	lui	a2,0x1
    80005c7e:	e4043503          	ld	a0,-448(s0)
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	0fc080e7          	jalr	252(ra) # 80002d7e <fetchstr>
    80005c8a:	00054663          	bltz	a0,80005c96 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005c8e:	0905                	add	s2,s2,1
    80005c90:	09a1                	add	s3,s3,8
    80005c92:	fb491de3          	bne	s2,s4,80005c4c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c96:	f5040913          	add	s2,s0,-176
    80005c9a:	6088                	ld	a0,0(s1)
    80005c9c:	c921                	beqz	a0,80005cec <sys_exec+0xf6>
    kfree(argv[i]);
    80005c9e:	ffffb097          	auipc	ra,0xffffb
    80005ca2:	d46080e7          	jalr	-698(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca6:	04a1                	add	s1,s1,8
    80005ca8:	ff2499e3          	bne	s1,s2,80005c9a <sys_exec+0xa4>
  return -1;
    80005cac:	557d                	li	a0,-1
    80005cae:	a081                	j	80005cee <sys_exec+0xf8>
      argv[i] = 0;
    80005cb0:	0009079b          	sext.w	a5,s2
    80005cb4:	078e                	sll	a5,a5,0x3
    80005cb6:	fd078793          	add	a5,a5,-48
    80005cba:	97a2                	add	a5,a5,s0
    80005cbc:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005cc0:	e5040593          	add	a1,s0,-432
    80005cc4:	f5040513          	add	a0,s0,-176
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	194080e7          	jalr	404(ra) # 80004e5c <exec>
    80005cd0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd2:	f5040993          	add	s3,s0,-176
    80005cd6:	6088                	ld	a0,0(s1)
    80005cd8:	c901                	beqz	a0,80005ce8 <sys_exec+0xf2>
    kfree(argv[i]);
    80005cda:	ffffb097          	auipc	ra,0xffffb
    80005cde:	d0a080e7          	jalr	-758(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce2:	04a1                	add	s1,s1,8
    80005ce4:	ff3499e3          	bne	s1,s3,80005cd6 <sys_exec+0xe0>
  return ret;
    80005ce8:	854a                	mv	a0,s2
    80005cea:	a011                	j	80005cee <sys_exec+0xf8>
  return -1;
    80005cec:	557d                	li	a0,-1
}
    80005cee:	70fa                	ld	ra,440(sp)
    80005cf0:	745a                	ld	s0,432(sp)
    80005cf2:	74ba                	ld	s1,424(sp)
    80005cf4:	791a                	ld	s2,416(sp)
    80005cf6:	69fa                	ld	s3,408(sp)
    80005cf8:	6a5a                	ld	s4,400(sp)
    80005cfa:	6139                	add	sp,sp,448
    80005cfc:	8082                	ret

0000000080005cfe <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cfe:	7139                	add	sp,sp,-64
    80005d00:	fc06                	sd	ra,56(sp)
    80005d02:	f822                	sd	s0,48(sp)
    80005d04:	f426                	sd	s1,40(sp)
    80005d06:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d08:	ffffc097          	auipc	ra,0xffffc
    80005d0c:	c9e080e7          	jalr	-866(ra) # 800019a6 <myproc>
    80005d10:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d12:	fd840593          	add	a1,s0,-40
    80005d16:	4501                	li	a0,0
    80005d18:	ffffd097          	auipc	ra,0xffffd
    80005d1c:	0d2080e7          	jalr	210(ra) # 80002dea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d20:	fc840593          	add	a1,s0,-56
    80005d24:	fd040513          	add	a0,s0,-48
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	dea080e7          	jalr	-534(ra) # 80004b12 <pipealloc>
    return -1;
    80005d30:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d32:	0c054463          	bltz	a0,80005dfa <sys_pipe+0xfc>
  fd0 = -1;
    80005d36:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d3a:	fd043503          	ld	a0,-48(s0)
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	524080e7          	jalr	1316(ra) # 80005262 <fdalloc>
    80005d46:	fca42223          	sw	a0,-60(s0)
    80005d4a:	08054b63          	bltz	a0,80005de0 <sys_pipe+0xe2>
    80005d4e:	fc843503          	ld	a0,-56(s0)
    80005d52:	fffff097          	auipc	ra,0xfffff
    80005d56:	510080e7          	jalr	1296(ra) # 80005262 <fdalloc>
    80005d5a:	fca42023          	sw	a0,-64(s0)
    80005d5e:	06054863          	bltz	a0,80005dce <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d62:	4691                	li	a3,4
    80005d64:	fc440613          	add	a2,s0,-60
    80005d68:	fd843583          	ld	a1,-40(s0)
    80005d6c:	68a8                	ld	a0,80(s1)
    80005d6e:	ffffc097          	auipc	ra,0xffffc
    80005d72:	8f8080e7          	jalr	-1800(ra) # 80001666 <copyout>
    80005d76:	02054063          	bltz	a0,80005d96 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d7a:	4691                	li	a3,4
    80005d7c:	fc040613          	add	a2,s0,-64
    80005d80:	fd843583          	ld	a1,-40(s0)
    80005d84:	0591                	add	a1,a1,4
    80005d86:	68a8                	ld	a0,80(s1)
    80005d88:	ffffc097          	auipc	ra,0xffffc
    80005d8c:	8de080e7          	jalr	-1826(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d90:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d92:	06055463          	bgez	a0,80005dfa <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d96:	fc442783          	lw	a5,-60(s0)
    80005d9a:	07e9                	add	a5,a5,26
    80005d9c:	078e                	sll	a5,a5,0x3
    80005d9e:	97a6                	add	a5,a5,s1
    80005da0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005da4:	fc042783          	lw	a5,-64(s0)
    80005da8:	07e9                	add	a5,a5,26
    80005daa:	078e                	sll	a5,a5,0x3
    80005dac:	94be                	add	s1,s1,a5
    80005dae:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005db2:	fd043503          	ld	a0,-48(s0)
    80005db6:	fffff097          	auipc	ra,0xfffff
    80005dba:	a30080e7          	jalr	-1488(ra) # 800047e6 <fileclose>
    fileclose(wf);
    80005dbe:	fc843503          	ld	a0,-56(s0)
    80005dc2:	fffff097          	auipc	ra,0xfffff
    80005dc6:	a24080e7          	jalr	-1500(ra) # 800047e6 <fileclose>
    return -1;
    80005dca:	57fd                	li	a5,-1
    80005dcc:	a03d                	j	80005dfa <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005dce:	fc442783          	lw	a5,-60(s0)
    80005dd2:	0007c763          	bltz	a5,80005de0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005dd6:	07e9                	add	a5,a5,26
    80005dd8:	078e                	sll	a5,a5,0x3
    80005dda:	97a6                	add	a5,a5,s1
    80005ddc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005de0:	fd043503          	ld	a0,-48(s0)
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	a02080e7          	jalr	-1534(ra) # 800047e6 <fileclose>
    fileclose(wf);
    80005dec:	fc843503          	ld	a0,-56(s0)
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	9f6080e7          	jalr	-1546(ra) # 800047e6 <fileclose>
    return -1;
    80005df8:	57fd                	li	a5,-1
}
    80005dfa:	853e                	mv	a0,a5
    80005dfc:	70e2                	ld	ra,56(sp)
    80005dfe:	7442                	ld	s0,48(sp)
    80005e00:	74a2                	ld	s1,40(sp)
    80005e02:	6121                	add	sp,sp,64
    80005e04:	8082                	ret
	...

0000000080005e10 <kernelvec>:
    80005e10:	7111                	add	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	da9fc0ef          	jal	80002bf8 <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	add	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	6d0c                	ld	a1,24(a0)
    80005eac:	7110                	ld	a2,32(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	add	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
}
    80005eda:	6422                	ld	s0,8(sp)
    80005edc:	0141                	add	sp,sp,16
    80005ede:	8082                	ret

0000000080005ee0 <plicinithart>:

void
plicinithart(void)
{
    80005ee0:	1141                	add	sp,sp,-16
    80005ee2:	e406                	sd	ra,8(sp)
    80005ee4:	e022                	sd	s0,0(sp)
    80005ee6:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	a92080e7          	jalr	-1390(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ef0:	0085171b          	sllw	a4,a0,0x8
    80005ef4:	0c0027b7          	lui	a5,0xc002
    80005ef8:	97ba                	add	a5,a5,a4
    80005efa:	40200713          	li	a4,1026
    80005efe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f02:	00d5151b          	sllw	a0,a0,0xd
    80005f06:	0c2017b7          	lui	a5,0xc201
    80005f0a:	97aa                	add	a5,a5,a0
    80005f0c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f10:	60a2                	ld	ra,8(sp)
    80005f12:	6402                	ld	s0,0(sp)
    80005f14:	0141                	add	sp,sp,16
    80005f16:	8082                	ret

0000000080005f18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f18:	1141                	add	sp,sp,-16
    80005f1a:	e406                	sd	ra,8(sp)
    80005f1c:	e022                	sd	s0,0(sp)
    80005f1e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005f20:	ffffc097          	auipc	ra,0xffffc
    80005f24:	a5a080e7          	jalr	-1446(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f28:	00d5151b          	sllw	a0,a0,0xd
    80005f2c:	0c2017b7          	lui	a5,0xc201
    80005f30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f32:	43c8                	lw	a0,4(a5)
    80005f34:	60a2                	ld	ra,8(sp)
    80005f36:	6402                	ld	s0,0(sp)
    80005f38:	0141                	add	sp,sp,16
    80005f3a:	8082                	ret

0000000080005f3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f3c:	1101                	add	sp,sp,-32
    80005f3e:	ec06                	sd	ra,24(sp)
    80005f40:	e822                	sd	s0,16(sp)
    80005f42:	e426                	sd	s1,8(sp)
    80005f44:	1000                	add	s0,sp,32
    80005f46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	a32080e7          	jalr	-1486(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f50:	00d5151b          	sllw	a0,a0,0xd
    80005f54:	0c2017b7          	lui	a5,0xc201
    80005f58:	97aa                	add	a5,a5,a0
    80005f5a:	c3c4                	sw	s1,4(a5)
}
    80005f5c:	60e2                	ld	ra,24(sp)
    80005f5e:	6442                	ld	s0,16(sp)
    80005f60:	64a2                	ld	s1,8(sp)
    80005f62:	6105                	add	sp,sp,32
    80005f64:	8082                	ret

0000000080005f66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f66:	1141                	add	sp,sp,-16
    80005f68:	e406                	sd	ra,8(sp)
    80005f6a:	e022                	sd	s0,0(sp)
    80005f6c:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005f6e:	479d                	li	a5,7
    80005f70:	04a7cc63          	blt	a5,a0,80005fc8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f74:	0001c797          	auipc	a5,0x1c
    80005f78:	44478793          	add	a5,a5,1092 # 800223b8 <disk>
    80005f7c:	97aa                	add	a5,a5,a0
    80005f7e:	0187c783          	lbu	a5,24(a5)
    80005f82:	ebb9                	bnez	a5,80005fd8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f84:	00451693          	sll	a3,a0,0x4
    80005f88:	0001c797          	auipc	a5,0x1c
    80005f8c:	43078793          	add	a5,a5,1072 # 800223b8 <disk>
    80005f90:	6398                	ld	a4,0(a5)
    80005f92:	9736                	add	a4,a4,a3
    80005f94:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005f98:	6398                	ld	a4,0(a5)
    80005f9a:	9736                	add	a4,a4,a3
    80005f9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fa0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fa4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fa8:	97aa                	add	a5,a5,a0
    80005faa:	4705                	li	a4,1
    80005fac:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005fb0:	0001c517          	auipc	a0,0x1c
    80005fb4:	42050513          	add	a0,a0,1056 # 800223d0 <disk+0x18>
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	0fa080e7          	jalr	250(ra) # 800020b2 <wakeup>
}
    80005fc0:	60a2                	ld	ra,8(sp)
    80005fc2:	6402                	ld	s0,0(sp)
    80005fc4:	0141                	add	sp,sp,16
    80005fc6:	8082                	ret
    panic("free_desc 1");
    80005fc8:	00003517          	auipc	a0,0x3
    80005fcc:	8d850513          	add	a0,a0,-1832 # 800088a0 <syscalls+0x2f8>
    80005fd0:	ffffa097          	auipc	ra,0xffffa
    80005fd4:	56c080e7          	jalr	1388(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005fd8:	00003517          	auipc	a0,0x3
    80005fdc:	8d850513          	add	a0,a0,-1832 # 800088b0 <syscalls+0x308>
    80005fe0:	ffffa097          	auipc	ra,0xffffa
    80005fe4:	55c080e7          	jalr	1372(ra) # 8000053c <panic>

0000000080005fe8 <virtio_disk_init>:
{
    80005fe8:	1101                	add	sp,sp,-32
    80005fea:	ec06                	sd	ra,24(sp)
    80005fec:	e822                	sd	s0,16(sp)
    80005fee:	e426                	sd	s1,8(sp)
    80005ff0:	e04a                	sd	s2,0(sp)
    80005ff2:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ff4:	00003597          	auipc	a1,0x3
    80005ff8:	8cc58593          	add	a1,a1,-1844 # 800088c0 <syscalls+0x318>
    80005ffc:	0001c517          	auipc	a0,0x1c
    80006000:	4e450513          	add	a0,a0,1252 # 800224e0 <disk+0x128>
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	b3e080e7          	jalr	-1218(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	4398                	lw	a4,0(a5)
    80006012:	2701                	sext.w	a4,a4
    80006014:	747277b7          	lui	a5,0x74727
    80006018:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000601c:	14f71b63          	bne	a4,a5,80006172 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006020:	100017b7          	lui	a5,0x10001
    80006024:	43dc                	lw	a5,4(a5)
    80006026:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006028:	4709                	li	a4,2
    8000602a:	14e79463          	bne	a5,a4,80006172 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000602e:	100017b7          	lui	a5,0x10001
    80006032:	479c                	lw	a5,8(a5)
    80006034:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006036:	12e79e63          	bne	a5,a4,80006172 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000603a:	100017b7          	lui	a5,0x10001
    8000603e:	47d8                	lw	a4,12(a5)
    80006040:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006042:	554d47b7          	lui	a5,0x554d4
    80006046:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000604a:	12f71463          	bne	a4,a5,80006172 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604e:	100017b7          	lui	a5,0x10001
    80006052:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006056:	4705                	li	a4,1
    80006058:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605a:	470d                	li	a4,3
    8000605c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000605e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006060:	c7ffe6b7          	lui	a3,0xc7ffe
    80006064:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc267>
    80006068:	8f75                	and	a4,a4,a3
    8000606a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606c:	472d                	li	a4,11
    8000606e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006070:	5bbc                	lw	a5,112(a5)
    80006072:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006076:	8ba1                	and	a5,a5,8
    80006078:	10078563          	beqz	a5,80006182 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000607c:	100017b7          	lui	a5,0x10001
    80006080:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006084:	43fc                	lw	a5,68(a5)
    80006086:	2781                	sext.w	a5,a5
    80006088:	10079563          	bnez	a5,80006192 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000608c:	100017b7          	lui	a5,0x10001
    80006090:	5bdc                	lw	a5,52(a5)
    80006092:	2781                	sext.w	a5,a5
  if(max == 0)
    80006094:	10078763          	beqz	a5,800061a2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006098:	471d                	li	a4,7
    8000609a:	10f77c63          	bgeu	a4,a5,800061b2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000609e:	ffffb097          	auipc	ra,0xffffb
    800060a2:	a44080e7          	jalr	-1468(ra) # 80000ae2 <kalloc>
    800060a6:	0001c497          	auipc	s1,0x1c
    800060aa:	31248493          	add	s1,s1,786 # 800223b8 <disk>
    800060ae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	a32080e7          	jalr	-1486(ra) # 80000ae2 <kalloc>
    800060b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060ba:	ffffb097          	auipc	ra,0xffffb
    800060be:	a28080e7          	jalr	-1496(ra) # 80000ae2 <kalloc>
    800060c2:	87aa                	mv	a5,a0
    800060c4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060c6:	6088                	ld	a0,0(s1)
    800060c8:	cd6d                	beqz	a0,800061c2 <virtio_disk_init+0x1da>
    800060ca:	0001c717          	auipc	a4,0x1c
    800060ce:	2f673703          	ld	a4,758(a4) # 800223c0 <disk+0x8>
    800060d2:	cb65                	beqz	a4,800061c2 <virtio_disk_init+0x1da>
    800060d4:	c7fd                	beqz	a5,800061c2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800060d6:	6605                	lui	a2,0x1
    800060d8:	4581                	li	a1,0
    800060da:	ffffb097          	auipc	ra,0xffffb
    800060de:	bf4080e7          	jalr	-1036(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800060e2:	0001c497          	auipc	s1,0x1c
    800060e6:	2d648493          	add	s1,s1,726 # 800223b8 <disk>
    800060ea:	6605                	lui	a2,0x1
    800060ec:	4581                	li	a1,0
    800060ee:	6488                	ld	a0,8(s1)
    800060f0:	ffffb097          	auipc	ra,0xffffb
    800060f4:	bde080e7          	jalr	-1058(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    800060f8:	6605                	lui	a2,0x1
    800060fa:	4581                	li	a1,0
    800060fc:	6888                	ld	a0,16(s1)
    800060fe:	ffffb097          	auipc	ra,0xffffb
    80006102:	bd0080e7          	jalr	-1072(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006106:	100017b7          	lui	a5,0x10001
    8000610a:	4721                	li	a4,8
    8000610c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000610e:	4098                	lw	a4,0(s1)
    80006110:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006114:	40d8                	lw	a4,4(s1)
    80006116:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000611a:	6498                	ld	a4,8(s1)
    8000611c:	0007069b          	sext.w	a3,a4
    80006120:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006124:	9701                	sra	a4,a4,0x20
    80006126:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000612a:	6898                	ld	a4,16(s1)
    8000612c:	0007069b          	sext.w	a3,a4
    80006130:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006134:	9701                	sra	a4,a4,0x20
    80006136:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000613a:	4705                	li	a4,1
    8000613c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000613e:	00e48c23          	sb	a4,24(s1)
    80006142:	00e48ca3          	sb	a4,25(s1)
    80006146:	00e48d23          	sb	a4,26(s1)
    8000614a:	00e48da3          	sb	a4,27(s1)
    8000614e:	00e48e23          	sb	a4,28(s1)
    80006152:	00e48ea3          	sb	a4,29(s1)
    80006156:	00e48f23          	sb	a4,30(s1)
    8000615a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000615e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006162:	0727a823          	sw	s2,112(a5)
}
    80006166:	60e2                	ld	ra,24(sp)
    80006168:	6442                	ld	s0,16(sp)
    8000616a:	64a2                	ld	s1,8(sp)
    8000616c:	6902                	ld	s2,0(sp)
    8000616e:	6105                	add	sp,sp,32
    80006170:	8082                	ret
    panic("could not find virtio disk");
    80006172:	00002517          	auipc	a0,0x2
    80006176:	75e50513          	add	a0,a0,1886 # 800088d0 <syscalls+0x328>
    8000617a:	ffffa097          	auipc	ra,0xffffa
    8000617e:	3c2080e7          	jalr	962(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	76e50513          	add	a0,a0,1902 # 800088f0 <syscalls+0x348>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3b2080e7          	jalr	946(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006192:	00002517          	auipc	a0,0x2
    80006196:	77e50513          	add	a0,a0,1918 # 80008910 <syscalls+0x368>
    8000619a:	ffffa097          	auipc	ra,0xffffa
    8000619e:	3a2080e7          	jalr	930(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800061a2:	00002517          	auipc	a0,0x2
    800061a6:	78e50513          	add	a0,a0,1934 # 80008930 <syscalls+0x388>
    800061aa:	ffffa097          	auipc	ra,0xffffa
    800061ae:	392080e7          	jalr	914(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800061b2:	00002517          	auipc	a0,0x2
    800061b6:	79e50513          	add	a0,a0,1950 # 80008950 <syscalls+0x3a8>
    800061ba:	ffffa097          	auipc	ra,0xffffa
    800061be:	382080e7          	jalr	898(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800061c2:	00002517          	auipc	a0,0x2
    800061c6:	7ae50513          	add	a0,a0,1966 # 80008970 <syscalls+0x3c8>
    800061ca:	ffffa097          	auipc	ra,0xffffa
    800061ce:	372080e7          	jalr	882(ra) # 8000053c <panic>

00000000800061d2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061d2:	7159                	add	sp,sp,-112
    800061d4:	f486                	sd	ra,104(sp)
    800061d6:	f0a2                	sd	s0,96(sp)
    800061d8:	eca6                	sd	s1,88(sp)
    800061da:	e8ca                	sd	s2,80(sp)
    800061dc:	e4ce                	sd	s3,72(sp)
    800061de:	e0d2                	sd	s4,64(sp)
    800061e0:	fc56                	sd	s5,56(sp)
    800061e2:	f85a                	sd	s6,48(sp)
    800061e4:	f45e                	sd	s7,40(sp)
    800061e6:	f062                	sd	s8,32(sp)
    800061e8:	ec66                	sd	s9,24(sp)
    800061ea:	e86a                	sd	s10,16(sp)
    800061ec:	1880                	add	s0,sp,112
    800061ee:	8a2a                	mv	s4,a0
    800061f0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061f2:	00c52c83          	lw	s9,12(a0)
    800061f6:	001c9c9b          	sllw	s9,s9,0x1
    800061fa:	1c82                	sll	s9,s9,0x20
    800061fc:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006200:	0001c517          	auipc	a0,0x1c
    80006204:	2e050513          	add	a0,a0,736 # 800224e0 <disk+0x128>
    80006208:	ffffb097          	auipc	ra,0xffffb
    8000620c:	9ca080e7          	jalr	-1590(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006210:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006212:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006214:	0001cb17          	auipc	s6,0x1c
    80006218:	1a4b0b13          	add	s6,s6,420 # 800223b8 <disk>
  for(int i = 0; i < 3; i++){
    8000621c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000621e:	0001cc17          	auipc	s8,0x1c
    80006222:	2c2c0c13          	add	s8,s8,706 # 800224e0 <disk+0x128>
    80006226:	a095                	j	8000628a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006228:	00fb0733          	add	a4,s6,a5
    8000622c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006230:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006232:	0207c563          	bltz	a5,8000625c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006236:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006238:	0591                	add	a1,a1,4
    8000623a:	05560d63          	beq	a2,s5,80006294 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000623e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006240:	0001c717          	auipc	a4,0x1c
    80006244:	17870713          	add	a4,a4,376 # 800223b8 <disk>
    80006248:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000624a:	01874683          	lbu	a3,24(a4)
    8000624e:	fee9                	bnez	a3,80006228 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006250:	2785                	addw	a5,a5,1
    80006252:	0705                	add	a4,a4,1
    80006254:	fe979be3          	bne	a5,s1,8000624a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006258:	57fd                	li	a5,-1
    8000625a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000625c:	00c05e63          	blez	a2,80006278 <virtio_disk_rw+0xa6>
    80006260:	060a                	sll	a2,a2,0x2
    80006262:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006266:	0009a503          	lw	a0,0(s3)
    8000626a:	00000097          	auipc	ra,0x0
    8000626e:	cfc080e7          	jalr	-772(ra) # 80005f66 <free_desc>
      for(int j = 0; j < i; j++)
    80006272:	0991                	add	s3,s3,4
    80006274:	ffa999e3          	bne	s3,s10,80006266 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006278:	85e2                	mv	a1,s8
    8000627a:	0001c517          	auipc	a0,0x1c
    8000627e:	15650513          	add	a0,a0,342 # 800223d0 <disk+0x18>
    80006282:	ffffc097          	auipc	ra,0xffffc
    80006286:	dcc080e7          	jalr	-564(ra) # 8000204e <sleep>
  for(int i = 0; i < 3; i++){
    8000628a:	f9040993          	add	s3,s0,-112
{
    8000628e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006290:	864a                	mv	a2,s2
    80006292:	b775                	j	8000623e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006294:	f9042503          	lw	a0,-112(s0)
    80006298:	00a50713          	add	a4,a0,10
    8000629c:	0712                	sll	a4,a4,0x4

  if(write)
    8000629e:	0001c797          	auipc	a5,0x1c
    800062a2:	11a78793          	add	a5,a5,282 # 800223b8 <disk>
    800062a6:	00e786b3          	add	a3,a5,a4
    800062aa:	01703633          	snez	a2,s7
    800062ae:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062b0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800062b4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062b8:	f6070613          	add	a2,a4,-160
    800062bc:	6394                	ld	a3,0(a5)
    800062be:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062c0:	00870593          	add	a1,a4,8
    800062c4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062c6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062c8:	0007b803          	ld	a6,0(a5)
    800062cc:	9642                	add	a2,a2,a6
    800062ce:	46c1                	li	a3,16
    800062d0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062d2:	4585                	li	a1,1
    800062d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800062d8:	f9442683          	lw	a3,-108(s0)
    800062dc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062e0:	0692                	sll	a3,a3,0x4
    800062e2:	9836                	add	a6,a6,a3
    800062e4:	058a0613          	add	a2,s4,88
    800062e8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800062ec:	0007b803          	ld	a6,0(a5)
    800062f0:	96c2                	add	a3,a3,a6
    800062f2:	40000613          	li	a2,1024
    800062f6:	c690                	sw	a2,8(a3)
  if(write)
    800062f8:	001bb613          	seqz	a2,s7
    800062fc:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006300:	00166613          	or	a2,a2,1
    80006304:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006308:	f9842603          	lw	a2,-104(s0)
    8000630c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006310:	00250693          	add	a3,a0,2
    80006314:	0692                	sll	a3,a3,0x4
    80006316:	96be                	add	a3,a3,a5
    80006318:	58fd                	li	a7,-1
    8000631a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000631e:	0612                	sll	a2,a2,0x4
    80006320:	9832                	add	a6,a6,a2
    80006322:	f9070713          	add	a4,a4,-112
    80006326:	973e                	add	a4,a4,a5
    80006328:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000632c:	6398                	ld	a4,0(a5)
    8000632e:	9732                	add	a4,a4,a2
    80006330:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006332:	4609                	li	a2,2
    80006334:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006338:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000633c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006340:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006344:	6794                	ld	a3,8(a5)
    80006346:	0026d703          	lhu	a4,2(a3)
    8000634a:	8b1d                	and	a4,a4,7
    8000634c:	0706                	sll	a4,a4,0x1
    8000634e:	96ba                	add	a3,a3,a4
    80006350:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006354:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006358:	6798                	ld	a4,8(a5)
    8000635a:	00275783          	lhu	a5,2(a4)
    8000635e:	2785                	addw	a5,a5,1
    80006360:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006364:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006368:	100017b7          	lui	a5,0x10001
    8000636c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006370:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006374:	0001c917          	auipc	s2,0x1c
    80006378:	16c90913          	add	s2,s2,364 # 800224e0 <disk+0x128>
  while(b->disk == 1) {
    8000637c:	4485                	li	s1,1
    8000637e:	00b79c63          	bne	a5,a1,80006396 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006382:	85ca                	mv	a1,s2
    80006384:	8552                	mv	a0,s4
    80006386:	ffffc097          	auipc	ra,0xffffc
    8000638a:	cc8080e7          	jalr	-824(ra) # 8000204e <sleep>
  while(b->disk == 1) {
    8000638e:	004a2783          	lw	a5,4(s4)
    80006392:	fe9788e3          	beq	a5,s1,80006382 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006396:	f9042903          	lw	s2,-112(s0)
    8000639a:	00290713          	add	a4,s2,2
    8000639e:	0712                	sll	a4,a4,0x4
    800063a0:	0001c797          	auipc	a5,0x1c
    800063a4:	01878793          	add	a5,a5,24 # 800223b8 <disk>
    800063a8:	97ba                	add	a5,a5,a4
    800063aa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063ae:	0001c997          	auipc	s3,0x1c
    800063b2:	00a98993          	add	s3,s3,10 # 800223b8 <disk>
    800063b6:	00491713          	sll	a4,s2,0x4
    800063ba:	0009b783          	ld	a5,0(s3)
    800063be:	97ba                	add	a5,a5,a4
    800063c0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063c4:	854a                	mv	a0,s2
    800063c6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063ca:	00000097          	auipc	ra,0x0
    800063ce:	b9c080e7          	jalr	-1124(ra) # 80005f66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063d2:	8885                	and	s1,s1,1
    800063d4:	f0ed                	bnez	s1,800063b6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063d6:	0001c517          	auipc	a0,0x1c
    800063da:	10a50513          	add	a0,a0,266 # 800224e0 <disk+0x128>
    800063de:	ffffb097          	auipc	ra,0xffffb
    800063e2:	8a8080e7          	jalr	-1880(ra) # 80000c86 <release>
}
    800063e6:	70a6                	ld	ra,104(sp)
    800063e8:	7406                	ld	s0,96(sp)
    800063ea:	64e6                	ld	s1,88(sp)
    800063ec:	6946                	ld	s2,80(sp)
    800063ee:	69a6                	ld	s3,72(sp)
    800063f0:	6a06                	ld	s4,64(sp)
    800063f2:	7ae2                	ld	s5,56(sp)
    800063f4:	7b42                	ld	s6,48(sp)
    800063f6:	7ba2                	ld	s7,40(sp)
    800063f8:	7c02                	ld	s8,32(sp)
    800063fa:	6ce2                	ld	s9,24(sp)
    800063fc:	6d42                	ld	s10,16(sp)
    800063fe:	6165                	add	sp,sp,112
    80006400:	8082                	ret

0000000080006402 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006402:	1101                	add	sp,sp,-32
    80006404:	ec06                	sd	ra,24(sp)
    80006406:	e822                	sd	s0,16(sp)
    80006408:	e426                	sd	s1,8(sp)
    8000640a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000640c:	0001c497          	auipc	s1,0x1c
    80006410:	fac48493          	add	s1,s1,-84 # 800223b8 <disk>
    80006414:	0001c517          	auipc	a0,0x1c
    80006418:	0cc50513          	add	a0,a0,204 # 800224e0 <disk+0x128>
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	7b6080e7          	jalr	1974(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006424:	10001737          	lui	a4,0x10001
    80006428:	533c                	lw	a5,96(a4)
    8000642a:	8b8d                	and	a5,a5,3
    8000642c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000642e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006432:	689c                	ld	a5,16(s1)
    80006434:	0204d703          	lhu	a4,32(s1)
    80006438:	0027d783          	lhu	a5,2(a5)
    8000643c:	04f70863          	beq	a4,a5,8000648c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006440:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006444:	6898                	ld	a4,16(s1)
    80006446:	0204d783          	lhu	a5,32(s1)
    8000644a:	8b9d                	and	a5,a5,7
    8000644c:	078e                	sll	a5,a5,0x3
    8000644e:	97ba                	add	a5,a5,a4
    80006450:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006452:	00278713          	add	a4,a5,2
    80006456:	0712                	sll	a4,a4,0x4
    80006458:	9726                	add	a4,a4,s1
    8000645a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000645e:	e721                	bnez	a4,800064a6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006460:	0789                	add	a5,a5,2
    80006462:	0792                	sll	a5,a5,0x4
    80006464:	97a6                	add	a5,a5,s1
    80006466:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006468:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000646c:	ffffc097          	auipc	ra,0xffffc
    80006470:	c46080e7          	jalr	-954(ra) # 800020b2 <wakeup>

    disk.used_idx += 1;
    80006474:	0204d783          	lhu	a5,32(s1)
    80006478:	2785                	addw	a5,a5,1
    8000647a:	17c2                	sll	a5,a5,0x30
    8000647c:	93c1                	srl	a5,a5,0x30
    8000647e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006482:	6898                	ld	a4,16(s1)
    80006484:	00275703          	lhu	a4,2(a4)
    80006488:	faf71ce3          	bne	a4,a5,80006440 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000648c:	0001c517          	auipc	a0,0x1c
    80006490:	05450513          	add	a0,a0,84 # 800224e0 <disk+0x128>
    80006494:	ffffa097          	auipc	ra,0xffffa
    80006498:	7f2080e7          	jalr	2034(ra) # 80000c86 <release>
}
    8000649c:	60e2                	ld	ra,24(sp)
    8000649e:	6442                	ld	s0,16(sp)
    800064a0:	64a2                	ld	s1,8(sp)
    800064a2:	6105                	add	sp,sp,32
    800064a4:	8082                	ret
      panic("virtio_disk_intr status");
    800064a6:	00002517          	auipc	a0,0x2
    800064aa:	4e250513          	add	a0,a0,1250 # 80008988 <syscalls+0x3e0>
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	08e080e7          	jalr	142(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
