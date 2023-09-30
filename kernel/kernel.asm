
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ba010113          	add	sp,sp,-1120 # 80008ba0 <stack0>
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
    80000054:	a1070713          	add	a4,a4,-1520 # 80008a60 <timer_scratch>
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
    80000066:	e9e78793          	add	a5,a5,-354 # 80005f00 <timervec>
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
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc2d7>
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
    80000188:	a1c50513          	add	a0,a0,-1508 # 80010ba0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a0c48493          	add	s1,s1,-1524 # 80010ba0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	a9c90913          	add	s2,s2,-1380 # 80010c38 <cons+0x98>
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
    800001e2:	9c270713          	add	a4,a4,-1598 # 80010ba0 <cons>
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
    8000022c:	97850513          	add	a0,a0,-1672 # 80010ba0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	96250513          	add	a0,a0,-1694 # 80010ba0 <cons>
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
    80000272:	9cf72523          	sw	a5,-1590(a4) # 80010c38 <cons+0x98>
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
    800002cc:	8d850513          	add	a0,a0,-1832 # 80010ba0 <cons>
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
    800002fa:	8aa50513          	add	a0,a0,-1878 # 80010ba0 <cons>
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
    8000031e:	88670713          	add	a4,a4,-1914 # 80010ba0 <cons>
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
    80000348:	85c78793          	add	a5,a5,-1956 # 80010ba0 <cons>
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
    80000376:	8c67a783          	lw	a5,-1850(a5) # 80010c38 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	81a70713          	add	a4,a4,-2022 # 80010ba0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	80a48493          	add	s1,s1,-2038 # 80010ba0 <cons>
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
    800003d6:	7ce70713          	add	a4,a4,1998 # 80010ba0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	84f72c23          	sw	a5,-1960(a4) # 80010c40 <cons+0xa0>
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
    80000412:	79278793          	add	a5,a5,1938 # 80010ba0 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	80c7a523          	sw	a2,-2038(a5) # 80010c3c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	7fe50513          	add	a0,a0,2046 # 80010c38 <cons+0x98>
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
    80000460:	74450513          	add	a0,a0,1860 # 80010ba0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	f1c78793          	add	a5,a5,-228 # 80021390 <devsw>
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
    8000054c:	7007ac23          	sw	zero,1816(a5) # 80010c60 <pr+0x18>
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
    80000580:	4af72223          	sw	a5,1188(a4) # 80008a20 <panicked>
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
    800005bc:	6a8dad83          	lw	s11,1704(s11) # 80010c60 <pr+0x18>
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
    800005fa:	65250513          	add	a0,a0,1618 # 80010c48 <pr>
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
    80000758:	4f450513          	add	a0,a0,1268 # 80010c48 <pr>
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
    80000774:	4d848493          	add	s1,s1,1240 # 80010c48 <pr>
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
    800007d4:	49850513          	add	a0,a0,1176 # 80010c68 <uart_tx_lock>
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
    80000800:	2247a783          	lw	a5,548(a5) # 80008a20 <panicked>
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
    80000838:	1f47b783          	ld	a5,500(a5) # 80008a28 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	1f473703          	ld	a4,500(a4) # 80008a30 <uart_tx_w>
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
    80000862:	40aa0a13          	add	s4,s4,1034 # 80010c68 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	1c248493          	add	s1,s1,450 # 80008a28 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	1c298993          	add	s3,s3,450 # 80008a30 <uart_tx_w>
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
    800008d0:	39c50513          	add	a0,a0,924 # 80010c68 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1447a783          	lw	a5,324(a5) # 80008a20 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	14a73703          	ld	a4,330(a4) # 80008a30 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	13a7b783          	ld	a5,314(a5) # 80008a28 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	36e98993          	add	s3,s3,878 # 80010c68 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	12648493          	add	s1,s1,294 # 80008a28 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	12690913          	add	s2,s2,294 # 80008a30 <uart_tx_w>
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
    80000934:	33848493          	add	s1,s1,824 # 80010c68 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	0ee7b623          	sd	a4,236(a5) # 80008a30 <uart_tx_w>
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
    800009ba:	2b248493          	add	s1,s1,690 # 80010c68 <uart_tx_lock>
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
    800009fc:	b3078793          	add	a5,a5,-1232 # 80022528 <end>
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
    80000a1c:	28890913          	add	s2,s2,648 # 80010ca0 <kmem>
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
    80000aba:	1ea50513          	add	a0,a0,490 # 80010ca0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	a5e50513          	add	a0,a0,-1442 # 80022528 <end>
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
    80000af0:	1b448493          	add	s1,s1,436 # 80010ca0 <kmem>
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
    80000b08:	19c50513          	add	a0,a0,412 # 80010ca0 <kmem>
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
    80000b34:	17050513          	add	a0,a0,368 # 80010ca0 <kmem>
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
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcad9>
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
    80000e86:	bb670713          	add	a4,a4,-1098 # 80008a38 <started>
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
    80000ebc:	af2080e7          	jalr	-1294(ra) # 800029aa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	080080e7          	jalr	128(ra) # 80005f40 <plicinithart>
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
    80000f34:	a52080e7          	jalr	-1454(ra) # 80002982 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	a72080e7          	jalr	-1422(ra) # 800029aa <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	fea080e7          	jalr	-22(ra) # 80005f2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	ff8080e7          	jalr	-8(ra) # 80005f40 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	1ea080e7          	jalr	490(ra) # 8000313a <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	888080e7          	jalr	-1912(ra) # 800037e0 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	7fe080e7          	jalr	2046(ra) # 8000475e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	0e0080e7          	jalr	224(ra) # 80006048 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d0e080e7          	jalr	-754(ra) # 80001c7e <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	aaf72d23          	sw	a5,-1350(a4) # 80008a38 <started>
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
    80000f96:	aae7b783          	ld	a5,-1362(a5) # 80008a40 <kernel_pagetable>
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
    80001010:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcacf>
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
    80001252:	7ea7b923          	sd	a0,2034(a5) # 80008a40 <kernel_pagetable>
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
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcad8>
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
    8000184a:	f0248493          	add	s1,s1,-254 # 80011748 <proc>
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
    80001864:	8e8a0a13          	add	s4,s4,-1816 # 80017148 <tickslock>
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
    800018e6:	3de50513          	add	a0,a0,990 # 80010cc0 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	add	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	3de50513          	add	a0,a0,990 # 80010cd8 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	00010497          	auipc	s1,0x10
    8000190e:	e3e48493          	add	s1,s1,-450 # 80011748 <proc>
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
    8000192c:	00016997          	auipc	s3,0x16
    80001930:	81c98993          	add	s3,s3,-2020 # 80017148 <tickslock>
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
    8000199a:	35a50513          	add	a0,a0,858 # 80010cf0 <cpus>
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
    800019c2:	30270713          	add	a4,a4,770 # 80010cc0 <pid_lock>
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
    800019fa:	fda7a783          	lw	a5,-38(a5) # 800089d0 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	fc2080e7          	jalr	-62(ra) # 800029c2 <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	add	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	fc07a023          	sw	zero,-64(a5) # 800089d0 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	d46080e7          	jalr	-698(ra) # 80003760 <fsinit>
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
    80001a34:	29090913          	add	s2,s2,656 # 80010cc0 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	f9278793          	add	a5,a5,-110 # 800089d4 <nextpid>
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
    80001bc0:	b8c48493          	add	s1,s1,-1140 # 80011748 <proc>
    80001bc4:	00015917          	auipc	s2,0x15
    80001bc8:	58490913          	add	s2,s2,1412 # 80017148 <tickslock>
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
    80001c96:	daa7bb23          	sd	a0,-586(a5) # 80008a48 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c9a:	03400613          	li	a2,52
    80001c9e:	00007597          	auipc	a1,0x7
    80001ca2:	d4258593          	add	a1,a1,-702 # 800089e0 <initcode>
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
    80001ce0:	4a2080e7          	jalr	1186(ra) # 8000417e <namei>
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
    80001e10:	9e4080e7          	jalr	-1564(ra) # 800047f0 <filedup>
    80001e14:	00a93023          	sd	a0,0(s2)
    80001e18:	b7e5                	j	80001e00 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e1a:	150ab503          	ld	a0,336(s5)
    80001e1e:	00002097          	auipc	ra,0x2
    80001e22:	b7c080e7          	jalr	-1156(ra) # 8000399a <idup>
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
    80001e4e:	e8e48493          	add	s1,s1,-370 # 80010cd8 <wait_lock>
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
    80001ebc:	e0870713          	add	a4,a4,-504 # 80010cc0 <pid_lock>
    80001ec0:	9756                	add	a4,a4,s5
    80001ec2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	e3270713          	add	a4,a4,-462 # 80010cf8 <cpus+0x8>
    80001ece:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed0:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed2:	4b11                	li	s6,4
        c->proc = p;
    80001ed4:	079e                	sll	a5,a5,0x7
    80001ed6:	0000fa17          	auipc	s4,0xf
    80001eda:	deaa0a13          	add	s4,s4,-534 # 80010cc0 <pid_lock>
    80001ede:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee0:	00015917          	auipc	s2,0x15
    80001ee4:	26890913          	add	s2,s2,616 # 80017148 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eec:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef0:	10079073          	csrw	sstatus,a5
    80001ef4:	00010497          	auipc	s1,0x10
    80001ef8:	85448493          	add	s1,s1,-1964 # 80011748 <proc>
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
    80001f32:	9ea080e7          	jalr	-1558(ra) # 80002918 <swtch>
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
    80001f68:	d5c70713          	add	a4,a4,-676 # 80010cc0 <pid_lock>
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
    80001f8e:	d3690913          	add	s2,s2,-714 # 80010cc0 <pid_lock>
    80001f92:	2781                	sext.w	a5,a5
    80001f94:	079e                	sll	a5,a5,0x7
    80001f96:	97ca                	add	a5,a5,s2
    80001f98:	0ac7a983          	lw	s3,172(a5)
    80001f9c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f9e:	2781                	sext.w	a5,a5
    80001fa0:	079e                	sll	a5,a5,0x7
    80001fa2:	0000f597          	auipc	a1,0xf
    80001fa6:	d5658593          	add	a1,a1,-682 # 80010cf8 <cpus+0x8>
    80001faa:	95be                	add	a1,a1,a5
    80001fac:	06048513          	add	a0,s1,96
    80001fb0:	00001097          	auipc	ra,0x1
    80001fb4:	968080e7          	jalr	-1688(ra) # 80002918 <swtch>
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
    800020ca:	68248493          	add	s1,s1,1666 # 80011748 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ce:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d2:	00015917          	auipc	s2,0x15
    800020d6:	07690913          	add	s2,s2,118 # 80017148 <tickslock>
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
    8000213e:	60e48493          	add	s1,s1,1550 # 80011748 <proc>
      pp->parent = initproc;
    80002142:	00007a17          	auipc	s4,0x7
    80002146:	906a0a13          	add	s4,s4,-1786 # 80008a48 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000214a:	00015997          	auipc	s3,0x15
    8000214e:	ffe98993          	add	s3,s3,-2 # 80017148 <tickslock>
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
    800021a2:	8aa7b783          	ld	a5,-1878(a5) # 80008a48 <initproc>
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
    800021c6:	680080e7          	jalr	1664(ra) # 80004842 <fileclose>
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
    800021de:	1a4080e7          	jalr	420(ra) # 8000437e <begin_op>
  iput(p->cwd);
    800021e2:	1509b503          	ld	a0,336(s3)
    800021e6:	00002097          	auipc	ra,0x2
    800021ea:	9ac080e7          	jalr	-1620(ra) # 80003b92 <iput>
  end_op();
    800021ee:	00002097          	auipc	ra,0x2
    800021f2:	20a080e7          	jalr	522(ra) # 800043f8 <end_op>
  p->cwd = 0;
    800021f6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021fa:	0000f497          	auipc	s1,0xf
    800021fe:	ade48493          	add	s1,s1,-1314 # 80010cd8 <wait_lock>
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
    8000226c:	4e048493          	add	s1,s1,1248 # 80011748 <proc>
    80002270:	00015997          	auipc	s3,0x15
    80002274:	ed898993          	add	s3,s3,-296 # 80017148 <tickslock>
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
    80002350:	98c50513          	add	a0,a0,-1652 # 80010cd8 <wait_lock>
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
    80002366:	de698993          	add	s3,s3,-538 # 80017148 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000236a:	0000fc17          	auipc	s8,0xf
    8000236e:	96ec0c13          	add	s8,s8,-1682 # 80010cd8 <wait_lock>
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
    800023ac:	93050513          	add	a0,a0,-1744 # 80010cd8 <wait_lock>
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
    800023e0:	8fc50513          	add	a0,a0,-1796 # 80010cd8 <wait_lock>
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
    8000243c:	31048493          	add	s1,s1,784 # 80011748 <proc>
    80002440:	bf65                	j	800023f8 <wait+0xd0>
      release(&wait_lock);
    80002442:	0000f517          	auipc	a0,0xf
    80002446:	89650513          	add	a0,a0,-1898 # 80010cd8 <wait_lock>
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
    8000252c:	37848493          	add	s1,s1,888 # 800118a0 <proc+0x158>
    80002530:	00015917          	auipc	s2,0x15
    80002534:	d7090913          	add	s2,s2,-656 # 800172a0 <bcache+0x140>
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
    80002556:	ef6b8b93          	add	s7,s7,-266 # 80008448 <states.0>
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
ringbuf(const char *name, int open, uint64 addr)
{
    800025fa:	714d                	add	sp,sp,-336
    800025fc:	e686                	sd	ra,328(sp)
    800025fe:	e2a2                	sd	s0,320(sp)
    80002600:	fe26                	sd	s1,312(sp)
    80002602:	fa4a                	sd	s2,304(sp)
    80002604:	f64e                	sd	s3,296(sp)
    80002606:	f252                	sd	s4,288(sp)
    80002608:	ee56                	sd	s5,280(sp)
    8000260a:	ea5a                	sd	s6,272(sp)
    8000260c:	e65e                	sd	s7,264(sp)
    8000260e:	e262                	sd	s8,256(sp)
    80002610:	fde6                	sd	s9,248(sp)
    80002612:	f9ea                	sd	s10,240(sp)
    80002614:	f5ee                	sd	s11,232(sp)
    80002616:	0a80                	add	s0,sp,336
    80002618:	8b2a                	mv	s6,a0
    8000261a:	8dae                	mv	s11,a1
    8000261c:	eac43c23          	sd	a2,-328(s0)
  struct ringbuf *rb;
  int ringbuf_exists = 0, ringbuf_count = 0;

  // Step 1: Check if maximum ringbuf allocated.
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    80002620:	0000f917          	auipc	s2,0xf
    80002624:	ad490913          	add	s2,s2,-1324 # 800110f4 <ringbufs+0x4>
    80002628:	0000f997          	auipc	s3,0xf
    8000262c:	10c98993          	add	s3,s3,268 # 80011734 <ringbuf_lock+0x4>
{
    80002630:	84ca                	mv	s1,s2
  int ringbuf_exists = 0, ringbuf_count = 0;
    80002632:	4a81                	li	s5,0
    if(strcmp(rb->name, "")) ringbuf_count++; // Ringbuf has name then it is allocated.
    80002634:	00006a17          	auipc	s4,0x6
    80002638:	eb4a0a13          	add	s4,s4,-332 # 800084e8 <states.0+0xa0>
    8000263c:	a029                	j	80002646 <ringbuf+0x4c>
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    8000263e:	0a048493          	add	s1,s1,160
    80002642:	01348b63          	beq	s1,s3,80002658 <ringbuf+0x5e>
    if(strcmp(rb->name, "")) ringbuf_count++; // Ringbuf has name then it is allocated.
    80002646:	85d2                	mv	a1,s4
    80002648:	8526                	mv	a0,s1
    8000264a:	00000097          	auipc	ra,0x0
    8000264e:	f68080e7          	jalr	-152(ra) # 800025b2 <strcmp>
    80002652:	d575                	beqz	a0,8000263e <ringbuf+0x44>
    80002654:	2a85                	addw	s5,s5,1
    80002656:	b7e5                	j	8000263e <ringbuf+0x44>
  }

  if (ringbuf_count >= MAX_RINGBUFS) {
    80002658:	47a5                	li	a5,9
    8000265a:	0757c263          	blt	a5,s5,800026be <ringbuf+0xc4>
    return -1;
  }

  // Step 2: Check if ringbuf already exists else create and append ringbufs.
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    if (strcmp(rb->name, name) == 0) {
    8000265e:	85da                	mv	a1,s6
    80002660:	854a                	mv	a0,s2
    80002662:	00000097          	auipc	ra,0x0
    80002666:	f50080e7          	jalr	-176(ra) # 800025b2 <strcmp>
    8000266a:	26050363          	beqz	a0,800028d0 <ringbuf+0x2d6>
  for(rb = ringbufs; rb < &ringbufs[MAX_RINGBUFS]; rb++) {
    8000266e:	0a090913          	add	s2,s2,160
    80002672:	ff3916e3          	bne	s2,s3,8000265e <ringbuf+0x64>
    }
  }
  
  if (!ringbuf_exists) {
    // Does not exists create and append.
    printf("creating new ringbuf: %s\n", name);
    80002676:	85da                	mv	a1,s6
    80002678:	00006517          	auipc	a0,0x6
    8000267c:	d8050513          	add	a0,a0,-640 # 800083f8 <digits+0x3b8>
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	f06080e7          	jalr	-250(ra) # 80000586 <printf>
    struct ringbuf new_ringbuf;
    new_ringbuf.refcount = 0;
    80002688:	ee042823          	sw	zero,-272(s0)
    strcpy( (char *) new_ringbuf.name, (char *) name); // copy name
    8000268c:	85da                	mv	a1,s6
    8000268e:	ef440513          	add	a0,s0,-268
    80002692:	00000097          	auipc	ra,0x0
    80002696:	f4c080e7          	jalr	-180(ra) # 800025de <strcpy>

    void *mem;
    void **abs = new_ringbuf.buf;
    int count = 0;
    uint64 a, pg, base, va0;
    struct proc *pr = myproc();
    8000269a:	fffff097          	auipc	ra,0xfffff
    8000269e:	30c080e7          	jalr	780(ra) # 800019a6 <myproc>
    800026a2:	892a                	mv	s2,a0

    // MAX virtual address - trampoline - trapframe - gurad page.
    //base = MAXVA - PGSIZE - PGSIZE - PGSIZE;
    base = TRAPFRAME - PGSIZE;
    va0 = PGROUNDUP(base);
    800026a4:	040004b7          	lui	s1,0x4000
    800026a8:	14f5                	add	s1,s1,-3 # 3fffffd <_entry-0x7c000003>
    800026aa:	04b2                	sll	s1,s1,0xc
    800026ac:	ee943023          	sd	s1,-288(s0)
    int count = 0;
    800026b0:	4981                	li	s3,0
        if (count == 18) {
          printf("found %d pages end: %p\n", count, a);
          break;
        }
      } else {
        count = 0;
    800026b2:	4c81                	li	s9,0
        if (count == 18) {
    800026b4:	4c49                	li	s8,18
    for (a = va0; a > KERNBASE; a -= PGSIZE) {
    800026b6:	7bfd                	lui	s7,0xfffff
    800026b8:	4a05                	li	s4,1
    800026ba:	0a7e                	sll	s4,s4,0x1f
    800026bc:	a099                	j	80002702 <ringbuf+0x108>
    printf("Maximum ringbuf allocated. # ringbufs: %d",  ringbuf_lock);
    800026be:	0000f797          	auipc	a5,0xf
    800026c2:	60278793          	add	a5,a5,1538 # 80011cc0 <proc+0x578>
    800026c6:	a707b703          	ld	a4,-1424(a5)
    800026ca:	ece43023          	sd	a4,-320(s0)
    800026ce:	a787b703          	ld	a4,-1416(a5)
    800026d2:	ece43423          	sd	a4,-312(s0)
    800026d6:	a807b783          	ld	a5,-1408(a5)
    800026da:	ecf43823          	sd	a5,-304(s0)
    800026de:	ec040593          	add	a1,s0,-320
    800026e2:	00006517          	auipc	a0,0x6
    800026e6:	bb650513          	add	a0,a0,-1098 # 80008298 <digits+0x258>
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	e9c080e7          	jalr	-356(ra) # 80000586 <printf>
    return -1;
    800026f2:	557d                	li	a0,-1
    800026f4:	a419                	j	800028fa <ringbuf+0x300>
        va0 = a;
    800026f6:	ee943023          	sd	s1,-288(s0)
        count = 0;
    800026fa:	89e6                	mv	s3,s9
    for (a = va0; a > KERNBASE; a -= PGSIZE) {
    800026fc:	94de                	add	s1,s1,s7
    800026fe:	03448763          	beq	s1,s4,8000272c <ringbuf+0x132>
      pg = walkaddr(pr->pagetable, a);
    80002702:	85a6                	mv	a1,s1
    80002704:	05093503          	ld	a0,80(s2)
    80002708:	fffff097          	auipc	ra,0xfffff
    8000270c:	94e080e7          	jalr	-1714(ra) # 80001056 <walkaddr>
      if (pg == 0) {
    80002710:	f17d                	bnez	a0,800026f6 <ringbuf+0xfc>
        count++;
    80002712:	2985                	addw	s3,s3,1
        if (count == 18) {
    80002714:	ff8994e3          	bne	s3,s8,800026fc <ringbuf+0x102>
          printf("found %d pages end: %p\n", count, a);
    80002718:	8626                	mv	a2,s1
    8000271a:	45c9                	li	a1,18
    8000271c:	00006517          	auipc	a0,0x6
    80002720:	bac50513          	add	a0,a0,-1108 # 800082c8 <digits+0x288>
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	e62080e7          	jalr	-414(ra) # 80000586 <printf>
      }
    }

    printf("base of %d pages: %p\n", count, base);
    8000272c:	04000637          	lui	a2,0x4000
    80002730:	1675                	add	a2,a2,-3 # 3fffffd <_entry-0x7c000003>
    80002732:	0632                	sll	a2,a2,0xc
    80002734:	85ce                	mv	a1,s3
    80002736:	00006517          	auipc	a0,0x6
    8000273a:	baa50513          	add	a0,a0,-1110 # 800082e0 <digits+0x2a0>
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	e48080e7          	jalr	-440(ra) # 80000586 <printf>
    // start from 1 because allocate gurad page at top
    for (int i = 1 ; i <= 16; i++ ) {
    80002746:	f0840b93          	add	s7,s0,-248
    printf("base of %d pages: %p\n", count, base);
    8000274a:	4a05                	li	s4,1
        uvmdealloc(pr->pagetable, a, PGSIZE);
        return -1;
      }

      memset(mem, 0, PGSIZE);
      printf("allocated page i: %d, va: %p\n", i, a);
    8000274c:	00006c97          	auipc	s9,0x6
    80002750:	bacc8c93          	add	s9,s9,-1108 # 800082f8 <digits+0x2b8>
    for (int i = 1 ; i <= 16; i++ ) {
    80002754:	4d45                	li	s10,17
    80002756:	000a0c1b          	sext.w	s8,s4
      a = va0 - (i * PGSIZE);
    8000275a:	00ca1793          	sll	a5,s4,0xc
    8000275e:	ee043983          	ld	s3,-288(s0)
    80002762:	40f989b3          	sub	s3,s3,a5
      mem = kalloc(); // Physcall address
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	37c080e7          	jalr	892(ra) # 80000ae2 <kalloc>
    8000276e:	84aa                	mv	s1,a0
      if(mem == 0){
    80002770:	10050f63          	beqz	a0,8000288e <ringbuf+0x294>
      memset(mem, 0, PGSIZE);
    80002774:	6605                	lui	a2,0x1
    80002776:	4581                	li	a1,0
    80002778:	ffffe097          	auipc	ra,0xffffe
    8000277c:	556080e7          	jalr	1366(ra) # 80000cce <memset>
      printf("allocated page i: %d, va: %p\n", i, a);
    80002780:	864e                	mv	a2,s3
    80002782:	85e2                	mv	a1,s8
    80002784:	8566                	mv	a0,s9
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	e00080e7          	jalr	-512(ra) # 80000586 <printf>

      // TODO handle unmap of previoous pages.
      if(mappages(pr->pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_W|PTE_U|PTE_X) != 0){
    8000278e:	4779                	li	a4,30
    80002790:	86a6                	mv	a3,s1
    80002792:	6605                	lui	a2,0x1
    80002794:	85ce                	mv	a1,s3
    80002796:	05093503          	ld	a0,80(s2)
    8000279a:	fffff097          	auipc	ra,0xfffff
    8000279e:	8fe080e7          	jalr	-1794(ra) # 80001098 <mappages>
    800027a2:	10051063          	bnez	a0,800028a2 <ringbuf+0x2a8>
      }
      
      // I do not have to touch the buffer.
      // I think i need because we need it to reallocate same pages for new process.
      //new_ringbuf.buf[i-1] = mem; 
      *(abs + i - 1) = mem;
    800027a6:	009bb023          	sd	s1,0(s7) # fffffffffffff000 <end+0xffffffff7ffdcad8>
    for (int i = 1 ; i <= 16; i++ ) {
    800027aa:	0a05                	add	s4,s4,1
    800027ac:	0ba1                	add	s7,s7,8
    800027ae:	fbaa14e3          	bne	s4,s10,80002756 <ringbuf+0x15c>
    }
    char *str = "Hello";
    strcpy( (char *) mem, str);
    800027b2:	00006597          	auipc	a1,0x6
    800027b6:	b6658593          	add	a1,a1,-1178 # 80008318 <digits+0x2d8>
    800027ba:	8526                	mv	a0,s1
    800027bc:	00000097          	auipc	ra,0x0
    800027c0:	e22080e7          	jalr	-478(ra) # 800025de <strcpy>

    new_ringbuf.book = &va0 - (17 * PGSIZE);
    800027c4:	fff787b7          	lui	a5,0xfff78
    800027c8:	ee040713          	add	a4,s0,-288
    800027cc:	97ba                	add	a5,a5,a4
    800027ce:	f8f43423          	sd	a5,-120(s0)
   //strcpy( (char *) new_ringbuf.buf[15], str);
    printf("mem: %s\n", (char *) new_ringbuf.buf[15]);
    800027d2:	f8043583          	ld	a1,-128(s0)
    800027d6:	00006517          	auipc	a0,0x6
    800027da:	b4a50513          	add	a0,a0,-1206 # 80008320 <digits+0x2e0>
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	da8080e7          	jalr	-600(ra) # 80000586 <printf>
    uint64 temp = va0 - (16 * PGSIZE);
    800027e6:	7741                	lui	a4,0xffff0
    800027e8:	ee043783          	ld	a5,-288(s0)
    800027ec:	97ba                	add	a5,a5,a4
    800027ee:	eef43423          	sd	a5,-280(s0)
    if(copyout(myproc()->pagetable, addr, (char*)&(temp), sizeof(uint64)) < 0) {
    800027f2:	fffff097          	auipc	ra,0xfffff
    800027f6:	1b4080e7          	jalr	436(ra) # 800019a6 <myproc>
    800027fa:	46a1                	li	a3,8
    800027fc:	ee840613          	add	a2,s0,-280
    80002800:	eb843583          	ld	a1,-328(s0)
    80002804:	6928                	ld	a0,80(a0)
    80002806:	fffff097          	auipc	ra,0xfffff
    8000280a:	e60080e7          	jalr	-416(ra) # 80001666 <copyout>
    8000280e:	0a054863          	bltz	a0,800028be <ringbuf+0x2c4>
    //   printf("pa addr failed: %p\n", pa_addr);
    //   return -1;
    // }

    // *addr = va0;
    printf("before addr: %p, temp: %p, buf: %p\n", addr, temp, new_ringbuf.buf[0]);
    80002812:	f0843683          	ld	a3,-248(s0)
    80002816:	ee843603          	ld	a2,-280(s0)
    8000281a:	eb843483          	ld	s1,-328(s0)
    8000281e:	85a6                	mv	a1,s1
    80002820:	00006517          	auipc	a0,0x6
    80002824:	b3850513          	add	a0,a0,-1224 # 80008358 <digits+0x318>
    80002828:	ffffe097          	auipc	ra,0xffffe
    8000282c:	d5e080e7          	jalr	-674(ra) # 80000586 <printf>
    // Question:  we need to send physical address to userspace?
    // Question:  in buf of ringbuf struct we need to store physical addr of pages? If so for transimitting data we need to use PA right?
    // Question:  how to map twice? Is it two 32 byte chunks or 64 chunks?
    // Question:  user process panics at the return.

    printf("book: %p, base: %p, addr: %p\n", new_ringbuf.book, base, (uint64 )addr);
    80002830:	86a6                	mv	a3,s1
    80002832:	04000637          	lui	a2,0x4000
    80002836:	1675                	add	a2,a2,-3 # 3fffffd <_entry-0x7c000003>
    80002838:	0632                	sll	a2,a2,0xc
    8000283a:	fff785b7          	lui	a1,0xfff78
    8000283e:	ee040793          	add	a5,s0,-288
    80002842:	95be                	add	a1,a1,a5
    80002844:	00006517          	auipc	a0,0x6
    80002848:	b3c50513          	add	a0,a0,-1220 # 80008380 <digits+0x340>
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	d3a080e7          	jalr	-710(ra) # 80000586 <printf>
    ringbufs[++ringbuf_count] = new_ringbuf;
    80002854:	2a85                	addw	s5,s5,1
    80002856:	002a9793          	sll	a5,s5,0x2
    8000285a:	97d6                	add	a5,a5,s5
    8000285c:	0796                	sll	a5,a5,0x5
    8000285e:	ef040713          	add	a4,s0,-272
    80002862:	0000f697          	auipc	a3,0xf
    80002866:	88e68693          	add	a3,a3,-1906 # 800110f0 <ringbufs>
    8000286a:	97b6                	add	a5,a5,a3
    8000286c:	f9040813          	add	a6,s0,-112
    80002870:	6308                	ld	a0,0(a4)
    80002872:	670c                	ld	a1,8(a4)
    80002874:	6b10                	ld	a2,16(a4)
    80002876:	6f14                	ld	a3,24(a4)
    80002878:	e388                	sd	a0,0(a5)
    8000287a:	e78c                	sd	a1,8(a5)
    8000287c:	eb90                	sd	a2,16(a5)
    8000287e:	ef94                	sd	a3,24(a5)
    80002880:	02070713          	add	a4,a4,32 # ffffffffffff0020 <end+0xffffffff7ffcdaf8>
    80002884:	02078793          	add	a5,a5,32 # fffffffffff78020 <end+0xffffffff7ff55af8>
    80002888:	ff0714e3          	bne	a4,a6,80002870 <ringbuf+0x276>
    8000288c:	a899                	j	800028e2 <ringbuf+0x2e8>
        uvmdealloc(pr->pagetable, a, PGSIZE);
    8000288e:	6605                	lui	a2,0x1
    80002890:	85ce                	mv	a1,s3
    80002892:	05093503          	ld	a0,80(s2)
    80002896:	fffff097          	auipc	ra,0xfffff
    8000289a:	b2c080e7          	jalr	-1236(ra) # 800013c2 <uvmdealloc>
        return -1;
    8000289e:	557d                	li	a0,-1
    800028a0:	a8a9                	j	800028fa <ringbuf+0x300>
        kfree(mem);
    800028a2:	8526                	mv	a0,s1
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	140080e7          	jalr	320(ra) # 800009e4 <kfree>
        uvmdealloc(pr->pagetable, a, PGSIZE);
    800028ac:	6605                	lui	a2,0x1
    800028ae:	85ce                	mv	a1,s3
    800028b0:	05093503          	ld	a0,80(s2)
    800028b4:	fffff097          	auipc	ra,0xfffff
    800028b8:	b0e080e7          	jalr	-1266(ra) # 800013c2 <uvmdealloc>
        return -1;
    800028bc:	b7cd                	j	8000289e <ringbuf+0x2a4>
      printf("Failed to perform copyout operation\n");
    800028be:	00006517          	auipc	a0,0x6
    800028c2:	a7250513          	add	a0,a0,-1422 # 80008330 <digits+0x2f0>
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	cc0080e7          	jalr	-832(ra) # 80000586 <printf>
      return -1;
    800028ce:	bfc1                	j	8000289e <ringbuf+0x2a4>
  } else {
    // Already exists return the already mapped address space.
    printf("already exists ringbuf: %s\n", name);
    800028d0:	85da                	mv	a1,s6
    800028d2:	00006517          	auipc	a0,0x6
    800028d6:	b0650513          	add	a0,a0,-1274 # 800083d8 <digits+0x398>
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	cac080e7          	jalr	-852(ra) # 80000586 <printf>
  }

  printf("recieved name: %s, open: %d, current ringbuf_count: %d\n", name, open, ringbuf_count);
    800028e2:	86d6                	mv	a3,s5
    800028e4:	866e                	mv	a2,s11
    800028e6:	85da                	mv	a1,s6
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	ab850513          	add	a0,a0,-1352 # 800083a0 <digits+0x360>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	c96080e7          	jalr	-874(ra) # 80000586 <printf>
  return 0;
    800028f8:	4501                	li	a0,0
    800028fa:	60b6                	ld	ra,328(sp)
    800028fc:	6416                	ld	s0,320(sp)
    800028fe:	74f2                	ld	s1,312(sp)
    80002900:	7952                	ld	s2,304(sp)
    80002902:	79b2                	ld	s3,296(sp)
    80002904:	7a12                	ld	s4,288(sp)
    80002906:	6af2                	ld	s5,280(sp)
    80002908:	6b52                	ld	s6,272(sp)
    8000290a:	6bb2                	ld	s7,264(sp)
    8000290c:	6c12                	ld	s8,256(sp)
    8000290e:	7cee                	ld	s9,248(sp)
    80002910:	7d4e                	ld	s10,240(sp)
    80002912:	7dae                	ld	s11,232(sp)
    80002914:	6171                	add	sp,sp,336
    80002916:	8082                	ret

0000000080002918 <swtch>:
    80002918:	00153023          	sd	ra,0(a0)
    8000291c:	00253423          	sd	sp,8(a0)
    80002920:	e900                	sd	s0,16(a0)
    80002922:	ed04                	sd	s1,24(a0)
    80002924:	03253023          	sd	s2,32(a0)
    80002928:	03353423          	sd	s3,40(a0)
    8000292c:	03453823          	sd	s4,48(a0)
    80002930:	03553c23          	sd	s5,56(a0)
    80002934:	05653023          	sd	s6,64(a0)
    80002938:	05753423          	sd	s7,72(a0)
    8000293c:	05853823          	sd	s8,80(a0)
    80002940:	05953c23          	sd	s9,88(a0)
    80002944:	07a53023          	sd	s10,96(a0)
    80002948:	07b53423          	sd	s11,104(a0)
    8000294c:	0005b083          	ld	ra,0(a1) # fffffffffff78000 <end+0xffffffff7ff55ad8>
    80002950:	0085b103          	ld	sp,8(a1)
    80002954:	6980                	ld	s0,16(a1)
    80002956:	6d84                	ld	s1,24(a1)
    80002958:	0205b903          	ld	s2,32(a1)
    8000295c:	0285b983          	ld	s3,40(a1)
    80002960:	0305ba03          	ld	s4,48(a1)
    80002964:	0385ba83          	ld	s5,56(a1)
    80002968:	0405bb03          	ld	s6,64(a1)
    8000296c:	0485bb83          	ld	s7,72(a1)
    80002970:	0505bc03          	ld	s8,80(a1)
    80002974:	0585bc83          	ld	s9,88(a1)
    80002978:	0605bd03          	ld	s10,96(a1)
    8000297c:	0685bd83          	ld	s11,104(a1)
    80002980:	8082                	ret

0000000080002982 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002982:	1141                	add	sp,sp,-16
    80002984:	e406                	sd	ra,8(sp)
    80002986:	e022                	sd	s0,0(sp)
    80002988:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000298a:	00006597          	auipc	a1,0x6
    8000298e:	aee58593          	add	a1,a1,-1298 # 80008478 <states.0+0x30>
    80002992:	00014517          	auipc	a0,0x14
    80002996:	7b650513          	add	a0,a0,1974 # 80017148 <tickslock>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	1a8080e7          	jalr	424(ra) # 80000b42 <initlock>
}
    800029a2:	60a2                	ld	ra,8(sp)
    800029a4:	6402                	ld	s0,0(sp)
    800029a6:	0141                	add	sp,sp,16
    800029a8:	8082                	ret

00000000800029aa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029aa:	1141                	add	sp,sp,-16
    800029ac:	e422                	sd	s0,8(sp)
    800029ae:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029b0:	00003797          	auipc	a5,0x3
    800029b4:	4c078793          	add	a5,a5,1216 # 80005e70 <kernelvec>
    800029b8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029bc:	6422                	ld	s0,8(sp)
    800029be:	0141                	add	sp,sp,16
    800029c0:	8082                	ret

00000000800029c2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029c2:	1141                	add	sp,sp,-16
    800029c4:	e406                	sd	ra,8(sp)
    800029c6:	e022                	sd	s0,0(sp)
    800029c8:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800029ca:	fffff097          	auipc	ra,0xfffff
    800029ce:	fdc080e7          	jalr	-36(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029d6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029dc:	00004697          	auipc	a3,0x4
    800029e0:	62468693          	add	a3,a3,1572 # 80007000 <_trampoline>
    800029e4:	00004717          	auipc	a4,0x4
    800029e8:	61c70713          	add	a4,a4,1564 # 80007000 <_trampoline>
    800029ec:	8f15                	sub	a4,a4,a3
    800029ee:	040007b7          	lui	a5,0x4000
    800029f2:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800029f4:	07b2                	sll	a5,a5,0xc
    800029f6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029fc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029fe:	18002673          	csrr	a2,satp
    80002a02:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a04:	6d30                	ld	a2,88(a0)
    80002a06:	6138                	ld	a4,64(a0)
    80002a08:	6585                	lui	a1,0x1
    80002a0a:	972e                	add	a4,a4,a1
    80002a0c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a0e:	6d38                	ld	a4,88(a0)
    80002a10:	00000617          	auipc	a2,0x0
    80002a14:	13460613          	add	a2,a2,308 # 80002b44 <usertrap>
    80002a18:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a1a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a1c:	8612                	mv	a2,tp
    80002a1e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a20:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a24:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a28:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a30:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a32:	6f18                	ld	a4,24(a4)
    80002a34:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a38:	6928                	ld	a0,80(a0)
    80002a3a:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a3c:	00004717          	auipc	a4,0x4
    80002a40:	66070713          	add	a4,a4,1632 # 8000709c <userret>
    80002a44:	8f15                	sub	a4,a4,a3
    80002a46:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a48:	577d                	li	a4,-1
    80002a4a:	177e                	sll	a4,a4,0x3f
    80002a4c:	8d59                	or	a0,a0,a4
    80002a4e:	9782                	jalr	a5
}
    80002a50:	60a2                	ld	ra,8(sp)
    80002a52:	6402                	ld	s0,0(sp)
    80002a54:	0141                	add	sp,sp,16
    80002a56:	8082                	ret

0000000080002a58 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a58:	1101                	add	sp,sp,-32
    80002a5a:	ec06                	sd	ra,24(sp)
    80002a5c:	e822                	sd	s0,16(sp)
    80002a5e:	e426                	sd	s1,8(sp)
    80002a60:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002a62:	00014497          	auipc	s1,0x14
    80002a66:	6e648493          	add	s1,s1,1766 # 80017148 <tickslock>
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	166080e7          	jalr	358(ra) # 80000bd2 <acquire>
  ticks++;
    80002a74:	00006517          	auipc	a0,0x6
    80002a78:	fdc50513          	add	a0,a0,-36 # 80008a50 <ticks>
    80002a7c:	411c                	lw	a5,0(a0)
    80002a7e:	2785                	addw	a5,a5,1
    80002a80:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	630080e7          	jalr	1584(ra) # 800020b2 <wakeup>
  release(&tickslock);
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	1fa080e7          	jalr	506(ra) # 80000c86 <release>
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	add	sp,sp,32
    80002a9c:	8082                	ret

0000000080002a9e <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a9e:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002aa2:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002aa4:	0807df63          	bgez	a5,80002b42 <devintr+0xa4>
{
    80002aa8:	1101                	add	sp,sp,-32
    80002aaa:	ec06                	sd	ra,24(sp)
    80002aac:	e822                	sd	s0,16(sp)
    80002aae:	e426                	sd	s1,8(sp)
    80002ab0:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002ab2:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002ab6:	46a5                	li	a3,9
    80002ab8:	00d70d63          	beq	a4,a3,80002ad2 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002abc:	577d                	li	a4,-1
    80002abe:	177e                	sll	a4,a4,0x3f
    80002ac0:	0705                	add	a4,a4,1
    return 0;
    80002ac2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ac4:	04e78e63          	beq	a5,a4,80002b20 <devintr+0x82>
  }
}
    80002ac8:	60e2                	ld	ra,24(sp)
    80002aca:	6442                	ld	s0,16(sp)
    80002acc:	64a2                	ld	s1,8(sp)
    80002ace:	6105                	add	sp,sp,32
    80002ad0:	8082                	ret
    int irq = plic_claim();
    80002ad2:	00003097          	auipc	ra,0x3
    80002ad6:	4a6080e7          	jalr	1190(ra) # 80005f78 <plic_claim>
    80002ada:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002adc:	47a9                	li	a5,10
    80002ade:	02f50763          	beq	a0,a5,80002b0c <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002ae2:	4785                	li	a5,1
    80002ae4:	02f50963          	beq	a0,a5,80002b16 <devintr+0x78>
    return 1;
    80002ae8:	4505                	li	a0,1
    } else if(irq){
    80002aea:	dcf9                	beqz	s1,80002ac8 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002aec:	85a6                	mv	a1,s1
    80002aee:	00006517          	auipc	a0,0x6
    80002af2:	99250513          	add	a0,a0,-1646 # 80008480 <states.0+0x38>
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	a90080e7          	jalr	-1392(ra) # 80000586 <printf>
      plic_complete(irq);
    80002afe:	8526                	mv	a0,s1
    80002b00:	00003097          	auipc	ra,0x3
    80002b04:	49c080e7          	jalr	1180(ra) # 80005f9c <plic_complete>
    return 1;
    80002b08:	4505                	li	a0,1
    80002b0a:	bf7d                	j	80002ac8 <devintr+0x2a>
      uartintr();
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	e88080e7          	jalr	-376(ra) # 80000994 <uartintr>
    if(irq)
    80002b14:	b7ed                	j	80002afe <devintr+0x60>
      virtio_disk_intr();
    80002b16:	00004097          	auipc	ra,0x4
    80002b1a:	94c080e7          	jalr	-1716(ra) # 80006462 <virtio_disk_intr>
    if(irq)
    80002b1e:	b7c5                	j	80002afe <devintr+0x60>
    if(cpuid() == 0){
    80002b20:	fffff097          	auipc	ra,0xfffff
    80002b24:	e5a080e7          	jalr	-422(ra) # 8000197a <cpuid>
    80002b28:	c901                	beqz	a0,80002b38 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b2a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b2e:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b30:	14479073          	csrw	sip,a5
    return 2;
    80002b34:	4509                	li	a0,2
    80002b36:	bf49                	j	80002ac8 <devintr+0x2a>
      clockintr();
    80002b38:	00000097          	auipc	ra,0x0
    80002b3c:	f20080e7          	jalr	-224(ra) # 80002a58 <clockintr>
    80002b40:	b7ed                	j	80002b2a <devintr+0x8c>
}
    80002b42:	8082                	ret

0000000080002b44 <usertrap>:
{
    80002b44:	1101                	add	sp,sp,-32
    80002b46:	ec06                	sd	ra,24(sp)
    80002b48:	e822                	sd	s0,16(sp)
    80002b4a:	e426                	sd	s1,8(sp)
    80002b4c:	e04a                	sd	s2,0(sp)
    80002b4e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b50:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b54:	1007f793          	and	a5,a5,256
    80002b58:	e3b1                	bnez	a5,80002b9c <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b5a:	00003797          	auipc	a5,0x3
    80002b5e:	31678793          	add	a5,a5,790 # 80005e70 <kernelvec>
    80002b62:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b66:	fffff097          	auipc	ra,0xfffff
    80002b6a:	e40080e7          	jalr	-448(ra) # 800019a6 <myproc>
    80002b6e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b70:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b72:	14102773          	csrr	a4,sepc
    80002b76:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b78:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b7c:	47a1                	li	a5,8
    80002b7e:	02f70763          	beq	a4,a5,80002bac <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002b82:	00000097          	auipc	ra,0x0
    80002b86:	f1c080e7          	jalr	-228(ra) # 80002a9e <devintr>
    80002b8a:	892a                	mv	s2,a0
    80002b8c:	c151                	beqz	a0,80002c10 <usertrap+0xcc>
  if(killed(p))
    80002b8e:	8526                	mv	a0,s1
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	766080e7          	jalr	1894(ra) # 800022f6 <killed>
    80002b98:	c929                	beqz	a0,80002bea <usertrap+0xa6>
    80002b9a:	a099                	j	80002be0 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002b9c:	00006517          	auipc	a0,0x6
    80002ba0:	90450513          	add	a0,a0,-1788 # 800084a0 <states.0+0x58>
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	998080e7          	jalr	-1640(ra) # 8000053c <panic>
    if(killed(p))
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	74a080e7          	jalr	1866(ra) # 800022f6 <killed>
    80002bb4:	e921                	bnez	a0,80002c04 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002bb6:	6cb8                	ld	a4,88(s1)
    80002bb8:	6f1c                	ld	a5,24(a4)
    80002bba:	0791                	add	a5,a5,4
    80002bbc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bc2:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc6:	10079073          	csrw	sstatus,a5
    syscall();
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	2d4080e7          	jalr	724(ra) # 80002e9e <syscall>
  if(killed(p))
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	fffff097          	auipc	ra,0xfffff
    80002bd8:	722080e7          	jalr	1826(ra) # 800022f6 <killed>
    80002bdc:	c911                	beqz	a0,80002bf0 <usertrap+0xac>
    80002bde:	4901                	li	s2,0
    exit(-1);
    80002be0:	557d                	li	a0,-1
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	5a0080e7          	jalr	1440(ra) # 80002182 <exit>
  if(which_dev == 2)
    80002bea:	4789                	li	a5,2
    80002bec:	04f90f63          	beq	s2,a5,80002c4a <usertrap+0x106>
  usertrapret();
    80002bf0:	00000097          	auipc	ra,0x0
    80002bf4:	dd2080e7          	jalr	-558(ra) # 800029c2 <usertrapret>
}
    80002bf8:	60e2                	ld	ra,24(sp)
    80002bfa:	6442                	ld	s0,16(sp)
    80002bfc:	64a2                	ld	s1,8(sp)
    80002bfe:	6902                	ld	s2,0(sp)
    80002c00:	6105                	add	sp,sp,32
    80002c02:	8082                	ret
      exit(-1);
    80002c04:	557d                	li	a0,-1
    80002c06:	fffff097          	auipc	ra,0xfffff
    80002c0a:	57c080e7          	jalr	1404(ra) # 80002182 <exit>
    80002c0e:	b765                	j	80002bb6 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c10:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c14:	5890                	lw	a2,48(s1)
    80002c16:	00006517          	auipc	a0,0x6
    80002c1a:	8aa50513          	add	a0,a0,-1878 # 800084c0 <states.0+0x78>
    80002c1e:	ffffe097          	auipc	ra,0xffffe
    80002c22:	968080e7          	jalr	-1688(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c26:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c2a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c2e:	00006517          	auipc	a0,0x6
    80002c32:	8c250513          	add	a0,a0,-1854 # 800084f0 <states.0+0xa8>
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	950080e7          	jalr	-1712(ra) # 80000586 <printf>
    setkilled(p);
    80002c3e:	8526                	mv	a0,s1
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	68a080e7          	jalr	1674(ra) # 800022ca <setkilled>
    80002c48:	b769                	j	80002bd2 <usertrap+0x8e>
    yield();
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	3c8080e7          	jalr	968(ra) # 80002012 <yield>
    80002c52:	bf79                	j	80002bf0 <usertrap+0xac>

0000000080002c54 <kerneltrap>:
{
    80002c54:	7179                	add	sp,sp,-48
    80002c56:	f406                	sd	ra,40(sp)
    80002c58:	f022                	sd	s0,32(sp)
    80002c5a:	ec26                	sd	s1,24(sp)
    80002c5c:	e84a                	sd	s2,16(sp)
    80002c5e:	e44e                	sd	s3,8(sp)
    80002c60:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c62:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c66:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c6e:	1004f793          	and	a5,s1,256
    80002c72:	cb85                	beqz	a5,80002ca2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c74:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c78:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002c7a:	ef85                	bnez	a5,80002cb2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c7c:	00000097          	auipc	ra,0x0
    80002c80:	e22080e7          	jalr	-478(ra) # 80002a9e <devintr>
    80002c84:	cd1d                	beqz	a0,80002cc2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c86:	4789                	li	a5,2
    80002c88:	06f50a63          	beq	a0,a5,80002cfc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c8c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c90:	10049073          	csrw	sstatus,s1
}
    80002c94:	70a2                	ld	ra,40(sp)
    80002c96:	7402                	ld	s0,32(sp)
    80002c98:	64e2                	ld	s1,24(sp)
    80002c9a:	6942                	ld	s2,16(sp)
    80002c9c:	69a2                	ld	s3,8(sp)
    80002c9e:	6145                	add	sp,sp,48
    80002ca0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ca2:	00006517          	auipc	a0,0x6
    80002ca6:	86e50513          	add	a0,a0,-1938 # 80008510 <states.0+0xc8>
    80002caa:	ffffe097          	auipc	ra,0xffffe
    80002cae:	892080e7          	jalr	-1902(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002cb2:	00006517          	auipc	a0,0x6
    80002cb6:	88650513          	add	a0,a0,-1914 # 80008538 <states.0+0xf0>
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	882080e7          	jalr	-1918(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002cc2:	85ce                	mv	a1,s3
    80002cc4:	00006517          	auipc	a0,0x6
    80002cc8:	89450513          	add	a0,a0,-1900 # 80008558 <states.0+0x110>
    80002ccc:	ffffe097          	auipc	ra,0xffffe
    80002cd0:	8ba080e7          	jalr	-1862(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cd8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cdc:	00006517          	auipc	a0,0x6
    80002ce0:	88c50513          	add	a0,a0,-1908 # 80008568 <states.0+0x120>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	8a2080e7          	jalr	-1886(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002cec:	00006517          	auipc	a0,0x6
    80002cf0:	89450513          	add	a0,a0,-1900 # 80008580 <states.0+0x138>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	848080e7          	jalr	-1976(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	caa080e7          	jalr	-854(ra) # 800019a6 <myproc>
    80002d04:	d541                	beqz	a0,80002c8c <kerneltrap+0x38>
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	ca0080e7          	jalr	-864(ra) # 800019a6 <myproc>
    80002d0e:	4d18                	lw	a4,24(a0)
    80002d10:	4791                	li	a5,4
    80002d12:	f6f71de3          	bne	a4,a5,80002c8c <kerneltrap+0x38>
    yield();
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	2fc080e7          	jalr	764(ra) # 80002012 <yield>
    80002d1e:	b7bd                	j	80002c8c <kerneltrap+0x38>

0000000080002d20 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d20:	1101                	add	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	1000                	add	s0,sp,32
    80002d2a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	c7a080e7          	jalr	-902(ra) # 800019a6 <myproc>
  switch (n) {
    80002d34:	4795                	li	a5,5
    80002d36:	0497e163          	bltu	a5,s1,80002d78 <argraw+0x58>
    80002d3a:	048a                	sll	s1,s1,0x2
    80002d3c:	00006717          	auipc	a4,0x6
    80002d40:	87c70713          	add	a4,a4,-1924 # 800085b8 <states.0+0x170>
    80002d44:	94ba                	add	s1,s1,a4
    80002d46:	409c                	lw	a5,0(s1)
    80002d48:	97ba                	add	a5,a5,a4
    80002d4a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d4c:	6d3c                	ld	a5,88(a0)
    80002d4e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d50:	60e2                	ld	ra,24(sp)
    80002d52:	6442                	ld	s0,16(sp)
    80002d54:	64a2                	ld	s1,8(sp)
    80002d56:	6105                	add	sp,sp,32
    80002d58:	8082                	ret
    return p->trapframe->a1;
    80002d5a:	6d3c                	ld	a5,88(a0)
    80002d5c:	7fa8                	ld	a0,120(a5)
    80002d5e:	bfcd                	j	80002d50 <argraw+0x30>
    return p->trapframe->a2;
    80002d60:	6d3c                	ld	a5,88(a0)
    80002d62:	63c8                	ld	a0,128(a5)
    80002d64:	b7f5                	j	80002d50 <argraw+0x30>
    return p->trapframe->a3;
    80002d66:	6d3c                	ld	a5,88(a0)
    80002d68:	67c8                	ld	a0,136(a5)
    80002d6a:	b7dd                	j	80002d50 <argraw+0x30>
    return p->trapframe->a4;
    80002d6c:	6d3c                	ld	a5,88(a0)
    80002d6e:	6bc8                	ld	a0,144(a5)
    80002d70:	b7c5                	j	80002d50 <argraw+0x30>
    return p->trapframe->a5;
    80002d72:	6d3c                	ld	a5,88(a0)
    80002d74:	6fc8                	ld	a0,152(a5)
    80002d76:	bfe9                	j	80002d50 <argraw+0x30>
  panic("argraw");
    80002d78:	00006517          	auipc	a0,0x6
    80002d7c:	81850513          	add	a0,a0,-2024 # 80008590 <states.0+0x148>
    80002d80:	ffffd097          	auipc	ra,0xffffd
    80002d84:	7bc080e7          	jalr	1980(ra) # 8000053c <panic>

0000000080002d88 <fetchaddr>:
{
    80002d88:	1101                	add	sp,sp,-32
    80002d8a:	ec06                	sd	ra,24(sp)
    80002d8c:	e822                	sd	s0,16(sp)
    80002d8e:	e426                	sd	s1,8(sp)
    80002d90:	e04a                	sd	s2,0(sp)
    80002d92:	1000                	add	s0,sp,32
    80002d94:	84aa                	mv	s1,a0
    80002d96:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d98:	fffff097          	auipc	ra,0xfffff
    80002d9c:	c0e080e7          	jalr	-1010(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002da0:	653c                	ld	a5,72(a0)
    80002da2:	02f4f863          	bgeu	s1,a5,80002dd2 <fetchaddr+0x4a>
    80002da6:	00848713          	add	a4,s1,8
    80002daa:	02e7e663          	bltu	a5,a4,80002dd6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dae:	46a1                	li	a3,8
    80002db0:	8626                	mv	a2,s1
    80002db2:	85ca                	mv	a1,s2
    80002db4:	6928                	ld	a0,80(a0)
    80002db6:	fffff097          	auipc	ra,0xfffff
    80002dba:	93c080e7          	jalr	-1732(ra) # 800016f2 <copyin>
    80002dbe:	00a03533          	snez	a0,a0
    80002dc2:	40a00533          	neg	a0,a0
}
    80002dc6:	60e2                	ld	ra,24(sp)
    80002dc8:	6442                	ld	s0,16(sp)
    80002dca:	64a2                	ld	s1,8(sp)
    80002dcc:	6902                	ld	s2,0(sp)
    80002dce:	6105                	add	sp,sp,32
    80002dd0:	8082                	ret
    return -1;
    80002dd2:	557d                	li	a0,-1
    80002dd4:	bfcd                	j	80002dc6 <fetchaddr+0x3e>
    80002dd6:	557d                	li	a0,-1
    80002dd8:	b7fd                	j	80002dc6 <fetchaddr+0x3e>

0000000080002dda <fetchstr>:
{
    80002dda:	7179                	add	sp,sp,-48
    80002ddc:	f406                	sd	ra,40(sp)
    80002dde:	f022                	sd	s0,32(sp)
    80002de0:	ec26                	sd	s1,24(sp)
    80002de2:	e84a                	sd	s2,16(sp)
    80002de4:	e44e                	sd	s3,8(sp)
    80002de6:	1800                	add	s0,sp,48
    80002de8:	892a                	mv	s2,a0
    80002dea:	84ae                	mv	s1,a1
    80002dec:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	bb8080e7          	jalr	-1096(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002df6:	86ce                	mv	a3,s3
    80002df8:	864a                	mv	a2,s2
    80002dfa:	85a6                	mv	a1,s1
    80002dfc:	6928                	ld	a0,80(a0)
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	982080e7          	jalr	-1662(ra) # 80001780 <copyinstr>
    80002e06:	00054e63          	bltz	a0,80002e22 <fetchstr+0x48>
  return strlen(buf);
    80002e0a:	8526                	mv	a0,s1
    80002e0c:	ffffe097          	auipc	ra,0xffffe
    80002e10:	03c080e7          	jalr	60(ra) # 80000e48 <strlen>
}
    80002e14:	70a2                	ld	ra,40(sp)
    80002e16:	7402                	ld	s0,32(sp)
    80002e18:	64e2                	ld	s1,24(sp)
    80002e1a:	6942                	ld	s2,16(sp)
    80002e1c:	69a2                	ld	s3,8(sp)
    80002e1e:	6145                	add	sp,sp,48
    80002e20:	8082                	ret
    return -1;
    80002e22:	557d                	li	a0,-1
    80002e24:	bfc5                	j	80002e14 <fetchstr+0x3a>

0000000080002e26 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e26:	1101                	add	sp,sp,-32
    80002e28:	ec06                	sd	ra,24(sp)
    80002e2a:	e822                	sd	s0,16(sp)
    80002e2c:	e426                	sd	s1,8(sp)
    80002e2e:	1000                	add	s0,sp,32
    80002e30:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	eee080e7          	jalr	-274(ra) # 80002d20 <argraw>
    80002e3a:	c088                	sw	a0,0(s1)
}
    80002e3c:	60e2                	ld	ra,24(sp)
    80002e3e:	6442                	ld	s0,16(sp)
    80002e40:	64a2                	ld	s1,8(sp)
    80002e42:	6105                	add	sp,sp,32
    80002e44:	8082                	ret

0000000080002e46 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e46:	1101                	add	sp,sp,-32
    80002e48:	ec06                	sd	ra,24(sp)
    80002e4a:	e822                	sd	s0,16(sp)
    80002e4c:	e426                	sd	s1,8(sp)
    80002e4e:	1000                	add	s0,sp,32
    80002e50:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e52:	00000097          	auipc	ra,0x0
    80002e56:	ece080e7          	jalr	-306(ra) # 80002d20 <argraw>
    80002e5a:	e088                	sd	a0,0(s1)
}
    80002e5c:	60e2                	ld	ra,24(sp)
    80002e5e:	6442                	ld	s0,16(sp)
    80002e60:	64a2                	ld	s1,8(sp)
    80002e62:	6105                	add	sp,sp,32
    80002e64:	8082                	ret

0000000080002e66 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e66:	7179                	add	sp,sp,-48
    80002e68:	f406                	sd	ra,40(sp)
    80002e6a:	f022                	sd	s0,32(sp)
    80002e6c:	ec26                	sd	s1,24(sp)
    80002e6e:	e84a                	sd	s2,16(sp)
    80002e70:	1800                	add	s0,sp,48
    80002e72:	84ae                	mv	s1,a1
    80002e74:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e76:	fd840593          	add	a1,s0,-40
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	fcc080e7          	jalr	-52(ra) # 80002e46 <argaddr>
  return fetchstr(addr, buf, max);
    80002e82:	864a                	mv	a2,s2
    80002e84:	85a6                	mv	a1,s1
    80002e86:	fd843503          	ld	a0,-40(s0)
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	f50080e7          	jalr	-176(ra) # 80002dda <fetchstr>
}
    80002e92:	70a2                	ld	ra,40(sp)
    80002e94:	7402                	ld	s0,32(sp)
    80002e96:	64e2                	ld	s1,24(sp)
    80002e98:	6942                	ld	s2,16(sp)
    80002e9a:	6145                	add	sp,sp,48
    80002e9c:	8082                	ret

0000000080002e9e <syscall>:
[SYS_ringbuf]  sys_ringbuf,
};

void
syscall(void)
{
    80002e9e:	1101                	add	sp,sp,-32
    80002ea0:	ec06                	sd	ra,24(sp)
    80002ea2:	e822                	sd	s0,16(sp)
    80002ea4:	e426                	sd	s1,8(sp)
    80002ea6:	e04a                	sd	s2,0(sp)
    80002ea8:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	afc080e7          	jalr	-1284(ra) # 800019a6 <myproc>
    80002eb2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002eb4:	05853903          	ld	s2,88(a0)
    80002eb8:	0a893783          	ld	a5,168(s2)
    80002ebc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ec0:	37fd                	addw	a5,a5,-1
    80002ec2:	4755                	li	a4,21
    80002ec4:	00f76f63          	bltu	a4,a5,80002ee2 <syscall+0x44>
    80002ec8:	00369713          	sll	a4,a3,0x3
    80002ecc:	00005797          	auipc	a5,0x5
    80002ed0:	70478793          	add	a5,a5,1796 # 800085d0 <syscalls>
    80002ed4:	97ba                	add	a5,a5,a4
    80002ed6:	639c                	ld	a5,0(a5)
    80002ed8:	c789                	beqz	a5,80002ee2 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002eda:	9782                	jalr	a5
    80002edc:	06a93823          	sd	a0,112(s2)
    80002ee0:	a839                	j	80002efe <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ee2:	15848613          	add	a2,s1,344
    80002ee6:	588c                	lw	a1,48(s1)
    80002ee8:	00005517          	auipc	a0,0x5
    80002eec:	6b050513          	add	a0,a0,1712 # 80008598 <states.0+0x150>
    80002ef0:	ffffd097          	auipc	ra,0xffffd
    80002ef4:	696080e7          	jalr	1686(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ef8:	6cbc                	ld	a5,88(s1)
    80002efa:	577d                	li	a4,-1
    80002efc:	fbb8                	sd	a4,112(a5)
  }
}
    80002efe:	60e2                	ld	ra,24(sp)
    80002f00:	6442                	ld	s0,16(sp)
    80002f02:	64a2                	ld	s1,8(sp)
    80002f04:	6902                	ld	s2,0(sp)
    80002f06:	6105                	add	sp,sp,32
    80002f08:	8082                	ret

0000000080002f0a <sys_ringbuf>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_ringbuf(void)
{
    80002f0a:	7179                	add	sp,sp,-48
    80002f0c:	f406                	sd	ra,40(sp)
    80002f0e:	f022                	sd	s0,32(sp)
    80002f10:	1800                	add	s0,sp,48
  int open;
  char name[16];
  uint64 uaddr;
  
  argstr(0, name, 16);
    80002f12:	4641                	li	a2,16
    80002f14:	fd840593          	add	a1,s0,-40
    80002f18:	4501                	li	a0,0
    80002f1a:	00000097          	auipc	ra,0x0
    80002f1e:	f4c080e7          	jalr	-180(ra) # 80002e66 <argstr>
  argint(1, &open);
    80002f22:	fec40593          	add	a1,s0,-20
    80002f26:	4505                	li	a0,1
    80002f28:	00000097          	auipc	ra,0x0
    80002f2c:	efe080e7          	jalr	-258(ra) # 80002e26 <argint>
  argaddr(2, &uaddr);
    80002f30:	fd040593          	add	a1,s0,-48
    80002f34:	4509                	li	a0,2
    80002f36:	00000097          	auipc	ra,0x0
    80002f3a:	f10080e7          	jalr	-240(ra) # 80002e46 <argaddr>

  return ringbuf(name, open, uaddr);
    80002f3e:	fd043603          	ld	a2,-48(s0)
    80002f42:	fec42583          	lw	a1,-20(s0)
    80002f46:	fd840513          	add	a0,s0,-40
    80002f4a:	fffff097          	auipc	ra,0xfffff
    80002f4e:	6b0080e7          	jalr	1712(ra) # 800025fa <ringbuf>
}
    80002f52:	70a2                	ld	ra,40(sp)
    80002f54:	7402                	ld	s0,32(sp)
    80002f56:	6145                	add	sp,sp,48
    80002f58:	8082                	ret

0000000080002f5a <sys_exit>:

uint64
sys_exit(void)
{
    80002f5a:	1101                	add	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002f62:	fec40593          	add	a1,s0,-20
    80002f66:	4501                	li	a0,0
    80002f68:	00000097          	auipc	ra,0x0
    80002f6c:	ebe080e7          	jalr	-322(ra) # 80002e26 <argint>
  exit(n);
    80002f70:	fec42503          	lw	a0,-20(s0)
    80002f74:	fffff097          	auipc	ra,0xfffff
    80002f78:	20e080e7          	jalr	526(ra) # 80002182 <exit>
  return 0;  // not reached
}
    80002f7c:	4501                	li	a0,0
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	6105                	add	sp,sp,32
    80002f84:	8082                	ret

0000000080002f86 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f86:	1141                	add	sp,sp,-16
    80002f88:	e406                	sd	ra,8(sp)
    80002f8a:	e022                	sd	s0,0(sp)
    80002f8c:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	a18080e7          	jalr	-1512(ra) # 800019a6 <myproc>
}
    80002f96:	5908                	lw	a0,48(a0)
    80002f98:	60a2                	ld	ra,8(sp)
    80002f9a:	6402                	ld	s0,0(sp)
    80002f9c:	0141                	add	sp,sp,16
    80002f9e:	8082                	ret

0000000080002fa0 <sys_fork>:

uint64
sys_fork(void)
{
    80002fa0:	1141                	add	sp,sp,-16
    80002fa2:	e406                	sd	ra,8(sp)
    80002fa4:	e022                	sd	s0,0(sp)
    80002fa6:	0800                	add	s0,sp,16
  return fork();
    80002fa8:	fffff097          	auipc	ra,0xfffff
    80002fac:	db4080e7          	jalr	-588(ra) # 80001d5c <fork>
}
    80002fb0:	60a2                	ld	ra,8(sp)
    80002fb2:	6402                	ld	s0,0(sp)
    80002fb4:	0141                	add	sp,sp,16
    80002fb6:	8082                	ret

0000000080002fb8 <sys_wait>:

uint64
sys_wait(void)
{
    80002fb8:	1101                	add	sp,sp,-32
    80002fba:	ec06                	sd	ra,24(sp)
    80002fbc:	e822                	sd	s0,16(sp)
    80002fbe:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fc0:	fe840593          	add	a1,s0,-24
    80002fc4:	4501                	li	a0,0
    80002fc6:	00000097          	auipc	ra,0x0
    80002fca:	e80080e7          	jalr	-384(ra) # 80002e46 <argaddr>
  return wait(p);
    80002fce:	fe843503          	ld	a0,-24(s0)
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	356080e7          	jalr	854(ra) # 80002328 <wait>
}
    80002fda:	60e2                	ld	ra,24(sp)
    80002fdc:	6442                	ld	s0,16(sp)
    80002fde:	6105                	add	sp,sp,32
    80002fe0:	8082                	ret

0000000080002fe2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fe2:	7179                	add	sp,sp,-48
    80002fe4:	f406                	sd	ra,40(sp)
    80002fe6:	f022                	sd	s0,32(sp)
    80002fe8:	ec26                	sd	s1,24(sp)
    80002fea:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fec:	fdc40593          	add	a1,s0,-36
    80002ff0:	4501                	li	a0,0
    80002ff2:	00000097          	auipc	ra,0x0
    80002ff6:	e34080e7          	jalr	-460(ra) # 80002e26 <argint>
  addr = myproc()->sz;
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	9ac080e7          	jalr	-1620(ra) # 800019a6 <myproc>
    80003002:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003004:	fdc42503          	lw	a0,-36(s0)
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	cf8080e7          	jalr	-776(ra) # 80001d00 <growproc>
    80003010:	00054863          	bltz	a0,80003020 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003014:	8526                	mv	a0,s1
    80003016:	70a2                	ld	ra,40(sp)
    80003018:	7402                	ld	s0,32(sp)
    8000301a:	64e2                	ld	s1,24(sp)
    8000301c:	6145                	add	sp,sp,48
    8000301e:	8082                	ret
    return -1;
    80003020:	54fd                	li	s1,-1
    80003022:	bfcd                	j	80003014 <sys_sbrk+0x32>

0000000080003024 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003024:	7139                	add	sp,sp,-64
    80003026:	fc06                	sd	ra,56(sp)
    80003028:	f822                	sd	s0,48(sp)
    8000302a:	f426                	sd	s1,40(sp)
    8000302c:	f04a                	sd	s2,32(sp)
    8000302e:	ec4e                	sd	s3,24(sp)
    80003030:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003032:	fcc40593          	add	a1,s0,-52
    80003036:	4501                	li	a0,0
    80003038:	00000097          	auipc	ra,0x0
    8000303c:	dee080e7          	jalr	-530(ra) # 80002e26 <argint>
  acquire(&tickslock);
    80003040:	00014517          	auipc	a0,0x14
    80003044:	10850513          	add	a0,a0,264 # 80017148 <tickslock>
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	b8a080e7          	jalr	-1142(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80003050:	00006917          	auipc	s2,0x6
    80003054:	a0092903          	lw	s2,-1536(s2) # 80008a50 <ticks>
  while(ticks - ticks0 < n){
    80003058:	fcc42783          	lw	a5,-52(s0)
    8000305c:	cf9d                	beqz	a5,8000309a <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000305e:	00014997          	auipc	s3,0x14
    80003062:	0ea98993          	add	s3,s3,234 # 80017148 <tickslock>
    80003066:	00006497          	auipc	s1,0x6
    8000306a:	9ea48493          	add	s1,s1,-1558 # 80008a50 <ticks>
    if(killed(myproc())){
    8000306e:	fffff097          	auipc	ra,0xfffff
    80003072:	938080e7          	jalr	-1736(ra) # 800019a6 <myproc>
    80003076:	fffff097          	auipc	ra,0xfffff
    8000307a:	280080e7          	jalr	640(ra) # 800022f6 <killed>
    8000307e:	ed15                	bnez	a0,800030ba <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003080:	85ce                	mv	a1,s3
    80003082:	8526                	mv	a0,s1
    80003084:	fffff097          	auipc	ra,0xfffff
    80003088:	fca080e7          	jalr	-54(ra) # 8000204e <sleep>
  while(ticks - ticks0 < n){
    8000308c:	409c                	lw	a5,0(s1)
    8000308e:	412787bb          	subw	a5,a5,s2
    80003092:	fcc42703          	lw	a4,-52(s0)
    80003096:	fce7ece3          	bltu	a5,a4,8000306e <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000309a:	00014517          	auipc	a0,0x14
    8000309e:	0ae50513          	add	a0,a0,174 # 80017148 <tickslock>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	be4080e7          	jalr	-1052(ra) # 80000c86 <release>
  return 0;
    800030aa:	4501                	li	a0,0
}
    800030ac:	70e2                	ld	ra,56(sp)
    800030ae:	7442                	ld	s0,48(sp)
    800030b0:	74a2                	ld	s1,40(sp)
    800030b2:	7902                	ld	s2,32(sp)
    800030b4:	69e2                	ld	s3,24(sp)
    800030b6:	6121                	add	sp,sp,64
    800030b8:	8082                	ret
      release(&tickslock);
    800030ba:	00014517          	auipc	a0,0x14
    800030be:	08e50513          	add	a0,a0,142 # 80017148 <tickslock>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	bc4080e7          	jalr	-1084(ra) # 80000c86 <release>
      return -1;
    800030ca:	557d                	li	a0,-1
    800030cc:	b7c5                	j	800030ac <sys_sleep+0x88>

00000000800030ce <sys_kill>:

uint64
sys_kill(void)
{
    800030ce:	1101                	add	sp,sp,-32
    800030d0:	ec06                	sd	ra,24(sp)
    800030d2:	e822                	sd	s0,16(sp)
    800030d4:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    800030d6:	fec40593          	add	a1,s0,-20
    800030da:	4501                	li	a0,0
    800030dc:	00000097          	auipc	ra,0x0
    800030e0:	d4a080e7          	jalr	-694(ra) # 80002e26 <argint>
  return kill(pid);
    800030e4:	fec42503          	lw	a0,-20(s0)
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	170080e7          	jalr	368(ra) # 80002258 <kill>
}
    800030f0:	60e2                	ld	ra,24(sp)
    800030f2:	6442                	ld	s0,16(sp)
    800030f4:	6105                	add	sp,sp,32
    800030f6:	8082                	ret

00000000800030f8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030f8:	1101                	add	sp,sp,-32
    800030fa:	ec06                	sd	ra,24(sp)
    800030fc:	e822                	sd	s0,16(sp)
    800030fe:	e426                	sd	s1,8(sp)
    80003100:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003102:	00014517          	auipc	a0,0x14
    80003106:	04650513          	add	a0,a0,70 # 80017148 <tickslock>
    8000310a:	ffffe097          	auipc	ra,0xffffe
    8000310e:	ac8080e7          	jalr	-1336(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80003112:	00006497          	auipc	s1,0x6
    80003116:	93e4a483          	lw	s1,-1730(s1) # 80008a50 <ticks>
  release(&tickslock);
    8000311a:	00014517          	auipc	a0,0x14
    8000311e:	02e50513          	add	a0,a0,46 # 80017148 <tickslock>
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	b64080e7          	jalr	-1180(ra) # 80000c86 <release>
  return xticks;
}
    8000312a:	02049513          	sll	a0,s1,0x20
    8000312e:	9101                	srl	a0,a0,0x20
    80003130:	60e2                	ld	ra,24(sp)
    80003132:	6442                	ld	s0,16(sp)
    80003134:	64a2                	ld	s1,8(sp)
    80003136:	6105                	add	sp,sp,32
    80003138:	8082                	ret

000000008000313a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000313a:	7179                	add	sp,sp,-48
    8000313c:	f406                	sd	ra,40(sp)
    8000313e:	f022                	sd	s0,32(sp)
    80003140:	ec26                	sd	s1,24(sp)
    80003142:	e84a                	sd	s2,16(sp)
    80003144:	e44e                	sd	s3,8(sp)
    80003146:	e052                	sd	s4,0(sp)
    80003148:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000314a:	00005597          	auipc	a1,0x5
    8000314e:	53e58593          	add	a1,a1,1342 # 80008688 <syscalls+0xb8>
    80003152:	00014517          	auipc	a0,0x14
    80003156:	00e50513          	add	a0,a0,14 # 80017160 <bcache>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	9e8080e7          	jalr	-1560(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003162:	0001c797          	auipc	a5,0x1c
    80003166:	ffe78793          	add	a5,a5,-2 # 8001f160 <bcache+0x8000>
    8000316a:	0001c717          	auipc	a4,0x1c
    8000316e:	25e70713          	add	a4,a4,606 # 8001f3c8 <bcache+0x8268>
    80003172:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003176:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000317a:	00014497          	auipc	s1,0x14
    8000317e:	ffe48493          	add	s1,s1,-2 # 80017178 <bcache+0x18>
    b->next = bcache.head.next;
    80003182:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003184:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003186:	00005a17          	auipc	s4,0x5
    8000318a:	50aa0a13          	add	s4,s4,1290 # 80008690 <syscalls+0xc0>
    b->next = bcache.head.next;
    8000318e:	2b893783          	ld	a5,696(s2)
    80003192:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003194:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003198:	85d2                	mv	a1,s4
    8000319a:	01048513          	add	a0,s1,16
    8000319e:	00001097          	auipc	ra,0x1
    800031a2:	496080e7          	jalr	1174(ra) # 80004634 <initsleeplock>
    bcache.head.next->prev = b;
    800031a6:	2b893783          	ld	a5,696(s2)
    800031aa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031ac:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031b0:	45848493          	add	s1,s1,1112
    800031b4:	fd349de3          	bne	s1,s3,8000318e <binit+0x54>
  }
}
    800031b8:	70a2                	ld	ra,40(sp)
    800031ba:	7402                	ld	s0,32(sp)
    800031bc:	64e2                	ld	s1,24(sp)
    800031be:	6942                	ld	s2,16(sp)
    800031c0:	69a2                	ld	s3,8(sp)
    800031c2:	6a02                	ld	s4,0(sp)
    800031c4:	6145                	add	sp,sp,48
    800031c6:	8082                	ret

00000000800031c8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031c8:	7179                	add	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	1800                	add	s0,sp,48
    800031d6:	892a                	mv	s2,a0
    800031d8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031da:	00014517          	auipc	a0,0x14
    800031de:	f8650513          	add	a0,a0,-122 # 80017160 <bcache>
    800031e2:	ffffe097          	auipc	ra,0xffffe
    800031e6:	9f0080e7          	jalr	-1552(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031ea:	0001c497          	auipc	s1,0x1c
    800031ee:	22e4b483          	ld	s1,558(s1) # 8001f418 <bcache+0x82b8>
    800031f2:	0001c797          	auipc	a5,0x1c
    800031f6:	1d678793          	add	a5,a5,470 # 8001f3c8 <bcache+0x8268>
    800031fa:	02f48f63          	beq	s1,a5,80003238 <bread+0x70>
    800031fe:	873e                	mv	a4,a5
    80003200:	a021                	j	80003208 <bread+0x40>
    80003202:	68a4                	ld	s1,80(s1)
    80003204:	02e48a63          	beq	s1,a4,80003238 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003208:	449c                	lw	a5,8(s1)
    8000320a:	ff279ce3          	bne	a5,s2,80003202 <bread+0x3a>
    8000320e:	44dc                	lw	a5,12(s1)
    80003210:	ff3799e3          	bne	a5,s3,80003202 <bread+0x3a>
      b->refcnt++;
    80003214:	40bc                	lw	a5,64(s1)
    80003216:	2785                	addw	a5,a5,1
    80003218:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000321a:	00014517          	auipc	a0,0x14
    8000321e:	f4650513          	add	a0,a0,-186 # 80017160 <bcache>
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	a64080e7          	jalr	-1436(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000322a:	01048513          	add	a0,s1,16
    8000322e:	00001097          	auipc	ra,0x1
    80003232:	440080e7          	jalr	1088(ra) # 8000466e <acquiresleep>
      return b;
    80003236:	a8b9                	j	80003294 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003238:	0001c497          	auipc	s1,0x1c
    8000323c:	1d84b483          	ld	s1,472(s1) # 8001f410 <bcache+0x82b0>
    80003240:	0001c797          	auipc	a5,0x1c
    80003244:	18878793          	add	a5,a5,392 # 8001f3c8 <bcache+0x8268>
    80003248:	00f48863          	beq	s1,a5,80003258 <bread+0x90>
    8000324c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000324e:	40bc                	lw	a5,64(s1)
    80003250:	cf81                	beqz	a5,80003268 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003252:	64a4                	ld	s1,72(s1)
    80003254:	fee49de3          	bne	s1,a4,8000324e <bread+0x86>
  panic("bget: no buffers");
    80003258:	00005517          	auipc	a0,0x5
    8000325c:	44050513          	add	a0,a0,1088 # 80008698 <syscalls+0xc8>
    80003260:	ffffd097          	auipc	ra,0xffffd
    80003264:	2dc080e7          	jalr	732(ra) # 8000053c <panic>
      b->dev = dev;
    80003268:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000326c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003270:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003274:	4785                	li	a5,1
    80003276:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003278:	00014517          	auipc	a0,0x14
    8000327c:	ee850513          	add	a0,a0,-280 # 80017160 <bcache>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	a06080e7          	jalr	-1530(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003288:	01048513          	add	a0,s1,16
    8000328c:	00001097          	auipc	ra,0x1
    80003290:	3e2080e7          	jalr	994(ra) # 8000466e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003294:	409c                	lw	a5,0(s1)
    80003296:	cb89                	beqz	a5,800032a8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003298:	8526                	mv	a0,s1
    8000329a:	70a2                	ld	ra,40(sp)
    8000329c:	7402                	ld	s0,32(sp)
    8000329e:	64e2                	ld	s1,24(sp)
    800032a0:	6942                	ld	s2,16(sp)
    800032a2:	69a2                	ld	s3,8(sp)
    800032a4:	6145                	add	sp,sp,48
    800032a6:	8082                	ret
    virtio_disk_rw(b, 0);
    800032a8:	4581                	li	a1,0
    800032aa:	8526                	mv	a0,s1
    800032ac:	00003097          	auipc	ra,0x3
    800032b0:	f86080e7          	jalr	-122(ra) # 80006232 <virtio_disk_rw>
    b->valid = 1;
    800032b4:	4785                	li	a5,1
    800032b6:	c09c                	sw	a5,0(s1)
  return b;
    800032b8:	b7c5                	j	80003298 <bread+0xd0>

00000000800032ba <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032ba:	1101                	add	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	add	s0,sp,32
    800032c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032c6:	0541                	add	a0,a0,16
    800032c8:	00001097          	auipc	ra,0x1
    800032cc:	440080e7          	jalr	1088(ra) # 80004708 <holdingsleep>
    800032d0:	cd01                	beqz	a0,800032e8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032d2:	4585                	li	a1,1
    800032d4:	8526                	mv	a0,s1
    800032d6:	00003097          	auipc	ra,0x3
    800032da:	f5c080e7          	jalr	-164(ra) # 80006232 <virtio_disk_rw>
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6105                	add	sp,sp,32
    800032e6:	8082                	ret
    panic("bwrite");
    800032e8:	00005517          	auipc	a0,0x5
    800032ec:	3c850513          	add	a0,a0,968 # 800086b0 <syscalls+0xe0>
    800032f0:	ffffd097          	auipc	ra,0xffffd
    800032f4:	24c080e7          	jalr	588(ra) # 8000053c <panic>

00000000800032f8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032f8:	1101                	add	sp,sp,-32
    800032fa:	ec06                	sd	ra,24(sp)
    800032fc:	e822                	sd	s0,16(sp)
    800032fe:	e426                	sd	s1,8(sp)
    80003300:	e04a                	sd	s2,0(sp)
    80003302:	1000                	add	s0,sp,32
    80003304:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003306:	01050913          	add	s2,a0,16
    8000330a:	854a                	mv	a0,s2
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	3fc080e7          	jalr	1020(ra) # 80004708 <holdingsleep>
    80003314:	c925                	beqz	a0,80003384 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003316:	854a                	mv	a0,s2
    80003318:	00001097          	auipc	ra,0x1
    8000331c:	3ac080e7          	jalr	940(ra) # 800046c4 <releasesleep>

  acquire(&bcache.lock);
    80003320:	00014517          	auipc	a0,0x14
    80003324:	e4050513          	add	a0,a0,-448 # 80017160 <bcache>
    80003328:	ffffe097          	auipc	ra,0xffffe
    8000332c:	8aa080e7          	jalr	-1878(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003330:	40bc                	lw	a5,64(s1)
    80003332:	37fd                	addw	a5,a5,-1
    80003334:	0007871b          	sext.w	a4,a5
    80003338:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000333a:	e71d                	bnez	a4,80003368 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000333c:	68b8                	ld	a4,80(s1)
    8000333e:	64bc                	ld	a5,72(s1)
    80003340:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003342:	68b8                	ld	a4,80(s1)
    80003344:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003346:	0001c797          	auipc	a5,0x1c
    8000334a:	e1a78793          	add	a5,a5,-486 # 8001f160 <bcache+0x8000>
    8000334e:	2b87b703          	ld	a4,696(a5)
    80003352:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003354:	0001c717          	auipc	a4,0x1c
    80003358:	07470713          	add	a4,a4,116 # 8001f3c8 <bcache+0x8268>
    8000335c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000335e:	2b87b703          	ld	a4,696(a5)
    80003362:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003364:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003368:	00014517          	auipc	a0,0x14
    8000336c:	df850513          	add	a0,a0,-520 # 80017160 <bcache>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	916080e7          	jalr	-1770(ra) # 80000c86 <release>
}
    80003378:	60e2                	ld	ra,24(sp)
    8000337a:	6442                	ld	s0,16(sp)
    8000337c:	64a2                	ld	s1,8(sp)
    8000337e:	6902                	ld	s2,0(sp)
    80003380:	6105                	add	sp,sp,32
    80003382:	8082                	ret
    panic("brelse");
    80003384:	00005517          	auipc	a0,0x5
    80003388:	33450513          	add	a0,a0,820 # 800086b8 <syscalls+0xe8>
    8000338c:	ffffd097          	auipc	ra,0xffffd
    80003390:	1b0080e7          	jalr	432(ra) # 8000053c <panic>

0000000080003394 <bpin>:

void
bpin(struct buf *b) {
    80003394:	1101                	add	sp,sp,-32
    80003396:	ec06                	sd	ra,24(sp)
    80003398:	e822                	sd	s0,16(sp)
    8000339a:	e426                	sd	s1,8(sp)
    8000339c:	1000                	add	s0,sp,32
    8000339e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033a0:	00014517          	auipc	a0,0x14
    800033a4:	dc050513          	add	a0,a0,-576 # 80017160 <bcache>
    800033a8:	ffffe097          	auipc	ra,0xffffe
    800033ac:	82a080e7          	jalr	-2006(ra) # 80000bd2 <acquire>
  b->refcnt++;
    800033b0:	40bc                	lw	a5,64(s1)
    800033b2:	2785                	addw	a5,a5,1
    800033b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033b6:	00014517          	auipc	a0,0x14
    800033ba:	daa50513          	add	a0,a0,-598 # 80017160 <bcache>
    800033be:	ffffe097          	auipc	ra,0xffffe
    800033c2:	8c8080e7          	jalr	-1848(ra) # 80000c86 <release>
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6105                	add	sp,sp,32
    800033ce:	8082                	ret

00000000800033d0 <bunpin>:

void
bunpin(struct buf *b) {
    800033d0:	1101                	add	sp,sp,-32
    800033d2:	ec06                	sd	ra,24(sp)
    800033d4:	e822                	sd	s0,16(sp)
    800033d6:	e426                	sd	s1,8(sp)
    800033d8:	1000                	add	s0,sp,32
    800033da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033dc:	00014517          	auipc	a0,0x14
    800033e0:	d8450513          	add	a0,a0,-636 # 80017160 <bcache>
    800033e4:	ffffd097          	auipc	ra,0xffffd
    800033e8:	7ee080e7          	jalr	2030(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800033ec:	40bc                	lw	a5,64(s1)
    800033ee:	37fd                	addw	a5,a5,-1
    800033f0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033f2:	00014517          	auipc	a0,0x14
    800033f6:	d6e50513          	add	a0,a0,-658 # 80017160 <bcache>
    800033fa:	ffffe097          	auipc	ra,0xffffe
    800033fe:	88c080e7          	jalr	-1908(ra) # 80000c86 <release>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	add	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000340c:	1101                	add	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	e04a                	sd	s2,0(sp)
    80003416:	1000                	add	s0,sp,32
    80003418:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000341a:	00d5d59b          	srlw	a1,a1,0xd
    8000341e:	0001c797          	auipc	a5,0x1c
    80003422:	41e7a783          	lw	a5,1054(a5) # 8001f83c <sb+0x1c>
    80003426:	9dbd                	addw	a1,a1,a5
    80003428:	00000097          	auipc	ra,0x0
    8000342c:	da0080e7          	jalr	-608(ra) # 800031c8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003430:	0074f713          	and	a4,s1,7
    80003434:	4785                	li	a5,1
    80003436:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000343a:	14ce                	sll	s1,s1,0x33
    8000343c:	90d9                	srl	s1,s1,0x36
    8000343e:	00950733          	add	a4,a0,s1
    80003442:	05874703          	lbu	a4,88(a4)
    80003446:	00e7f6b3          	and	a3,a5,a4
    8000344a:	c69d                	beqz	a3,80003478 <bfree+0x6c>
    8000344c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000344e:	94aa                	add	s1,s1,a0
    80003450:	fff7c793          	not	a5,a5
    80003454:	8f7d                	and	a4,a4,a5
    80003456:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000345a:	00001097          	auipc	ra,0x1
    8000345e:	0f6080e7          	jalr	246(ra) # 80004550 <log_write>
  brelse(bp);
    80003462:	854a                	mv	a0,s2
    80003464:	00000097          	auipc	ra,0x0
    80003468:	e94080e7          	jalr	-364(ra) # 800032f8 <brelse>
}
    8000346c:	60e2                	ld	ra,24(sp)
    8000346e:	6442                	ld	s0,16(sp)
    80003470:	64a2                	ld	s1,8(sp)
    80003472:	6902                	ld	s2,0(sp)
    80003474:	6105                	add	sp,sp,32
    80003476:	8082                	ret
    panic("freeing free block");
    80003478:	00005517          	auipc	a0,0x5
    8000347c:	24850513          	add	a0,a0,584 # 800086c0 <syscalls+0xf0>
    80003480:	ffffd097          	auipc	ra,0xffffd
    80003484:	0bc080e7          	jalr	188(ra) # 8000053c <panic>

0000000080003488 <balloc>:
{
    80003488:	711d                	add	sp,sp,-96
    8000348a:	ec86                	sd	ra,88(sp)
    8000348c:	e8a2                	sd	s0,80(sp)
    8000348e:	e4a6                	sd	s1,72(sp)
    80003490:	e0ca                	sd	s2,64(sp)
    80003492:	fc4e                	sd	s3,56(sp)
    80003494:	f852                	sd	s4,48(sp)
    80003496:	f456                	sd	s5,40(sp)
    80003498:	f05a                	sd	s6,32(sp)
    8000349a:	ec5e                	sd	s7,24(sp)
    8000349c:	e862                	sd	s8,16(sp)
    8000349e:	e466                	sd	s9,8(sp)
    800034a0:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034a2:	0001c797          	auipc	a5,0x1c
    800034a6:	3827a783          	lw	a5,898(a5) # 8001f824 <sb+0x4>
    800034aa:	cff5                	beqz	a5,800035a6 <balloc+0x11e>
    800034ac:	8baa                	mv	s7,a0
    800034ae:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034b0:	0001cb17          	auipc	s6,0x1c
    800034b4:	370b0b13          	add	s6,s6,880 # 8001f820 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ba:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034bc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034be:	6c89                	lui	s9,0x2
    800034c0:	a061                	j	80003548 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034c2:	97ca                	add	a5,a5,s2
    800034c4:	8e55                	or	a2,a2,a3
    800034c6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034ca:	854a                	mv	a0,s2
    800034cc:	00001097          	auipc	ra,0x1
    800034d0:	084080e7          	jalr	132(ra) # 80004550 <log_write>
        brelse(bp);
    800034d4:	854a                	mv	a0,s2
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	e22080e7          	jalr	-478(ra) # 800032f8 <brelse>
  bp = bread(dev, bno);
    800034de:	85a6                	mv	a1,s1
    800034e0:	855e                	mv	a0,s7
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	ce6080e7          	jalr	-794(ra) # 800031c8 <bread>
    800034ea:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034ec:	40000613          	li	a2,1024
    800034f0:	4581                	li	a1,0
    800034f2:	05850513          	add	a0,a0,88
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	7d8080e7          	jalr	2008(ra) # 80000cce <memset>
  log_write(bp);
    800034fe:	854a                	mv	a0,s2
    80003500:	00001097          	auipc	ra,0x1
    80003504:	050080e7          	jalr	80(ra) # 80004550 <log_write>
  brelse(bp);
    80003508:	854a                	mv	a0,s2
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	dee080e7          	jalr	-530(ra) # 800032f8 <brelse>
}
    80003512:	8526                	mv	a0,s1
    80003514:	60e6                	ld	ra,88(sp)
    80003516:	6446                	ld	s0,80(sp)
    80003518:	64a6                	ld	s1,72(sp)
    8000351a:	6906                	ld	s2,64(sp)
    8000351c:	79e2                	ld	s3,56(sp)
    8000351e:	7a42                	ld	s4,48(sp)
    80003520:	7aa2                	ld	s5,40(sp)
    80003522:	7b02                	ld	s6,32(sp)
    80003524:	6be2                	ld	s7,24(sp)
    80003526:	6c42                	ld	s8,16(sp)
    80003528:	6ca2                	ld	s9,8(sp)
    8000352a:	6125                	add	sp,sp,96
    8000352c:	8082                	ret
    brelse(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	00000097          	auipc	ra,0x0
    80003534:	dc8080e7          	jalr	-568(ra) # 800032f8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003538:	015c87bb          	addw	a5,s9,s5
    8000353c:	00078a9b          	sext.w	s5,a5
    80003540:	004b2703          	lw	a4,4(s6)
    80003544:	06eaf163          	bgeu	s5,a4,800035a6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003548:	41fad79b          	sraw	a5,s5,0x1f
    8000354c:	0137d79b          	srlw	a5,a5,0x13
    80003550:	015787bb          	addw	a5,a5,s5
    80003554:	40d7d79b          	sraw	a5,a5,0xd
    80003558:	01cb2583          	lw	a1,28(s6)
    8000355c:	9dbd                	addw	a1,a1,a5
    8000355e:	855e                	mv	a0,s7
    80003560:	00000097          	auipc	ra,0x0
    80003564:	c68080e7          	jalr	-920(ra) # 800031c8 <bread>
    80003568:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000356a:	004b2503          	lw	a0,4(s6)
    8000356e:	000a849b          	sext.w	s1,s5
    80003572:	8762                	mv	a4,s8
    80003574:	faa4fde3          	bgeu	s1,a0,8000352e <balloc+0xa6>
      m = 1 << (bi % 8);
    80003578:	00777693          	and	a3,a4,7
    8000357c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003580:	41f7579b          	sraw	a5,a4,0x1f
    80003584:	01d7d79b          	srlw	a5,a5,0x1d
    80003588:	9fb9                	addw	a5,a5,a4
    8000358a:	4037d79b          	sraw	a5,a5,0x3
    8000358e:	00f90633          	add	a2,s2,a5
    80003592:	05864603          	lbu	a2,88(a2)
    80003596:	00c6f5b3          	and	a1,a3,a2
    8000359a:	d585                	beqz	a1,800034c2 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000359c:	2705                	addw	a4,a4,1
    8000359e:	2485                	addw	s1,s1,1
    800035a0:	fd471ae3          	bne	a4,s4,80003574 <balloc+0xec>
    800035a4:	b769                	j	8000352e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800035a6:	00005517          	auipc	a0,0x5
    800035aa:	13250513          	add	a0,a0,306 # 800086d8 <syscalls+0x108>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	fd8080e7          	jalr	-40(ra) # 80000586 <printf>
  return 0;
    800035b6:	4481                	li	s1,0
    800035b8:	bfa9                	j	80003512 <balloc+0x8a>

00000000800035ba <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035ba:	7179                	add	sp,sp,-48
    800035bc:	f406                	sd	ra,40(sp)
    800035be:	f022                	sd	s0,32(sp)
    800035c0:	ec26                	sd	s1,24(sp)
    800035c2:	e84a                	sd	s2,16(sp)
    800035c4:	e44e                	sd	s3,8(sp)
    800035c6:	e052                	sd	s4,0(sp)
    800035c8:	1800                	add	s0,sp,48
    800035ca:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035cc:	47ad                	li	a5,11
    800035ce:	02b7e863          	bltu	a5,a1,800035fe <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800035d2:	02059793          	sll	a5,a1,0x20
    800035d6:	01e7d593          	srl	a1,a5,0x1e
    800035da:	00b504b3          	add	s1,a0,a1
    800035de:	0504a903          	lw	s2,80(s1)
    800035e2:	06091e63          	bnez	s2,8000365e <bmap+0xa4>
      addr = balloc(ip->dev);
    800035e6:	4108                	lw	a0,0(a0)
    800035e8:	00000097          	auipc	ra,0x0
    800035ec:	ea0080e7          	jalr	-352(ra) # 80003488 <balloc>
    800035f0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035f4:	06090563          	beqz	s2,8000365e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800035f8:	0524a823          	sw	s2,80(s1)
    800035fc:	a08d                	j	8000365e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035fe:	ff45849b          	addw	s1,a1,-12
    80003602:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003606:	0ff00793          	li	a5,255
    8000360a:	08e7e563          	bltu	a5,a4,80003694 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000360e:	08052903          	lw	s2,128(a0)
    80003612:	00091d63          	bnez	s2,8000362c <bmap+0x72>
      addr = balloc(ip->dev);
    80003616:	4108                	lw	a0,0(a0)
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	e70080e7          	jalr	-400(ra) # 80003488 <balloc>
    80003620:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003624:	02090d63          	beqz	s2,8000365e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003628:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000362c:	85ca                	mv	a1,s2
    8000362e:	0009a503          	lw	a0,0(s3)
    80003632:	00000097          	auipc	ra,0x0
    80003636:	b96080e7          	jalr	-1130(ra) # 800031c8 <bread>
    8000363a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000363c:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003640:	02049713          	sll	a4,s1,0x20
    80003644:	01e75593          	srl	a1,a4,0x1e
    80003648:	00b784b3          	add	s1,a5,a1
    8000364c:	0004a903          	lw	s2,0(s1)
    80003650:	02090063          	beqz	s2,80003670 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003654:	8552                	mv	a0,s4
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	ca2080e7          	jalr	-862(ra) # 800032f8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000365e:	854a                	mv	a0,s2
    80003660:	70a2                	ld	ra,40(sp)
    80003662:	7402                	ld	s0,32(sp)
    80003664:	64e2                	ld	s1,24(sp)
    80003666:	6942                	ld	s2,16(sp)
    80003668:	69a2                	ld	s3,8(sp)
    8000366a:	6a02                	ld	s4,0(sp)
    8000366c:	6145                	add	sp,sp,48
    8000366e:	8082                	ret
      addr = balloc(ip->dev);
    80003670:	0009a503          	lw	a0,0(s3)
    80003674:	00000097          	auipc	ra,0x0
    80003678:	e14080e7          	jalr	-492(ra) # 80003488 <balloc>
    8000367c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003680:	fc090ae3          	beqz	s2,80003654 <bmap+0x9a>
        a[bn] = addr;
    80003684:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003688:	8552                	mv	a0,s4
    8000368a:	00001097          	auipc	ra,0x1
    8000368e:	ec6080e7          	jalr	-314(ra) # 80004550 <log_write>
    80003692:	b7c9                	j	80003654 <bmap+0x9a>
  panic("bmap: out of range");
    80003694:	00005517          	auipc	a0,0x5
    80003698:	05c50513          	add	a0,a0,92 # 800086f0 <syscalls+0x120>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	ea0080e7          	jalr	-352(ra) # 8000053c <panic>

00000000800036a4 <iget>:
{
    800036a4:	7179                	add	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	ec26                	sd	s1,24(sp)
    800036ac:	e84a                	sd	s2,16(sp)
    800036ae:	e44e                	sd	s3,8(sp)
    800036b0:	e052                	sd	s4,0(sp)
    800036b2:	1800                	add	s0,sp,48
    800036b4:	89aa                	mv	s3,a0
    800036b6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036b8:	0001c517          	auipc	a0,0x1c
    800036bc:	18850513          	add	a0,a0,392 # 8001f840 <itable>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	512080e7          	jalr	1298(ra) # 80000bd2 <acquire>
  empty = 0;
    800036c8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036ca:	0001c497          	auipc	s1,0x1c
    800036ce:	18e48493          	add	s1,s1,398 # 8001f858 <itable+0x18>
    800036d2:	0001e697          	auipc	a3,0x1e
    800036d6:	c1668693          	add	a3,a3,-1002 # 800212e8 <log>
    800036da:	a039                	j	800036e8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036dc:	02090b63          	beqz	s2,80003712 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036e0:	08848493          	add	s1,s1,136
    800036e4:	02d48a63          	beq	s1,a3,80003718 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036e8:	449c                	lw	a5,8(s1)
    800036ea:	fef059e3          	blez	a5,800036dc <iget+0x38>
    800036ee:	4098                	lw	a4,0(s1)
    800036f0:	ff3716e3          	bne	a4,s3,800036dc <iget+0x38>
    800036f4:	40d8                	lw	a4,4(s1)
    800036f6:	ff4713e3          	bne	a4,s4,800036dc <iget+0x38>
      ip->ref++;
    800036fa:	2785                	addw	a5,a5,1
    800036fc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036fe:	0001c517          	auipc	a0,0x1c
    80003702:	14250513          	add	a0,a0,322 # 8001f840 <itable>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	580080e7          	jalr	1408(ra) # 80000c86 <release>
      return ip;
    8000370e:	8926                	mv	s2,s1
    80003710:	a03d                	j	8000373e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003712:	f7f9                	bnez	a5,800036e0 <iget+0x3c>
    80003714:	8926                	mv	s2,s1
    80003716:	b7e9                	j	800036e0 <iget+0x3c>
  if(empty == 0)
    80003718:	02090c63          	beqz	s2,80003750 <iget+0xac>
  ip->dev = dev;
    8000371c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003720:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003724:	4785                	li	a5,1
    80003726:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000372a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000372e:	0001c517          	auipc	a0,0x1c
    80003732:	11250513          	add	a0,a0,274 # 8001f840 <itable>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	550080e7          	jalr	1360(ra) # 80000c86 <release>
}
    8000373e:	854a                	mv	a0,s2
    80003740:	70a2                	ld	ra,40(sp)
    80003742:	7402                	ld	s0,32(sp)
    80003744:	64e2                	ld	s1,24(sp)
    80003746:	6942                	ld	s2,16(sp)
    80003748:	69a2                	ld	s3,8(sp)
    8000374a:	6a02                	ld	s4,0(sp)
    8000374c:	6145                	add	sp,sp,48
    8000374e:	8082                	ret
    panic("iget: no inodes");
    80003750:	00005517          	auipc	a0,0x5
    80003754:	fb850513          	add	a0,a0,-72 # 80008708 <syscalls+0x138>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	de4080e7          	jalr	-540(ra) # 8000053c <panic>

0000000080003760 <fsinit>:
fsinit(int dev) {
    80003760:	7179                	add	sp,sp,-48
    80003762:	f406                	sd	ra,40(sp)
    80003764:	f022                	sd	s0,32(sp)
    80003766:	ec26                	sd	s1,24(sp)
    80003768:	e84a                	sd	s2,16(sp)
    8000376a:	e44e                	sd	s3,8(sp)
    8000376c:	1800                	add	s0,sp,48
    8000376e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003770:	4585                	li	a1,1
    80003772:	00000097          	auipc	ra,0x0
    80003776:	a56080e7          	jalr	-1450(ra) # 800031c8 <bread>
    8000377a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000377c:	0001c997          	auipc	s3,0x1c
    80003780:	0a498993          	add	s3,s3,164 # 8001f820 <sb>
    80003784:	02000613          	li	a2,32
    80003788:	05850593          	add	a1,a0,88
    8000378c:	854e                	mv	a0,s3
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	59c080e7          	jalr	1436(ra) # 80000d2a <memmove>
  brelse(bp);
    80003796:	8526                	mv	a0,s1
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	b60080e7          	jalr	-1184(ra) # 800032f8 <brelse>
  if(sb.magic != FSMAGIC)
    800037a0:	0009a703          	lw	a4,0(s3)
    800037a4:	102037b7          	lui	a5,0x10203
    800037a8:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037ac:	02f71263          	bne	a4,a5,800037d0 <fsinit+0x70>
  initlog(dev, &sb);
    800037b0:	0001c597          	auipc	a1,0x1c
    800037b4:	07058593          	add	a1,a1,112 # 8001f820 <sb>
    800037b8:	854a                	mv	a0,s2
    800037ba:	00001097          	auipc	ra,0x1
    800037be:	b2c080e7          	jalr	-1236(ra) # 800042e6 <initlog>
}
    800037c2:	70a2                	ld	ra,40(sp)
    800037c4:	7402                	ld	s0,32(sp)
    800037c6:	64e2                	ld	s1,24(sp)
    800037c8:	6942                	ld	s2,16(sp)
    800037ca:	69a2                	ld	s3,8(sp)
    800037cc:	6145                	add	sp,sp,48
    800037ce:	8082                	ret
    panic("invalid file system");
    800037d0:	00005517          	auipc	a0,0x5
    800037d4:	f4850513          	add	a0,a0,-184 # 80008718 <syscalls+0x148>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	d64080e7          	jalr	-668(ra) # 8000053c <panic>

00000000800037e0 <iinit>:
{
    800037e0:	7179                	add	sp,sp,-48
    800037e2:	f406                	sd	ra,40(sp)
    800037e4:	f022                	sd	s0,32(sp)
    800037e6:	ec26                	sd	s1,24(sp)
    800037e8:	e84a                	sd	s2,16(sp)
    800037ea:	e44e                	sd	s3,8(sp)
    800037ec:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800037ee:	00005597          	auipc	a1,0x5
    800037f2:	f4258593          	add	a1,a1,-190 # 80008730 <syscalls+0x160>
    800037f6:	0001c517          	auipc	a0,0x1c
    800037fa:	04a50513          	add	a0,a0,74 # 8001f840 <itable>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	344080e7          	jalr	836(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003806:	0001c497          	auipc	s1,0x1c
    8000380a:	06248493          	add	s1,s1,98 # 8001f868 <itable+0x28>
    8000380e:	0001e997          	auipc	s3,0x1e
    80003812:	aea98993          	add	s3,s3,-1302 # 800212f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003816:	00005917          	auipc	s2,0x5
    8000381a:	f2290913          	add	s2,s2,-222 # 80008738 <syscalls+0x168>
    8000381e:	85ca                	mv	a1,s2
    80003820:	8526                	mv	a0,s1
    80003822:	00001097          	auipc	ra,0x1
    80003826:	e12080e7          	jalr	-494(ra) # 80004634 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000382a:	08848493          	add	s1,s1,136
    8000382e:	ff3498e3          	bne	s1,s3,8000381e <iinit+0x3e>
}
    80003832:	70a2                	ld	ra,40(sp)
    80003834:	7402                	ld	s0,32(sp)
    80003836:	64e2                	ld	s1,24(sp)
    80003838:	6942                	ld	s2,16(sp)
    8000383a:	69a2                	ld	s3,8(sp)
    8000383c:	6145                	add	sp,sp,48
    8000383e:	8082                	ret

0000000080003840 <ialloc>:
{
    80003840:	7139                	add	sp,sp,-64
    80003842:	fc06                	sd	ra,56(sp)
    80003844:	f822                	sd	s0,48(sp)
    80003846:	f426                	sd	s1,40(sp)
    80003848:	f04a                	sd	s2,32(sp)
    8000384a:	ec4e                	sd	s3,24(sp)
    8000384c:	e852                	sd	s4,16(sp)
    8000384e:	e456                	sd	s5,8(sp)
    80003850:	e05a                	sd	s6,0(sp)
    80003852:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003854:	0001c717          	auipc	a4,0x1c
    80003858:	fd872703          	lw	a4,-40(a4) # 8001f82c <sb+0xc>
    8000385c:	4785                	li	a5,1
    8000385e:	04e7f863          	bgeu	a5,a4,800038ae <ialloc+0x6e>
    80003862:	8aaa                	mv	s5,a0
    80003864:	8b2e                	mv	s6,a1
    80003866:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003868:	0001ca17          	auipc	s4,0x1c
    8000386c:	fb8a0a13          	add	s4,s4,-72 # 8001f820 <sb>
    80003870:	00495593          	srl	a1,s2,0x4
    80003874:	018a2783          	lw	a5,24(s4)
    80003878:	9dbd                	addw	a1,a1,a5
    8000387a:	8556                	mv	a0,s5
    8000387c:	00000097          	auipc	ra,0x0
    80003880:	94c080e7          	jalr	-1716(ra) # 800031c8 <bread>
    80003884:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003886:	05850993          	add	s3,a0,88
    8000388a:	00f97793          	and	a5,s2,15
    8000388e:	079a                	sll	a5,a5,0x6
    80003890:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003892:	00099783          	lh	a5,0(s3)
    80003896:	cf9d                	beqz	a5,800038d4 <ialloc+0x94>
    brelse(bp);
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	a60080e7          	jalr	-1440(ra) # 800032f8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038a0:	0905                	add	s2,s2,1
    800038a2:	00ca2703          	lw	a4,12(s4)
    800038a6:	0009079b          	sext.w	a5,s2
    800038aa:	fce7e3e3          	bltu	a5,a4,80003870 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    800038ae:	00005517          	auipc	a0,0x5
    800038b2:	e9250513          	add	a0,a0,-366 # 80008740 <syscalls+0x170>
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	cd0080e7          	jalr	-816(ra) # 80000586 <printf>
  return 0;
    800038be:	4501                	li	a0,0
}
    800038c0:	70e2                	ld	ra,56(sp)
    800038c2:	7442                	ld	s0,48(sp)
    800038c4:	74a2                	ld	s1,40(sp)
    800038c6:	7902                	ld	s2,32(sp)
    800038c8:	69e2                	ld	s3,24(sp)
    800038ca:	6a42                	ld	s4,16(sp)
    800038cc:	6aa2                	ld	s5,8(sp)
    800038ce:	6b02                	ld	s6,0(sp)
    800038d0:	6121                	add	sp,sp,64
    800038d2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038d4:	04000613          	li	a2,64
    800038d8:	4581                	li	a1,0
    800038da:	854e                	mv	a0,s3
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	3f2080e7          	jalr	1010(ra) # 80000cce <memset>
      dip->type = type;
    800038e4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038e8:	8526                	mv	a0,s1
    800038ea:	00001097          	auipc	ra,0x1
    800038ee:	c66080e7          	jalr	-922(ra) # 80004550 <log_write>
      brelse(bp);
    800038f2:	8526                	mv	a0,s1
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	a04080e7          	jalr	-1532(ra) # 800032f8 <brelse>
      return iget(dev, inum);
    800038fc:	0009059b          	sext.w	a1,s2
    80003900:	8556                	mv	a0,s5
    80003902:	00000097          	auipc	ra,0x0
    80003906:	da2080e7          	jalr	-606(ra) # 800036a4 <iget>
    8000390a:	bf5d                	j	800038c0 <ialloc+0x80>

000000008000390c <iupdate>:
{
    8000390c:	1101                	add	sp,sp,-32
    8000390e:	ec06                	sd	ra,24(sp)
    80003910:	e822                	sd	s0,16(sp)
    80003912:	e426                	sd	s1,8(sp)
    80003914:	e04a                	sd	s2,0(sp)
    80003916:	1000                	add	s0,sp,32
    80003918:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000391a:	415c                	lw	a5,4(a0)
    8000391c:	0047d79b          	srlw	a5,a5,0x4
    80003920:	0001c597          	auipc	a1,0x1c
    80003924:	f185a583          	lw	a1,-232(a1) # 8001f838 <sb+0x18>
    80003928:	9dbd                	addw	a1,a1,a5
    8000392a:	4108                	lw	a0,0(a0)
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	89c080e7          	jalr	-1892(ra) # 800031c8 <bread>
    80003934:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003936:	05850793          	add	a5,a0,88
    8000393a:	40d8                	lw	a4,4(s1)
    8000393c:	8b3d                	and	a4,a4,15
    8000393e:	071a                	sll	a4,a4,0x6
    80003940:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003942:	04449703          	lh	a4,68(s1)
    80003946:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000394a:	04649703          	lh	a4,70(s1)
    8000394e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003952:	04849703          	lh	a4,72(s1)
    80003956:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000395a:	04a49703          	lh	a4,74(s1)
    8000395e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003962:	44f8                	lw	a4,76(s1)
    80003964:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003966:	03400613          	li	a2,52
    8000396a:	05048593          	add	a1,s1,80
    8000396e:	00c78513          	add	a0,a5,12
    80003972:	ffffd097          	auipc	ra,0xffffd
    80003976:	3b8080e7          	jalr	952(ra) # 80000d2a <memmove>
  log_write(bp);
    8000397a:	854a                	mv	a0,s2
    8000397c:	00001097          	auipc	ra,0x1
    80003980:	bd4080e7          	jalr	-1068(ra) # 80004550 <log_write>
  brelse(bp);
    80003984:	854a                	mv	a0,s2
    80003986:	00000097          	auipc	ra,0x0
    8000398a:	972080e7          	jalr	-1678(ra) # 800032f8 <brelse>
}
    8000398e:	60e2                	ld	ra,24(sp)
    80003990:	6442                	ld	s0,16(sp)
    80003992:	64a2                	ld	s1,8(sp)
    80003994:	6902                	ld	s2,0(sp)
    80003996:	6105                	add	sp,sp,32
    80003998:	8082                	ret

000000008000399a <idup>:
{
    8000399a:	1101                	add	sp,sp,-32
    8000399c:	ec06                	sd	ra,24(sp)
    8000399e:	e822                	sd	s0,16(sp)
    800039a0:	e426                	sd	s1,8(sp)
    800039a2:	1000                	add	s0,sp,32
    800039a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039a6:	0001c517          	auipc	a0,0x1c
    800039aa:	e9a50513          	add	a0,a0,-358 # 8001f840 <itable>
    800039ae:	ffffd097          	auipc	ra,0xffffd
    800039b2:	224080e7          	jalr	548(ra) # 80000bd2 <acquire>
  ip->ref++;
    800039b6:	449c                	lw	a5,8(s1)
    800039b8:	2785                	addw	a5,a5,1
    800039ba:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039bc:	0001c517          	auipc	a0,0x1c
    800039c0:	e8450513          	add	a0,a0,-380 # 8001f840 <itable>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	2c2080e7          	jalr	706(ra) # 80000c86 <release>
}
    800039cc:	8526                	mv	a0,s1
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	64a2                	ld	s1,8(sp)
    800039d4:	6105                	add	sp,sp,32
    800039d6:	8082                	ret

00000000800039d8 <ilock>:
{
    800039d8:	1101                	add	sp,sp,-32
    800039da:	ec06                	sd	ra,24(sp)
    800039dc:	e822                	sd	s0,16(sp)
    800039de:	e426                	sd	s1,8(sp)
    800039e0:	e04a                	sd	s2,0(sp)
    800039e2:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039e4:	c115                	beqz	a0,80003a08 <ilock+0x30>
    800039e6:	84aa                	mv	s1,a0
    800039e8:	451c                	lw	a5,8(a0)
    800039ea:	00f05f63          	blez	a5,80003a08 <ilock+0x30>
  acquiresleep(&ip->lock);
    800039ee:	0541                	add	a0,a0,16
    800039f0:	00001097          	auipc	ra,0x1
    800039f4:	c7e080e7          	jalr	-898(ra) # 8000466e <acquiresleep>
  if(ip->valid == 0){
    800039f8:	40bc                	lw	a5,64(s1)
    800039fa:	cf99                	beqz	a5,80003a18 <ilock+0x40>
}
    800039fc:	60e2                	ld	ra,24(sp)
    800039fe:	6442                	ld	s0,16(sp)
    80003a00:	64a2                	ld	s1,8(sp)
    80003a02:	6902                	ld	s2,0(sp)
    80003a04:	6105                	add	sp,sp,32
    80003a06:	8082                	ret
    panic("ilock");
    80003a08:	00005517          	auipc	a0,0x5
    80003a0c:	d5050513          	add	a0,a0,-688 # 80008758 <syscalls+0x188>
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	b2c080e7          	jalr	-1236(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a18:	40dc                	lw	a5,4(s1)
    80003a1a:	0047d79b          	srlw	a5,a5,0x4
    80003a1e:	0001c597          	auipc	a1,0x1c
    80003a22:	e1a5a583          	lw	a1,-486(a1) # 8001f838 <sb+0x18>
    80003a26:	9dbd                	addw	a1,a1,a5
    80003a28:	4088                	lw	a0,0(s1)
    80003a2a:	fffff097          	auipc	ra,0xfffff
    80003a2e:	79e080e7          	jalr	1950(ra) # 800031c8 <bread>
    80003a32:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a34:	05850593          	add	a1,a0,88
    80003a38:	40dc                	lw	a5,4(s1)
    80003a3a:	8bbd                	and	a5,a5,15
    80003a3c:	079a                	sll	a5,a5,0x6
    80003a3e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a40:	00059783          	lh	a5,0(a1)
    80003a44:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a48:	00259783          	lh	a5,2(a1)
    80003a4c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a50:	00459783          	lh	a5,4(a1)
    80003a54:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a58:	00659783          	lh	a5,6(a1)
    80003a5c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a60:	459c                	lw	a5,8(a1)
    80003a62:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a64:	03400613          	li	a2,52
    80003a68:	05b1                	add	a1,a1,12
    80003a6a:	05048513          	add	a0,s1,80
    80003a6e:	ffffd097          	auipc	ra,0xffffd
    80003a72:	2bc080e7          	jalr	700(ra) # 80000d2a <memmove>
    brelse(bp);
    80003a76:	854a                	mv	a0,s2
    80003a78:	00000097          	auipc	ra,0x0
    80003a7c:	880080e7          	jalr	-1920(ra) # 800032f8 <brelse>
    ip->valid = 1;
    80003a80:	4785                	li	a5,1
    80003a82:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a84:	04449783          	lh	a5,68(s1)
    80003a88:	fbb5                	bnez	a5,800039fc <ilock+0x24>
      panic("ilock: no type");
    80003a8a:	00005517          	auipc	a0,0x5
    80003a8e:	cd650513          	add	a0,a0,-810 # 80008760 <syscalls+0x190>
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	aaa080e7          	jalr	-1366(ra) # 8000053c <panic>

0000000080003a9a <iunlock>:
{
    80003a9a:	1101                	add	sp,sp,-32
    80003a9c:	ec06                	sd	ra,24(sp)
    80003a9e:	e822                	sd	s0,16(sp)
    80003aa0:	e426                	sd	s1,8(sp)
    80003aa2:	e04a                	sd	s2,0(sp)
    80003aa4:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003aa6:	c905                	beqz	a0,80003ad6 <iunlock+0x3c>
    80003aa8:	84aa                	mv	s1,a0
    80003aaa:	01050913          	add	s2,a0,16
    80003aae:	854a                	mv	a0,s2
    80003ab0:	00001097          	auipc	ra,0x1
    80003ab4:	c58080e7          	jalr	-936(ra) # 80004708 <holdingsleep>
    80003ab8:	cd19                	beqz	a0,80003ad6 <iunlock+0x3c>
    80003aba:	449c                	lw	a5,8(s1)
    80003abc:	00f05d63          	blez	a5,80003ad6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ac0:	854a                	mv	a0,s2
    80003ac2:	00001097          	auipc	ra,0x1
    80003ac6:	c02080e7          	jalr	-1022(ra) # 800046c4 <releasesleep>
}
    80003aca:	60e2                	ld	ra,24(sp)
    80003acc:	6442                	ld	s0,16(sp)
    80003ace:	64a2                	ld	s1,8(sp)
    80003ad0:	6902                	ld	s2,0(sp)
    80003ad2:	6105                	add	sp,sp,32
    80003ad4:	8082                	ret
    panic("iunlock");
    80003ad6:	00005517          	auipc	a0,0x5
    80003ada:	c9a50513          	add	a0,a0,-870 # 80008770 <syscalls+0x1a0>
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	a5e080e7          	jalr	-1442(ra) # 8000053c <panic>

0000000080003ae6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ae6:	7179                	add	sp,sp,-48
    80003ae8:	f406                	sd	ra,40(sp)
    80003aea:	f022                	sd	s0,32(sp)
    80003aec:	ec26                	sd	s1,24(sp)
    80003aee:	e84a                	sd	s2,16(sp)
    80003af0:	e44e                	sd	s3,8(sp)
    80003af2:	e052                	sd	s4,0(sp)
    80003af4:	1800                	add	s0,sp,48
    80003af6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003af8:	05050493          	add	s1,a0,80
    80003afc:	08050913          	add	s2,a0,128
    80003b00:	a021                	j	80003b08 <itrunc+0x22>
    80003b02:	0491                	add	s1,s1,4
    80003b04:	01248d63          	beq	s1,s2,80003b1e <itrunc+0x38>
    if(ip->addrs[i]){
    80003b08:	408c                	lw	a1,0(s1)
    80003b0a:	dde5                	beqz	a1,80003b02 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b0c:	0009a503          	lw	a0,0(s3)
    80003b10:	00000097          	auipc	ra,0x0
    80003b14:	8fc080e7          	jalr	-1796(ra) # 8000340c <bfree>
      ip->addrs[i] = 0;
    80003b18:	0004a023          	sw	zero,0(s1)
    80003b1c:	b7dd                	j	80003b02 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b1e:	0809a583          	lw	a1,128(s3)
    80003b22:	e185                	bnez	a1,80003b42 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b24:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b28:	854e                	mv	a0,s3
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	de2080e7          	jalr	-542(ra) # 8000390c <iupdate>
}
    80003b32:	70a2                	ld	ra,40(sp)
    80003b34:	7402                	ld	s0,32(sp)
    80003b36:	64e2                	ld	s1,24(sp)
    80003b38:	6942                	ld	s2,16(sp)
    80003b3a:	69a2                	ld	s3,8(sp)
    80003b3c:	6a02                	ld	s4,0(sp)
    80003b3e:	6145                	add	sp,sp,48
    80003b40:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b42:	0009a503          	lw	a0,0(s3)
    80003b46:	fffff097          	auipc	ra,0xfffff
    80003b4a:	682080e7          	jalr	1666(ra) # 800031c8 <bread>
    80003b4e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b50:	05850493          	add	s1,a0,88
    80003b54:	45850913          	add	s2,a0,1112
    80003b58:	a021                	j	80003b60 <itrunc+0x7a>
    80003b5a:	0491                	add	s1,s1,4
    80003b5c:	01248b63          	beq	s1,s2,80003b72 <itrunc+0x8c>
      if(a[j])
    80003b60:	408c                	lw	a1,0(s1)
    80003b62:	dde5                	beqz	a1,80003b5a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b64:	0009a503          	lw	a0,0(s3)
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	8a4080e7          	jalr	-1884(ra) # 8000340c <bfree>
    80003b70:	b7ed                	j	80003b5a <itrunc+0x74>
    brelse(bp);
    80003b72:	8552                	mv	a0,s4
    80003b74:	fffff097          	auipc	ra,0xfffff
    80003b78:	784080e7          	jalr	1924(ra) # 800032f8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b7c:	0809a583          	lw	a1,128(s3)
    80003b80:	0009a503          	lw	a0,0(s3)
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	888080e7          	jalr	-1912(ra) # 8000340c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b8c:	0809a023          	sw	zero,128(s3)
    80003b90:	bf51                	j	80003b24 <itrunc+0x3e>

0000000080003b92 <iput>:
{
    80003b92:	1101                	add	sp,sp,-32
    80003b94:	ec06                	sd	ra,24(sp)
    80003b96:	e822                	sd	s0,16(sp)
    80003b98:	e426                	sd	s1,8(sp)
    80003b9a:	e04a                	sd	s2,0(sp)
    80003b9c:	1000                	add	s0,sp,32
    80003b9e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ba0:	0001c517          	auipc	a0,0x1c
    80003ba4:	ca050513          	add	a0,a0,-864 # 8001f840 <itable>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	02a080e7          	jalr	42(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bb0:	4498                	lw	a4,8(s1)
    80003bb2:	4785                	li	a5,1
    80003bb4:	02f70363          	beq	a4,a5,80003bda <iput+0x48>
  ip->ref--;
    80003bb8:	449c                	lw	a5,8(s1)
    80003bba:	37fd                	addw	a5,a5,-1
    80003bbc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bbe:	0001c517          	auipc	a0,0x1c
    80003bc2:	c8250513          	add	a0,a0,-894 # 8001f840 <itable>
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	0c0080e7          	jalr	192(ra) # 80000c86 <release>
}
    80003bce:	60e2                	ld	ra,24(sp)
    80003bd0:	6442                	ld	s0,16(sp)
    80003bd2:	64a2                	ld	s1,8(sp)
    80003bd4:	6902                	ld	s2,0(sp)
    80003bd6:	6105                	add	sp,sp,32
    80003bd8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bda:	40bc                	lw	a5,64(s1)
    80003bdc:	dff1                	beqz	a5,80003bb8 <iput+0x26>
    80003bde:	04a49783          	lh	a5,74(s1)
    80003be2:	fbf9                	bnez	a5,80003bb8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003be4:	01048913          	add	s2,s1,16
    80003be8:	854a                	mv	a0,s2
    80003bea:	00001097          	auipc	ra,0x1
    80003bee:	a84080e7          	jalr	-1404(ra) # 8000466e <acquiresleep>
    release(&itable.lock);
    80003bf2:	0001c517          	auipc	a0,0x1c
    80003bf6:	c4e50513          	add	a0,a0,-946 # 8001f840 <itable>
    80003bfa:	ffffd097          	auipc	ra,0xffffd
    80003bfe:	08c080e7          	jalr	140(ra) # 80000c86 <release>
    itrunc(ip);
    80003c02:	8526                	mv	a0,s1
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	ee2080e7          	jalr	-286(ra) # 80003ae6 <itrunc>
    ip->type = 0;
    80003c0c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c10:	8526                	mv	a0,s1
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	cfa080e7          	jalr	-774(ra) # 8000390c <iupdate>
    ip->valid = 0;
    80003c1a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c1e:	854a                	mv	a0,s2
    80003c20:	00001097          	auipc	ra,0x1
    80003c24:	aa4080e7          	jalr	-1372(ra) # 800046c4 <releasesleep>
    acquire(&itable.lock);
    80003c28:	0001c517          	auipc	a0,0x1c
    80003c2c:	c1850513          	add	a0,a0,-1000 # 8001f840 <itable>
    80003c30:	ffffd097          	auipc	ra,0xffffd
    80003c34:	fa2080e7          	jalr	-94(ra) # 80000bd2 <acquire>
    80003c38:	b741                	j	80003bb8 <iput+0x26>

0000000080003c3a <iunlockput>:
{
    80003c3a:	1101                	add	sp,sp,-32
    80003c3c:	ec06                	sd	ra,24(sp)
    80003c3e:	e822                	sd	s0,16(sp)
    80003c40:	e426                	sd	s1,8(sp)
    80003c42:	1000                	add	s0,sp,32
    80003c44:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	e54080e7          	jalr	-428(ra) # 80003a9a <iunlock>
  iput(ip);
    80003c4e:	8526                	mv	a0,s1
    80003c50:	00000097          	auipc	ra,0x0
    80003c54:	f42080e7          	jalr	-190(ra) # 80003b92 <iput>
}
    80003c58:	60e2                	ld	ra,24(sp)
    80003c5a:	6442                	ld	s0,16(sp)
    80003c5c:	64a2                	ld	s1,8(sp)
    80003c5e:	6105                	add	sp,sp,32
    80003c60:	8082                	ret

0000000080003c62 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c62:	1141                	add	sp,sp,-16
    80003c64:	e422                	sd	s0,8(sp)
    80003c66:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003c68:	411c                	lw	a5,0(a0)
    80003c6a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c6c:	415c                	lw	a5,4(a0)
    80003c6e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c70:	04451783          	lh	a5,68(a0)
    80003c74:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c78:	04a51783          	lh	a5,74(a0)
    80003c7c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c80:	04c56783          	lwu	a5,76(a0)
    80003c84:	e99c                	sd	a5,16(a1)
}
    80003c86:	6422                	ld	s0,8(sp)
    80003c88:	0141                	add	sp,sp,16
    80003c8a:	8082                	ret

0000000080003c8c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c8c:	457c                	lw	a5,76(a0)
    80003c8e:	0ed7e963          	bltu	a5,a3,80003d80 <readi+0xf4>
{
    80003c92:	7159                	add	sp,sp,-112
    80003c94:	f486                	sd	ra,104(sp)
    80003c96:	f0a2                	sd	s0,96(sp)
    80003c98:	eca6                	sd	s1,88(sp)
    80003c9a:	e8ca                	sd	s2,80(sp)
    80003c9c:	e4ce                	sd	s3,72(sp)
    80003c9e:	e0d2                	sd	s4,64(sp)
    80003ca0:	fc56                	sd	s5,56(sp)
    80003ca2:	f85a                	sd	s6,48(sp)
    80003ca4:	f45e                	sd	s7,40(sp)
    80003ca6:	f062                	sd	s8,32(sp)
    80003ca8:	ec66                	sd	s9,24(sp)
    80003caa:	e86a                	sd	s10,16(sp)
    80003cac:	e46e                	sd	s11,8(sp)
    80003cae:	1880                	add	s0,sp,112
    80003cb0:	8b2a                	mv	s6,a0
    80003cb2:	8bae                	mv	s7,a1
    80003cb4:	8a32                	mv	s4,a2
    80003cb6:	84b6                	mv	s1,a3
    80003cb8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cba:	9f35                	addw	a4,a4,a3
    return 0;
    80003cbc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cbe:	0ad76063          	bltu	a4,a3,80003d5e <readi+0xd2>
  if(off + n > ip->size)
    80003cc2:	00e7f463          	bgeu	a5,a4,80003cca <readi+0x3e>
    n = ip->size - off;
    80003cc6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cca:	0a0a8963          	beqz	s5,80003d7c <readi+0xf0>
    80003cce:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cd4:	5c7d                	li	s8,-1
    80003cd6:	a82d                	j	80003d10 <readi+0x84>
    80003cd8:	020d1d93          	sll	s11,s10,0x20
    80003cdc:	020ddd93          	srl	s11,s11,0x20
    80003ce0:	05890613          	add	a2,s2,88
    80003ce4:	86ee                	mv	a3,s11
    80003ce6:	963a                	add	a2,a2,a4
    80003ce8:	85d2                	mv	a1,s4
    80003cea:	855e                	mv	a0,s7
    80003cec:	ffffe097          	auipc	ra,0xffffe
    80003cf0:	76a080e7          	jalr	1898(ra) # 80002456 <either_copyout>
    80003cf4:	05850d63          	beq	a0,s8,80003d4e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	fffff097          	auipc	ra,0xfffff
    80003cfe:	5fe080e7          	jalr	1534(ra) # 800032f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d02:	013d09bb          	addw	s3,s10,s3
    80003d06:	009d04bb          	addw	s1,s10,s1
    80003d0a:	9a6e                	add	s4,s4,s11
    80003d0c:	0559f763          	bgeu	s3,s5,80003d5a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d10:	00a4d59b          	srlw	a1,s1,0xa
    80003d14:	855a                	mv	a0,s6
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	8a4080e7          	jalr	-1884(ra) # 800035ba <bmap>
    80003d1e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d22:	cd85                	beqz	a1,80003d5a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d24:	000b2503          	lw	a0,0(s6)
    80003d28:	fffff097          	auipc	ra,0xfffff
    80003d2c:	4a0080e7          	jalr	1184(ra) # 800031c8 <bread>
    80003d30:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d32:	3ff4f713          	and	a4,s1,1023
    80003d36:	40ec87bb          	subw	a5,s9,a4
    80003d3a:	413a86bb          	subw	a3,s5,s3
    80003d3e:	8d3e                	mv	s10,a5
    80003d40:	2781                	sext.w	a5,a5
    80003d42:	0006861b          	sext.w	a2,a3
    80003d46:	f8f679e3          	bgeu	a2,a5,80003cd8 <readi+0x4c>
    80003d4a:	8d36                	mv	s10,a3
    80003d4c:	b771                	j	80003cd8 <readi+0x4c>
      brelse(bp);
    80003d4e:	854a                	mv	a0,s2
    80003d50:	fffff097          	auipc	ra,0xfffff
    80003d54:	5a8080e7          	jalr	1448(ra) # 800032f8 <brelse>
      tot = -1;
    80003d58:	59fd                	li	s3,-1
  }
  return tot;
    80003d5a:	0009851b          	sext.w	a0,s3
}
    80003d5e:	70a6                	ld	ra,104(sp)
    80003d60:	7406                	ld	s0,96(sp)
    80003d62:	64e6                	ld	s1,88(sp)
    80003d64:	6946                	ld	s2,80(sp)
    80003d66:	69a6                	ld	s3,72(sp)
    80003d68:	6a06                	ld	s4,64(sp)
    80003d6a:	7ae2                	ld	s5,56(sp)
    80003d6c:	7b42                	ld	s6,48(sp)
    80003d6e:	7ba2                	ld	s7,40(sp)
    80003d70:	7c02                	ld	s8,32(sp)
    80003d72:	6ce2                	ld	s9,24(sp)
    80003d74:	6d42                	ld	s10,16(sp)
    80003d76:	6da2                	ld	s11,8(sp)
    80003d78:	6165                	add	sp,sp,112
    80003d7a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d7c:	89d6                	mv	s3,s5
    80003d7e:	bff1                	j	80003d5a <readi+0xce>
    return 0;
    80003d80:	4501                	li	a0,0
}
    80003d82:	8082                	ret

0000000080003d84 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d84:	457c                	lw	a5,76(a0)
    80003d86:	10d7e863          	bltu	a5,a3,80003e96 <writei+0x112>
{
    80003d8a:	7159                	add	sp,sp,-112
    80003d8c:	f486                	sd	ra,104(sp)
    80003d8e:	f0a2                	sd	s0,96(sp)
    80003d90:	eca6                	sd	s1,88(sp)
    80003d92:	e8ca                	sd	s2,80(sp)
    80003d94:	e4ce                	sd	s3,72(sp)
    80003d96:	e0d2                	sd	s4,64(sp)
    80003d98:	fc56                	sd	s5,56(sp)
    80003d9a:	f85a                	sd	s6,48(sp)
    80003d9c:	f45e                	sd	s7,40(sp)
    80003d9e:	f062                	sd	s8,32(sp)
    80003da0:	ec66                	sd	s9,24(sp)
    80003da2:	e86a                	sd	s10,16(sp)
    80003da4:	e46e                	sd	s11,8(sp)
    80003da6:	1880                	add	s0,sp,112
    80003da8:	8aaa                	mv	s5,a0
    80003daa:	8bae                	mv	s7,a1
    80003dac:	8a32                	mv	s4,a2
    80003dae:	8936                	mv	s2,a3
    80003db0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003db2:	00e687bb          	addw	a5,a3,a4
    80003db6:	0ed7e263          	bltu	a5,a3,80003e9a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dba:	00043737          	lui	a4,0x43
    80003dbe:	0ef76063          	bltu	a4,a5,80003e9e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc2:	0c0b0863          	beqz	s6,80003e92 <writei+0x10e>
    80003dc6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dcc:	5c7d                	li	s8,-1
    80003dce:	a091                	j	80003e12 <writei+0x8e>
    80003dd0:	020d1d93          	sll	s11,s10,0x20
    80003dd4:	020ddd93          	srl	s11,s11,0x20
    80003dd8:	05848513          	add	a0,s1,88
    80003ddc:	86ee                	mv	a3,s11
    80003dde:	8652                	mv	a2,s4
    80003de0:	85de                	mv	a1,s7
    80003de2:	953a                	add	a0,a0,a4
    80003de4:	ffffe097          	auipc	ra,0xffffe
    80003de8:	6c8080e7          	jalr	1736(ra) # 800024ac <either_copyin>
    80003dec:	07850263          	beq	a0,s8,80003e50 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003df0:	8526                	mv	a0,s1
    80003df2:	00000097          	auipc	ra,0x0
    80003df6:	75e080e7          	jalr	1886(ra) # 80004550 <log_write>
    brelse(bp);
    80003dfa:	8526                	mv	a0,s1
    80003dfc:	fffff097          	auipc	ra,0xfffff
    80003e00:	4fc080e7          	jalr	1276(ra) # 800032f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e04:	013d09bb          	addw	s3,s10,s3
    80003e08:	012d093b          	addw	s2,s10,s2
    80003e0c:	9a6e                	add	s4,s4,s11
    80003e0e:	0569f663          	bgeu	s3,s6,80003e5a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e12:	00a9559b          	srlw	a1,s2,0xa
    80003e16:	8556                	mv	a0,s5
    80003e18:	fffff097          	auipc	ra,0xfffff
    80003e1c:	7a2080e7          	jalr	1954(ra) # 800035ba <bmap>
    80003e20:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e24:	c99d                	beqz	a1,80003e5a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e26:	000aa503          	lw	a0,0(s5)
    80003e2a:	fffff097          	auipc	ra,0xfffff
    80003e2e:	39e080e7          	jalr	926(ra) # 800031c8 <bread>
    80003e32:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e34:	3ff97713          	and	a4,s2,1023
    80003e38:	40ec87bb          	subw	a5,s9,a4
    80003e3c:	413b06bb          	subw	a3,s6,s3
    80003e40:	8d3e                	mv	s10,a5
    80003e42:	2781                	sext.w	a5,a5
    80003e44:	0006861b          	sext.w	a2,a3
    80003e48:	f8f674e3          	bgeu	a2,a5,80003dd0 <writei+0x4c>
    80003e4c:	8d36                	mv	s10,a3
    80003e4e:	b749                	j	80003dd0 <writei+0x4c>
      brelse(bp);
    80003e50:	8526                	mv	a0,s1
    80003e52:	fffff097          	auipc	ra,0xfffff
    80003e56:	4a6080e7          	jalr	1190(ra) # 800032f8 <brelse>
  }

  if(off > ip->size)
    80003e5a:	04caa783          	lw	a5,76(s5)
    80003e5e:	0127f463          	bgeu	a5,s2,80003e66 <writei+0xe2>
    ip->size = off;
    80003e62:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e66:	8556                	mv	a0,s5
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	aa4080e7          	jalr	-1372(ra) # 8000390c <iupdate>

  return tot;
    80003e70:	0009851b          	sext.w	a0,s3
}
    80003e74:	70a6                	ld	ra,104(sp)
    80003e76:	7406                	ld	s0,96(sp)
    80003e78:	64e6                	ld	s1,88(sp)
    80003e7a:	6946                	ld	s2,80(sp)
    80003e7c:	69a6                	ld	s3,72(sp)
    80003e7e:	6a06                	ld	s4,64(sp)
    80003e80:	7ae2                	ld	s5,56(sp)
    80003e82:	7b42                	ld	s6,48(sp)
    80003e84:	7ba2                	ld	s7,40(sp)
    80003e86:	7c02                	ld	s8,32(sp)
    80003e88:	6ce2                	ld	s9,24(sp)
    80003e8a:	6d42                	ld	s10,16(sp)
    80003e8c:	6da2                	ld	s11,8(sp)
    80003e8e:	6165                	add	sp,sp,112
    80003e90:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e92:	89da                	mv	s3,s6
    80003e94:	bfc9                	j	80003e66 <writei+0xe2>
    return -1;
    80003e96:	557d                	li	a0,-1
}
    80003e98:	8082                	ret
    return -1;
    80003e9a:	557d                	li	a0,-1
    80003e9c:	bfe1                	j	80003e74 <writei+0xf0>
    return -1;
    80003e9e:	557d                	li	a0,-1
    80003ea0:	bfd1                	j	80003e74 <writei+0xf0>

0000000080003ea2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ea2:	1141                	add	sp,sp,-16
    80003ea4:	e406                	sd	ra,8(sp)
    80003ea6:	e022                	sd	s0,0(sp)
    80003ea8:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eaa:	4639                	li	a2,14
    80003eac:	ffffd097          	auipc	ra,0xffffd
    80003eb0:	ef2080e7          	jalr	-270(ra) # 80000d9e <strncmp>
}
    80003eb4:	60a2                	ld	ra,8(sp)
    80003eb6:	6402                	ld	s0,0(sp)
    80003eb8:	0141                	add	sp,sp,16
    80003eba:	8082                	ret

0000000080003ebc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ebc:	7139                	add	sp,sp,-64
    80003ebe:	fc06                	sd	ra,56(sp)
    80003ec0:	f822                	sd	s0,48(sp)
    80003ec2:	f426                	sd	s1,40(sp)
    80003ec4:	f04a                	sd	s2,32(sp)
    80003ec6:	ec4e                	sd	s3,24(sp)
    80003ec8:	e852                	sd	s4,16(sp)
    80003eca:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ecc:	04451703          	lh	a4,68(a0)
    80003ed0:	4785                	li	a5,1
    80003ed2:	00f71a63          	bne	a4,a5,80003ee6 <dirlookup+0x2a>
    80003ed6:	892a                	mv	s2,a0
    80003ed8:	89ae                	mv	s3,a1
    80003eda:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003edc:	457c                	lw	a5,76(a0)
    80003ede:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ee0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee2:	e79d                	bnez	a5,80003f10 <dirlookup+0x54>
    80003ee4:	a8a5                	j	80003f5c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ee6:	00005517          	auipc	a0,0x5
    80003eea:	89250513          	add	a0,a0,-1902 # 80008778 <syscalls+0x1a8>
    80003eee:	ffffc097          	auipc	ra,0xffffc
    80003ef2:	64e080e7          	jalr	1614(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003ef6:	00005517          	auipc	a0,0x5
    80003efa:	89a50513          	add	a0,a0,-1894 # 80008790 <syscalls+0x1c0>
    80003efe:	ffffc097          	auipc	ra,0xffffc
    80003f02:	63e080e7          	jalr	1598(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f06:	24c1                	addw	s1,s1,16
    80003f08:	04c92783          	lw	a5,76(s2)
    80003f0c:	04f4f763          	bgeu	s1,a5,80003f5a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f10:	4741                	li	a4,16
    80003f12:	86a6                	mv	a3,s1
    80003f14:	fc040613          	add	a2,s0,-64
    80003f18:	4581                	li	a1,0
    80003f1a:	854a                	mv	a0,s2
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	d70080e7          	jalr	-656(ra) # 80003c8c <readi>
    80003f24:	47c1                	li	a5,16
    80003f26:	fcf518e3          	bne	a0,a5,80003ef6 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f2a:	fc045783          	lhu	a5,-64(s0)
    80003f2e:	dfe1                	beqz	a5,80003f06 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f30:	fc240593          	add	a1,s0,-62
    80003f34:	854e                	mv	a0,s3
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	f6c080e7          	jalr	-148(ra) # 80003ea2 <namecmp>
    80003f3e:	f561                	bnez	a0,80003f06 <dirlookup+0x4a>
      if(poff)
    80003f40:	000a0463          	beqz	s4,80003f48 <dirlookup+0x8c>
        *poff = off;
    80003f44:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f48:	fc045583          	lhu	a1,-64(s0)
    80003f4c:	00092503          	lw	a0,0(s2)
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	754080e7          	jalr	1876(ra) # 800036a4 <iget>
    80003f58:	a011                	j	80003f5c <dirlookup+0xa0>
  return 0;
    80003f5a:	4501                	li	a0,0
}
    80003f5c:	70e2                	ld	ra,56(sp)
    80003f5e:	7442                	ld	s0,48(sp)
    80003f60:	74a2                	ld	s1,40(sp)
    80003f62:	7902                	ld	s2,32(sp)
    80003f64:	69e2                	ld	s3,24(sp)
    80003f66:	6a42                	ld	s4,16(sp)
    80003f68:	6121                	add	sp,sp,64
    80003f6a:	8082                	ret

0000000080003f6c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f6c:	711d                	add	sp,sp,-96
    80003f6e:	ec86                	sd	ra,88(sp)
    80003f70:	e8a2                	sd	s0,80(sp)
    80003f72:	e4a6                	sd	s1,72(sp)
    80003f74:	e0ca                	sd	s2,64(sp)
    80003f76:	fc4e                	sd	s3,56(sp)
    80003f78:	f852                	sd	s4,48(sp)
    80003f7a:	f456                	sd	s5,40(sp)
    80003f7c:	f05a                	sd	s6,32(sp)
    80003f7e:	ec5e                	sd	s7,24(sp)
    80003f80:	e862                	sd	s8,16(sp)
    80003f82:	e466                	sd	s9,8(sp)
    80003f84:	1080                	add	s0,sp,96
    80003f86:	84aa                	mv	s1,a0
    80003f88:	8b2e                	mv	s6,a1
    80003f8a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f8c:	00054703          	lbu	a4,0(a0)
    80003f90:	02f00793          	li	a5,47
    80003f94:	02f70263          	beq	a4,a5,80003fb8 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f98:	ffffe097          	auipc	ra,0xffffe
    80003f9c:	a0e080e7          	jalr	-1522(ra) # 800019a6 <myproc>
    80003fa0:	15053503          	ld	a0,336(a0)
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	9f6080e7          	jalr	-1546(ra) # 8000399a <idup>
    80003fac:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003fae:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003fb2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fb4:	4b85                	li	s7,1
    80003fb6:	a875                	j	80004072 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003fb8:	4585                	li	a1,1
    80003fba:	4505                	li	a0,1
    80003fbc:	fffff097          	auipc	ra,0xfffff
    80003fc0:	6e8080e7          	jalr	1768(ra) # 800036a4 <iget>
    80003fc4:	8a2a                	mv	s4,a0
    80003fc6:	b7e5                	j	80003fae <namex+0x42>
      iunlockput(ip);
    80003fc8:	8552                	mv	a0,s4
    80003fca:	00000097          	auipc	ra,0x0
    80003fce:	c70080e7          	jalr	-912(ra) # 80003c3a <iunlockput>
      return 0;
    80003fd2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fd4:	8552                	mv	a0,s4
    80003fd6:	60e6                	ld	ra,88(sp)
    80003fd8:	6446                	ld	s0,80(sp)
    80003fda:	64a6                	ld	s1,72(sp)
    80003fdc:	6906                	ld	s2,64(sp)
    80003fde:	79e2                	ld	s3,56(sp)
    80003fe0:	7a42                	ld	s4,48(sp)
    80003fe2:	7aa2                	ld	s5,40(sp)
    80003fe4:	7b02                	ld	s6,32(sp)
    80003fe6:	6be2                	ld	s7,24(sp)
    80003fe8:	6c42                	ld	s8,16(sp)
    80003fea:	6ca2                	ld	s9,8(sp)
    80003fec:	6125                	add	sp,sp,96
    80003fee:	8082                	ret
      iunlock(ip);
    80003ff0:	8552                	mv	a0,s4
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	aa8080e7          	jalr	-1368(ra) # 80003a9a <iunlock>
      return ip;
    80003ffa:	bfe9                	j	80003fd4 <namex+0x68>
      iunlockput(ip);
    80003ffc:	8552                	mv	a0,s4
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	c3c080e7          	jalr	-964(ra) # 80003c3a <iunlockput>
      return 0;
    80004006:	8a4e                	mv	s4,s3
    80004008:	b7f1                	j	80003fd4 <namex+0x68>
  len = path - s;
    8000400a:	40998633          	sub	a2,s3,s1
    8000400e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004012:	099c5863          	bge	s8,s9,800040a2 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004016:	4639                	li	a2,14
    80004018:	85a6                	mv	a1,s1
    8000401a:	8556                	mv	a0,s5
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	d0e080e7          	jalr	-754(ra) # 80000d2a <memmove>
    80004024:	84ce                	mv	s1,s3
  while(*path == '/')
    80004026:	0004c783          	lbu	a5,0(s1)
    8000402a:	01279763          	bne	a5,s2,80004038 <namex+0xcc>
    path++;
    8000402e:	0485                	add	s1,s1,1
  while(*path == '/')
    80004030:	0004c783          	lbu	a5,0(s1)
    80004034:	ff278de3          	beq	a5,s2,8000402e <namex+0xc2>
    ilock(ip);
    80004038:	8552                	mv	a0,s4
    8000403a:	00000097          	auipc	ra,0x0
    8000403e:	99e080e7          	jalr	-1634(ra) # 800039d8 <ilock>
    if(ip->type != T_DIR){
    80004042:	044a1783          	lh	a5,68(s4)
    80004046:	f97791e3          	bne	a5,s7,80003fc8 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000404a:	000b0563          	beqz	s6,80004054 <namex+0xe8>
    8000404e:	0004c783          	lbu	a5,0(s1)
    80004052:	dfd9                	beqz	a5,80003ff0 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004054:	4601                	li	a2,0
    80004056:	85d6                	mv	a1,s5
    80004058:	8552                	mv	a0,s4
    8000405a:	00000097          	auipc	ra,0x0
    8000405e:	e62080e7          	jalr	-414(ra) # 80003ebc <dirlookup>
    80004062:	89aa                	mv	s3,a0
    80004064:	dd41                	beqz	a0,80003ffc <namex+0x90>
    iunlockput(ip);
    80004066:	8552                	mv	a0,s4
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	bd2080e7          	jalr	-1070(ra) # 80003c3a <iunlockput>
    ip = next;
    80004070:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004072:	0004c783          	lbu	a5,0(s1)
    80004076:	01279763          	bne	a5,s2,80004084 <namex+0x118>
    path++;
    8000407a:	0485                	add	s1,s1,1
  while(*path == '/')
    8000407c:	0004c783          	lbu	a5,0(s1)
    80004080:	ff278de3          	beq	a5,s2,8000407a <namex+0x10e>
  if(*path == 0)
    80004084:	cb9d                	beqz	a5,800040ba <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004086:	0004c783          	lbu	a5,0(s1)
    8000408a:	89a6                	mv	s3,s1
  len = path - s;
    8000408c:	4c81                	li	s9,0
    8000408e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004090:	01278963          	beq	a5,s2,800040a2 <namex+0x136>
    80004094:	dbbd                	beqz	a5,8000400a <namex+0x9e>
    path++;
    80004096:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80004098:	0009c783          	lbu	a5,0(s3)
    8000409c:	ff279ce3          	bne	a5,s2,80004094 <namex+0x128>
    800040a0:	b7ad                	j	8000400a <namex+0x9e>
    memmove(name, s, len);
    800040a2:	2601                	sext.w	a2,a2
    800040a4:	85a6                	mv	a1,s1
    800040a6:	8556                	mv	a0,s5
    800040a8:	ffffd097          	auipc	ra,0xffffd
    800040ac:	c82080e7          	jalr	-894(ra) # 80000d2a <memmove>
    name[len] = 0;
    800040b0:	9cd6                	add	s9,s9,s5
    800040b2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040b6:	84ce                	mv	s1,s3
    800040b8:	b7bd                	j	80004026 <namex+0xba>
  if(nameiparent){
    800040ba:	f00b0de3          	beqz	s6,80003fd4 <namex+0x68>
    iput(ip);
    800040be:	8552                	mv	a0,s4
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	ad2080e7          	jalr	-1326(ra) # 80003b92 <iput>
    return 0;
    800040c8:	4a01                	li	s4,0
    800040ca:	b729                	j	80003fd4 <namex+0x68>

00000000800040cc <dirlink>:
{
    800040cc:	7139                	add	sp,sp,-64
    800040ce:	fc06                	sd	ra,56(sp)
    800040d0:	f822                	sd	s0,48(sp)
    800040d2:	f426                	sd	s1,40(sp)
    800040d4:	f04a                	sd	s2,32(sp)
    800040d6:	ec4e                	sd	s3,24(sp)
    800040d8:	e852                	sd	s4,16(sp)
    800040da:	0080                	add	s0,sp,64
    800040dc:	892a                	mv	s2,a0
    800040de:	8a2e                	mv	s4,a1
    800040e0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040e2:	4601                	li	a2,0
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	dd8080e7          	jalr	-552(ra) # 80003ebc <dirlookup>
    800040ec:	e93d                	bnez	a0,80004162 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ee:	04c92483          	lw	s1,76(s2)
    800040f2:	c49d                	beqz	s1,80004120 <dirlink+0x54>
    800040f4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f6:	4741                	li	a4,16
    800040f8:	86a6                	mv	a3,s1
    800040fa:	fc040613          	add	a2,s0,-64
    800040fe:	4581                	li	a1,0
    80004100:	854a                	mv	a0,s2
    80004102:	00000097          	auipc	ra,0x0
    80004106:	b8a080e7          	jalr	-1142(ra) # 80003c8c <readi>
    8000410a:	47c1                	li	a5,16
    8000410c:	06f51163          	bne	a0,a5,8000416e <dirlink+0xa2>
    if(de.inum == 0)
    80004110:	fc045783          	lhu	a5,-64(s0)
    80004114:	c791                	beqz	a5,80004120 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004116:	24c1                	addw	s1,s1,16
    80004118:	04c92783          	lw	a5,76(s2)
    8000411c:	fcf4ede3          	bltu	s1,a5,800040f6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004120:	4639                	li	a2,14
    80004122:	85d2                	mv	a1,s4
    80004124:	fc240513          	add	a0,s0,-62
    80004128:	ffffd097          	auipc	ra,0xffffd
    8000412c:	cb2080e7          	jalr	-846(ra) # 80000dda <strncpy>
  de.inum = inum;
    80004130:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004134:	4741                	li	a4,16
    80004136:	86a6                	mv	a3,s1
    80004138:	fc040613          	add	a2,s0,-64
    8000413c:	4581                	li	a1,0
    8000413e:	854a                	mv	a0,s2
    80004140:	00000097          	auipc	ra,0x0
    80004144:	c44080e7          	jalr	-956(ra) # 80003d84 <writei>
    80004148:	1541                	add	a0,a0,-16
    8000414a:	00a03533          	snez	a0,a0
    8000414e:	40a00533          	neg	a0,a0
}
    80004152:	70e2                	ld	ra,56(sp)
    80004154:	7442                	ld	s0,48(sp)
    80004156:	74a2                	ld	s1,40(sp)
    80004158:	7902                	ld	s2,32(sp)
    8000415a:	69e2                	ld	s3,24(sp)
    8000415c:	6a42                	ld	s4,16(sp)
    8000415e:	6121                	add	sp,sp,64
    80004160:	8082                	ret
    iput(ip);
    80004162:	00000097          	auipc	ra,0x0
    80004166:	a30080e7          	jalr	-1488(ra) # 80003b92 <iput>
    return -1;
    8000416a:	557d                	li	a0,-1
    8000416c:	b7dd                	j	80004152 <dirlink+0x86>
      panic("dirlink read");
    8000416e:	00004517          	auipc	a0,0x4
    80004172:	63250513          	add	a0,a0,1586 # 800087a0 <syscalls+0x1d0>
    80004176:	ffffc097          	auipc	ra,0xffffc
    8000417a:	3c6080e7          	jalr	966(ra) # 8000053c <panic>

000000008000417e <namei>:

struct inode*
namei(char *path)
{
    8000417e:	1101                	add	sp,sp,-32
    80004180:	ec06                	sd	ra,24(sp)
    80004182:	e822                	sd	s0,16(sp)
    80004184:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004186:	fe040613          	add	a2,s0,-32
    8000418a:	4581                	li	a1,0
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	de0080e7          	jalr	-544(ra) # 80003f6c <namex>
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	6105                	add	sp,sp,32
    8000419a:	8082                	ret

000000008000419c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000419c:	1141                	add	sp,sp,-16
    8000419e:	e406                	sd	ra,8(sp)
    800041a0:	e022                	sd	s0,0(sp)
    800041a2:	0800                	add	s0,sp,16
    800041a4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041a6:	4585                	li	a1,1
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	dc4080e7          	jalr	-572(ra) # 80003f6c <namex>
}
    800041b0:	60a2                	ld	ra,8(sp)
    800041b2:	6402                	ld	s0,0(sp)
    800041b4:	0141                	add	sp,sp,16
    800041b6:	8082                	ret

00000000800041b8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041b8:	1101                	add	sp,sp,-32
    800041ba:	ec06                	sd	ra,24(sp)
    800041bc:	e822                	sd	s0,16(sp)
    800041be:	e426                	sd	s1,8(sp)
    800041c0:	e04a                	sd	s2,0(sp)
    800041c2:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041c4:	0001d917          	auipc	s2,0x1d
    800041c8:	12490913          	add	s2,s2,292 # 800212e8 <log>
    800041cc:	01892583          	lw	a1,24(s2)
    800041d0:	02892503          	lw	a0,40(s2)
    800041d4:	fffff097          	auipc	ra,0xfffff
    800041d8:	ff4080e7          	jalr	-12(ra) # 800031c8 <bread>
    800041dc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041de:	02c92603          	lw	a2,44(s2)
    800041e2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041e4:	00c05f63          	blez	a2,80004202 <write_head+0x4a>
    800041e8:	0001d717          	auipc	a4,0x1d
    800041ec:	13070713          	add	a4,a4,304 # 80021318 <log+0x30>
    800041f0:	87aa                	mv	a5,a0
    800041f2:	060a                	sll	a2,a2,0x2
    800041f4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800041f6:	4314                	lw	a3,0(a4)
    800041f8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800041fa:	0711                	add	a4,a4,4
    800041fc:	0791                	add	a5,a5,4
    800041fe:	fec79ce3          	bne	a5,a2,800041f6 <write_head+0x3e>
  }
  bwrite(buf);
    80004202:	8526                	mv	a0,s1
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	0b6080e7          	jalr	182(ra) # 800032ba <bwrite>
  brelse(buf);
    8000420c:	8526                	mv	a0,s1
    8000420e:	fffff097          	auipc	ra,0xfffff
    80004212:	0ea080e7          	jalr	234(ra) # 800032f8 <brelse>
}
    80004216:	60e2                	ld	ra,24(sp)
    80004218:	6442                	ld	s0,16(sp)
    8000421a:	64a2                	ld	s1,8(sp)
    8000421c:	6902                	ld	s2,0(sp)
    8000421e:	6105                	add	sp,sp,32
    80004220:	8082                	ret

0000000080004222 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004222:	0001d797          	auipc	a5,0x1d
    80004226:	0f27a783          	lw	a5,242(a5) # 80021314 <log+0x2c>
    8000422a:	0af05d63          	blez	a5,800042e4 <install_trans+0xc2>
{
    8000422e:	7139                	add	sp,sp,-64
    80004230:	fc06                	sd	ra,56(sp)
    80004232:	f822                	sd	s0,48(sp)
    80004234:	f426                	sd	s1,40(sp)
    80004236:	f04a                	sd	s2,32(sp)
    80004238:	ec4e                	sd	s3,24(sp)
    8000423a:	e852                	sd	s4,16(sp)
    8000423c:	e456                	sd	s5,8(sp)
    8000423e:	e05a                	sd	s6,0(sp)
    80004240:	0080                	add	s0,sp,64
    80004242:	8b2a                	mv	s6,a0
    80004244:	0001da97          	auipc	s5,0x1d
    80004248:	0d4a8a93          	add	s5,s5,212 # 80021318 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000424c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000424e:	0001d997          	auipc	s3,0x1d
    80004252:	09a98993          	add	s3,s3,154 # 800212e8 <log>
    80004256:	a00d                	j	80004278 <install_trans+0x56>
    brelse(lbuf);
    80004258:	854a                	mv	a0,s2
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	09e080e7          	jalr	158(ra) # 800032f8 <brelse>
    brelse(dbuf);
    80004262:	8526                	mv	a0,s1
    80004264:	fffff097          	auipc	ra,0xfffff
    80004268:	094080e7          	jalr	148(ra) # 800032f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000426c:	2a05                	addw	s4,s4,1
    8000426e:	0a91                	add	s5,s5,4
    80004270:	02c9a783          	lw	a5,44(s3)
    80004274:	04fa5e63          	bge	s4,a5,800042d0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004278:	0189a583          	lw	a1,24(s3)
    8000427c:	014585bb          	addw	a1,a1,s4
    80004280:	2585                	addw	a1,a1,1
    80004282:	0289a503          	lw	a0,40(s3)
    80004286:	fffff097          	auipc	ra,0xfffff
    8000428a:	f42080e7          	jalr	-190(ra) # 800031c8 <bread>
    8000428e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004290:	000aa583          	lw	a1,0(s5)
    80004294:	0289a503          	lw	a0,40(s3)
    80004298:	fffff097          	auipc	ra,0xfffff
    8000429c:	f30080e7          	jalr	-208(ra) # 800031c8 <bread>
    800042a0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042a2:	40000613          	li	a2,1024
    800042a6:	05890593          	add	a1,s2,88
    800042aa:	05850513          	add	a0,a0,88
    800042ae:	ffffd097          	auipc	ra,0xffffd
    800042b2:	a7c080e7          	jalr	-1412(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    800042b6:	8526                	mv	a0,s1
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	002080e7          	jalr	2(ra) # 800032ba <bwrite>
    if(recovering == 0)
    800042c0:	f80b1ce3          	bnez	s6,80004258 <install_trans+0x36>
      bunpin(dbuf);
    800042c4:	8526                	mv	a0,s1
    800042c6:	fffff097          	auipc	ra,0xfffff
    800042ca:	10a080e7          	jalr	266(ra) # 800033d0 <bunpin>
    800042ce:	b769                	j	80004258 <install_trans+0x36>
}
    800042d0:	70e2                	ld	ra,56(sp)
    800042d2:	7442                	ld	s0,48(sp)
    800042d4:	74a2                	ld	s1,40(sp)
    800042d6:	7902                	ld	s2,32(sp)
    800042d8:	69e2                	ld	s3,24(sp)
    800042da:	6a42                	ld	s4,16(sp)
    800042dc:	6aa2                	ld	s5,8(sp)
    800042de:	6b02                	ld	s6,0(sp)
    800042e0:	6121                	add	sp,sp,64
    800042e2:	8082                	ret
    800042e4:	8082                	ret

00000000800042e6 <initlog>:
{
    800042e6:	7179                	add	sp,sp,-48
    800042e8:	f406                	sd	ra,40(sp)
    800042ea:	f022                	sd	s0,32(sp)
    800042ec:	ec26                	sd	s1,24(sp)
    800042ee:	e84a                	sd	s2,16(sp)
    800042f0:	e44e                	sd	s3,8(sp)
    800042f2:	1800                	add	s0,sp,48
    800042f4:	892a                	mv	s2,a0
    800042f6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042f8:	0001d497          	auipc	s1,0x1d
    800042fc:	ff048493          	add	s1,s1,-16 # 800212e8 <log>
    80004300:	00004597          	auipc	a1,0x4
    80004304:	4b058593          	add	a1,a1,1200 # 800087b0 <syscalls+0x1e0>
    80004308:	8526                	mv	a0,s1
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	838080e7          	jalr	-1992(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004312:	0149a583          	lw	a1,20(s3)
    80004316:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004318:	0109a783          	lw	a5,16(s3)
    8000431c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000431e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004322:	854a                	mv	a0,s2
    80004324:	fffff097          	auipc	ra,0xfffff
    80004328:	ea4080e7          	jalr	-348(ra) # 800031c8 <bread>
  log.lh.n = lh->n;
    8000432c:	4d30                	lw	a2,88(a0)
    8000432e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004330:	00c05f63          	blez	a2,8000434e <initlog+0x68>
    80004334:	87aa                	mv	a5,a0
    80004336:	0001d717          	auipc	a4,0x1d
    8000433a:	fe270713          	add	a4,a4,-30 # 80021318 <log+0x30>
    8000433e:	060a                	sll	a2,a2,0x2
    80004340:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004342:	4ff4                	lw	a3,92(a5)
    80004344:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004346:	0791                	add	a5,a5,4
    80004348:	0711                	add	a4,a4,4
    8000434a:	fec79ce3          	bne	a5,a2,80004342 <initlog+0x5c>
  brelse(buf);
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	faa080e7          	jalr	-86(ra) # 800032f8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004356:	4505                	li	a0,1
    80004358:	00000097          	auipc	ra,0x0
    8000435c:	eca080e7          	jalr	-310(ra) # 80004222 <install_trans>
  log.lh.n = 0;
    80004360:	0001d797          	auipc	a5,0x1d
    80004364:	fa07aa23          	sw	zero,-76(a5) # 80021314 <log+0x2c>
  write_head(); // clear the log
    80004368:	00000097          	auipc	ra,0x0
    8000436c:	e50080e7          	jalr	-432(ra) # 800041b8 <write_head>
}
    80004370:	70a2                	ld	ra,40(sp)
    80004372:	7402                	ld	s0,32(sp)
    80004374:	64e2                	ld	s1,24(sp)
    80004376:	6942                	ld	s2,16(sp)
    80004378:	69a2                	ld	s3,8(sp)
    8000437a:	6145                	add	sp,sp,48
    8000437c:	8082                	ret

000000008000437e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000437e:	1101                	add	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	e04a                	sd	s2,0(sp)
    80004388:	1000                	add	s0,sp,32
  acquire(&log.lock);
    8000438a:	0001d517          	auipc	a0,0x1d
    8000438e:	f5e50513          	add	a0,a0,-162 # 800212e8 <log>
    80004392:	ffffd097          	auipc	ra,0xffffd
    80004396:	840080e7          	jalr	-1984(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000439a:	0001d497          	auipc	s1,0x1d
    8000439e:	f4e48493          	add	s1,s1,-178 # 800212e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043a2:	4979                	li	s2,30
    800043a4:	a039                	j	800043b2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043a6:	85a6                	mv	a1,s1
    800043a8:	8526                	mv	a0,s1
    800043aa:	ffffe097          	auipc	ra,0xffffe
    800043ae:	ca4080e7          	jalr	-860(ra) # 8000204e <sleep>
    if(log.committing){
    800043b2:	50dc                	lw	a5,36(s1)
    800043b4:	fbed                	bnez	a5,800043a6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043b6:	5098                	lw	a4,32(s1)
    800043b8:	2705                	addw	a4,a4,1
    800043ba:	0027179b          	sllw	a5,a4,0x2
    800043be:	9fb9                	addw	a5,a5,a4
    800043c0:	0017979b          	sllw	a5,a5,0x1
    800043c4:	54d4                	lw	a3,44(s1)
    800043c6:	9fb5                	addw	a5,a5,a3
    800043c8:	00f95963          	bge	s2,a5,800043da <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043cc:	85a6                	mv	a1,s1
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffe097          	auipc	ra,0xffffe
    800043d4:	c7e080e7          	jalr	-898(ra) # 8000204e <sleep>
    800043d8:	bfe9                	j	800043b2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043da:	0001d517          	auipc	a0,0x1d
    800043de:	f0e50513          	add	a0,a0,-242 # 800212e8 <log>
    800043e2:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800043e4:	ffffd097          	auipc	ra,0xffffd
    800043e8:	8a2080e7          	jalr	-1886(ra) # 80000c86 <release>
      break;
    }
  }
}
    800043ec:	60e2                	ld	ra,24(sp)
    800043ee:	6442                	ld	s0,16(sp)
    800043f0:	64a2                	ld	s1,8(sp)
    800043f2:	6902                	ld	s2,0(sp)
    800043f4:	6105                	add	sp,sp,32
    800043f6:	8082                	ret

00000000800043f8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043f8:	7139                	add	sp,sp,-64
    800043fa:	fc06                	sd	ra,56(sp)
    800043fc:	f822                	sd	s0,48(sp)
    800043fe:	f426                	sd	s1,40(sp)
    80004400:	f04a                	sd	s2,32(sp)
    80004402:	ec4e                	sd	s3,24(sp)
    80004404:	e852                	sd	s4,16(sp)
    80004406:	e456                	sd	s5,8(sp)
    80004408:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000440a:	0001d497          	auipc	s1,0x1d
    8000440e:	ede48493          	add	s1,s1,-290 # 800212e8 <log>
    80004412:	8526                	mv	a0,s1
    80004414:	ffffc097          	auipc	ra,0xffffc
    80004418:	7be080e7          	jalr	1982(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    8000441c:	509c                	lw	a5,32(s1)
    8000441e:	37fd                	addw	a5,a5,-1
    80004420:	0007891b          	sext.w	s2,a5
    80004424:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004426:	50dc                	lw	a5,36(s1)
    80004428:	e7b9                	bnez	a5,80004476 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000442a:	04091e63          	bnez	s2,80004486 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000442e:	0001d497          	auipc	s1,0x1d
    80004432:	eba48493          	add	s1,s1,-326 # 800212e8 <log>
    80004436:	4785                	li	a5,1
    80004438:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000443a:	8526                	mv	a0,s1
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	84a080e7          	jalr	-1974(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004444:	54dc                	lw	a5,44(s1)
    80004446:	06f04763          	bgtz	a5,800044b4 <end_op+0xbc>
    acquire(&log.lock);
    8000444a:	0001d497          	auipc	s1,0x1d
    8000444e:	e9e48493          	add	s1,s1,-354 # 800212e8 <log>
    80004452:	8526                	mv	a0,s1
    80004454:	ffffc097          	auipc	ra,0xffffc
    80004458:	77e080e7          	jalr	1918(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000445c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004460:	8526                	mv	a0,s1
    80004462:	ffffe097          	auipc	ra,0xffffe
    80004466:	c50080e7          	jalr	-944(ra) # 800020b2 <wakeup>
    release(&log.lock);
    8000446a:	8526                	mv	a0,s1
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	81a080e7          	jalr	-2022(ra) # 80000c86 <release>
}
    80004474:	a03d                	j	800044a2 <end_op+0xaa>
    panic("log.committing");
    80004476:	00004517          	auipc	a0,0x4
    8000447a:	34250513          	add	a0,a0,834 # 800087b8 <syscalls+0x1e8>
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	0be080e7          	jalr	190(ra) # 8000053c <panic>
    wakeup(&log);
    80004486:	0001d497          	auipc	s1,0x1d
    8000448a:	e6248493          	add	s1,s1,-414 # 800212e8 <log>
    8000448e:	8526                	mv	a0,s1
    80004490:	ffffe097          	auipc	ra,0xffffe
    80004494:	c22080e7          	jalr	-990(ra) # 800020b2 <wakeup>
  release(&log.lock);
    80004498:	8526                	mv	a0,s1
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	7ec080e7          	jalr	2028(ra) # 80000c86 <release>
}
    800044a2:	70e2                	ld	ra,56(sp)
    800044a4:	7442                	ld	s0,48(sp)
    800044a6:	74a2                	ld	s1,40(sp)
    800044a8:	7902                	ld	s2,32(sp)
    800044aa:	69e2                	ld	s3,24(sp)
    800044ac:	6a42                	ld	s4,16(sp)
    800044ae:	6aa2                	ld	s5,8(sp)
    800044b0:	6121                	add	sp,sp,64
    800044b2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800044b4:	0001da97          	auipc	s5,0x1d
    800044b8:	e64a8a93          	add	s5,s5,-412 # 80021318 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044bc:	0001da17          	auipc	s4,0x1d
    800044c0:	e2ca0a13          	add	s4,s4,-468 # 800212e8 <log>
    800044c4:	018a2583          	lw	a1,24(s4)
    800044c8:	012585bb          	addw	a1,a1,s2
    800044cc:	2585                	addw	a1,a1,1
    800044ce:	028a2503          	lw	a0,40(s4)
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	cf6080e7          	jalr	-778(ra) # 800031c8 <bread>
    800044da:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044dc:	000aa583          	lw	a1,0(s5)
    800044e0:	028a2503          	lw	a0,40(s4)
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	ce4080e7          	jalr	-796(ra) # 800031c8 <bread>
    800044ec:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044ee:	40000613          	li	a2,1024
    800044f2:	05850593          	add	a1,a0,88
    800044f6:	05848513          	add	a0,s1,88
    800044fa:	ffffd097          	auipc	ra,0xffffd
    800044fe:	830080e7          	jalr	-2000(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004502:	8526                	mv	a0,s1
    80004504:	fffff097          	auipc	ra,0xfffff
    80004508:	db6080e7          	jalr	-586(ra) # 800032ba <bwrite>
    brelse(from);
    8000450c:	854e                	mv	a0,s3
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	dea080e7          	jalr	-534(ra) # 800032f8 <brelse>
    brelse(to);
    80004516:	8526                	mv	a0,s1
    80004518:	fffff097          	auipc	ra,0xfffff
    8000451c:	de0080e7          	jalr	-544(ra) # 800032f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004520:	2905                	addw	s2,s2,1
    80004522:	0a91                	add	s5,s5,4
    80004524:	02ca2783          	lw	a5,44(s4)
    80004528:	f8f94ee3          	blt	s2,a5,800044c4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000452c:	00000097          	auipc	ra,0x0
    80004530:	c8c080e7          	jalr	-884(ra) # 800041b8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004534:	4501                	li	a0,0
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	cec080e7          	jalr	-788(ra) # 80004222 <install_trans>
    log.lh.n = 0;
    8000453e:	0001d797          	auipc	a5,0x1d
    80004542:	dc07ab23          	sw	zero,-554(a5) # 80021314 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	c72080e7          	jalr	-910(ra) # 800041b8 <write_head>
    8000454e:	bdf5                	j	8000444a <end_op+0x52>

0000000080004550 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004550:	1101                	add	sp,sp,-32
    80004552:	ec06                	sd	ra,24(sp)
    80004554:	e822                	sd	s0,16(sp)
    80004556:	e426                	sd	s1,8(sp)
    80004558:	e04a                	sd	s2,0(sp)
    8000455a:	1000                	add	s0,sp,32
    8000455c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000455e:	0001d917          	auipc	s2,0x1d
    80004562:	d8a90913          	add	s2,s2,-630 # 800212e8 <log>
    80004566:	854a                	mv	a0,s2
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	66a080e7          	jalr	1642(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004570:	02c92603          	lw	a2,44(s2)
    80004574:	47f5                	li	a5,29
    80004576:	06c7c563          	blt	a5,a2,800045e0 <log_write+0x90>
    8000457a:	0001d797          	auipc	a5,0x1d
    8000457e:	d8a7a783          	lw	a5,-630(a5) # 80021304 <log+0x1c>
    80004582:	37fd                	addw	a5,a5,-1
    80004584:	04f65e63          	bge	a2,a5,800045e0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004588:	0001d797          	auipc	a5,0x1d
    8000458c:	d807a783          	lw	a5,-640(a5) # 80021308 <log+0x20>
    80004590:	06f05063          	blez	a5,800045f0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004594:	4781                	li	a5,0
    80004596:	06c05563          	blez	a2,80004600 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000459a:	44cc                	lw	a1,12(s1)
    8000459c:	0001d717          	auipc	a4,0x1d
    800045a0:	d7c70713          	add	a4,a4,-644 # 80021318 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045a4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045a6:	4314                	lw	a3,0(a4)
    800045a8:	04b68c63          	beq	a3,a1,80004600 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045ac:	2785                	addw	a5,a5,1
    800045ae:	0711                	add	a4,a4,4
    800045b0:	fef61be3          	bne	a2,a5,800045a6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045b4:	0621                	add	a2,a2,8
    800045b6:	060a                	sll	a2,a2,0x2
    800045b8:	0001d797          	auipc	a5,0x1d
    800045bc:	d3078793          	add	a5,a5,-720 # 800212e8 <log>
    800045c0:	97b2                	add	a5,a5,a2
    800045c2:	44d8                	lw	a4,12(s1)
    800045c4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045c6:	8526                	mv	a0,s1
    800045c8:	fffff097          	auipc	ra,0xfffff
    800045cc:	dcc080e7          	jalr	-564(ra) # 80003394 <bpin>
    log.lh.n++;
    800045d0:	0001d717          	auipc	a4,0x1d
    800045d4:	d1870713          	add	a4,a4,-744 # 800212e8 <log>
    800045d8:	575c                	lw	a5,44(a4)
    800045da:	2785                	addw	a5,a5,1
    800045dc:	d75c                	sw	a5,44(a4)
    800045de:	a82d                	j	80004618 <log_write+0xc8>
    panic("too big a transaction");
    800045e0:	00004517          	auipc	a0,0x4
    800045e4:	1e850513          	add	a0,a0,488 # 800087c8 <syscalls+0x1f8>
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	f54080e7          	jalr	-172(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800045f0:	00004517          	auipc	a0,0x4
    800045f4:	1f050513          	add	a0,a0,496 # 800087e0 <syscalls+0x210>
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	f44080e7          	jalr	-188(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004600:	00878693          	add	a3,a5,8
    80004604:	068a                	sll	a3,a3,0x2
    80004606:	0001d717          	auipc	a4,0x1d
    8000460a:	ce270713          	add	a4,a4,-798 # 800212e8 <log>
    8000460e:	9736                	add	a4,a4,a3
    80004610:	44d4                	lw	a3,12(s1)
    80004612:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004614:	faf609e3          	beq	a2,a5,800045c6 <log_write+0x76>
  }
  release(&log.lock);
    80004618:	0001d517          	auipc	a0,0x1d
    8000461c:	cd050513          	add	a0,a0,-816 # 800212e8 <log>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	666080e7          	jalr	1638(ra) # 80000c86 <release>
}
    80004628:	60e2                	ld	ra,24(sp)
    8000462a:	6442                	ld	s0,16(sp)
    8000462c:	64a2                	ld	s1,8(sp)
    8000462e:	6902                	ld	s2,0(sp)
    80004630:	6105                	add	sp,sp,32
    80004632:	8082                	ret

0000000080004634 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004634:	1101                	add	sp,sp,-32
    80004636:	ec06                	sd	ra,24(sp)
    80004638:	e822                	sd	s0,16(sp)
    8000463a:	e426                	sd	s1,8(sp)
    8000463c:	e04a                	sd	s2,0(sp)
    8000463e:	1000                	add	s0,sp,32
    80004640:	84aa                	mv	s1,a0
    80004642:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004644:	00004597          	auipc	a1,0x4
    80004648:	1bc58593          	add	a1,a1,444 # 80008800 <syscalls+0x230>
    8000464c:	0521                	add	a0,a0,8
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	4f4080e7          	jalr	1268(ra) # 80000b42 <initlock>
  lk->name = name;
    80004656:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000465a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000465e:	0204a423          	sw	zero,40(s1)
}
    80004662:	60e2                	ld	ra,24(sp)
    80004664:	6442                	ld	s0,16(sp)
    80004666:	64a2                	ld	s1,8(sp)
    80004668:	6902                	ld	s2,0(sp)
    8000466a:	6105                	add	sp,sp,32
    8000466c:	8082                	ret

000000008000466e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000466e:	1101                	add	sp,sp,-32
    80004670:	ec06                	sd	ra,24(sp)
    80004672:	e822                	sd	s0,16(sp)
    80004674:	e426                	sd	s1,8(sp)
    80004676:	e04a                	sd	s2,0(sp)
    80004678:	1000                	add	s0,sp,32
    8000467a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000467c:	00850913          	add	s2,a0,8
    80004680:	854a                	mv	a0,s2
    80004682:	ffffc097          	auipc	ra,0xffffc
    80004686:	550080e7          	jalr	1360(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000468a:	409c                	lw	a5,0(s1)
    8000468c:	cb89                	beqz	a5,8000469e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000468e:	85ca                	mv	a1,s2
    80004690:	8526                	mv	a0,s1
    80004692:	ffffe097          	auipc	ra,0xffffe
    80004696:	9bc080e7          	jalr	-1604(ra) # 8000204e <sleep>
  while (lk->locked) {
    8000469a:	409c                	lw	a5,0(s1)
    8000469c:	fbed                	bnez	a5,8000468e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000469e:	4785                	li	a5,1
    800046a0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046a2:	ffffd097          	auipc	ra,0xffffd
    800046a6:	304080e7          	jalr	772(ra) # 800019a6 <myproc>
    800046aa:	591c                	lw	a5,48(a0)
    800046ac:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046ae:	854a                	mv	a0,s2
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	5d6080e7          	jalr	1494(ra) # 80000c86 <release>
}
    800046b8:	60e2                	ld	ra,24(sp)
    800046ba:	6442                	ld	s0,16(sp)
    800046bc:	64a2                	ld	s1,8(sp)
    800046be:	6902                	ld	s2,0(sp)
    800046c0:	6105                	add	sp,sp,32
    800046c2:	8082                	ret

00000000800046c4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046c4:	1101                	add	sp,sp,-32
    800046c6:	ec06                	sd	ra,24(sp)
    800046c8:	e822                	sd	s0,16(sp)
    800046ca:	e426                	sd	s1,8(sp)
    800046cc:	e04a                	sd	s2,0(sp)
    800046ce:	1000                	add	s0,sp,32
    800046d0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046d2:	00850913          	add	s2,a0,8
    800046d6:	854a                	mv	a0,s2
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	4fa080e7          	jalr	1274(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800046e0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046e4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046e8:	8526                	mv	a0,s1
    800046ea:	ffffe097          	auipc	ra,0xffffe
    800046ee:	9c8080e7          	jalr	-1592(ra) # 800020b2 <wakeup>
  release(&lk->lk);
    800046f2:	854a                	mv	a0,s2
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	592080e7          	jalr	1426(ra) # 80000c86 <release>
}
    800046fc:	60e2                	ld	ra,24(sp)
    800046fe:	6442                	ld	s0,16(sp)
    80004700:	64a2                	ld	s1,8(sp)
    80004702:	6902                	ld	s2,0(sp)
    80004704:	6105                	add	sp,sp,32
    80004706:	8082                	ret

0000000080004708 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004708:	7179                	add	sp,sp,-48
    8000470a:	f406                	sd	ra,40(sp)
    8000470c:	f022                	sd	s0,32(sp)
    8000470e:	ec26                	sd	s1,24(sp)
    80004710:	e84a                	sd	s2,16(sp)
    80004712:	e44e                	sd	s3,8(sp)
    80004714:	1800                	add	s0,sp,48
    80004716:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004718:	00850913          	add	s2,a0,8
    8000471c:	854a                	mv	a0,s2
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	4b4080e7          	jalr	1204(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004726:	409c                	lw	a5,0(s1)
    80004728:	ef99                	bnez	a5,80004746 <holdingsleep+0x3e>
    8000472a:	4481                	li	s1,0
  release(&lk->lk);
    8000472c:	854a                	mv	a0,s2
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	558080e7          	jalr	1368(ra) # 80000c86 <release>
  return r;
}
    80004736:	8526                	mv	a0,s1
    80004738:	70a2                	ld	ra,40(sp)
    8000473a:	7402                	ld	s0,32(sp)
    8000473c:	64e2                	ld	s1,24(sp)
    8000473e:	6942                	ld	s2,16(sp)
    80004740:	69a2                	ld	s3,8(sp)
    80004742:	6145                	add	sp,sp,48
    80004744:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004746:	0284a983          	lw	s3,40(s1)
    8000474a:	ffffd097          	auipc	ra,0xffffd
    8000474e:	25c080e7          	jalr	604(ra) # 800019a6 <myproc>
    80004752:	5904                	lw	s1,48(a0)
    80004754:	413484b3          	sub	s1,s1,s3
    80004758:	0014b493          	seqz	s1,s1
    8000475c:	bfc1                	j	8000472c <holdingsleep+0x24>

000000008000475e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000475e:	1141                	add	sp,sp,-16
    80004760:	e406                	sd	ra,8(sp)
    80004762:	e022                	sd	s0,0(sp)
    80004764:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004766:	00004597          	auipc	a1,0x4
    8000476a:	0aa58593          	add	a1,a1,170 # 80008810 <syscalls+0x240>
    8000476e:	0001d517          	auipc	a0,0x1d
    80004772:	cc250513          	add	a0,a0,-830 # 80021430 <ftable>
    80004776:	ffffc097          	auipc	ra,0xffffc
    8000477a:	3cc080e7          	jalr	972(ra) # 80000b42 <initlock>
}
    8000477e:	60a2                	ld	ra,8(sp)
    80004780:	6402                	ld	s0,0(sp)
    80004782:	0141                	add	sp,sp,16
    80004784:	8082                	ret

0000000080004786 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004786:	1101                	add	sp,sp,-32
    80004788:	ec06                	sd	ra,24(sp)
    8000478a:	e822                	sd	s0,16(sp)
    8000478c:	e426                	sd	s1,8(sp)
    8000478e:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004790:	0001d517          	auipc	a0,0x1d
    80004794:	ca050513          	add	a0,a0,-864 # 80021430 <ftable>
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	43a080e7          	jalr	1082(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047a0:	0001d497          	auipc	s1,0x1d
    800047a4:	ca848493          	add	s1,s1,-856 # 80021448 <ftable+0x18>
    800047a8:	0001e717          	auipc	a4,0x1e
    800047ac:	c4070713          	add	a4,a4,-960 # 800223e8 <disk>
    if(f->ref == 0){
    800047b0:	40dc                	lw	a5,4(s1)
    800047b2:	cf99                	beqz	a5,800047d0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047b4:	02848493          	add	s1,s1,40
    800047b8:	fee49ce3          	bne	s1,a4,800047b0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047bc:	0001d517          	auipc	a0,0x1d
    800047c0:	c7450513          	add	a0,a0,-908 # 80021430 <ftable>
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	4c2080e7          	jalr	1218(ra) # 80000c86 <release>
  return 0;
    800047cc:	4481                	li	s1,0
    800047ce:	a819                	j	800047e4 <filealloc+0x5e>
      f->ref = 1;
    800047d0:	4785                	li	a5,1
    800047d2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047d4:	0001d517          	auipc	a0,0x1d
    800047d8:	c5c50513          	add	a0,a0,-932 # 80021430 <ftable>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	4aa080e7          	jalr	1194(ra) # 80000c86 <release>
}
    800047e4:	8526                	mv	a0,s1
    800047e6:	60e2                	ld	ra,24(sp)
    800047e8:	6442                	ld	s0,16(sp)
    800047ea:	64a2                	ld	s1,8(sp)
    800047ec:	6105                	add	sp,sp,32
    800047ee:	8082                	ret

00000000800047f0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047f0:	1101                	add	sp,sp,-32
    800047f2:	ec06                	sd	ra,24(sp)
    800047f4:	e822                	sd	s0,16(sp)
    800047f6:	e426                	sd	s1,8(sp)
    800047f8:	1000                	add	s0,sp,32
    800047fa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047fc:	0001d517          	auipc	a0,0x1d
    80004800:	c3450513          	add	a0,a0,-972 # 80021430 <ftable>
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	3ce080e7          	jalr	974(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000480c:	40dc                	lw	a5,4(s1)
    8000480e:	02f05263          	blez	a5,80004832 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004812:	2785                	addw	a5,a5,1
    80004814:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004816:	0001d517          	auipc	a0,0x1d
    8000481a:	c1a50513          	add	a0,a0,-998 # 80021430 <ftable>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	468080e7          	jalr	1128(ra) # 80000c86 <release>
  return f;
}
    80004826:	8526                	mv	a0,s1
    80004828:	60e2                	ld	ra,24(sp)
    8000482a:	6442                	ld	s0,16(sp)
    8000482c:	64a2                	ld	s1,8(sp)
    8000482e:	6105                	add	sp,sp,32
    80004830:	8082                	ret
    panic("filedup");
    80004832:	00004517          	auipc	a0,0x4
    80004836:	fe650513          	add	a0,a0,-26 # 80008818 <syscalls+0x248>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	d02080e7          	jalr	-766(ra) # 8000053c <panic>

0000000080004842 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004842:	7139                	add	sp,sp,-64
    80004844:	fc06                	sd	ra,56(sp)
    80004846:	f822                	sd	s0,48(sp)
    80004848:	f426                	sd	s1,40(sp)
    8000484a:	f04a                	sd	s2,32(sp)
    8000484c:	ec4e                	sd	s3,24(sp)
    8000484e:	e852                	sd	s4,16(sp)
    80004850:	e456                	sd	s5,8(sp)
    80004852:	0080                	add	s0,sp,64
    80004854:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004856:	0001d517          	auipc	a0,0x1d
    8000485a:	bda50513          	add	a0,a0,-1062 # 80021430 <ftable>
    8000485e:	ffffc097          	auipc	ra,0xffffc
    80004862:	374080e7          	jalr	884(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004866:	40dc                	lw	a5,4(s1)
    80004868:	06f05163          	blez	a5,800048ca <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000486c:	37fd                	addw	a5,a5,-1
    8000486e:	0007871b          	sext.w	a4,a5
    80004872:	c0dc                	sw	a5,4(s1)
    80004874:	06e04363          	bgtz	a4,800048da <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004878:	0004a903          	lw	s2,0(s1)
    8000487c:	0094ca83          	lbu	s5,9(s1)
    80004880:	0104ba03          	ld	s4,16(s1)
    80004884:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004888:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000488c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004890:	0001d517          	auipc	a0,0x1d
    80004894:	ba050513          	add	a0,a0,-1120 # 80021430 <ftable>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	3ee080e7          	jalr	1006(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    800048a0:	4785                	li	a5,1
    800048a2:	04f90d63          	beq	s2,a5,800048fc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048a6:	3979                	addw	s2,s2,-2
    800048a8:	4785                	li	a5,1
    800048aa:	0527e063          	bltu	a5,s2,800048ea <fileclose+0xa8>
    begin_op();
    800048ae:	00000097          	auipc	ra,0x0
    800048b2:	ad0080e7          	jalr	-1328(ra) # 8000437e <begin_op>
    iput(ff.ip);
    800048b6:	854e                	mv	a0,s3
    800048b8:	fffff097          	auipc	ra,0xfffff
    800048bc:	2da080e7          	jalr	730(ra) # 80003b92 <iput>
    end_op();
    800048c0:	00000097          	auipc	ra,0x0
    800048c4:	b38080e7          	jalr	-1224(ra) # 800043f8 <end_op>
    800048c8:	a00d                	j	800048ea <fileclose+0xa8>
    panic("fileclose");
    800048ca:	00004517          	auipc	a0,0x4
    800048ce:	f5650513          	add	a0,a0,-170 # 80008820 <syscalls+0x250>
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	c6a080e7          	jalr	-918(ra) # 8000053c <panic>
    release(&ftable.lock);
    800048da:	0001d517          	auipc	a0,0x1d
    800048de:	b5650513          	add	a0,a0,-1194 # 80021430 <ftable>
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	3a4080e7          	jalr	932(ra) # 80000c86 <release>
  }
}
    800048ea:	70e2                	ld	ra,56(sp)
    800048ec:	7442                	ld	s0,48(sp)
    800048ee:	74a2                	ld	s1,40(sp)
    800048f0:	7902                	ld	s2,32(sp)
    800048f2:	69e2                	ld	s3,24(sp)
    800048f4:	6a42                	ld	s4,16(sp)
    800048f6:	6aa2                	ld	s5,8(sp)
    800048f8:	6121                	add	sp,sp,64
    800048fa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048fc:	85d6                	mv	a1,s5
    800048fe:	8552                	mv	a0,s4
    80004900:	00000097          	auipc	ra,0x0
    80004904:	348080e7          	jalr	840(ra) # 80004c48 <pipeclose>
    80004908:	b7cd                	j	800048ea <fileclose+0xa8>

000000008000490a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000490a:	715d                	add	sp,sp,-80
    8000490c:	e486                	sd	ra,72(sp)
    8000490e:	e0a2                	sd	s0,64(sp)
    80004910:	fc26                	sd	s1,56(sp)
    80004912:	f84a                	sd	s2,48(sp)
    80004914:	f44e                	sd	s3,40(sp)
    80004916:	0880                	add	s0,sp,80
    80004918:	84aa                	mv	s1,a0
    8000491a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000491c:	ffffd097          	auipc	ra,0xffffd
    80004920:	08a080e7          	jalr	138(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004924:	409c                	lw	a5,0(s1)
    80004926:	37f9                	addw	a5,a5,-2
    80004928:	4705                	li	a4,1
    8000492a:	04f76763          	bltu	a4,a5,80004978 <filestat+0x6e>
    8000492e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004930:	6c88                	ld	a0,24(s1)
    80004932:	fffff097          	auipc	ra,0xfffff
    80004936:	0a6080e7          	jalr	166(ra) # 800039d8 <ilock>
    stati(f->ip, &st);
    8000493a:	fb840593          	add	a1,s0,-72
    8000493e:	6c88                	ld	a0,24(s1)
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	322080e7          	jalr	802(ra) # 80003c62 <stati>
    iunlock(f->ip);
    80004948:	6c88                	ld	a0,24(s1)
    8000494a:	fffff097          	auipc	ra,0xfffff
    8000494e:	150080e7          	jalr	336(ra) # 80003a9a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004952:	46e1                	li	a3,24
    80004954:	fb840613          	add	a2,s0,-72
    80004958:	85ce                	mv	a1,s3
    8000495a:	05093503          	ld	a0,80(s2)
    8000495e:	ffffd097          	auipc	ra,0xffffd
    80004962:	d08080e7          	jalr	-760(ra) # 80001666 <copyout>
    80004966:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000496a:	60a6                	ld	ra,72(sp)
    8000496c:	6406                	ld	s0,64(sp)
    8000496e:	74e2                	ld	s1,56(sp)
    80004970:	7942                	ld	s2,48(sp)
    80004972:	79a2                	ld	s3,40(sp)
    80004974:	6161                	add	sp,sp,80
    80004976:	8082                	ret
  return -1;
    80004978:	557d                	li	a0,-1
    8000497a:	bfc5                	j	8000496a <filestat+0x60>

000000008000497c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000497c:	7179                	add	sp,sp,-48
    8000497e:	f406                	sd	ra,40(sp)
    80004980:	f022                	sd	s0,32(sp)
    80004982:	ec26                	sd	s1,24(sp)
    80004984:	e84a                	sd	s2,16(sp)
    80004986:	e44e                	sd	s3,8(sp)
    80004988:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000498a:	00854783          	lbu	a5,8(a0)
    8000498e:	c3d5                	beqz	a5,80004a32 <fileread+0xb6>
    80004990:	84aa                	mv	s1,a0
    80004992:	89ae                	mv	s3,a1
    80004994:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004996:	411c                	lw	a5,0(a0)
    80004998:	4705                	li	a4,1
    8000499a:	04e78963          	beq	a5,a4,800049ec <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000499e:	470d                	li	a4,3
    800049a0:	04e78d63          	beq	a5,a4,800049fa <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049a4:	4709                	li	a4,2
    800049a6:	06e79e63          	bne	a5,a4,80004a22 <fileread+0xa6>
    ilock(f->ip);
    800049aa:	6d08                	ld	a0,24(a0)
    800049ac:	fffff097          	auipc	ra,0xfffff
    800049b0:	02c080e7          	jalr	44(ra) # 800039d8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049b4:	874a                	mv	a4,s2
    800049b6:	5094                	lw	a3,32(s1)
    800049b8:	864e                	mv	a2,s3
    800049ba:	4585                	li	a1,1
    800049bc:	6c88                	ld	a0,24(s1)
    800049be:	fffff097          	auipc	ra,0xfffff
    800049c2:	2ce080e7          	jalr	718(ra) # 80003c8c <readi>
    800049c6:	892a                	mv	s2,a0
    800049c8:	00a05563          	blez	a0,800049d2 <fileread+0x56>
      f->off += r;
    800049cc:	509c                	lw	a5,32(s1)
    800049ce:	9fa9                	addw	a5,a5,a0
    800049d0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049d2:	6c88                	ld	a0,24(s1)
    800049d4:	fffff097          	auipc	ra,0xfffff
    800049d8:	0c6080e7          	jalr	198(ra) # 80003a9a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049dc:	854a                	mv	a0,s2
    800049de:	70a2                	ld	ra,40(sp)
    800049e0:	7402                	ld	s0,32(sp)
    800049e2:	64e2                	ld	s1,24(sp)
    800049e4:	6942                	ld	s2,16(sp)
    800049e6:	69a2                	ld	s3,8(sp)
    800049e8:	6145                	add	sp,sp,48
    800049ea:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049ec:	6908                	ld	a0,16(a0)
    800049ee:	00000097          	auipc	ra,0x0
    800049f2:	3c2080e7          	jalr	962(ra) # 80004db0 <piperead>
    800049f6:	892a                	mv	s2,a0
    800049f8:	b7d5                	j	800049dc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049fa:	02451783          	lh	a5,36(a0)
    800049fe:	03079693          	sll	a3,a5,0x30
    80004a02:	92c1                	srl	a3,a3,0x30
    80004a04:	4725                	li	a4,9
    80004a06:	02d76863          	bltu	a4,a3,80004a36 <fileread+0xba>
    80004a0a:	0792                	sll	a5,a5,0x4
    80004a0c:	0001d717          	auipc	a4,0x1d
    80004a10:	98470713          	add	a4,a4,-1660 # 80021390 <devsw>
    80004a14:	97ba                	add	a5,a5,a4
    80004a16:	639c                	ld	a5,0(a5)
    80004a18:	c38d                	beqz	a5,80004a3a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a1a:	4505                	li	a0,1
    80004a1c:	9782                	jalr	a5
    80004a1e:	892a                	mv	s2,a0
    80004a20:	bf75                	j	800049dc <fileread+0x60>
    panic("fileread");
    80004a22:	00004517          	auipc	a0,0x4
    80004a26:	e0e50513          	add	a0,a0,-498 # 80008830 <syscalls+0x260>
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	b12080e7          	jalr	-1262(ra) # 8000053c <panic>
    return -1;
    80004a32:	597d                	li	s2,-1
    80004a34:	b765                	j	800049dc <fileread+0x60>
      return -1;
    80004a36:	597d                	li	s2,-1
    80004a38:	b755                	j	800049dc <fileread+0x60>
    80004a3a:	597d                	li	s2,-1
    80004a3c:	b745                	j	800049dc <fileread+0x60>

0000000080004a3e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a3e:	00954783          	lbu	a5,9(a0)
    80004a42:	10078e63          	beqz	a5,80004b5e <filewrite+0x120>
{
    80004a46:	715d                	add	sp,sp,-80
    80004a48:	e486                	sd	ra,72(sp)
    80004a4a:	e0a2                	sd	s0,64(sp)
    80004a4c:	fc26                	sd	s1,56(sp)
    80004a4e:	f84a                	sd	s2,48(sp)
    80004a50:	f44e                	sd	s3,40(sp)
    80004a52:	f052                	sd	s4,32(sp)
    80004a54:	ec56                	sd	s5,24(sp)
    80004a56:	e85a                	sd	s6,16(sp)
    80004a58:	e45e                	sd	s7,8(sp)
    80004a5a:	e062                	sd	s8,0(sp)
    80004a5c:	0880                	add	s0,sp,80
    80004a5e:	892a                	mv	s2,a0
    80004a60:	8b2e                	mv	s6,a1
    80004a62:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a64:	411c                	lw	a5,0(a0)
    80004a66:	4705                	li	a4,1
    80004a68:	02e78263          	beq	a5,a4,80004a8c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a6c:	470d                	li	a4,3
    80004a6e:	02e78563          	beq	a5,a4,80004a98 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a72:	4709                	li	a4,2
    80004a74:	0ce79d63          	bne	a5,a4,80004b4e <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a78:	0ac05b63          	blez	a2,80004b2e <filewrite+0xf0>
    int i = 0;
    80004a7c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004a7e:	6b85                	lui	s7,0x1
    80004a80:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a84:	6c05                	lui	s8,0x1
    80004a86:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004a8a:	a851                	j	80004b1e <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a8c:	6908                	ld	a0,16(a0)
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	22a080e7          	jalr	554(ra) # 80004cb8 <pipewrite>
    80004a96:	a045                	j	80004b36 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a98:	02451783          	lh	a5,36(a0)
    80004a9c:	03079693          	sll	a3,a5,0x30
    80004aa0:	92c1                	srl	a3,a3,0x30
    80004aa2:	4725                	li	a4,9
    80004aa4:	0ad76f63          	bltu	a4,a3,80004b62 <filewrite+0x124>
    80004aa8:	0792                	sll	a5,a5,0x4
    80004aaa:	0001d717          	auipc	a4,0x1d
    80004aae:	8e670713          	add	a4,a4,-1818 # 80021390 <devsw>
    80004ab2:	97ba                	add	a5,a5,a4
    80004ab4:	679c                	ld	a5,8(a5)
    80004ab6:	cbc5                	beqz	a5,80004b66 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004ab8:	4505                	li	a0,1
    80004aba:	9782                	jalr	a5
    80004abc:	a8ad                	j	80004b36 <filewrite+0xf8>
      if(n1 > max)
    80004abe:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	8bc080e7          	jalr	-1860(ra) # 8000437e <begin_op>
      ilock(f->ip);
    80004aca:	01893503          	ld	a0,24(s2)
    80004ace:	fffff097          	auipc	ra,0xfffff
    80004ad2:	f0a080e7          	jalr	-246(ra) # 800039d8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ad6:	8756                	mv	a4,s5
    80004ad8:	02092683          	lw	a3,32(s2)
    80004adc:	01698633          	add	a2,s3,s6
    80004ae0:	4585                	li	a1,1
    80004ae2:	01893503          	ld	a0,24(s2)
    80004ae6:	fffff097          	auipc	ra,0xfffff
    80004aea:	29e080e7          	jalr	670(ra) # 80003d84 <writei>
    80004aee:	84aa                	mv	s1,a0
    80004af0:	00a05763          	blez	a0,80004afe <filewrite+0xc0>
        f->off += r;
    80004af4:	02092783          	lw	a5,32(s2)
    80004af8:	9fa9                	addw	a5,a5,a0
    80004afa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004afe:	01893503          	ld	a0,24(s2)
    80004b02:	fffff097          	auipc	ra,0xfffff
    80004b06:	f98080e7          	jalr	-104(ra) # 80003a9a <iunlock>
      end_op();
    80004b0a:	00000097          	auipc	ra,0x0
    80004b0e:	8ee080e7          	jalr	-1810(ra) # 800043f8 <end_op>

      if(r != n1){
    80004b12:	009a9f63          	bne	s5,s1,80004b30 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004b16:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b1a:	0149db63          	bge	s3,s4,80004b30 <filewrite+0xf2>
      int n1 = n - i;
    80004b1e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004b22:	0004879b          	sext.w	a5,s1
    80004b26:	f8fbdce3          	bge	s7,a5,80004abe <filewrite+0x80>
    80004b2a:	84e2                	mv	s1,s8
    80004b2c:	bf49                	j	80004abe <filewrite+0x80>
    int i = 0;
    80004b2e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b30:	033a1d63          	bne	s4,s3,80004b6a <filewrite+0x12c>
    80004b34:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b36:	60a6                	ld	ra,72(sp)
    80004b38:	6406                	ld	s0,64(sp)
    80004b3a:	74e2                	ld	s1,56(sp)
    80004b3c:	7942                	ld	s2,48(sp)
    80004b3e:	79a2                	ld	s3,40(sp)
    80004b40:	7a02                	ld	s4,32(sp)
    80004b42:	6ae2                	ld	s5,24(sp)
    80004b44:	6b42                	ld	s6,16(sp)
    80004b46:	6ba2                	ld	s7,8(sp)
    80004b48:	6c02                	ld	s8,0(sp)
    80004b4a:	6161                	add	sp,sp,80
    80004b4c:	8082                	ret
    panic("filewrite");
    80004b4e:	00004517          	auipc	a0,0x4
    80004b52:	cf250513          	add	a0,a0,-782 # 80008840 <syscalls+0x270>
    80004b56:	ffffc097          	auipc	ra,0xffffc
    80004b5a:	9e6080e7          	jalr	-1562(ra) # 8000053c <panic>
    return -1;
    80004b5e:	557d                	li	a0,-1
}
    80004b60:	8082                	ret
      return -1;
    80004b62:	557d                	li	a0,-1
    80004b64:	bfc9                	j	80004b36 <filewrite+0xf8>
    80004b66:	557d                	li	a0,-1
    80004b68:	b7f9                	j	80004b36 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004b6a:	557d                	li	a0,-1
    80004b6c:	b7e9                	j	80004b36 <filewrite+0xf8>

0000000080004b6e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b6e:	7179                	add	sp,sp,-48
    80004b70:	f406                	sd	ra,40(sp)
    80004b72:	f022                	sd	s0,32(sp)
    80004b74:	ec26                	sd	s1,24(sp)
    80004b76:	e84a                	sd	s2,16(sp)
    80004b78:	e44e                	sd	s3,8(sp)
    80004b7a:	e052                	sd	s4,0(sp)
    80004b7c:	1800                	add	s0,sp,48
    80004b7e:	84aa                	mv	s1,a0
    80004b80:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b82:	0005b023          	sd	zero,0(a1)
    80004b86:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b8a:	00000097          	auipc	ra,0x0
    80004b8e:	bfc080e7          	jalr	-1028(ra) # 80004786 <filealloc>
    80004b92:	e088                	sd	a0,0(s1)
    80004b94:	c551                	beqz	a0,80004c20 <pipealloc+0xb2>
    80004b96:	00000097          	auipc	ra,0x0
    80004b9a:	bf0080e7          	jalr	-1040(ra) # 80004786 <filealloc>
    80004b9e:	00aa3023          	sd	a0,0(s4)
    80004ba2:	c92d                	beqz	a0,80004c14 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ba4:	ffffc097          	auipc	ra,0xffffc
    80004ba8:	f3e080e7          	jalr	-194(ra) # 80000ae2 <kalloc>
    80004bac:	892a                	mv	s2,a0
    80004bae:	c125                	beqz	a0,80004c0e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bb0:	4985                	li	s3,1
    80004bb2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bb6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004bba:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bbe:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bc2:	00004597          	auipc	a1,0x4
    80004bc6:	c8e58593          	add	a1,a1,-882 # 80008850 <syscalls+0x280>
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	f78080e7          	jalr	-136(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004bd2:	609c                	ld	a5,0(s1)
    80004bd4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bd8:	609c                	ld	a5,0(s1)
    80004bda:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bde:	609c                	ld	a5,0(s1)
    80004be0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004be4:	609c                	ld	a5,0(s1)
    80004be6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bea:	000a3783          	ld	a5,0(s4)
    80004bee:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bf2:	000a3783          	ld	a5,0(s4)
    80004bf6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bfa:	000a3783          	ld	a5,0(s4)
    80004bfe:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c02:	000a3783          	ld	a5,0(s4)
    80004c06:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c0a:	4501                	li	a0,0
    80004c0c:	a025                	j	80004c34 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c0e:	6088                	ld	a0,0(s1)
    80004c10:	e501                	bnez	a0,80004c18 <pipealloc+0xaa>
    80004c12:	a039                	j	80004c20 <pipealloc+0xb2>
    80004c14:	6088                	ld	a0,0(s1)
    80004c16:	c51d                	beqz	a0,80004c44 <pipealloc+0xd6>
    fileclose(*f0);
    80004c18:	00000097          	auipc	ra,0x0
    80004c1c:	c2a080e7          	jalr	-982(ra) # 80004842 <fileclose>
  if(*f1)
    80004c20:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c24:	557d                	li	a0,-1
  if(*f1)
    80004c26:	c799                	beqz	a5,80004c34 <pipealloc+0xc6>
    fileclose(*f1);
    80004c28:	853e                	mv	a0,a5
    80004c2a:	00000097          	auipc	ra,0x0
    80004c2e:	c18080e7          	jalr	-1000(ra) # 80004842 <fileclose>
  return -1;
    80004c32:	557d                	li	a0,-1
}
    80004c34:	70a2                	ld	ra,40(sp)
    80004c36:	7402                	ld	s0,32(sp)
    80004c38:	64e2                	ld	s1,24(sp)
    80004c3a:	6942                	ld	s2,16(sp)
    80004c3c:	69a2                	ld	s3,8(sp)
    80004c3e:	6a02                	ld	s4,0(sp)
    80004c40:	6145                	add	sp,sp,48
    80004c42:	8082                	ret
  return -1;
    80004c44:	557d                	li	a0,-1
    80004c46:	b7fd                	j	80004c34 <pipealloc+0xc6>

0000000080004c48 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c48:	1101                	add	sp,sp,-32
    80004c4a:	ec06                	sd	ra,24(sp)
    80004c4c:	e822                	sd	s0,16(sp)
    80004c4e:	e426                	sd	s1,8(sp)
    80004c50:	e04a                	sd	s2,0(sp)
    80004c52:	1000                	add	s0,sp,32
    80004c54:	84aa                	mv	s1,a0
    80004c56:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	f7a080e7          	jalr	-134(ra) # 80000bd2 <acquire>
  if(writable){
    80004c60:	02090d63          	beqz	s2,80004c9a <pipeclose+0x52>
    pi->writeopen = 0;
    80004c64:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c68:	21848513          	add	a0,s1,536
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	446080e7          	jalr	1094(ra) # 800020b2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c74:	2204b783          	ld	a5,544(s1)
    80004c78:	eb95                	bnez	a5,80004cac <pipeclose+0x64>
    release(&pi->lock);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	00a080e7          	jalr	10(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	d5e080e7          	jalr	-674(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004c8e:	60e2                	ld	ra,24(sp)
    80004c90:	6442                	ld	s0,16(sp)
    80004c92:	64a2                	ld	s1,8(sp)
    80004c94:	6902                	ld	s2,0(sp)
    80004c96:	6105                	add	sp,sp,32
    80004c98:	8082                	ret
    pi->readopen = 0;
    80004c9a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c9e:	21c48513          	add	a0,s1,540
    80004ca2:	ffffd097          	auipc	ra,0xffffd
    80004ca6:	410080e7          	jalr	1040(ra) # 800020b2 <wakeup>
    80004caa:	b7e9                	j	80004c74 <pipeclose+0x2c>
    release(&pi->lock);
    80004cac:	8526                	mv	a0,s1
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	fd8080e7          	jalr	-40(ra) # 80000c86 <release>
}
    80004cb6:	bfe1                	j	80004c8e <pipeclose+0x46>

0000000080004cb8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cb8:	711d                	add	sp,sp,-96
    80004cba:	ec86                	sd	ra,88(sp)
    80004cbc:	e8a2                	sd	s0,80(sp)
    80004cbe:	e4a6                	sd	s1,72(sp)
    80004cc0:	e0ca                	sd	s2,64(sp)
    80004cc2:	fc4e                	sd	s3,56(sp)
    80004cc4:	f852                	sd	s4,48(sp)
    80004cc6:	f456                	sd	s5,40(sp)
    80004cc8:	f05a                	sd	s6,32(sp)
    80004cca:	ec5e                	sd	s7,24(sp)
    80004ccc:	e862                	sd	s8,16(sp)
    80004cce:	1080                	add	s0,sp,96
    80004cd0:	84aa                	mv	s1,a0
    80004cd2:	8aae                	mv	s5,a1
    80004cd4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cd6:	ffffd097          	auipc	ra,0xffffd
    80004cda:	cd0080e7          	jalr	-816(ra) # 800019a6 <myproc>
    80004cde:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	ef0080e7          	jalr	-272(ra) # 80000bd2 <acquire>
  while(i < n){
    80004cea:	0b405663          	blez	s4,80004d96 <pipewrite+0xde>
  int i = 0;
    80004cee:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cf0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cf2:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cf6:	21c48b93          	add	s7,s1,540
    80004cfa:	a089                	j	80004d3c <pipewrite+0x84>
      release(&pi->lock);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	f88080e7          	jalr	-120(ra) # 80000c86 <release>
      return -1;
    80004d06:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d08:	854a                	mv	a0,s2
    80004d0a:	60e6                	ld	ra,88(sp)
    80004d0c:	6446                	ld	s0,80(sp)
    80004d0e:	64a6                	ld	s1,72(sp)
    80004d10:	6906                	ld	s2,64(sp)
    80004d12:	79e2                	ld	s3,56(sp)
    80004d14:	7a42                	ld	s4,48(sp)
    80004d16:	7aa2                	ld	s5,40(sp)
    80004d18:	7b02                	ld	s6,32(sp)
    80004d1a:	6be2                	ld	s7,24(sp)
    80004d1c:	6c42                	ld	s8,16(sp)
    80004d1e:	6125                	add	sp,sp,96
    80004d20:	8082                	ret
      wakeup(&pi->nread);
    80004d22:	8562                	mv	a0,s8
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	38e080e7          	jalr	910(ra) # 800020b2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d2c:	85a6                	mv	a1,s1
    80004d2e:	855e                	mv	a0,s7
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	31e080e7          	jalr	798(ra) # 8000204e <sleep>
  while(i < n){
    80004d38:	07495063          	bge	s2,s4,80004d98 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d3c:	2204a783          	lw	a5,544(s1)
    80004d40:	dfd5                	beqz	a5,80004cfc <pipewrite+0x44>
    80004d42:	854e                	mv	a0,s3
    80004d44:	ffffd097          	auipc	ra,0xffffd
    80004d48:	5b2080e7          	jalr	1458(ra) # 800022f6 <killed>
    80004d4c:	f945                	bnez	a0,80004cfc <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d4e:	2184a783          	lw	a5,536(s1)
    80004d52:	21c4a703          	lw	a4,540(s1)
    80004d56:	2007879b          	addw	a5,a5,512
    80004d5a:	fcf704e3          	beq	a4,a5,80004d22 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d5e:	4685                	li	a3,1
    80004d60:	01590633          	add	a2,s2,s5
    80004d64:	faf40593          	add	a1,s0,-81
    80004d68:	0509b503          	ld	a0,80(s3)
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	986080e7          	jalr	-1658(ra) # 800016f2 <copyin>
    80004d74:	03650263          	beq	a0,s6,80004d98 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d78:	21c4a783          	lw	a5,540(s1)
    80004d7c:	0017871b          	addw	a4,a5,1
    80004d80:	20e4ae23          	sw	a4,540(s1)
    80004d84:	1ff7f793          	and	a5,a5,511
    80004d88:	97a6                	add	a5,a5,s1
    80004d8a:	faf44703          	lbu	a4,-81(s0)
    80004d8e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d92:	2905                	addw	s2,s2,1
    80004d94:	b755                	j	80004d38 <pipewrite+0x80>
  int i = 0;
    80004d96:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d98:	21848513          	add	a0,s1,536
    80004d9c:	ffffd097          	auipc	ra,0xffffd
    80004da0:	316080e7          	jalr	790(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004da4:	8526                	mv	a0,s1
    80004da6:	ffffc097          	auipc	ra,0xffffc
    80004daa:	ee0080e7          	jalr	-288(ra) # 80000c86 <release>
  return i;
    80004dae:	bfa9                	j	80004d08 <pipewrite+0x50>

0000000080004db0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004db0:	715d                	add	sp,sp,-80
    80004db2:	e486                	sd	ra,72(sp)
    80004db4:	e0a2                	sd	s0,64(sp)
    80004db6:	fc26                	sd	s1,56(sp)
    80004db8:	f84a                	sd	s2,48(sp)
    80004dba:	f44e                	sd	s3,40(sp)
    80004dbc:	f052                	sd	s4,32(sp)
    80004dbe:	ec56                	sd	s5,24(sp)
    80004dc0:	e85a                	sd	s6,16(sp)
    80004dc2:	0880                	add	s0,sp,80
    80004dc4:	84aa                	mv	s1,a0
    80004dc6:	892e                	mv	s2,a1
    80004dc8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	bdc080e7          	jalr	-1060(ra) # 800019a6 <myproc>
    80004dd2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	dfc080e7          	jalr	-516(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dde:	2184a703          	lw	a4,536(s1)
    80004de2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004de6:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dea:	02f71763          	bne	a4,a5,80004e18 <piperead+0x68>
    80004dee:	2244a783          	lw	a5,548(s1)
    80004df2:	c39d                	beqz	a5,80004e18 <piperead+0x68>
    if(killed(pr)){
    80004df4:	8552                	mv	a0,s4
    80004df6:	ffffd097          	auipc	ra,0xffffd
    80004dfa:	500080e7          	jalr	1280(ra) # 800022f6 <killed>
    80004dfe:	e949                	bnez	a0,80004e90 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e00:	85a6                	mv	a1,s1
    80004e02:	854e                	mv	a0,s3
    80004e04:	ffffd097          	auipc	ra,0xffffd
    80004e08:	24a080e7          	jalr	586(ra) # 8000204e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e0c:	2184a703          	lw	a4,536(s1)
    80004e10:	21c4a783          	lw	a5,540(s1)
    80004e14:	fcf70de3          	beq	a4,a5,80004dee <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e18:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e1a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e1c:	05505463          	blez	s5,80004e64 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004e20:	2184a783          	lw	a5,536(s1)
    80004e24:	21c4a703          	lw	a4,540(s1)
    80004e28:	02f70e63          	beq	a4,a5,80004e64 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e2c:	0017871b          	addw	a4,a5,1
    80004e30:	20e4ac23          	sw	a4,536(s1)
    80004e34:	1ff7f793          	and	a5,a5,511
    80004e38:	97a6                	add	a5,a5,s1
    80004e3a:	0187c783          	lbu	a5,24(a5)
    80004e3e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e42:	4685                	li	a3,1
    80004e44:	fbf40613          	add	a2,s0,-65
    80004e48:	85ca                	mv	a1,s2
    80004e4a:	050a3503          	ld	a0,80(s4)
    80004e4e:	ffffd097          	auipc	ra,0xffffd
    80004e52:	818080e7          	jalr	-2024(ra) # 80001666 <copyout>
    80004e56:	01650763          	beq	a0,s6,80004e64 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e5a:	2985                	addw	s3,s3,1
    80004e5c:	0905                	add	s2,s2,1
    80004e5e:	fd3a91e3          	bne	s5,s3,80004e20 <piperead+0x70>
    80004e62:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e64:	21c48513          	add	a0,s1,540
    80004e68:	ffffd097          	auipc	ra,0xffffd
    80004e6c:	24a080e7          	jalr	586(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004e70:	8526                	mv	a0,s1
    80004e72:	ffffc097          	auipc	ra,0xffffc
    80004e76:	e14080e7          	jalr	-492(ra) # 80000c86 <release>
  return i;
}
    80004e7a:	854e                	mv	a0,s3
    80004e7c:	60a6                	ld	ra,72(sp)
    80004e7e:	6406                	ld	s0,64(sp)
    80004e80:	74e2                	ld	s1,56(sp)
    80004e82:	7942                	ld	s2,48(sp)
    80004e84:	79a2                	ld	s3,40(sp)
    80004e86:	7a02                	ld	s4,32(sp)
    80004e88:	6ae2                	ld	s5,24(sp)
    80004e8a:	6b42                	ld	s6,16(sp)
    80004e8c:	6161                	add	sp,sp,80
    80004e8e:	8082                	ret
      release(&pi->lock);
    80004e90:	8526                	mv	a0,s1
    80004e92:	ffffc097          	auipc	ra,0xffffc
    80004e96:	df4080e7          	jalr	-524(ra) # 80000c86 <release>
      return -1;
    80004e9a:	59fd                	li	s3,-1
    80004e9c:	bff9                	j	80004e7a <piperead+0xca>

0000000080004e9e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e9e:	1141                	add	sp,sp,-16
    80004ea0:	e422                	sd	s0,8(sp)
    80004ea2:	0800                	add	s0,sp,16
    80004ea4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ea6:	8905                	and	a0,a0,1
    80004ea8:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004eaa:	8b89                	and	a5,a5,2
    80004eac:	c399                	beqz	a5,80004eb2 <flags2perm+0x14>
      perm |= PTE_W;
    80004eae:	00456513          	or	a0,a0,4
    return perm;
}
    80004eb2:	6422                	ld	s0,8(sp)
    80004eb4:	0141                	add	sp,sp,16
    80004eb6:	8082                	ret

0000000080004eb8 <exec>:

int
exec(char *path, char **argv)
{
    80004eb8:	df010113          	add	sp,sp,-528
    80004ebc:	20113423          	sd	ra,520(sp)
    80004ec0:	20813023          	sd	s0,512(sp)
    80004ec4:	ffa6                	sd	s1,504(sp)
    80004ec6:	fbca                	sd	s2,496(sp)
    80004ec8:	f7ce                	sd	s3,488(sp)
    80004eca:	f3d2                	sd	s4,480(sp)
    80004ecc:	efd6                	sd	s5,472(sp)
    80004ece:	ebda                	sd	s6,464(sp)
    80004ed0:	e7de                	sd	s7,456(sp)
    80004ed2:	e3e2                	sd	s8,448(sp)
    80004ed4:	ff66                	sd	s9,440(sp)
    80004ed6:	fb6a                	sd	s10,432(sp)
    80004ed8:	f76e                	sd	s11,424(sp)
    80004eda:	0c00                	add	s0,sp,528
    80004edc:	892a                	mv	s2,a0
    80004ede:	dea43c23          	sd	a0,-520(s0)
    80004ee2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ee6:	ffffd097          	auipc	ra,0xffffd
    80004eea:	ac0080e7          	jalr	-1344(ra) # 800019a6 <myproc>
    80004eee:	84aa                	mv	s1,a0

  begin_op();
    80004ef0:	fffff097          	auipc	ra,0xfffff
    80004ef4:	48e080e7          	jalr	1166(ra) # 8000437e <begin_op>

  if((ip = namei(path)) == 0){
    80004ef8:	854a                	mv	a0,s2
    80004efa:	fffff097          	auipc	ra,0xfffff
    80004efe:	284080e7          	jalr	644(ra) # 8000417e <namei>
    80004f02:	c92d                	beqz	a0,80004f74 <exec+0xbc>
    80004f04:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f06:	fffff097          	auipc	ra,0xfffff
    80004f0a:	ad2080e7          	jalr	-1326(ra) # 800039d8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f0e:	04000713          	li	a4,64
    80004f12:	4681                	li	a3,0
    80004f14:	e5040613          	add	a2,s0,-432
    80004f18:	4581                	li	a1,0
    80004f1a:	8552                	mv	a0,s4
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	d70080e7          	jalr	-656(ra) # 80003c8c <readi>
    80004f24:	04000793          	li	a5,64
    80004f28:	00f51a63          	bne	a0,a5,80004f3c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f2c:	e5042703          	lw	a4,-432(s0)
    80004f30:	464c47b7          	lui	a5,0x464c4
    80004f34:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f38:	04f70463          	beq	a4,a5,80004f80 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f3c:	8552                	mv	a0,s4
    80004f3e:	fffff097          	auipc	ra,0xfffff
    80004f42:	cfc080e7          	jalr	-772(ra) # 80003c3a <iunlockput>
    end_op();
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	4b2080e7          	jalr	1202(ra) # 800043f8 <end_op>
  }
  return -1;
    80004f4e:	557d                	li	a0,-1
}
    80004f50:	20813083          	ld	ra,520(sp)
    80004f54:	20013403          	ld	s0,512(sp)
    80004f58:	74fe                	ld	s1,504(sp)
    80004f5a:	795e                	ld	s2,496(sp)
    80004f5c:	79be                	ld	s3,488(sp)
    80004f5e:	7a1e                	ld	s4,480(sp)
    80004f60:	6afe                	ld	s5,472(sp)
    80004f62:	6b5e                	ld	s6,464(sp)
    80004f64:	6bbe                	ld	s7,456(sp)
    80004f66:	6c1e                	ld	s8,448(sp)
    80004f68:	7cfa                	ld	s9,440(sp)
    80004f6a:	7d5a                	ld	s10,432(sp)
    80004f6c:	7dba                	ld	s11,424(sp)
    80004f6e:	21010113          	add	sp,sp,528
    80004f72:	8082                	ret
    end_op();
    80004f74:	fffff097          	auipc	ra,0xfffff
    80004f78:	484080e7          	jalr	1156(ra) # 800043f8 <end_op>
    return -1;
    80004f7c:	557d                	li	a0,-1
    80004f7e:	bfc9                	j	80004f50 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f80:	8526                	mv	a0,s1
    80004f82:	ffffd097          	auipc	ra,0xffffd
    80004f86:	ae8080e7          	jalr	-1304(ra) # 80001a6a <proc_pagetable>
    80004f8a:	8b2a                	mv	s6,a0
    80004f8c:	d945                	beqz	a0,80004f3c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f8e:	e7042d03          	lw	s10,-400(s0)
    80004f92:	e8845783          	lhu	a5,-376(s0)
    80004f96:	10078463          	beqz	a5,8000509e <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f9a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f9c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004f9e:	6c85                	lui	s9,0x1
    80004fa0:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004fa4:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004fa8:	6a85                	lui	s5,0x1
    80004faa:	a0b5                	j	80005016 <exec+0x15e>
      panic("loadseg: address should exist");
    80004fac:	00004517          	auipc	a0,0x4
    80004fb0:	8ac50513          	add	a0,a0,-1876 # 80008858 <syscalls+0x288>
    80004fb4:	ffffb097          	auipc	ra,0xffffb
    80004fb8:	588080e7          	jalr	1416(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004fbc:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fbe:	8726                	mv	a4,s1
    80004fc0:	012c06bb          	addw	a3,s8,s2
    80004fc4:	4581                	li	a1,0
    80004fc6:	8552                	mv	a0,s4
    80004fc8:	fffff097          	auipc	ra,0xfffff
    80004fcc:	cc4080e7          	jalr	-828(ra) # 80003c8c <readi>
    80004fd0:	2501                	sext.w	a0,a0
    80004fd2:	24a49863          	bne	s1,a0,80005222 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004fd6:	012a893b          	addw	s2,s5,s2
    80004fda:	03397563          	bgeu	s2,s3,80005004 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004fde:	02091593          	sll	a1,s2,0x20
    80004fe2:	9181                	srl	a1,a1,0x20
    80004fe4:	95de                	add	a1,a1,s7
    80004fe6:	855a                	mv	a0,s6
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	06e080e7          	jalr	110(ra) # 80001056 <walkaddr>
    80004ff0:	862a                	mv	a2,a0
    if(pa == 0)
    80004ff2:	dd4d                	beqz	a0,80004fac <exec+0xf4>
    if(sz - i < PGSIZE)
    80004ff4:	412984bb          	subw	s1,s3,s2
    80004ff8:	0004879b          	sext.w	a5,s1
    80004ffc:	fcfcf0e3          	bgeu	s9,a5,80004fbc <exec+0x104>
    80005000:	84d6                	mv	s1,s5
    80005002:	bf6d                	j	80004fbc <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005004:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005008:	2d85                	addw	s11,s11,1
    8000500a:	038d0d1b          	addw	s10,s10,56
    8000500e:	e8845783          	lhu	a5,-376(s0)
    80005012:	08fdd763          	bge	s11,a5,800050a0 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005016:	2d01                	sext.w	s10,s10
    80005018:	03800713          	li	a4,56
    8000501c:	86ea                	mv	a3,s10
    8000501e:	e1840613          	add	a2,s0,-488
    80005022:	4581                	li	a1,0
    80005024:	8552                	mv	a0,s4
    80005026:	fffff097          	auipc	ra,0xfffff
    8000502a:	c66080e7          	jalr	-922(ra) # 80003c8c <readi>
    8000502e:	03800793          	li	a5,56
    80005032:	1ef51663          	bne	a0,a5,8000521e <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80005036:	e1842783          	lw	a5,-488(s0)
    8000503a:	4705                	li	a4,1
    8000503c:	fce796e3          	bne	a5,a4,80005008 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80005040:	e4043483          	ld	s1,-448(s0)
    80005044:	e3843783          	ld	a5,-456(s0)
    80005048:	1ef4e863          	bltu	s1,a5,80005238 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000504c:	e2843783          	ld	a5,-472(s0)
    80005050:	94be                	add	s1,s1,a5
    80005052:	1ef4e663          	bltu	s1,a5,8000523e <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80005056:	df043703          	ld	a4,-528(s0)
    8000505a:	8ff9                	and	a5,a5,a4
    8000505c:	1e079463          	bnez	a5,80005244 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005060:	e1c42503          	lw	a0,-484(s0)
    80005064:	00000097          	auipc	ra,0x0
    80005068:	e3a080e7          	jalr	-454(ra) # 80004e9e <flags2perm>
    8000506c:	86aa                	mv	a3,a0
    8000506e:	8626                	mv	a2,s1
    80005070:	85ca                	mv	a1,s2
    80005072:	855a                	mv	a0,s6
    80005074:	ffffc097          	auipc	ra,0xffffc
    80005078:	396080e7          	jalr	918(ra) # 8000140a <uvmalloc>
    8000507c:	e0a43423          	sd	a0,-504(s0)
    80005080:	1c050563          	beqz	a0,8000524a <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005084:	e2843b83          	ld	s7,-472(s0)
    80005088:	e2042c03          	lw	s8,-480(s0)
    8000508c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005090:	00098463          	beqz	s3,80005098 <exec+0x1e0>
    80005094:	4901                	li	s2,0
    80005096:	b7a1                	j	80004fde <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005098:	e0843903          	ld	s2,-504(s0)
    8000509c:	b7b5                	j	80005008 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000509e:	4901                	li	s2,0
  iunlockput(ip);
    800050a0:	8552                	mv	a0,s4
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	b98080e7          	jalr	-1128(ra) # 80003c3a <iunlockput>
  end_op();
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	34e080e7          	jalr	846(ra) # 800043f8 <end_op>
  p = myproc();
    800050b2:	ffffd097          	auipc	ra,0xffffd
    800050b6:	8f4080e7          	jalr	-1804(ra) # 800019a6 <myproc>
    800050ba:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800050bc:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800050c0:	6985                	lui	s3,0x1
    800050c2:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    800050c4:	99ca                	add	s3,s3,s2
    800050c6:	77fd                	lui	a5,0xfffff
    800050c8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050cc:	4691                	li	a3,4
    800050ce:	6609                	lui	a2,0x2
    800050d0:	964e                	add	a2,a2,s3
    800050d2:	85ce                	mv	a1,s3
    800050d4:	855a                	mv	a0,s6
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	334080e7          	jalr	820(ra) # 8000140a <uvmalloc>
    800050de:	892a                	mv	s2,a0
    800050e0:	e0a43423          	sd	a0,-504(s0)
    800050e4:	e509                	bnez	a0,800050ee <exec+0x236>
  if(pagetable)
    800050e6:	e1343423          	sd	s3,-504(s0)
    800050ea:	4a01                	li	s4,0
    800050ec:	aa1d                	j	80005222 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050ee:	75f9                	lui	a1,0xffffe
    800050f0:	95aa                	add	a1,a1,a0
    800050f2:	855a                	mv	a0,s6
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	540080e7          	jalr	1344(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    800050fc:	7bfd                	lui	s7,0xfffff
    800050fe:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005100:	e0043783          	ld	a5,-512(s0)
    80005104:	6388                	ld	a0,0(a5)
    80005106:	c52d                	beqz	a0,80005170 <exec+0x2b8>
    80005108:	e9040993          	add	s3,s0,-368
    8000510c:	f9040c13          	add	s8,s0,-112
    80005110:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005112:	ffffc097          	auipc	ra,0xffffc
    80005116:	d36080e7          	jalr	-714(ra) # 80000e48 <strlen>
    8000511a:	0015079b          	addw	a5,a0,1
    8000511e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005122:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80005126:	13796563          	bltu	s2,s7,80005250 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000512a:	e0043d03          	ld	s10,-512(s0)
    8000512e:	000d3a03          	ld	s4,0(s10)
    80005132:	8552                	mv	a0,s4
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	d14080e7          	jalr	-748(ra) # 80000e48 <strlen>
    8000513c:	0015069b          	addw	a3,a0,1
    80005140:	8652                	mv	a2,s4
    80005142:	85ca                	mv	a1,s2
    80005144:	855a                	mv	a0,s6
    80005146:	ffffc097          	auipc	ra,0xffffc
    8000514a:	520080e7          	jalr	1312(ra) # 80001666 <copyout>
    8000514e:	10054363          	bltz	a0,80005254 <exec+0x39c>
    ustack[argc] = sp;
    80005152:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005156:	0485                	add	s1,s1,1
    80005158:	008d0793          	add	a5,s10,8
    8000515c:	e0f43023          	sd	a5,-512(s0)
    80005160:	008d3503          	ld	a0,8(s10)
    80005164:	c909                	beqz	a0,80005176 <exec+0x2be>
    if(argc >= MAXARG)
    80005166:	09a1                	add	s3,s3,8
    80005168:	fb8995e3          	bne	s3,s8,80005112 <exec+0x25a>
  ip = 0;
    8000516c:	4a01                	li	s4,0
    8000516e:	a855                	j	80005222 <exec+0x36a>
  sp = sz;
    80005170:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005174:	4481                	li	s1,0
  ustack[argc] = 0;
    80005176:	00349793          	sll	a5,s1,0x3
    8000517a:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdca68>
    8000517e:	97a2                	add	a5,a5,s0
    80005180:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005184:	00148693          	add	a3,s1,1
    80005188:	068e                	sll	a3,a3,0x3
    8000518a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000518e:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005192:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005196:	f57968e3          	bltu	s2,s7,800050e6 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000519a:	e9040613          	add	a2,s0,-368
    8000519e:	85ca                	mv	a1,s2
    800051a0:	855a                	mv	a0,s6
    800051a2:	ffffc097          	auipc	ra,0xffffc
    800051a6:	4c4080e7          	jalr	1220(ra) # 80001666 <copyout>
    800051aa:	0a054763          	bltz	a0,80005258 <exec+0x3a0>
  p->trapframe->a1 = sp;
    800051ae:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800051b2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051b6:	df843783          	ld	a5,-520(s0)
    800051ba:	0007c703          	lbu	a4,0(a5)
    800051be:	cf11                	beqz	a4,800051da <exec+0x322>
    800051c0:	0785                	add	a5,a5,1
    if(*s == '/')
    800051c2:	02f00693          	li	a3,47
    800051c6:	a039                	j	800051d4 <exec+0x31c>
      last = s+1;
    800051c8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051cc:	0785                	add	a5,a5,1
    800051ce:	fff7c703          	lbu	a4,-1(a5)
    800051d2:	c701                	beqz	a4,800051da <exec+0x322>
    if(*s == '/')
    800051d4:	fed71ce3          	bne	a4,a3,800051cc <exec+0x314>
    800051d8:	bfc5                	j	800051c8 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    800051da:	4641                	li	a2,16
    800051dc:	df843583          	ld	a1,-520(s0)
    800051e0:	158a8513          	add	a0,s5,344
    800051e4:	ffffc097          	auipc	ra,0xffffc
    800051e8:	c32080e7          	jalr	-974(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    800051ec:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051f0:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800051f4:	e0843783          	ld	a5,-504(s0)
    800051f8:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051fc:	058ab783          	ld	a5,88(s5)
    80005200:	e6843703          	ld	a4,-408(s0)
    80005204:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005206:	058ab783          	ld	a5,88(s5)
    8000520a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000520e:	85e6                	mv	a1,s9
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	8f6080e7          	jalr	-1802(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005218:	0004851b          	sext.w	a0,s1
    8000521c:	bb15                	j	80004f50 <exec+0x98>
    8000521e:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005222:	e0843583          	ld	a1,-504(s0)
    80005226:	855a                	mv	a0,s6
    80005228:	ffffd097          	auipc	ra,0xffffd
    8000522c:	8de080e7          	jalr	-1826(ra) # 80001b06 <proc_freepagetable>
  return -1;
    80005230:	557d                	li	a0,-1
  if(ip){
    80005232:	d00a0fe3          	beqz	s4,80004f50 <exec+0x98>
    80005236:	b319                	j	80004f3c <exec+0x84>
    80005238:	e1243423          	sd	s2,-504(s0)
    8000523c:	b7dd                	j	80005222 <exec+0x36a>
    8000523e:	e1243423          	sd	s2,-504(s0)
    80005242:	b7c5                	j	80005222 <exec+0x36a>
    80005244:	e1243423          	sd	s2,-504(s0)
    80005248:	bfe9                	j	80005222 <exec+0x36a>
    8000524a:	e1243423          	sd	s2,-504(s0)
    8000524e:	bfd1                	j	80005222 <exec+0x36a>
  ip = 0;
    80005250:	4a01                	li	s4,0
    80005252:	bfc1                	j	80005222 <exec+0x36a>
    80005254:	4a01                	li	s4,0
  if(pagetable)
    80005256:	b7f1                	j	80005222 <exec+0x36a>
  sz = sz1;
    80005258:	e0843983          	ld	s3,-504(s0)
    8000525c:	b569                	j	800050e6 <exec+0x22e>

000000008000525e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000525e:	7179                	add	sp,sp,-48
    80005260:	f406                	sd	ra,40(sp)
    80005262:	f022                	sd	s0,32(sp)
    80005264:	ec26                	sd	s1,24(sp)
    80005266:	e84a                	sd	s2,16(sp)
    80005268:	1800                	add	s0,sp,48
    8000526a:	892e                	mv	s2,a1
    8000526c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000526e:	fdc40593          	add	a1,s0,-36
    80005272:	ffffe097          	auipc	ra,0xffffe
    80005276:	bb4080e7          	jalr	-1100(ra) # 80002e26 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000527a:	fdc42703          	lw	a4,-36(s0)
    8000527e:	47bd                	li	a5,15
    80005280:	02e7eb63          	bltu	a5,a4,800052b6 <argfd+0x58>
    80005284:	ffffc097          	auipc	ra,0xffffc
    80005288:	722080e7          	jalr	1826(ra) # 800019a6 <myproc>
    8000528c:	fdc42703          	lw	a4,-36(s0)
    80005290:	01a70793          	add	a5,a4,26
    80005294:	078e                	sll	a5,a5,0x3
    80005296:	953e                	add	a0,a0,a5
    80005298:	611c                	ld	a5,0(a0)
    8000529a:	c385                	beqz	a5,800052ba <argfd+0x5c>
    return -1;
  if(pfd)
    8000529c:	00090463          	beqz	s2,800052a4 <argfd+0x46>
    *pfd = fd;
    800052a0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052a4:	4501                	li	a0,0
  if(pf)
    800052a6:	c091                	beqz	s1,800052aa <argfd+0x4c>
    *pf = f;
    800052a8:	e09c                	sd	a5,0(s1)
}
    800052aa:	70a2                	ld	ra,40(sp)
    800052ac:	7402                	ld	s0,32(sp)
    800052ae:	64e2                	ld	s1,24(sp)
    800052b0:	6942                	ld	s2,16(sp)
    800052b2:	6145                	add	sp,sp,48
    800052b4:	8082                	ret
    return -1;
    800052b6:	557d                	li	a0,-1
    800052b8:	bfcd                	j	800052aa <argfd+0x4c>
    800052ba:	557d                	li	a0,-1
    800052bc:	b7fd                	j	800052aa <argfd+0x4c>

00000000800052be <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052be:	1101                	add	sp,sp,-32
    800052c0:	ec06                	sd	ra,24(sp)
    800052c2:	e822                	sd	s0,16(sp)
    800052c4:	e426                	sd	s1,8(sp)
    800052c6:	1000                	add	s0,sp,32
    800052c8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ca:	ffffc097          	auipc	ra,0xffffc
    800052ce:	6dc080e7          	jalr	1756(ra) # 800019a6 <myproc>
    800052d2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052d4:	0d050793          	add	a5,a0,208
    800052d8:	4501                	li	a0,0
    800052da:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052dc:	6398                	ld	a4,0(a5)
    800052de:	cb19                	beqz	a4,800052f4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052e0:	2505                	addw	a0,a0,1
    800052e2:	07a1                	add	a5,a5,8
    800052e4:	fed51ce3          	bne	a0,a3,800052dc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052e8:	557d                	li	a0,-1
}
    800052ea:	60e2                	ld	ra,24(sp)
    800052ec:	6442                	ld	s0,16(sp)
    800052ee:	64a2                	ld	s1,8(sp)
    800052f0:	6105                	add	sp,sp,32
    800052f2:	8082                	ret
      p->ofile[fd] = f;
    800052f4:	01a50793          	add	a5,a0,26
    800052f8:	078e                	sll	a5,a5,0x3
    800052fa:	963e                	add	a2,a2,a5
    800052fc:	e204                	sd	s1,0(a2)
      return fd;
    800052fe:	b7f5                	j	800052ea <fdalloc+0x2c>

0000000080005300 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005300:	715d                	add	sp,sp,-80
    80005302:	e486                	sd	ra,72(sp)
    80005304:	e0a2                	sd	s0,64(sp)
    80005306:	fc26                	sd	s1,56(sp)
    80005308:	f84a                	sd	s2,48(sp)
    8000530a:	f44e                	sd	s3,40(sp)
    8000530c:	f052                	sd	s4,32(sp)
    8000530e:	ec56                	sd	s5,24(sp)
    80005310:	e85a                	sd	s6,16(sp)
    80005312:	0880                	add	s0,sp,80
    80005314:	8b2e                	mv	s6,a1
    80005316:	89b2                	mv	s3,a2
    80005318:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000531a:	fb040593          	add	a1,s0,-80
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	e7e080e7          	jalr	-386(ra) # 8000419c <nameiparent>
    80005326:	84aa                	mv	s1,a0
    80005328:	14050b63          	beqz	a0,8000547e <create+0x17e>
    return 0;

  ilock(dp);
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	6ac080e7          	jalr	1708(ra) # 800039d8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005334:	4601                	li	a2,0
    80005336:	fb040593          	add	a1,s0,-80
    8000533a:	8526                	mv	a0,s1
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	b80080e7          	jalr	-1152(ra) # 80003ebc <dirlookup>
    80005344:	8aaa                	mv	s5,a0
    80005346:	c921                	beqz	a0,80005396 <create+0x96>
    iunlockput(dp);
    80005348:	8526                	mv	a0,s1
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	8f0080e7          	jalr	-1808(ra) # 80003c3a <iunlockput>
    ilock(ip);
    80005352:	8556                	mv	a0,s5
    80005354:	ffffe097          	auipc	ra,0xffffe
    80005358:	684080e7          	jalr	1668(ra) # 800039d8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000535c:	4789                	li	a5,2
    8000535e:	02fb1563          	bne	s6,a5,80005388 <create+0x88>
    80005362:	044ad783          	lhu	a5,68(s5)
    80005366:	37f9                	addw	a5,a5,-2
    80005368:	17c2                	sll	a5,a5,0x30
    8000536a:	93c1                	srl	a5,a5,0x30
    8000536c:	4705                	li	a4,1
    8000536e:	00f76d63          	bltu	a4,a5,80005388 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005372:	8556                	mv	a0,s5
    80005374:	60a6                	ld	ra,72(sp)
    80005376:	6406                	ld	s0,64(sp)
    80005378:	74e2                	ld	s1,56(sp)
    8000537a:	7942                	ld	s2,48(sp)
    8000537c:	79a2                	ld	s3,40(sp)
    8000537e:	7a02                	ld	s4,32(sp)
    80005380:	6ae2                	ld	s5,24(sp)
    80005382:	6b42                	ld	s6,16(sp)
    80005384:	6161                	add	sp,sp,80
    80005386:	8082                	ret
    iunlockput(ip);
    80005388:	8556                	mv	a0,s5
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	8b0080e7          	jalr	-1872(ra) # 80003c3a <iunlockput>
    return 0;
    80005392:	4a81                	li	s5,0
    80005394:	bff9                	j	80005372 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005396:	85da                	mv	a1,s6
    80005398:	4088                	lw	a0,0(s1)
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	4a6080e7          	jalr	1190(ra) # 80003840 <ialloc>
    800053a2:	8a2a                	mv	s4,a0
    800053a4:	c529                	beqz	a0,800053ee <create+0xee>
  ilock(ip);
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	632080e7          	jalr	1586(ra) # 800039d8 <ilock>
  ip->major = major;
    800053ae:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053b2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053b6:	4905                	li	s2,1
    800053b8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053bc:	8552                	mv	a0,s4
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	54e080e7          	jalr	1358(ra) # 8000390c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053c6:	032b0b63          	beq	s6,s2,800053fc <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053ca:	004a2603          	lw	a2,4(s4)
    800053ce:	fb040593          	add	a1,s0,-80
    800053d2:	8526                	mv	a0,s1
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	cf8080e7          	jalr	-776(ra) # 800040cc <dirlink>
    800053dc:	06054f63          	bltz	a0,8000545a <create+0x15a>
  iunlockput(dp);
    800053e0:	8526                	mv	a0,s1
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	858080e7          	jalr	-1960(ra) # 80003c3a <iunlockput>
  return ip;
    800053ea:	8ad2                	mv	s5,s4
    800053ec:	b759                	j	80005372 <create+0x72>
    iunlockput(dp);
    800053ee:	8526                	mv	a0,s1
    800053f0:	fffff097          	auipc	ra,0xfffff
    800053f4:	84a080e7          	jalr	-1974(ra) # 80003c3a <iunlockput>
    return 0;
    800053f8:	8ad2                	mv	s5,s4
    800053fa:	bfa5                	j	80005372 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053fc:	004a2603          	lw	a2,4(s4)
    80005400:	00003597          	auipc	a1,0x3
    80005404:	47858593          	add	a1,a1,1144 # 80008878 <syscalls+0x2a8>
    80005408:	8552                	mv	a0,s4
    8000540a:	fffff097          	auipc	ra,0xfffff
    8000540e:	cc2080e7          	jalr	-830(ra) # 800040cc <dirlink>
    80005412:	04054463          	bltz	a0,8000545a <create+0x15a>
    80005416:	40d0                	lw	a2,4(s1)
    80005418:	00003597          	auipc	a1,0x3
    8000541c:	46858593          	add	a1,a1,1128 # 80008880 <syscalls+0x2b0>
    80005420:	8552                	mv	a0,s4
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	caa080e7          	jalr	-854(ra) # 800040cc <dirlink>
    8000542a:	02054863          	bltz	a0,8000545a <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    8000542e:	004a2603          	lw	a2,4(s4)
    80005432:	fb040593          	add	a1,s0,-80
    80005436:	8526                	mv	a0,s1
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	c94080e7          	jalr	-876(ra) # 800040cc <dirlink>
    80005440:	00054d63          	bltz	a0,8000545a <create+0x15a>
    dp->nlink++;  // for ".."
    80005444:	04a4d783          	lhu	a5,74(s1)
    80005448:	2785                	addw	a5,a5,1
    8000544a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000544e:	8526                	mv	a0,s1
    80005450:	ffffe097          	auipc	ra,0xffffe
    80005454:	4bc080e7          	jalr	1212(ra) # 8000390c <iupdate>
    80005458:	b761                	j	800053e0 <create+0xe0>
  ip->nlink = 0;
    8000545a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000545e:	8552                	mv	a0,s4
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	4ac080e7          	jalr	1196(ra) # 8000390c <iupdate>
  iunlockput(ip);
    80005468:	8552                	mv	a0,s4
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	7d0080e7          	jalr	2000(ra) # 80003c3a <iunlockput>
  iunlockput(dp);
    80005472:	8526                	mv	a0,s1
    80005474:	ffffe097          	auipc	ra,0xffffe
    80005478:	7c6080e7          	jalr	1990(ra) # 80003c3a <iunlockput>
  return 0;
    8000547c:	bddd                	j	80005372 <create+0x72>
    return 0;
    8000547e:	8aaa                	mv	s5,a0
    80005480:	bdcd                	j	80005372 <create+0x72>

0000000080005482 <sys_dup>:
{
    80005482:	7179                	add	sp,sp,-48
    80005484:	f406                	sd	ra,40(sp)
    80005486:	f022                	sd	s0,32(sp)
    80005488:	ec26                	sd	s1,24(sp)
    8000548a:	e84a                	sd	s2,16(sp)
    8000548c:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000548e:	fd840613          	add	a2,s0,-40
    80005492:	4581                	li	a1,0
    80005494:	4501                	li	a0,0
    80005496:	00000097          	auipc	ra,0x0
    8000549a:	dc8080e7          	jalr	-568(ra) # 8000525e <argfd>
    return -1;
    8000549e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054a0:	02054363          	bltz	a0,800054c6 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800054a4:	fd843903          	ld	s2,-40(s0)
    800054a8:	854a                	mv	a0,s2
    800054aa:	00000097          	auipc	ra,0x0
    800054ae:	e14080e7          	jalr	-492(ra) # 800052be <fdalloc>
    800054b2:	84aa                	mv	s1,a0
    return -1;
    800054b4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054b6:	00054863          	bltz	a0,800054c6 <sys_dup+0x44>
  filedup(f);
    800054ba:	854a                	mv	a0,s2
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	334080e7          	jalr	820(ra) # 800047f0 <filedup>
  return fd;
    800054c4:	87a6                	mv	a5,s1
}
    800054c6:	853e                	mv	a0,a5
    800054c8:	70a2                	ld	ra,40(sp)
    800054ca:	7402                	ld	s0,32(sp)
    800054cc:	64e2                	ld	s1,24(sp)
    800054ce:	6942                	ld	s2,16(sp)
    800054d0:	6145                	add	sp,sp,48
    800054d2:	8082                	ret

00000000800054d4 <sys_read>:
{
    800054d4:	7179                	add	sp,sp,-48
    800054d6:	f406                	sd	ra,40(sp)
    800054d8:	f022                	sd	s0,32(sp)
    800054da:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800054dc:	fd840593          	add	a1,s0,-40
    800054e0:	4505                	li	a0,1
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	964080e7          	jalr	-1692(ra) # 80002e46 <argaddr>
  argint(2, &n);
    800054ea:	fe440593          	add	a1,s0,-28
    800054ee:	4509                	li	a0,2
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	936080e7          	jalr	-1738(ra) # 80002e26 <argint>
  if(argfd(0, 0, &f) < 0)
    800054f8:	fe840613          	add	a2,s0,-24
    800054fc:	4581                	li	a1,0
    800054fe:	4501                	li	a0,0
    80005500:	00000097          	auipc	ra,0x0
    80005504:	d5e080e7          	jalr	-674(ra) # 8000525e <argfd>
    80005508:	87aa                	mv	a5,a0
    return -1;
    8000550a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000550c:	0007cc63          	bltz	a5,80005524 <sys_read+0x50>
  return fileread(f, p, n);
    80005510:	fe442603          	lw	a2,-28(s0)
    80005514:	fd843583          	ld	a1,-40(s0)
    80005518:	fe843503          	ld	a0,-24(s0)
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	460080e7          	jalr	1120(ra) # 8000497c <fileread>
}
    80005524:	70a2                	ld	ra,40(sp)
    80005526:	7402                	ld	s0,32(sp)
    80005528:	6145                	add	sp,sp,48
    8000552a:	8082                	ret

000000008000552c <sys_write>:
{
    8000552c:	7179                	add	sp,sp,-48
    8000552e:	f406                	sd	ra,40(sp)
    80005530:	f022                	sd	s0,32(sp)
    80005532:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005534:	fd840593          	add	a1,s0,-40
    80005538:	4505                	li	a0,1
    8000553a:	ffffe097          	auipc	ra,0xffffe
    8000553e:	90c080e7          	jalr	-1780(ra) # 80002e46 <argaddr>
  argint(2, &n);
    80005542:	fe440593          	add	a1,s0,-28
    80005546:	4509                	li	a0,2
    80005548:	ffffe097          	auipc	ra,0xffffe
    8000554c:	8de080e7          	jalr	-1826(ra) # 80002e26 <argint>
  if(argfd(0, 0, &f) < 0)
    80005550:	fe840613          	add	a2,s0,-24
    80005554:	4581                	li	a1,0
    80005556:	4501                	li	a0,0
    80005558:	00000097          	auipc	ra,0x0
    8000555c:	d06080e7          	jalr	-762(ra) # 8000525e <argfd>
    80005560:	87aa                	mv	a5,a0
    return -1;
    80005562:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005564:	0007cc63          	bltz	a5,8000557c <sys_write+0x50>
  return filewrite(f, p, n);
    80005568:	fe442603          	lw	a2,-28(s0)
    8000556c:	fd843583          	ld	a1,-40(s0)
    80005570:	fe843503          	ld	a0,-24(s0)
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	4ca080e7          	jalr	1226(ra) # 80004a3e <filewrite>
}
    8000557c:	70a2                	ld	ra,40(sp)
    8000557e:	7402                	ld	s0,32(sp)
    80005580:	6145                	add	sp,sp,48
    80005582:	8082                	ret

0000000080005584 <sys_close>:
{
    80005584:	1101                	add	sp,sp,-32
    80005586:	ec06                	sd	ra,24(sp)
    80005588:	e822                	sd	s0,16(sp)
    8000558a:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000558c:	fe040613          	add	a2,s0,-32
    80005590:	fec40593          	add	a1,s0,-20
    80005594:	4501                	li	a0,0
    80005596:	00000097          	auipc	ra,0x0
    8000559a:	cc8080e7          	jalr	-824(ra) # 8000525e <argfd>
    return -1;
    8000559e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055a0:	02054463          	bltz	a0,800055c8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055a4:	ffffc097          	auipc	ra,0xffffc
    800055a8:	402080e7          	jalr	1026(ra) # 800019a6 <myproc>
    800055ac:	fec42783          	lw	a5,-20(s0)
    800055b0:	07e9                	add	a5,a5,26
    800055b2:	078e                	sll	a5,a5,0x3
    800055b4:	953e                	add	a0,a0,a5
    800055b6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055ba:	fe043503          	ld	a0,-32(s0)
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	284080e7          	jalr	644(ra) # 80004842 <fileclose>
  return 0;
    800055c6:	4781                	li	a5,0
}
    800055c8:	853e                	mv	a0,a5
    800055ca:	60e2                	ld	ra,24(sp)
    800055cc:	6442                	ld	s0,16(sp)
    800055ce:	6105                	add	sp,sp,32
    800055d0:	8082                	ret

00000000800055d2 <sys_fstat>:
{
    800055d2:	1101                	add	sp,sp,-32
    800055d4:	ec06                	sd	ra,24(sp)
    800055d6:	e822                	sd	s0,16(sp)
    800055d8:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800055da:	fe040593          	add	a1,s0,-32
    800055de:	4505                	li	a0,1
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	866080e7          	jalr	-1946(ra) # 80002e46 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055e8:	fe840613          	add	a2,s0,-24
    800055ec:	4581                	li	a1,0
    800055ee:	4501                	li	a0,0
    800055f0:	00000097          	auipc	ra,0x0
    800055f4:	c6e080e7          	jalr	-914(ra) # 8000525e <argfd>
    800055f8:	87aa                	mv	a5,a0
    return -1;
    800055fa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055fc:	0007ca63          	bltz	a5,80005610 <sys_fstat+0x3e>
  return filestat(f, st);
    80005600:	fe043583          	ld	a1,-32(s0)
    80005604:	fe843503          	ld	a0,-24(s0)
    80005608:	fffff097          	auipc	ra,0xfffff
    8000560c:	302080e7          	jalr	770(ra) # 8000490a <filestat>
}
    80005610:	60e2                	ld	ra,24(sp)
    80005612:	6442                	ld	s0,16(sp)
    80005614:	6105                	add	sp,sp,32
    80005616:	8082                	ret

0000000080005618 <sys_link>:
{
    80005618:	7169                	add	sp,sp,-304
    8000561a:	f606                	sd	ra,296(sp)
    8000561c:	f222                	sd	s0,288(sp)
    8000561e:	ee26                	sd	s1,280(sp)
    80005620:	ea4a                	sd	s2,272(sp)
    80005622:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005624:	08000613          	li	a2,128
    80005628:	ed040593          	add	a1,s0,-304
    8000562c:	4501                	li	a0,0
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	838080e7          	jalr	-1992(ra) # 80002e66 <argstr>
    return -1;
    80005636:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005638:	10054e63          	bltz	a0,80005754 <sys_link+0x13c>
    8000563c:	08000613          	li	a2,128
    80005640:	f5040593          	add	a1,s0,-176
    80005644:	4505                	li	a0,1
    80005646:	ffffe097          	auipc	ra,0xffffe
    8000564a:	820080e7          	jalr	-2016(ra) # 80002e66 <argstr>
    return -1;
    8000564e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005650:	10054263          	bltz	a0,80005754 <sys_link+0x13c>
  begin_op();
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	d2a080e7          	jalr	-726(ra) # 8000437e <begin_op>
  if((ip = namei(old)) == 0){
    8000565c:	ed040513          	add	a0,s0,-304
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	b1e080e7          	jalr	-1250(ra) # 8000417e <namei>
    80005668:	84aa                	mv	s1,a0
    8000566a:	c551                	beqz	a0,800056f6 <sys_link+0xde>
  ilock(ip);
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	36c080e7          	jalr	876(ra) # 800039d8 <ilock>
  if(ip->type == T_DIR){
    80005674:	04449703          	lh	a4,68(s1)
    80005678:	4785                	li	a5,1
    8000567a:	08f70463          	beq	a4,a5,80005702 <sys_link+0xea>
  ip->nlink++;
    8000567e:	04a4d783          	lhu	a5,74(s1)
    80005682:	2785                	addw	a5,a5,1
    80005684:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	282080e7          	jalr	642(ra) # 8000390c <iupdate>
  iunlock(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	406080e7          	jalr	1030(ra) # 80003a9a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000569c:	fd040593          	add	a1,s0,-48
    800056a0:	f5040513          	add	a0,s0,-176
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	af8080e7          	jalr	-1288(ra) # 8000419c <nameiparent>
    800056ac:	892a                	mv	s2,a0
    800056ae:	c935                	beqz	a0,80005722 <sys_link+0x10a>
  ilock(dp);
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	328080e7          	jalr	808(ra) # 800039d8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056b8:	00092703          	lw	a4,0(s2)
    800056bc:	409c                	lw	a5,0(s1)
    800056be:	04f71d63          	bne	a4,a5,80005718 <sys_link+0x100>
    800056c2:	40d0                	lw	a2,4(s1)
    800056c4:	fd040593          	add	a1,s0,-48
    800056c8:	854a                	mv	a0,s2
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	a02080e7          	jalr	-1534(ra) # 800040cc <dirlink>
    800056d2:	04054363          	bltz	a0,80005718 <sys_link+0x100>
  iunlockput(dp);
    800056d6:	854a                	mv	a0,s2
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	562080e7          	jalr	1378(ra) # 80003c3a <iunlockput>
  iput(ip);
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	4b0080e7          	jalr	1200(ra) # 80003b92 <iput>
  end_op();
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	d0e080e7          	jalr	-754(ra) # 800043f8 <end_op>
  return 0;
    800056f2:	4781                	li	a5,0
    800056f4:	a085                	j	80005754 <sys_link+0x13c>
    end_op();
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	d02080e7          	jalr	-766(ra) # 800043f8 <end_op>
    return -1;
    800056fe:	57fd                	li	a5,-1
    80005700:	a891                	j	80005754 <sys_link+0x13c>
    iunlockput(ip);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	536080e7          	jalr	1334(ra) # 80003c3a <iunlockput>
    end_op();
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	cec080e7          	jalr	-788(ra) # 800043f8 <end_op>
    return -1;
    80005714:	57fd                	li	a5,-1
    80005716:	a83d                	j	80005754 <sys_link+0x13c>
    iunlockput(dp);
    80005718:	854a                	mv	a0,s2
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	520080e7          	jalr	1312(ra) # 80003c3a <iunlockput>
  ilock(ip);
    80005722:	8526                	mv	a0,s1
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	2b4080e7          	jalr	692(ra) # 800039d8 <ilock>
  ip->nlink--;
    8000572c:	04a4d783          	lhu	a5,74(s1)
    80005730:	37fd                	addw	a5,a5,-1
    80005732:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	1d4080e7          	jalr	468(ra) # 8000390c <iupdate>
  iunlockput(ip);
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	4f8080e7          	jalr	1272(ra) # 80003c3a <iunlockput>
  end_op();
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	cae080e7          	jalr	-850(ra) # 800043f8 <end_op>
  return -1;
    80005752:	57fd                	li	a5,-1
}
    80005754:	853e                	mv	a0,a5
    80005756:	70b2                	ld	ra,296(sp)
    80005758:	7412                	ld	s0,288(sp)
    8000575a:	64f2                	ld	s1,280(sp)
    8000575c:	6952                	ld	s2,272(sp)
    8000575e:	6155                	add	sp,sp,304
    80005760:	8082                	ret

0000000080005762 <sys_unlink>:
{
    80005762:	7151                	add	sp,sp,-240
    80005764:	f586                	sd	ra,232(sp)
    80005766:	f1a2                	sd	s0,224(sp)
    80005768:	eda6                	sd	s1,216(sp)
    8000576a:	e9ca                	sd	s2,208(sp)
    8000576c:	e5ce                	sd	s3,200(sp)
    8000576e:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005770:	08000613          	li	a2,128
    80005774:	f3040593          	add	a1,s0,-208
    80005778:	4501                	li	a0,0
    8000577a:	ffffd097          	auipc	ra,0xffffd
    8000577e:	6ec080e7          	jalr	1772(ra) # 80002e66 <argstr>
    80005782:	18054163          	bltz	a0,80005904 <sys_unlink+0x1a2>
  begin_op();
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	bf8080e7          	jalr	-1032(ra) # 8000437e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000578e:	fb040593          	add	a1,s0,-80
    80005792:	f3040513          	add	a0,s0,-208
    80005796:	fffff097          	auipc	ra,0xfffff
    8000579a:	a06080e7          	jalr	-1530(ra) # 8000419c <nameiparent>
    8000579e:	84aa                	mv	s1,a0
    800057a0:	c979                	beqz	a0,80005876 <sys_unlink+0x114>
  ilock(dp);
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	236080e7          	jalr	566(ra) # 800039d8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057aa:	00003597          	auipc	a1,0x3
    800057ae:	0ce58593          	add	a1,a1,206 # 80008878 <syscalls+0x2a8>
    800057b2:	fb040513          	add	a0,s0,-80
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	6ec080e7          	jalr	1772(ra) # 80003ea2 <namecmp>
    800057be:	14050a63          	beqz	a0,80005912 <sys_unlink+0x1b0>
    800057c2:	00003597          	auipc	a1,0x3
    800057c6:	0be58593          	add	a1,a1,190 # 80008880 <syscalls+0x2b0>
    800057ca:	fb040513          	add	a0,s0,-80
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	6d4080e7          	jalr	1748(ra) # 80003ea2 <namecmp>
    800057d6:	12050e63          	beqz	a0,80005912 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057da:	f2c40613          	add	a2,s0,-212
    800057de:	fb040593          	add	a1,s0,-80
    800057e2:	8526                	mv	a0,s1
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	6d8080e7          	jalr	1752(ra) # 80003ebc <dirlookup>
    800057ec:	892a                	mv	s2,a0
    800057ee:	12050263          	beqz	a0,80005912 <sys_unlink+0x1b0>
  ilock(ip);
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	1e6080e7          	jalr	486(ra) # 800039d8 <ilock>
  if(ip->nlink < 1)
    800057fa:	04a91783          	lh	a5,74(s2)
    800057fe:	08f05263          	blez	a5,80005882 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005802:	04491703          	lh	a4,68(s2)
    80005806:	4785                	li	a5,1
    80005808:	08f70563          	beq	a4,a5,80005892 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000580c:	4641                	li	a2,16
    8000580e:	4581                	li	a1,0
    80005810:	fc040513          	add	a0,s0,-64
    80005814:	ffffb097          	auipc	ra,0xffffb
    80005818:	4ba080e7          	jalr	1210(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000581c:	4741                	li	a4,16
    8000581e:	f2c42683          	lw	a3,-212(s0)
    80005822:	fc040613          	add	a2,s0,-64
    80005826:	4581                	li	a1,0
    80005828:	8526                	mv	a0,s1
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	55a080e7          	jalr	1370(ra) # 80003d84 <writei>
    80005832:	47c1                	li	a5,16
    80005834:	0af51563          	bne	a0,a5,800058de <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005838:	04491703          	lh	a4,68(s2)
    8000583c:	4785                	li	a5,1
    8000583e:	0af70863          	beq	a4,a5,800058ee <sys_unlink+0x18c>
  iunlockput(dp);
    80005842:	8526                	mv	a0,s1
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	3f6080e7          	jalr	1014(ra) # 80003c3a <iunlockput>
  ip->nlink--;
    8000584c:	04a95783          	lhu	a5,74(s2)
    80005850:	37fd                	addw	a5,a5,-1
    80005852:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005856:	854a                	mv	a0,s2
    80005858:	ffffe097          	auipc	ra,0xffffe
    8000585c:	0b4080e7          	jalr	180(ra) # 8000390c <iupdate>
  iunlockput(ip);
    80005860:	854a                	mv	a0,s2
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	3d8080e7          	jalr	984(ra) # 80003c3a <iunlockput>
  end_op();
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	b8e080e7          	jalr	-1138(ra) # 800043f8 <end_op>
  return 0;
    80005872:	4501                	li	a0,0
    80005874:	a84d                	j	80005926 <sys_unlink+0x1c4>
    end_op();
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	b82080e7          	jalr	-1150(ra) # 800043f8 <end_op>
    return -1;
    8000587e:	557d                	li	a0,-1
    80005880:	a05d                	j	80005926 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005882:	00003517          	auipc	a0,0x3
    80005886:	00650513          	add	a0,a0,6 # 80008888 <syscalls+0x2b8>
    8000588a:	ffffb097          	auipc	ra,0xffffb
    8000588e:	cb2080e7          	jalr	-846(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005892:	04c92703          	lw	a4,76(s2)
    80005896:	02000793          	li	a5,32
    8000589a:	f6e7f9e3          	bgeu	a5,a4,8000580c <sys_unlink+0xaa>
    8000589e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a2:	4741                	li	a4,16
    800058a4:	86ce                	mv	a3,s3
    800058a6:	f1840613          	add	a2,s0,-232
    800058aa:	4581                	li	a1,0
    800058ac:	854a                	mv	a0,s2
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	3de080e7          	jalr	990(ra) # 80003c8c <readi>
    800058b6:	47c1                	li	a5,16
    800058b8:	00f51b63          	bne	a0,a5,800058ce <sys_unlink+0x16c>
    if(de.inum != 0)
    800058bc:	f1845783          	lhu	a5,-232(s0)
    800058c0:	e7a1                	bnez	a5,80005908 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058c2:	29c1                	addw	s3,s3,16
    800058c4:	04c92783          	lw	a5,76(s2)
    800058c8:	fcf9ede3          	bltu	s3,a5,800058a2 <sys_unlink+0x140>
    800058cc:	b781                	j	8000580c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058ce:	00003517          	auipc	a0,0x3
    800058d2:	fd250513          	add	a0,a0,-46 # 800088a0 <syscalls+0x2d0>
    800058d6:	ffffb097          	auipc	ra,0xffffb
    800058da:	c66080e7          	jalr	-922(ra) # 8000053c <panic>
    panic("unlink: writei");
    800058de:	00003517          	auipc	a0,0x3
    800058e2:	fda50513          	add	a0,a0,-38 # 800088b8 <syscalls+0x2e8>
    800058e6:	ffffb097          	auipc	ra,0xffffb
    800058ea:	c56080e7          	jalr	-938(ra) # 8000053c <panic>
    dp->nlink--;
    800058ee:	04a4d783          	lhu	a5,74(s1)
    800058f2:	37fd                	addw	a5,a5,-1
    800058f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058f8:	8526                	mv	a0,s1
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	012080e7          	jalr	18(ra) # 8000390c <iupdate>
    80005902:	b781                	j	80005842 <sys_unlink+0xe0>
    return -1;
    80005904:	557d                	li	a0,-1
    80005906:	a005                	j	80005926 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005908:	854a                	mv	a0,s2
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	330080e7          	jalr	816(ra) # 80003c3a <iunlockput>
  iunlockput(dp);
    80005912:	8526                	mv	a0,s1
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	326080e7          	jalr	806(ra) # 80003c3a <iunlockput>
  end_op();
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	adc080e7          	jalr	-1316(ra) # 800043f8 <end_op>
  return -1;
    80005924:	557d                	li	a0,-1
}
    80005926:	70ae                	ld	ra,232(sp)
    80005928:	740e                	ld	s0,224(sp)
    8000592a:	64ee                	ld	s1,216(sp)
    8000592c:	694e                	ld	s2,208(sp)
    8000592e:	69ae                	ld	s3,200(sp)
    80005930:	616d                	add	sp,sp,240
    80005932:	8082                	ret

0000000080005934 <sys_open>:

uint64
sys_open(void)
{
    80005934:	7131                	add	sp,sp,-192
    80005936:	fd06                	sd	ra,184(sp)
    80005938:	f922                	sd	s0,176(sp)
    8000593a:	f526                	sd	s1,168(sp)
    8000593c:	f14a                	sd	s2,160(sp)
    8000593e:	ed4e                	sd	s3,152(sp)
    80005940:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005942:	f4c40593          	add	a1,s0,-180
    80005946:	4505                	li	a0,1
    80005948:	ffffd097          	auipc	ra,0xffffd
    8000594c:	4de080e7          	jalr	1246(ra) # 80002e26 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005950:	08000613          	li	a2,128
    80005954:	f5040593          	add	a1,s0,-176
    80005958:	4501                	li	a0,0
    8000595a:	ffffd097          	auipc	ra,0xffffd
    8000595e:	50c080e7          	jalr	1292(ra) # 80002e66 <argstr>
    80005962:	87aa                	mv	a5,a0
    return -1;
    80005964:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005966:	0a07c863          	bltz	a5,80005a16 <sys_open+0xe2>

  begin_op();
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	a14080e7          	jalr	-1516(ra) # 8000437e <begin_op>

  if(omode & O_CREATE){
    80005972:	f4c42783          	lw	a5,-180(s0)
    80005976:	2007f793          	and	a5,a5,512
    8000597a:	cbdd                	beqz	a5,80005a30 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000597c:	4681                	li	a3,0
    8000597e:	4601                	li	a2,0
    80005980:	4589                	li	a1,2
    80005982:	f5040513          	add	a0,s0,-176
    80005986:	00000097          	auipc	ra,0x0
    8000598a:	97a080e7          	jalr	-1670(ra) # 80005300 <create>
    8000598e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005990:	c951                	beqz	a0,80005a24 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005992:	04449703          	lh	a4,68(s1)
    80005996:	478d                	li	a5,3
    80005998:	00f71763          	bne	a4,a5,800059a6 <sys_open+0x72>
    8000599c:	0464d703          	lhu	a4,70(s1)
    800059a0:	47a5                	li	a5,9
    800059a2:	0ce7ec63          	bltu	a5,a4,80005a7a <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	de0080e7          	jalr	-544(ra) # 80004786 <filealloc>
    800059ae:	892a                	mv	s2,a0
    800059b0:	c56d                	beqz	a0,80005a9a <sys_open+0x166>
    800059b2:	00000097          	auipc	ra,0x0
    800059b6:	90c080e7          	jalr	-1780(ra) # 800052be <fdalloc>
    800059ba:	89aa                	mv	s3,a0
    800059bc:	0c054a63          	bltz	a0,80005a90 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059c0:	04449703          	lh	a4,68(s1)
    800059c4:	478d                	li	a5,3
    800059c6:	0ef70563          	beq	a4,a5,80005ab0 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059ca:	4789                	li	a5,2
    800059cc:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059d0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059d4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059d8:	f4c42783          	lw	a5,-180(s0)
    800059dc:	0017c713          	xor	a4,a5,1
    800059e0:	8b05                	and	a4,a4,1
    800059e2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059e6:	0037f713          	and	a4,a5,3
    800059ea:	00e03733          	snez	a4,a4
    800059ee:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059f2:	4007f793          	and	a5,a5,1024
    800059f6:	c791                	beqz	a5,80005a02 <sys_open+0xce>
    800059f8:	04449703          	lh	a4,68(s1)
    800059fc:	4789                	li	a5,2
    800059fe:	0cf70063          	beq	a4,a5,80005abe <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	096080e7          	jalr	150(ra) # 80003a9a <iunlock>
  end_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	9ec080e7          	jalr	-1556(ra) # 800043f8 <end_op>

  return fd;
    80005a14:	854e                	mv	a0,s3
}
    80005a16:	70ea                	ld	ra,184(sp)
    80005a18:	744a                	ld	s0,176(sp)
    80005a1a:	74aa                	ld	s1,168(sp)
    80005a1c:	790a                	ld	s2,160(sp)
    80005a1e:	69ea                	ld	s3,152(sp)
    80005a20:	6129                	add	sp,sp,192
    80005a22:	8082                	ret
      end_op();
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	9d4080e7          	jalr	-1580(ra) # 800043f8 <end_op>
      return -1;
    80005a2c:	557d                	li	a0,-1
    80005a2e:	b7e5                	j	80005a16 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005a30:	f5040513          	add	a0,s0,-176
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	74a080e7          	jalr	1866(ra) # 8000417e <namei>
    80005a3c:	84aa                	mv	s1,a0
    80005a3e:	c905                	beqz	a0,80005a6e <sys_open+0x13a>
    ilock(ip);
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	f98080e7          	jalr	-104(ra) # 800039d8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a48:	04449703          	lh	a4,68(s1)
    80005a4c:	4785                	li	a5,1
    80005a4e:	f4f712e3          	bne	a4,a5,80005992 <sys_open+0x5e>
    80005a52:	f4c42783          	lw	a5,-180(s0)
    80005a56:	dba1                	beqz	a5,800059a6 <sys_open+0x72>
      iunlockput(ip);
    80005a58:	8526                	mv	a0,s1
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	1e0080e7          	jalr	480(ra) # 80003c3a <iunlockput>
      end_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	996080e7          	jalr	-1642(ra) # 800043f8 <end_op>
      return -1;
    80005a6a:	557d                	li	a0,-1
    80005a6c:	b76d                	j	80005a16 <sys_open+0xe2>
      end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	98a080e7          	jalr	-1654(ra) # 800043f8 <end_op>
      return -1;
    80005a76:	557d                	li	a0,-1
    80005a78:	bf79                	j	80005a16 <sys_open+0xe2>
    iunlockput(ip);
    80005a7a:	8526                	mv	a0,s1
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	1be080e7          	jalr	446(ra) # 80003c3a <iunlockput>
    end_op();
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	974080e7          	jalr	-1676(ra) # 800043f8 <end_op>
    return -1;
    80005a8c:	557d                	li	a0,-1
    80005a8e:	b761                	j	80005a16 <sys_open+0xe2>
      fileclose(f);
    80005a90:	854a                	mv	a0,s2
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	db0080e7          	jalr	-592(ra) # 80004842 <fileclose>
    iunlockput(ip);
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	19e080e7          	jalr	414(ra) # 80003c3a <iunlockput>
    end_op();
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	954080e7          	jalr	-1708(ra) # 800043f8 <end_op>
    return -1;
    80005aac:	557d                	li	a0,-1
    80005aae:	b7a5                	j	80005a16 <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005ab0:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005ab4:	04649783          	lh	a5,70(s1)
    80005ab8:	02f91223          	sh	a5,36(s2)
    80005abc:	bf21                	j	800059d4 <sys_open+0xa0>
    itrunc(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	026080e7          	jalr	38(ra) # 80003ae6 <itrunc>
    80005ac8:	bf2d                	j	80005a02 <sys_open+0xce>

0000000080005aca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005aca:	7175                	add	sp,sp,-144
    80005acc:	e506                	sd	ra,136(sp)
    80005ace:	e122                	sd	s0,128(sp)
    80005ad0:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	8ac080e7          	jalr	-1876(ra) # 8000437e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ada:	08000613          	li	a2,128
    80005ade:	f7040593          	add	a1,s0,-144
    80005ae2:	4501                	li	a0,0
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	382080e7          	jalr	898(ra) # 80002e66 <argstr>
    80005aec:	02054963          	bltz	a0,80005b1e <sys_mkdir+0x54>
    80005af0:	4681                	li	a3,0
    80005af2:	4601                	li	a2,0
    80005af4:	4585                	li	a1,1
    80005af6:	f7040513          	add	a0,s0,-144
    80005afa:	00000097          	auipc	ra,0x0
    80005afe:	806080e7          	jalr	-2042(ra) # 80005300 <create>
    80005b02:	cd11                	beqz	a0,80005b1e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	136080e7          	jalr	310(ra) # 80003c3a <iunlockput>
  end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	8ec080e7          	jalr	-1812(ra) # 800043f8 <end_op>
  return 0;
    80005b14:	4501                	li	a0,0
}
    80005b16:	60aa                	ld	ra,136(sp)
    80005b18:	640a                	ld	s0,128(sp)
    80005b1a:	6149                	add	sp,sp,144
    80005b1c:	8082                	ret
    end_op();
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	8da080e7          	jalr	-1830(ra) # 800043f8 <end_op>
    return -1;
    80005b26:	557d                	li	a0,-1
    80005b28:	b7fd                	j	80005b16 <sys_mkdir+0x4c>

0000000080005b2a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b2a:	7135                	add	sp,sp,-160
    80005b2c:	ed06                	sd	ra,152(sp)
    80005b2e:	e922                	sd	s0,144(sp)
    80005b30:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b32:	fffff097          	auipc	ra,0xfffff
    80005b36:	84c080e7          	jalr	-1972(ra) # 8000437e <begin_op>
  argint(1, &major);
    80005b3a:	f6c40593          	add	a1,s0,-148
    80005b3e:	4505                	li	a0,1
    80005b40:	ffffd097          	auipc	ra,0xffffd
    80005b44:	2e6080e7          	jalr	742(ra) # 80002e26 <argint>
  argint(2, &minor);
    80005b48:	f6840593          	add	a1,s0,-152
    80005b4c:	4509                	li	a0,2
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	2d8080e7          	jalr	728(ra) # 80002e26 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b56:	08000613          	li	a2,128
    80005b5a:	f7040593          	add	a1,s0,-144
    80005b5e:	4501                	li	a0,0
    80005b60:	ffffd097          	auipc	ra,0xffffd
    80005b64:	306080e7          	jalr	774(ra) # 80002e66 <argstr>
    80005b68:	02054b63          	bltz	a0,80005b9e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b6c:	f6841683          	lh	a3,-152(s0)
    80005b70:	f6c41603          	lh	a2,-148(s0)
    80005b74:	458d                	li	a1,3
    80005b76:	f7040513          	add	a0,s0,-144
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	786080e7          	jalr	1926(ra) # 80005300 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b82:	cd11                	beqz	a0,80005b9e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	0b6080e7          	jalr	182(ra) # 80003c3a <iunlockput>
  end_op();
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	86c080e7          	jalr	-1940(ra) # 800043f8 <end_op>
  return 0;
    80005b94:	4501                	li	a0,0
}
    80005b96:	60ea                	ld	ra,152(sp)
    80005b98:	644a                	ld	s0,144(sp)
    80005b9a:	610d                	add	sp,sp,160
    80005b9c:	8082                	ret
    end_op();
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	85a080e7          	jalr	-1958(ra) # 800043f8 <end_op>
    return -1;
    80005ba6:	557d                	li	a0,-1
    80005ba8:	b7fd                	j	80005b96 <sys_mknod+0x6c>

0000000080005baa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005baa:	7135                	add	sp,sp,-160
    80005bac:	ed06                	sd	ra,152(sp)
    80005bae:	e922                	sd	s0,144(sp)
    80005bb0:	e526                	sd	s1,136(sp)
    80005bb2:	e14a                	sd	s2,128(sp)
    80005bb4:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bb6:	ffffc097          	auipc	ra,0xffffc
    80005bba:	df0080e7          	jalr	-528(ra) # 800019a6 <myproc>
    80005bbe:	892a                	mv	s2,a0
  
  begin_op();
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	7be080e7          	jalr	1982(ra) # 8000437e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bc8:	08000613          	li	a2,128
    80005bcc:	f6040593          	add	a1,s0,-160
    80005bd0:	4501                	li	a0,0
    80005bd2:	ffffd097          	auipc	ra,0xffffd
    80005bd6:	294080e7          	jalr	660(ra) # 80002e66 <argstr>
    80005bda:	04054b63          	bltz	a0,80005c30 <sys_chdir+0x86>
    80005bde:	f6040513          	add	a0,s0,-160
    80005be2:	ffffe097          	auipc	ra,0xffffe
    80005be6:	59c080e7          	jalr	1436(ra) # 8000417e <namei>
    80005bea:	84aa                	mv	s1,a0
    80005bec:	c131                	beqz	a0,80005c30 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	dea080e7          	jalr	-534(ra) # 800039d8 <ilock>
  if(ip->type != T_DIR){
    80005bf6:	04449703          	lh	a4,68(s1)
    80005bfa:	4785                	li	a5,1
    80005bfc:	04f71063          	bne	a4,a5,80005c3c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	e98080e7          	jalr	-360(ra) # 80003a9a <iunlock>
  iput(p->cwd);
    80005c0a:	15093503          	ld	a0,336(s2)
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	f84080e7          	jalr	-124(ra) # 80003b92 <iput>
  end_op();
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	7e2080e7          	jalr	2018(ra) # 800043f8 <end_op>
  p->cwd = ip;
    80005c1e:	14993823          	sd	s1,336(s2)
  return 0;
    80005c22:	4501                	li	a0,0
}
    80005c24:	60ea                	ld	ra,152(sp)
    80005c26:	644a                	ld	s0,144(sp)
    80005c28:	64aa                	ld	s1,136(sp)
    80005c2a:	690a                	ld	s2,128(sp)
    80005c2c:	610d                	add	sp,sp,160
    80005c2e:	8082                	ret
    end_op();
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	7c8080e7          	jalr	1992(ra) # 800043f8 <end_op>
    return -1;
    80005c38:	557d                	li	a0,-1
    80005c3a:	b7ed                	j	80005c24 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c3c:	8526                	mv	a0,s1
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	ffc080e7          	jalr	-4(ra) # 80003c3a <iunlockput>
    end_op();
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	7b2080e7          	jalr	1970(ra) # 800043f8 <end_op>
    return -1;
    80005c4e:	557d                	li	a0,-1
    80005c50:	bfd1                	j	80005c24 <sys_chdir+0x7a>

0000000080005c52 <sys_exec>:

uint64
sys_exec(void)
{
    80005c52:	7121                	add	sp,sp,-448
    80005c54:	ff06                	sd	ra,440(sp)
    80005c56:	fb22                	sd	s0,432(sp)
    80005c58:	f726                	sd	s1,424(sp)
    80005c5a:	f34a                	sd	s2,416(sp)
    80005c5c:	ef4e                	sd	s3,408(sp)
    80005c5e:	eb52                	sd	s4,400(sp)
    80005c60:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c62:	e4840593          	add	a1,s0,-440
    80005c66:	4505                	li	a0,1
    80005c68:	ffffd097          	auipc	ra,0xffffd
    80005c6c:	1de080e7          	jalr	478(ra) # 80002e46 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c70:	08000613          	li	a2,128
    80005c74:	f5040593          	add	a1,s0,-176
    80005c78:	4501                	li	a0,0
    80005c7a:	ffffd097          	auipc	ra,0xffffd
    80005c7e:	1ec080e7          	jalr	492(ra) # 80002e66 <argstr>
    80005c82:	87aa                	mv	a5,a0
    return -1;
    80005c84:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c86:	0c07c263          	bltz	a5,80005d4a <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005c8a:	10000613          	li	a2,256
    80005c8e:	4581                	li	a1,0
    80005c90:	e5040513          	add	a0,s0,-432
    80005c94:	ffffb097          	auipc	ra,0xffffb
    80005c98:	03a080e7          	jalr	58(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c9c:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005ca0:	89a6                	mv	s3,s1
    80005ca2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ca4:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ca8:	00391513          	sll	a0,s2,0x3
    80005cac:	e4040593          	add	a1,s0,-448
    80005cb0:	e4843783          	ld	a5,-440(s0)
    80005cb4:	953e                	add	a0,a0,a5
    80005cb6:	ffffd097          	auipc	ra,0xffffd
    80005cba:	0d2080e7          	jalr	210(ra) # 80002d88 <fetchaddr>
    80005cbe:	02054a63          	bltz	a0,80005cf2 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005cc2:	e4043783          	ld	a5,-448(s0)
    80005cc6:	c3b9                	beqz	a5,80005d0c <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cc8:	ffffb097          	auipc	ra,0xffffb
    80005ccc:	e1a080e7          	jalr	-486(ra) # 80000ae2 <kalloc>
    80005cd0:	85aa                	mv	a1,a0
    80005cd2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cd6:	cd11                	beqz	a0,80005cf2 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cd8:	6605                	lui	a2,0x1
    80005cda:	e4043503          	ld	a0,-448(s0)
    80005cde:	ffffd097          	auipc	ra,0xffffd
    80005ce2:	0fc080e7          	jalr	252(ra) # 80002dda <fetchstr>
    80005ce6:	00054663          	bltz	a0,80005cf2 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005cea:	0905                	add	s2,s2,1
    80005cec:	09a1                	add	s3,s3,8
    80005cee:	fb491de3          	bne	s2,s4,80005ca8 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cf2:	f5040913          	add	s2,s0,-176
    80005cf6:	6088                	ld	a0,0(s1)
    80005cf8:	c921                	beqz	a0,80005d48 <sys_exec+0xf6>
    kfree(argv[i]);
    80005cfa:	ffffb097          	auipc	ra,0xffffb
    80005cfe:	cea080e7          	jalr	-790(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d02:	04a1                	add	s1,s1,8
    80005d04:	ff2499e3          	bne	s1,s2,80005cf6 <sys_exec+0xa4>
  return -1;
    80005d08:	557d                	li	a0,-1
    80005d0a:	a081                	j	80005d4a <sys_exec+0xf8>
      argv[i] = 0;
    80005d0c:	0009079b          	sext.w	a5,s2
    80005d10:	078e                	sll	a5,a5,0x3
    80005d12:	fd078793          	add	a5,a5,-48
    80005d16:	97a2                	add	a5,a5,s0
    80005d18:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005d1c:	e5040593          	add	a1,s0,-432
    80005d20:	f5040513          	add	a0,s0,-176
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	194080e7          	jalr	404(ra) # 80004eb8 <exec>
    80005d2c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d2e:	f5040993          	add	s3,s0,-176
    80005d32:	6088                	ld	a0,0(s1)
    80005d34:	c901                	beqz	a0,80005d44 <sys_exec+0xf2>
    kfree(argv[i]);
    80005d36:	ffffb097          	auipc	ra,0xffffb
    80005d3a:	cae080e7          	jalr	-850(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d3e:	04a1                	add	s1,s1,8
    80005d40:	ff3499e3          	bne	s1,s3,80005d32 <sys_exec+0xe0>
  return ret;
    80005d44:	854a                	mv	a0,s2
    80005d46:	a011                	j	80005d4a <sys_exec+0xf8>
  return -1;
    80005d48:	557d                	li	a0,-1
}
    80005d4a:	70fa                	ld	ra,440(sp)
    80005d4c:	745a                	ld	s0,432(sp)
    80005d4e:	74ba                	ld	s1,424(sp)
    80005d50:	791a                	ld	s2,416(sp)
    80005d52:	69fa                	ld	s3,408(sp)
    80005d54:	6a5a                	ld	s4,400(sp)
    80005d56:	6139                	add	sp,sp,448
    80005d58:	8082                	ret

0000000080005d5a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d5a:	7139                	add	sp,sp,-64
    80005d5c:	fc06                	sd	ra,56(sp)
    80005d5e:	f822                	sd	s0,48(sp)
    80005d60:	f426                	sd	s1,40(sp)
    80005d62:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d64:	ffffc097          	auipc	ra,0xffffc
    80005d68:	c42080e7          	jalr	-958(ra) # 800019a6 <myproc>
    80005d6c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d6e:	fd840593          	add	a1,s0,-40
    80005d72:	4501                	li	a0,0
    80005d74:	ffffd097          	auipc	ra,0xffffd
    80005d78:	0d2080e7          	jalr	210(ra) # 80002e46 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d7c:	fc840593          	add	a1,s0,-56
    80005d80:	fd040513          	add	a0,s0,-48
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	dea080e7          	jalr	-534(ra) # 80004b6e <pipealloc>
    return -1;
    80005d8c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d8e:	0c054463          	bltz	a0,80005e56 <sys_pipe+0xfc>
  fd0 = -1;
    80005d92:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d96:	fd043503          	ld	a0,-48(s0)
    80005d9a:	fffff097          	auipc	ra,0xfffff
    80005d9e:	524080e7          	jalr	1316(ra) # 800052be <fdalloc>
    80005da2:	fca42223          	sw	a0,-60(s0)
    80005da6:	08054b63          	bltz	a0,80005e3c <sys_pipe+0xe2>
    80005daa:	fc843503          	ld	a0,-56(s0)
    80005dae:	fffff097          	auipc	ra,0xfffff
    80005db2:	510080e7          	jalr	1296(ra) # 800052be <fdalloc>
    80005db6:	fca42023          	sw	a0,-64(s0)
    80005dba:	06054863          	bltz	a0,80005e2a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dbe:	4691                	li	a3,4
    80005dc0:	fc440613          	add	a2,s0,-60
    80005dc4:	fd843583          	ld	a1,-40(s0)
    80005dc8:	68a8                	ld	a0,80(s1)
    80005dca:	ffffc097          	auipc	ra,0xffffc
    80005dce:	89c080e7          	jalr	-1892(ra) # 80001666 <copyout>
    80005dd2:	02054063          	bltz	a0,80005df2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dd6:	4691                	li	a3,4
    80005dd8:	fc040613          	add	a2,s0,-64
    80005ddc:	fd843583          	ld	a1,-40(s0)
    80005de0:	0591                	add	a1,a1,4
    80005de2:	68a8                	ld	a0,80(s1)
    80005de4:	ffffc097          	auipc	ra,0xffffc
    80005de8:	882080e7          	jalr	-1918(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005dec:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dee:	06055463          	bgez	a0,80005e56 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005df2:	fc442783          	lw	a5,-60(s0)
    80005df6:	07e9                	add	a5,a5,26
    80005df8:	078e                	sll	a5,a5,0x3
    80005dfa:	97a6                	add	a5,a5,s1
    80005dfc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e00:	fc042783          	lw	a5,-64(s0)
    80005e04:	07e9                	add	a5,a5,26
    80005e06:	078e                	sll	a5,a5,0x3
    80005e08:	94be                	add	s1,s1,a5
    80005e0a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e0e:	fd043503          	ld	a0,-48(s0)
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	a30080e7          	jalr	-1488(ra) # 80004842 <fileclose>
    fileclose(wf);
    80005e1a:	fc843503          	ld	a0,-56(s0)
    80005e1e:	fffff097          	auipc	ra,0xfffff
    80005e22:	a24080e7          	jalr	-1500(ra) # 80004842 <fileclose>
    return -1;
    80005e26:	57fd                	li	a5,-1
    80005e28:	a03d                	j	80005e56 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e2a:	fc442783          	lw	a5,-60(s0)
    80005e2e:	0007c763          	bltz	a5,80005e3c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e32:	07e9                	add	a5,a5,26
    80005e34:	078e                	sll	a5,a5,0x3
    80005e36:	97a6                	add	a5,a5,s1
    80005e38:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e3c:	fd043503          	ld	a0,-48(s0)
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	a02080e7          	jalr	-1534(ra) # 80004842 <fileclose>
    fileclose(wf);
    80005e48:	fc843503          	ld	a0,-56(s0)
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	9f6080e7          	jalr	-1546(ra) # 80004842 <fileclose>
    return -1;
    80005e54:	57fd                	li	a5,-1
}
    80005e56:	853e                	mv	a0,a5
    80005e58:	70e2                	ld	ra,56(sp)
    80005e5a:	7442                	ld	s0,48(sp)
    80005e5c:	74a2                	ld	s1,40(sp)
    80005e5e:	6121                	add	sp,sp,64
    80005e60:	8082                	ret
	...

0000000080005e70 <kernelvec>:
    80005e70:	7111                	add	sp,sp,-256
    80005e72:	e006                	sd	ra,0(sp)
    80005e74:	e40a                	sd	sp,8(sp)
    80005e76:	e80e                	sd	gp,16(sp)
    80005e78:	ec12                	sd	tp,24(sp)
    80005e7a:	f016                	sd	t0,32(sp)
    80005e7c:	f41a                	sd	t1,40(sp)
    80005e7e:	f81e                	sd	t2,48(sp)
    80005e80:	fc22                	sd	s0,56(sp)
    80005e82:	e0a6                	sd	s1,64(sp)
    80005e84:	e4aa                	sd	a0,72(sp)
    80005e86:	e8ae                	sd	a1,80(sp)
    80005e88:	ecb2                	sd	a2,88(sp)
    80005e8a:	f0b6                	sd	a3,96(sp)
    80005e8c:	f4ba                	sd	a4,104(sp)
    80005e8e:	f8be                	sd	a5,112(sp)
    80005e90:	fcc2                	sd	a6,120(sp)
    80005e92:	e146                	sd	a7,128(sp)
    80005e94:	e54a                	sd	s2,136(sp)
    80005e96:	e94e                	sd	s3,144(sp)
    80005e98:	ed52                	sd	s4,152(sp)
    80005e9a:	f156                	sd	s5,160(sp)
    80005e9c:	f55a                	sd	s6,168(sp)
    80005e9e:	f95e                	sd	s7,176(sp)
    80005ea0:	fd62                	sd	s8,184(sp)
    80005ea2:	e1e6                	sd	s9,192(sp)
    80005ea4:	e5ea                	sd	s10,200(sp)
    80005ea6:	e9ee                	sd	s11,208(sp)
    80005ea8:	edf2                	sd	t3,216(sp)
    80005eaa:	f1f6                	sd	t4,224(sp)
    80005eac:	f5fa                	sd	t5,232(sp)
    80005eae:	f9fe                	sd	t6,240(sp)
    80005eb0:	da5fc0ef          	jal	80002c54 <kerneltrap>
    80005eb4:	6082                	ld	ra,0(sp)
    80005eb6:	6122                	ld	sp,8(sp)
    80005eb8:	61c2                	ld	gp,16(sp)
    80005eba:	7282                	ld	t0,32(sp)
    80005ebc:	7322                	ld	t1,40(sp)
    80005ebe:	73c2                	ld	t2,48(sp)
    80005ec0:	7462                	ld	s0,56(sp)
    80005ec2:	6486                	ld	s1,64(sp)
    80005ec4:	6526                	ld	a0,72(sp)
    80005ec6:	65c6                	ld	a1,80(sp)
    80005ec8:	6666                	ld	a2,88(sp)
    80005eca:	7686                	ld	a3,96(sp)
    80005ecc:	7726                	ld	a4,104(sp)
    80005ece:	77c6                	ld	a5,112(sp)
    80005ed0:	7866                	ld	a6,120(sp)
    80005ed2:	688a                	ld	a7,128(sp)
    80005ed4:	692a                	ld	s2,136(sp)
    80005ed6:	69ca                	ld	s3,144(sp)
    80005ed8:	6a6a                	ld	s4,152(sp)
    80005eda:	7a8a                	ld	s5,160(sp)
    80005edc:	7b2a                	ld	s6,168(sp)
    80005ede:	7bca                	ld	s7,176(sp)
    80005ee0:	7c6a                	ld	s8,184(sp)
    80005ee2:	6c8e                	ld	s9,192(sp)
    80005ee4:	6d2e                	ld	s10,200(sp)
    80005ee6:	6dce                	ld	s11,208(sp)
    80005ee8:	6e6e                	ld	t3,216(sp)
    80005eea:	7e8e                	ld	t4,224(sp)
    80005eec:	7f2e                	ld	t5,232(sp)
    80005eee:	7fce                	ld	t6,240(sp)
    80005ef0:	6111                	add	sp,sp,256
    80005ef2:	10200073          	sret
    80005ef6:	00000013          	nop
    80005efa:	00000013          	nop
    80005efe:	0001                	nop

0000000080005f00 <timervec>:
    80005f00:	34051573          	csrrw	a0,mscratch,a0
    80005f04:	e10c                	sd	a1,0(a0)
    80005f06:	e510                	sd	a2,8(a0)
    80005f08:	e914                	sd	a3,16(a0)
    80005f0a:	6d0c                	ld	a1,24(a0)
    80005f0c:	7110                	ld	a2,32(a0)
    80005f0e:	6194                	ld	a3,0(a1)
    80005f10:	96b2                	add	a3,a3,a2
    80005f12:	e194                	sd	a3,0(a1)
    80005f14:	4589                	li	a1,2
    80005f16:	14459073          	csrw	sip,a1
    80005f1a:	6914                	ld	a3,16(a0)
    80005f1c:	6510                	ld	a2,8(a0)
    80005f1e:	610c                	ld	a1,0(a0)
    80005f20:	34051573          	csrrw	a0,mscratch,a0
    80005f24:	30200073          	mret
	...

0000000080005f2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f2a:	1141                	add	sp,sp,-16
    80005f2c:	e422                	sd	s0,8(sp)
    80005f2e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f30:	0c0007b7          	lui	a5,0xc000
    80005f34:	4705                	li	a4,1
    80005f36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f38:	c3d8                	sw	a4,4(a5)
}
    80005f3a:	6422                	ld	s0,8(sp)
    80005f3c:	0141                	add	sp,sp,16
    80005f3e:	8082                	ret

0000000080005f40 <plicinithart>:

void
plicinithart(void)
{
    80005f40:	1141                	add	sp,sp,-16
    80005f42:	e406                	sd	ra,8(sp)
    80005f44:	e022                	sd	s0,0(sp)
    80005f46:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	a32080e7          	jalr	-1486(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f50:	0085171b          	sllw	a4,a0,0x8
    80005f54:	0c0027b7          	lui	a5,0xc002
    80005f58:	97ba                	add	a5,a5,a4
    80005f5a:	40200713          	li	a4,1026
    80005f5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f62:	00d5151b          	sllw	a0,a0,0xd
    80005f66:	0c2017b7          	lui	a5,0xc201
    80005f6a:	97aa                	add	a5,a5,a0
    80005f6c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	add	sp,sp,16
    80005f76:	8082                	ret

0000000080005f78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f78:	1141                	add	sp,sp,-16
    80005f7a:	e406                	sd	ra,8(sp)
    80005f7c:	e022                	sd	s0,0(sp)
    80005f7e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	9fa080e7          	jalr	-1542(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f88:	00d5151b          	sllw	a0,a0,0xd
    80005f8c:	0c2017b7          	lui	a5,0xc201
    80005f90:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f92:	43c8                	lw	a0,4(a5)
    80005f94:	60a2                	ld	ra,8(sp)
    80005f96:	6402                	ld	s0,0(sp)
    80005f98:	0141                	add	sp,sp,16
    80005f9a:	8082                	ret

0000000080005f9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f9c:	1101                	add	sp,sp,-32
    80005f9e:	ec06                	sd	ra,24(sp)
    80005fa0:	e822                	sd	s0,16(sp)
    80005fa2:	e426                	sd	s1,8(sp)
    80005fa4:	1000                	add	s0,sp,32
    80005fa6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	9d2080e7          	jalr	-1582(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fb0:	00d5151b          	sllw	a0,a0,0xd
    80005fb4:	0c2017b7          	lui	a5,0xc201
    80005fb8:	97aa                	add	a5,a5,a0
    80005fba:	c3c4                	sw	s1,4(a5)
}
    80005fbc:	60e2                	ld	ra,24(sp)
    80005fbe:	6442                	ld	s0,16(sp)
    80005fc0:	64a2                	ld	s1,8(sp)
    80005fc2:	6105                	add	sp,sp,32
    80005fc4:	8082                	ret

0000000080005fc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fc6:	1141                	add	sp,sp,-16
    80005fc8:	e406                	sd	ra,8(sp)
    80005fca:	e022                	sd	s0,0(sp)
    80005fcc:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005fce:	479d                	li	a5,7
    80005fd0:	04a7cc63          	blt	a5,a0,80006028 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005fd4:	0001c797          	auipc	a5,0x1c
    80005fd8:	41478793          	add	a5,a5,1044 # 800223e8 <disk>
    80005fdc:	97aa                	add	a5,a5,a0
    80005fde:	0187c783          	lbu	a5,24(a5)
    80005fe2:	ebb9                	bnez	a5,80006038 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fe4:	00451693          	sll	a3,a0,0x4
    80005fe8:	0001c797          	auipc	a5,0x1c
    80005fec:	40078793          	add	a5,a5,1024 # 800223e8 <disk>
    80005ff0:	6398                	ld	a4,0(a5)
    80005ff2:	9736                	add	a4,a4,a3
    80005ff4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005ff8:	6398                	ld	a4,0(a5)
    80005ffa:	9736                	add	a4,a4,a3
    80005ffc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006000:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006004:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006008:	97aa                	add	a5,a5,a0
    8000600a:	4705                	li	a4,1
    8000600c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006010:	0001c517          	auipc	a0,0x1c
    80006014:	3f050513          	add	a0,a0,1008 # 80022400 <disk+0x18>
    80006018:	ffffc097          	auipc	ra,0xffffc
    8000601c:	09a080e7          	jalr	154(ra) # 800020b2 <wakeup>
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	add	sp,sp,16
    80006026:	8082                	ret
    panic("free_desc 1");
    80006028:	00003517          	auipc	a0,0x3
    8000602c:	8a050513          	add	a0,a0,-1888 # 800088c8 <syscalls+0x2f8>
    80006030:	ffffa097          	auipc	ra,0xffffa
    80006034:	50c080e7          	jalr	1292(ra) # 8000053c <panic>
    panic("free_desc 2");
    80006038:	00003517          	auipc	a0,0x3
    8000603c:	8a050513          	add	a0,a0,-1888 # 800088d8 <syscalls+0x308>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	4fc080e7          	jalr	1276(ra) # 8000053c <panic>

0000000080006048 <virtio_disk_init>:
{
    80006048:	1101                	add	sp,sp,-32
    8000604a:	ec06                	sd	ra,24(sp)
    8000604c:	e822                	sd	s0,16(sp)
    8000604e:	e426                	sd	s1,8(sp)
    80006050:	e04a                	sd	s2,0(sp)
    80006052:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006054:	00003597          	auipc	a1,0x3
    80006058:	89458593          	add	a1,a1,-1900 # 800088e8 <syscalls+0x318>
    8000605c:	0001c517          	auipc	a0,0x1c
    80006060:	4b450513          	add	a0,a0,1204 # 80022510 <disk+0x128>
    80006064:	ffffb097          	auipc	ra,0xffffb
    80006068:	ade080e7          	jalr	-1314(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000606c:	100017b7          	lui	a5,0x10001
    80006070:	4398                	lw	a4,0(a5)
    80006072:	2701                	sext.w	a4,a4
    80006074:	747277b7          	lui	a5,0x74727
    80006078:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000607c:	14f71b63          	bne	a4,a5,800061d2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006080:	100017b7          	lui	a5,0x10001
    80006084:	43dc                	lw	a5,4(a5)
    80006086:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006088:	4709                	li	a4,2
    8000608a:	14e79463          	bne	a5,a4,800061d2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000608e:	100017b7          	lui	a5,0x10001
    80006092:	479c                	lw	a5,8(a5)
    80006094:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006096:	12e79e63          	bne	a5,a4,800061d2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000609a:	100017b7          	lui	a5,0x10001
    8000609e:	47d8                	lw	a4,12(a5)
    800060a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060a2:	554d47b7          	lui	a5,0x554d4
    800060a6:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060aa:	12f71463          	bne	a4,a5,800061d2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b6:	4705                	li	a4,1
    800060b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ba:	470d                	li	a4,3
    800060bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060be:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060c0:	c7ffe6b7          	lui	a3,0xc7ffe
    800060c4:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc237>
    800060c8:	8f75                	and	a4,a4,a3
    800060ca:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060cc:	472d                	li	a4,11
    800060ce:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060d0:	5bbc                	lw	a5,112(a5)
    800060d2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060d6:	8ba1                	and	a5,a5,8
    800060d8:	10078563          	beqz	a5,800061e2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060dc:	100017b7          	lui	a5,0x10001
    800060e0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060e4:	43fc                	lw	a5,68(a5)
    800060e6:	2781                	sext.w	a5,a5
    800060e8:	10079563          	bnez	a5,800061f2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060ec:	100017b7          	lui	a5,0x10001
    800060f0:	5bdc                	lw	a5,52(a5)
    800060f2:	2781                	sext.w	a5,a5
  if(max == 0)
    800060f4:	10078763          	beqz	a5,80006202 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800060f8:	471d                	li	a4,7
    800060fa:	10f77c63          	bgeu	a4,a5,80006212 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800060fe:	ffffb097          	auipc	ra,0xffffb
    80006102:	9e4080e7          	jalr	-1564(ra) # 80000ae2 <kalloc>
    80006106:	0001c497          	auipc	s1,0x1c
    8000610a:	2e248493          	add	s1,s1,738 # 800223e8 <disk>
    8000610e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006110:	ffffb097          	auipc	ra,0xffffb
    80006114:	9d2080e7          	jalr	-1582(ra) # 80000ae2 <kalloc>
    80006118:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000611a:	ffffb097          	auipc	ra,0xffffb
    8000611e:	9c8080e7          	jalr	-1592(ra) # 80000ae2 <kalloc>
    80006122:	87aa                	mv	a5,a0
    80006124:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006126:	6088                	ld	a0,0(s1)
    80006128:	cd6d                	beqz	a0,80006222 <virtio_disk_init+0x1da>
    8000612a:	0001c717          	auipc	a4,0x1c
    8000612e:	2c673703          	ld	a4,710(a4) # 800223f0 <disk+0x8>
    80006132:	cb65                	beqz	a4,80006222 <virtio_disk_init+0x1da>
    80006134:	c7fd                	beqz	a5,80006222 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006136:	6605                	lui	a2,0x1
    80006138:	4581                	li	a1,0
    8000613a:	ffffb097          	auipc	ra,0xffffb
    8000613e:	b94080e7          	jalr	-1132(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80006142:	0001c497          	auipc	s1,0x1c
    80006146:	2a648493          	add	s1,s1,678 # 800223e8 <disk>
    8000614a:	6605                	lui	a2,0x1
    8000614c:	4581                	li	a1,0
    8000614e:	6488                	ld	a0,8(s1)
    80006150:	ffffb097          	auipc	ra,0xffffb
    80006154:	b7e080e7          	jalr	-1154(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80006158:	6605                	lui	a2,0x1
    8000615a:	4581                	li	a1,0
    8000615c:	6888                	ld	a0,16(s1)
    8000615e:	ffffb097          	auipc	ra,0xffffb
    80006162:	b70080e7          	jalr	-1168(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006166:	100017b7          	lui	a5,0x10001
    8000616a:	4721                	li	a4,8
    8000616c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000616e:	4098                	lw	a4,0(s1)
    80006170:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006174:	40d8                	lw	a4,4(s1)
    80006176:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000617a:	6498                	ld	a4,8(s1)
    8000617c:	0007069b          	sext.w	a3,a4
    80006180:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006184:	9701                	sra	a4,a4,0x20
    80006186:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000618a:	6898                	ld	a4,16(s1)
    8000618c:	0007069b          	sext.w	a3,a4
    80006190:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006194:	9701                	sra	a4,a4,0x20
    80006196:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000619a:	4705                	li	a4,1
    8000619c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000619e:	00e48c23          	sb	a4,24(s1)
    800061a2:	00e48ca3          	sb	a4,25(s1)
    800061a6:	00e48d23          	sb	a4,26(s1)
    800061aa:	00e48da3          	sb	a4,27(s1)
    800061ae:	00e48e23          	sb	a4,28(s1)
    800061b2:	00e48ea3          	sb	a4,29(s1)
    800061b6:	00e48f23          	sb	a4,30(s1)
    800061ba:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061be:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c2:	0727a823          	sw	s2,112(a5)
}
    800061c6:	60e2                	ld	ra,24(sp)
    800061c8:	6442                	ld	s0,16(sp)
    800061ca:	64a2                	ld	s1,8(sp)
    800061cc:	6902                	ld	s2,0(sp)
    800061ce:	6105                	add	sp,sp,32
    800061d0:	8082                	ret
    panic("could not find virtio disk");
    800061d2:	00002517          	auipc	a0,0x2
    800061d6:	72650513          	add	a0,a0,1830 # 800088f8 <syscalls+0x328>
    800061da:	ffffa097          	auipc	ra,0xffffa
    800061de:	362080e7          	jalr	866(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    800061e2:	00002517          	auipc	a0,0x2
    800061e6:	73650513          	add	a0,a0,1846 # 80008918 <syscalls+0x348>
    800061ea:	ffffa097          	auipc	ra,0xffffa
    800061ee:	352080e7          	jalr	850(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800061f2:	00002517          	auipc	a0,0x2
    800061f6:	74650513          	add	a0,a0,1862 # 80008938 <syscalls+0x368>
    800061fa:	ffffa097          	auipc	ra,0xffffa
    800061fe:	342080e7          	jalr	834(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006202:	00002517          	auipc	a0,0x2
    80006206:	75650513          	add	a0,a0,1878 # 80008958 <syscalls+0x388>
    8000620a:	ffffa097          	auipc	ra,0xffffa
    8000620e:	332080e7          	jalr	818(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006212:	00002517          	auipc	a0,0x2
    80006216:	76650513          	add	a0,a0,1894 # 80008978 <syscalls+0x3a8>
    8000621a:	ffffa097          	auipc	ra,0xffffa
    8000621e:	322080e7          	jalr	802(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006222:	00002517          	auipc	a0,0x2
    80006226:	77650513          	add	a0,a0,1910 # 80008998 <syscalls+0x3c8>
    8000622a:	ffffa097          	auipc	ra,0xffffa
    8000622e:	312080e7          	jalr	786(ra) # 8000053c <panic>

0000000080006232 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006232:	7159                	add	sp,sp,-112
    80006234:	f486                	sd	ra,104(sp)
    80006236:	f0a2                	sd	s0,96(sp)
    80006238:	eca6                	sd	s1,88(sp)
    8000623a:	e8ca                	sd	s2,80(sp)
    8000623c:	e4ce                	sd	s3,72(sp)
    8000623e:	e0d2                	sd	s4,64(sp)
    80006240:	fc56                	sd	s5,56(sp)
    80006242:	f85a                	sd	s6,48(sp)
    80006244:	f45e                	sd	s7,40(sp)
    80006246:	f062                	sd	s8,32(sp)
    80006248:	ec66                	sd	s9,24(sp)
    8000624a:	e86a                	sd	s10,16(sp)
    8000624c:	1880                	add	s0,sp,112
    8000624e:	8a2a                	mv	s4,a0
    80006250:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006252:	00c52c83          	lw	s9,12(a0)
    80006256:	001c9c9b          	sllw	s9,s9,0x1
    8000625a:	1c82                	sll	s9,s9,0x20
    8000625c:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006260:	0001c517          	auipc	a0,0x1c
    80006264:	2b050513          	add	a0,a0,688 # 80022510 <disk+0x128>
    80006268:	ffffb097          	auipc	ra,0xffffb
    8000626c:	96a080e7          	jalr	-1686(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006270:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006272:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006274:	0001cb17          	auipc	s6,0x1c
    80006278:	174b0b13          	add	s6,s6,372 # 800223e8 <disk>
  for(int i = 0; i < 3; i++){
    8000627c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000627e:	0001cc17          	auipc	s8,0x1c
    80006282:	292c0c13          	add	s8,s8,658 # 80022510 <disk+0x128>
    80006286:	a095                	j	800062ea <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006288:	00fb0733          	add	a4,s6,a5
    8000628c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006290:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006292:	0207c563          	bltz	a5,800062bc <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006296:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006298:	0591                	add	a1,a1,4
    8000629a:	05560d63          	beq	a2,s5,800062f4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000629e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    800062a0:	0001c717          	auipc	a4,0x1c
    800062a4:	14870713          	add	a4,a4,328 # 800223e8 <disk>
    800062a8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    800062aa:	01874683          	lbu	a3,24(a4)
    800062ae:	fee9                	bnez	a3,80006288 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    800062b0:	2785                	addw	a5,a5,1
    800062b2:	0705                	add	a4,a4,1
    800062b4:	fe979be3          	bne	a5,s1,800062aa <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    800062b8:	57fd                	li	a5,-1
    800062ba:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    800062bc:	00c05e63          	blez	a2,800062d8 <virtio_disk_rw+0xa6>
    800062c0:	060a                	sll	a2,a2,0x2
    800062c2:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    800062c6:	0009a503          	lw	a0,0(s3)
    800062ca:	00000097          	auipc	ra,0x0
    800062ce:	cfc080e7          	jalr	-772(ra) # 80005fc6 <free_desc>
      for(int j = 0; j < i; j++)
    800062d2:	0991                	add	s3,s3,4
    800062d4:	ffa999e3          	bne	s3,s10,800062c6 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062d8:	85e2                	mv	a1,s8
    800062da:	0001c517          	auipc	a0,0x1c
    800062de:	12650513          	add	a0,a0,294 # 80022400 <disk+0x18>
    800062e2:	ffffc097          	auipc	ra,0xffffc
    800062e6:	d6c080e7          	jalr	-660(ra) # 8000204e <sleep>
  for(int i = 0; i < 3; i++){
    800062ea:	f9040993          	add	s3,s0,-112
{
    800062ee:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800062f0:	864a                	mv	a2,s2
    800062f2:	b775                	j	8000629e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062f4:	f9042503          	lw	a0,-112(s0)
    800062f8:	00a50713          	add	a4,a0,10
    800062fc:	0712                	sll	a4,a4,0x4

  if(write)
    800062fe:	0001c797          	auipc	a5,0x1c
    80006302:	0ea78793          	add	a5,a5,234 # 800223e8 <disk>
    80006306:	00e786b3          	add	a3,a5,a4
    8000630a:	01703633          	snez	a2,s7
    8000630e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006310:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006314:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006318:	f6070613          	add	a2,a4,-160
    8000631c:	6394                	ld	a3,0(a5)
    8000631e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006320:	00870593          	add	a1,a4,8
    80006324:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006326:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006328:	0007b803          	ld	a6,0(a5)
    8000632c:	9642                	add	a2,a2,a6
    8000632e:	46c1                	li	a3,16
    80006330:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006332:	4585                	li	a1,1
    80006334:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006338:	f9442683          	lw	a3,-108(s0)
    8000633c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006340:	0692                	sll	a3,a3,0x4
    80006342:	9836                	add	a6,a6,a3
    80006344:	058a0613          	add	a2,s4,88
    80006348:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000634c:	0007b803          	ld	a6,0(a5)
    80006350:	96c2                	add	a3,a3,a6
    80006352:	40000613          	li	a2,1024
    80006356:	c690                	sw	a2,8(a3)
  if(write)
    80006358:	001bb613          	seqz	a2,s7
    8000635c:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006360:	00166613          	or	a2,a2,1
    80006364:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006368:	f9842603          	lw	a2,-104(s0)
    8000636c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006370:	00250693          	add	a3,a0,2
    80006374:	0692                	sll	a3,a3,0x4
    80006376:	96be                	add	a3,a3,a5
    80006378:	58fd                	li	a7,-1
    8000637a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000637e:	0612                	sll	a2,a2,0x4
    80006380:	9832                	add	a6,a6,a2
    80006382:	f9070713          	add	a4,a4,-112
    80006386:	973e                	add	a4,a4,a5
    80006388:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000638c:	6398                	ld	a4,0(a5)
    8000638e:	9732                	add	a4,a4,a2
    80006390:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006392:	4609                	li	a2,2
    80006394:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006398:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000639c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    800063a0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063a4:	6794                	ld	a3,8(a5)
    800063a6:	0026d703          	lhu	a4,2(a3)
    800063aa:	8b1d                	and	a4,a4,7
    800063ac:	0706                	sll	a4,a4,0x1
    800063ae:	96ba                	add	a3,a3,a4
    800063b0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800063b4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063b8:	6798                	ld	a4,8(a5)
    800063ba:	00275783          	lhu	a5,2(a4)
    800063be:	2785                	addw	a5,a5,1
    800063c0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063c4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063c8:	100017b7          	lui	a5,0x10001
    800063cc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063d0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800063d4:	0001c917          	auipc	s2,0x1c
    800063d8:	13c90913          	add	s2,s2,316 # 80022510 <disk+0x128>
  while(b->disk == 1) {
    800063dc:	4485                	li	s1,1
    800063de:	00b79c63          	bne	a5,a1,800063f6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800063e2:	85ca                	mv	a1,s2
    800063e4:	8552                	mv	a0,s4
    800063e6:	ffffc097          	auipc	ra,0xffffc
    800063ea:	c68080e7          	jalr	-920(ra) # 8000204e <sleep>
  while(b->disk == 1) {
    800063ee:	004a2783          	lw	a5,4(s4)
    800063f2:	fe9788e3          	beq	a5,s1,800063e2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063f6:	f9042903          	lw	s2,-112(s0)
    800063fa:	00290713          	add	a4,s2,2
    800063fe:	0712                	sll	a4,a4,0x4
    80006400:	0001c797          	auipc	a5,0x1c
    80006404:	fe878793          	add	a5,a5,-24 # 800223e8 <disk>
    80006408:	97ba                	add	a5,a5,a4
    8000640a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000640e:	0001c997          	auipc	s3,0x1c
    80006412:	fda98993          	add	s3,s3,-38 # 800223e8 <disk>
    80006416:	00491713          	sll	a4,s2,0x4
    8000641a:	0009b783          	ld	a5,0(s3)
    8000641e:	97ba                	add	a5,a5,a4
    80006420:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006424:	854a                	mv	a0,s2
    80006426:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000642a:	00000097          	auipc	ra,0x0
    8000642e:	b9c080e7          	jalr	-1124(ra) # 80005fc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006432:	8885                	and	s1,s1,1
    80006434:	f0ed                	bnez	s1,80006416 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006436:	0001c517          	auipc	a0,0x1c
    8000643a:	0da50513          	add	a0,a0,218 # 80022510 <disk+0x128>
    8000643e:	ffffb097          	auipc	ra,0xffffb
    80006442:	848080e7          	jalr	-1976(ra) # 80000c86 <release>
}
    80006446:	70a6                	ld	ra,104(sp)
    80006448:	7406                	ld	s0,96(sp)
    8000644a:	64e6                	ld	s1,88(sp)
    8000644c:	6946                	ld	s2,80(sp)
    8000644e:	69a6                	ld	s3,72(sp)
    80006450:	6a06                	ld	s4,64(sp)
    80006452:	7ae2                	ld	s5,56(sp)
    80006454:	7b42                	ld	s6,48(sp)
    80006456:	7ba2                	ld	s7,40(sp)
    80006458:	7c02                	ld	s8,32(sp)
    8000645a:	6ce2                	ld	s9,24(sp)
    8000645c:	6d42                	ld	s10,16(sp)
    8000645e:	6165                	add	sp,sp,112
    80006460:	8082                	ret

0000000080006462 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006462:	1101                	add	sp,sp,-32
    80006464:	ec06                	sd	ra,24(sp)
    80006466:	e822                	sd	s0,16(sp)
    80006468:	e426                	sd	s1,8(sp)
    8000646a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000646c:	0001c497          	auipc	s1,0x1c
    80006470:	f7c48493          	add	s1,s1,-132 # 800223e8 <disk>
    80006474:	0001c517          	auipc	a0,0x1c
    80006478:	09c50513          	add	a0,a0,156 # 80022510 <disk+0x128>
    8000647c:	ffffa097          	auipc	ra,0xffffa
    80006480:	756080e7          	jalr	1878(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006484:	10001737          	lui	a4,0x10001
    80006488:	533c                	lw	a5,96(a4)
    8000648a:	8b8d                	and	a5,a5,3
    8000648c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000648e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006492:	689c                	ld	a5,16(s1)
    80006494:	0204d703          	lhu	a4,32(s1)
    80006498:	0027d783          	lhu	a5,2(a5)
    8000649c:	04f70863          	beq	a4,a5,800064ec <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800064a0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064a4:	6898                	ld	a4,16(s1)
    800064a6:	0204d783          	lhu	a5,32(s1)
    800064aa:	8b9d                	and	a5,a5,7
    800064ac:	078e                	sll	a5,a5,0x3
    800064ae:	97ba                	add	a5,a5,a4
    800064b0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064b2:	00278713          	add	a4,a5,2
    800064b6:	0712                	sll	a4,a4,0x4
    800064b8:	9726                	add	a4,a4,s1
    800064ba:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800064be:	e721                	bnez	a4,80006506 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064c0:	0789                	add	a5,a5,2
    800064c2:	0792                	sll	a5,a5,0x4
    800064c4:	97a6                	add	a5,a5,s1
    800064c6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064cc:	ffffc097          	auipc	ra,0xffffc
    800064d0:	be6080e7          	jalr	-1050(ra) # 800020b2 <wakeup>

    disk.used_idx += 1;
    800064d4:	0204d783          	lhu	a5,32(s1)
    800064d8:	2785                	addw	a5,a5,1
    800064da:	17c2                	sll	a5,a5,0x30
    800064dc:	93c1                	srl	a5,a5,0x30
    800064de:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064e2:	6898                	ld	a4,16(s1)
    800064e4:	00275703          	lhu	a4,2(a4)
    800064e8:	faf71ce3          	bne	a4,a5,800064a0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064ec:	0001c517          	auipc	a0,0x1c
    800064f0:	02450513          	add	a0,a0,36 # 80022510 <disk+0x128>
    800064f4:	ffffa097          	auipc	ra,0xffffa
    800064f8:	792080e7          	jalr	1938(ra) # 80000c86 <release>
}
    800064fc:	60e2                	ld	ra,24(sp)
    800064fe:	6442                	ld	s0,16(sp)
    80006500:	64a2                	ld	s1,8(sp)
    80006502:	6105                	add	sp,sp,32
    80006504:	8082                	ret
      panic("virtio_disk_intr status");
    80006506:	00002517          	auipc	a0,0x2
    8000650a:	4aa50513          	add	a0,a0,1194 # 800089b0 <syscalls+0x3e0>
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	02e080e7          	jalr	46(ra) # 8000053c <panic>
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
