
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 61 00 00 00       	call   f010009f <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100047:	83 3d 00 10 21 f0 00 	cmpl   $0x0,0xf0211000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 2b 09 00 00       	call   f0100985 <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 10 21 f0       	mov    %eax,0xf0211000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 eb 55 00 00       	call   f010565c <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 a0 5c 10 f0       	push   $0xf0105ca0
f010007d:	e8 94 39 00 00       	call   f0103a16 <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 62 39 00 00       	call   f01039f0 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 cf 70 10 f0 	movl   $0xf01070cf,(%esp)
f0100095:	e8 7c 39 00 00       	call   f0103a16 <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 9c 05 00 00       	call   f0100647 <cons_init>
	cprintf("444544 decimal is %o octal!\n", 444544);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 80 c8 06 00       	push   $0x6c880
f01000b3:	68 0c 5d 10 f0       	push   $0xf0105d0c
f01000b8:	e8 59 39 00 00       	call   f0103a16 <cprintf>
	mem_init();
f01000bd:	e8 fb 12 00 00       	call   f01013bd <mem_init>
	env_init();
f01000c2:	e8 43 31 00 00       	call   f010320a <env_init>
	trap_init();
f01000c7:	e8 f5 39 00 00       	call   f0103ac1 <trap_init>
	mp_init();
f01000cc:	e8 a5 52 00 00       	call   f0105376 <mp_init>
	lapic_init();
f01000d1:	e8 9c 55 00 00       	call   f0105672 <lapic_init>
	pic_init();
f01000d6:	e8 5c 38 00 00       	call   f0103937 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000db:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f01000e2:	e8 e5 57 00 00       	call   f01058cc <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e7:	83 c4 10             	add    $0x10,%esp
f01000ea:	83 3d 60 12 21 f0 07 	cmpl   $0x7,0xf0211260
f01000f1:	76 27                	jbe    f010011a <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 d2 52 10 f0       	mov    $0xf01052d2,%eax
f01000fb:	2d 58 52 10 f0       	sub    $0xf0105258,%eax
f0100100:	50                   	push   %eax
f0100101:	68 58 52 10 f0       	push   $0xf0105258
f0100106:	68 00 70 00 f0       	push   $0xf0007000
f010010b:	e8 9e 4f 00 00       	call   f01050ae <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	83 c4 10             	add    $0x10,%esp
f0100113:	bb 20 20 25 f0       	mov    $0xf0252020,%ebx
f0100118:	eb 19                	jmp    f0100133 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011a:	68 00 70 00 00       	push   $0x7000
f010011f:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0100124:	6a 4f                	push   $0x4f
f0100126:	68 29 5d 10 f0       	push   $0xf0105d29
f010012b:	e8 10 ff ff ff       	call   f0100040 <_panic>
f0100130:	83 c3 74             	add    $0x74,%ebx
f0100133:	6b 05 00 20 25 f0 74 	imul   $0x74,0xf0252000,%eax
f010013a:	05 20 20 25 f0       	add    $0xf0252020,%eax
f010013f:	39 c3                	cmp    %eax,%ebx
f0100141:	73 4d                	jae    f0100190 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100143:	e8 14 55 00 00       	call   f010565c <cpunum>
f0100148:	6b c0 74             	imul   $0x74,%eax,%eax
f010014b:	05 20 20 25 f0       	add    $0xf0252020,%eax
f0100150:	39 c3                	cmp    %eax,%ebx
f0100152:	74 dc                	je     f0100130 <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100154:	89 d8                	mov    %ebx,%eax
f0100156:	2d 20 20 25 f0       	sub    $0xf0252020,%eax
f010015b:	c1 f8 02             	sar    $0x2,%eax
f010015e:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100164:	c1 e0 0f             	shl    $0xf,%eax
f0100167:	8d 80 00 a0 21 f0    	lea    -0xfde6000(%eax),%eax
f010016d:	a3 04 10 21 f0       	mov    %eax,0xf0211004
		lapic_startap(c->cpu_id, PADDR(code));
f0100172:	83 ec 08             	sub    $0x8,%esp
f0100175:	68 00 70 00 00       	push   $0x7000
f010017a:	0f b6 03             	movzbl (%ebx),%eax
f010017d:	50                   	push   %eax
f010017e:	e8 41 56 00 00       	call   f01057c4 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100183:	83 c4 10             	add    $0x10,%esp
f0100186:	8b 43 04             	mov    0x4(%ebx),%eax
f0100189:	83 f8 01             	cmp    $0x1,%eax
f010018c:	75 f8                	jne    f0100186 <i386_init+0xe7>
f010018e:	eb a0                	jmp    f0100130 <i386_init+0x91>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100190:	83 ec 08             	sub    $0x8,%esp
f0100193:	6a 00                	push   $0x0
f0100195:	68 0c cc 18 f0       	push   $0xf018cc0c
f010019a:	e8 45 32 00 00       	call   f01033e4 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010019f:	83 c4 08             	add    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 0c cc 18 f0       	push   $0xf018cc0c
f01001a9:	e8 36 32 00 00       	call   f01033e4 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 0c cc 18 f0       	push   $0xf018cc0c
f01001b8:	e8 27 32 00 00       	call   f01033e4 <env_create>
	sched_yield();
f01001bd:	e8 fd 41 00 00       	call   f01043bf <sched_yield>

f01001c2 <mp_main>:
{
f01001c2:	55                   	push   %ebp
f01001c3:	89 e5                	mov    %esp,%ebp
f01001c5:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001c8:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d2:	76 52                	jbe    f0100226 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001d4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001dc:	e8 7b 54 00 00       	call   f010565c <cpunum>
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	50                   	push   %eax
f01001e5:	68 35 5d 10 f0       	push   $0xf0105d35
f01001ea:	e8 27 38 00 00       	call   f0103a16 <cprintf>
	lapic_init();
f01001ef:	e8 7e 54 00 00       	call   f0105672 <lapic_init>
	env_init_percpu();
f01001f4:	e8 e5 2f 00 00       	call   f01031de <env_init_percpu>
	trap_init_percpu();
f01001f9:	e8 2c 38 00 00       	call   f0103a2a <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fe:	e8 59 54 00 00       	call   f010565c <cpunum>
f0100203:	6b d0 74             	imul   $0x74,%eax,%edx
f0100206:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100209:	b8 01 00 00 00       	mov    $0x1,%eax
f010020e:	f0 87 82 20 20 25 f0 	lock xchg %eax,-0xfdadfe0(%edx)
f0100215:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010021c:	e8 ab 56 00 00       	call   f01058cc <spin_lock>
	sched_yield();
f0100221:	e8 99 41 00 00       	call   f01043bf <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100226:	50                   	push   %eax
f0100227:	68 e8 5c 10 f0       	push   $0xf0105ce8
f010022c:	6a 66                	push   $0x66
f010022e:	68 29 5d 10 f0       	push   $0xf0105d29
f0100233:	e8 08 fe ff ff       	call   f0100040 <_panic>

f0100238 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100238:	55                   	push   %ebp
f0100239:	89 e5                	mov    %esp,%ebp
f010023b:	53                   	push   %ebx
f010023c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010023f:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100242:	ff 75 0c             	push   0xc(%ebp)
f0100245:	ff 75 08             	push   0x8(%ebp)
f0100248:	68 4b 5d 10 f0       	push   $0xf0105d4b
f010024d:	e8 c4 37 00 00       	call   f0103a16 <cprintf>
	vcprintf(fmt, ap);
f0100252:	83 c4 08             	add    $0x8,%esp
f0100255:	53                   	push   %ebx
f0100256:	ff 75 10             	push   0x10(%ebp)
f0100259:	e8 92 37 00 00       	call   f01039f0 <vcprintf>
	cprintf("\n");
f010025e:	c7 04 24 cf 70 10 f0 	movl   $0xf01070cf,(%esp)
f0100265:	e8 ac 37 00 00       	call   f0103a16 <cprintf>
	va_end(ap);
}
f010026a:	83 c4 10             	add    $0x10,%esp
f010026d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100270:	c9                   	leave  
f0100271:	c3                   	ret    

f0100272 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100272:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100277:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100278:	a8 01                	test   $0x1,%al
f010027a:	74 0a                	je     f0100286 <serial_proc_data+0x14>
f010027c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100281:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100282:	0f b6 c0             	movzbl %al,%eax
f0100285:	c3                   	ret    
		return -1;
f0100286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010028b:	c3                   	ret    

f010028c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010028c:	55                   	push   %ebp
f010028d:	89 e5                	mov    %esp,%ebp
f010028f:	53                   	push   %ebx
f0100290:	83 ec 04             	sub    $0x4,%esp
f0100293:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100295:	eb 23                	jmp    f01002ba <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100297:	8b 0d 44 12 21 f0    	mov    0xf0211244,%ecx
f010029d:	8d 51 01             	lea    0x1(%ecx),%edx
f01002a0:	88 81 40 10 21 f0    	mov    %al,-0xfdeefc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01002b1:	0f 44 d0             	cmove  %eax,%edx
f01002b4:	89 15 44 12 21 f0    	mov    %edx,0xf0211244
	while ((c = (*proc)()) != -1) {
f01002ba:	ff d3                	call   *%ebx
f01002bc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bf:	74 06                	je     f01002c7 <cons_intr+0x3b>
		if (c == 0)
f01002c1:	85 c0                	test   %eax,%eax
f01002c3:	75 d2                	jne    f0100297 <cons_intr+0xb>
f01002c5:	eb f3                	jmp    f01002ba <cons_intr+0x2e>
	}
}
f01002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ca:	c9                   	leave  
f01002cb:	c3                   	ret    

f01002cc <kbd_proc_data>:
{
f01002cc:	55                   	push   %ebp
f01002cd:	89 e5                	mov    %esp,%ebp
f01002cf:	53                   	push   %ebx
f01002d0:	83 ec 04             	sub    $0x4,%esp
f01002d3:	ba 64 00 00 00       	mov    $0x64,%edx
f01002d8:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002d9:	a8 01                	test   $0x1,%al
f01002db:	0f 84 ee 00 00 00    	je     f01003cf <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002e1:	a8 20                	test   $0x20,%al
f01002e3:	0f 85 ed 00 00 00    	jne    f01003d6 <kbd_proc_data+0x10a>
f01002e9:	ba 60 00 00 00       	mov    $0x60,%edx
f01002ee:	ec                   	in     (%dx),%al
f01002ef:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002f1:	3c e0                	cmp    $0xe0,%al
f01002f3:	74 61                	je     f0100356 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01002f5:	84 c0                	test   %al,%al
f01002f7:	78 70                	js     f0100369 <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01002f9:	8b 0d 20 10 21 f0    	mov    0xf0211020,%ecx
f01002ff:	f6 c1 40             	test   $0x40,%cl
f0100302:	74 0e                	je     f0100312 <kbd_proc_data+0x46>
		data |= 0x80;
f0100304:	83 c8 80             	or     $0xffffff80,%eax
f0100307:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100309:	83 e1 bf             	and    $0xffffffbf,%ecx
f010030c:	89 0d 20 10 21 f0    	mov    %ecx,0xf0211020
	shift |= shiftcode[data];
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 82 c0 5e 10 f0 	movzbl -0xfefa140(%edx),%eax
f010031c:	0b 05 20 10 21 f0    	or     0xf0211020,%eax
	shift ^= togglecode[data];
f0100322:	0f b6 8a c0 5d 10 f0 	movzbl -0xfefa240(%edx),%ecx
f0100329:	31 c8                	xor    %ecx,%eax
f010032b:	a3 20 10 21 f0       	mov    %eax,0xf0211020
	c = charcode[shift & (CTL | SHIFT)][data];
f0100330:	89 c1                	mov    %eax,%ecx
f0100332:	83 e1 03             	and    $0x3,%ecx
f0100335:	8b 0c 8d a0 5d 10 f0 	mov    -0xfefa260(,%ecx,4),%ecx
f010033c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100340:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100343:	a8 08                	test   $0x8,%al
f0100345:	74 5d                	je     f01003a4 <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f0100347:	89 da                	mov    %ebx,%edx
f0100349:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010034c:	83 f9 19             	cmp    $0x19,%ecx
f010034f:	77 47                	ja     f0100398 <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100351:	83 eb 20             	sub    $0x20,%ebx
f0100354:	eb 0c                	jmp    f0100362 <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100356:	83 0d 20 10 21 f0 40 	orl    $0x40,0xf0211020
		return 0;
f010035d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100362:	89 d8                	mov    %ebx,%eax
f0100364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100367:	c9                   	leave  
f0100368:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100369:	8b 0d 20 10 21 f0    	mov    0xf0211020,%ecx
f010036f:	83 e0 7f             	and    $0x7f,%eax
f0100372:	f6 c1 40             	test   $0x40,%cl
f0100375:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100378:	0f b6 d2             	movzbl %dl,%edx
f010037b:	0f b6 82 c0 5e 10 f0 	movzbl -0xfefa140(%edx),%eax
f0100382:	83 c8 40             	or     $0x40,%eax
f0100385:	0f b6 c0             	movzbl %al,%eax
f0100388:	f7 d0                	not    %eax
f010038a:	21 c8                	and    %ecx,%eax
f010038c:	a3 20 10 21 f0       	mov    %eax,0xf0211020
		return 0;
f0100391:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100396:	eb ca                	jmp    f0100362 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f0100398:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010039b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010039e:	83 fa 1a             	cmp    $0x1a,%edx
f01003a1:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003a4:	f7 d0                	not    %eax
f01003a6:	a8 06                	test   $0x6,%al
f01003a8:	75 b8                	jne    f0100362 <kbd_proc_data+0x96>
f01003aa:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003b0:	75 b0                	jne    f0100362 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f01003b2:	83 ec 0c             	sub    $0xc,%esp
f01003b5:	68 65 5d 10 f0       	push   $0xf0105d65
f01003ba:	e8 57 36 00 00       	call   f0103a16 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003bf:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c4:	ba 92 00 00 00       	mov    $0x92,%edx
f01003c9:	ee                   	out    %al,(%dx)
}
f01003ca:	83 c4 10             	add    $0x10,%esp
f01003cd:	eb 93                	jmp    f0100362 <kbd_proc_data+0x96>
		return -1;
f01003cf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003d4:	eb 8c                	jmp    f0100362 <kbd_proc_data+0x96>
		return -1;
f01003d6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003db:	eb 85                	jmp    f0100362 <kbd_proc_data+0x96>

f01003dd <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003dd:	55                   	push   %ebp
f01003de:	89 e5                	mov    %esp,%ebp
f01003e0:	57                   	push   %edi
f01003e1:	56                   	push   %esi
f01003e2:	53                   	push   %ebx
f01003e3:	83 ec 1c             	sub    $0x1c,%esp
f01003e6:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ed:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f7:	89 f2                	mov    %esi,%edx
f01003f9:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003fa:	a8 20                	test   $0x20,%al
f01003fc:	75 13                	jne    f0100411 <cons_putc+0x34>
f01003fe:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100404:	7f 0b                	jg     f0100411 <cons_putc+0x34>
f0100406:	89 ca                	mov    %ecx,%edx
f0100408:	ec                   	in     (%dx),%al
f0100409:	ec                   	in     (%dx),%al
f010040a:	ec                   	in     (%dx),%al
f010040b:	ec                   	in     (%dx),%al
	     i++)
f010040c:	83 c3 01             	add    $0x1,%ebx
f010040f:	eb e6                	jmp    f01003f7 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100411:	89 f8                	mov    %edi,%eax
f0100413:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100416:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010041b:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041c:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100421:	be 79 03 00 00       	mov    $0x379,%esi
f0100426:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ec                   	in     (%dx),%al
f010042e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100434:	7f 0f                	jg     f0100445 <cons_putc+0x68>
f0100436:	84 c0                	test   %al,%al
f0100438:	78 0b                	js     f0100445 <cons_putc+0x68>
f010043a:	89 ca                	mov    %ecx,%edx
f010043c:	ec                   	in     (%dx),%al
f010043d:	ec                   	in     (%dx),%al
f010043e:	ec                   	in     (%dx),%al
f010043f:	ec                   	in     (%dx),%al
f0100440:	83 c3 01             	add    $0x1,%ebx
f0100443:	eb e6                	jmp    f010042b <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100445:	ba 78 03 00 00       	mov    $0x378,%edx
f010044a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044e:	ee                   	out    %al,(%dx)
f010044f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100454:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100459:	ee                   	out    %al,(%dx)
f010045a:	b8 08 00 00 00       	mov    $0x8,%eax
f010045f:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100460:	89 f8                	mov    %edi,%eax
f0100462:	80 cc 07             	or     $0x7,%ah
f0100465:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010046b:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010046e:	89 f8                	mov    %edi,%eax
f0100470:	0f b6 c0             	movzbl %al,%eax
f0100473:	89 fb                	mov    %edi,%ebx
f0100475:	80 fb 0a             	cmp    $0xa,%bl
f0100478:	0f 84 e1 00 00 00    	je     f010055f <cons_putc+0x182>
f010047e:	83 f8 0a             	cmp    $0xa,%eax
f0100481:	7f 46                	jg     f01004c9 <cons_putc+0xec>
f0100483:	83 f8 08             	cmp    $0x8,%eax
f0100486:	0f 84 a7 00 00 00    	je     f0100533 <cons_putc+0x156>
f010048c:	83 f8 09             	cmp    $0x9,%eax
f010048f:	0f 85 d7 00 00 00    	jne    f010056c <cons_putc+0x18f>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 3e ff ff ff       	call   f01003dd <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 34 ff ff ff       	call   f01003dd <cons_putc>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 2a ff ff ff       	call   f01003dd <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 20 ff ff ff       	call   f01003dd <cons_putc>
		cons_putc(' ');
f01004bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c2:	e8 16 ff ff ff       	call   f01003dd <cons_putc>
		break;
f01004c7:	eb 25                	jmp    f01004ee <cons_putc+0x111>
	switch (c & 0xff) {
f01004c9:	83 f8 0d             	cmp    $0xd,%eax
f01004cc:	0f 85 9a 00 00 00    	jne    f010056c <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004d2:	0f b7 05 48 12 21 f0 	movzwl 0xf0211248,%eax
f01004d9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004df:	c1 e8 16             	shr    $0x16,%eax
f01004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e5:	c1 e0 04             	shl    $0x4,%eax
f01004e8:	66 a3 48 12 21 f0    	mov    %ax,0xf0211248
	if (crt_pos >= CRT_SIZE) {
f01004ee:	66 81 3d 48 12 21 f0 	cmpw   $0x7cf,0xf0211248
f01004f5:	cf 07 
f01004f7:	0f 87 92 00 00 00    	ja     f010058f <cons_putc+0x1b2>
	outb(addr_6845, 14);
f01004fd:	8b 0d 50 12 21 f0    	mov    0xf0211250,%ecx
f0100503:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100508:	89 ca                	mov    %ecx,%edx
f010050a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010050b:	0f b7 1d 48 12 21 f0 	movzwl 0xf0211248,%ebx
f0100512:	8d 71 01             	lea    0x1(%ecx),%esi
f0100515:	89 d8                	mov    %ebx,%eax
f0100517:	66 c1 e8 08          	shr    $0x8,%ax
f010051b:	89 f2                	mov    %esi,%edx
f010051d:	ee                   	out    %al,(%dx)
f010051e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100523:	89 ca                	mov    %ecx,%edx
f0100525:	ee                   	out    %al,(%dx)
f0100526:	89 d8                	mov    %ebx,%eax
f0100528:	89 f2                	mov    %esi,%edx
f010052a:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010052b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010052e:	5b                   	pop    %ebx
f010052f:	5e                   	pop    %esi
f0100530:	5f                   	pop    %edi
f0100531:	5d                   	pop    %ebp
f0100532:	c3                   	ret    
		if (crt_pos > 0) {
f0100533:	0f b7 05 48 12 21 f0 	movzwl 0xf0211248,%eax
f010053a:	66 85 c0             	test   %ax,%ax
f010053d:	74 be                	je     f01004fd <cons_putc+0x120>
			crt_pos--;
f010053f:	83 e8 01             	sub    $0x1,%eax
f0100542:	66 a3 48 12 21 f0    	mov    %ax,0xf0211248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100548:	0f b7 c0             	movzwl %ax,%eax
f010054b:	66 81 e7 00 ff       	and    $0xff00,%di
f0100550:	83 cf 20             	or     $0x20,%edi
f0100553:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f0100559:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010055d:	eb 8f                	jmp    f01004ee <cons_putc+0x111>
		crt_pos += CRT_COLS;
f010055f:	66 83 05 48 12 21 f0 	addw   $0x50,0xf0211248
f0100566:	50 
f0100567:	e9 66 ff ff ff       	jmp    f01004d2 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f010056c:	0f b7 05 48 12 21 f0 	movzwl 0xf0211248,%eax
f0100573:	8d 50 01             	lea    0x1(%eax),%edx
f0100576:	66 89 15 48 12 21 f0 	mov    %dx,0xf0211248
f010057d:	0f b7 c0             	movzwl %ax,%eax
f0100580:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f0100586:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010058a:	e9 5f ff ff ff       	jmp    f01004ee <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010058f:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f0100594:	83 ec 04             	sub    $0x4,%esp
f0100597:	68 00 0f 00 00       	push   $0xf00
f010059c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a2:	52                   	push   %edx
f01005a3:	50                   	push   %eax
f01005a4:	e8 05 4b 00 00       	call   f01050ae <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005a9:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f01005af:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005b5:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005bb:	83 c4 10             	add    $0x10,%esp
f01005be:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c3:	83 c0 02             	add    $0x2,%eax
f01005c6:	39 d0                	cmp    %edx,%eax
f01005c8:	75 f4                	jne    f01005be <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005ca:	66 83 2d 48 12 21 f0 	subw   $0x50,0xf0211248
f01005d1:	50 
f01005d2:	e9 26 ff ff ff       	jmp    f01004fd <cons_putc+0x120>

f01005d7 <serial_intr>:
	if (serial_exists)
f01005d7:	80 3d 54 12 21 f0 00 	cmpb   $0x0,0xf0211254
f01005de:	75 01                	jne    f01005e1 <serial_intr+0xa>
f01005e0:	c3                   	ret    
{
f01005e1:	55                   	push   %ebp
f01005e2:	89 e5                	mov    %esp,%ebp
f01005e4:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005e7:	b8 72 02 10 f0       	mov    $0xf0100272,%eax
f01005ec:	e8 9b fc ff ff       	call   f010028c <cons_intr>
}
f01005f1:	c9                   	leave  
f01005f2:	c3                   	ret    

f01005f3 <kbd_intr>:
{
f01005f3:	55                   	push   %ebp
f01005f4:	89 e5                	mov    %esp,%ebp
f01005f6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f9:	b8 cc 02 10 f0       	mov    $0xf01002cc,%eax
f01005fe:	e8 89 fc ff ff       	call   f010028c <cons_intr>
}
f0100603:	c9                   	leave  
f0100604:	c3                   	ret    

f0100605 <cons_getc>:
{
f0100605:	55                   	push   %ebp
f0100606:	89 e5                	mov    %esp,%ebp
f0100608:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010060b:	e8 c7 ff ff ff       	call   f01005d7 <serial_intr>
	kbd_intr();
f0100610:	e8 de ff ff ff       	call   f01005f3 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100615:	a1 40 12 21 f0       	mov    0xf0211240,%eax
	return 0;
f010061a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010061f:	3b 05 44 12 21 f0    	cmp    0xf0211244,%eax
f0100625:	74 1c                	je     f0100643 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100627:	8d 48 01             	lea    0x1(%eax),%ecx
f010062a:	0f b6 90 40 10 21 f0 	movzbl -0xfdeefc0(%eax),%edx
			cons.rpos = 0;
f0100631:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100636:	b8 00 00 00 00       	mov    $0x0,%eax
f010063b:	0f 45 c1             	cmovne %ecx,%eax
f010063e:	a3 40 12 21 f0       	mov    %eax,0xf0211240
}
f0100643:	89 d0                	mov    %edx,%eax
f0100645:	c9                   	leave  
f0100646:	c3                   	ret    

f0100647 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100647:	55                   	push   %ebp
f0100648:	89 e5                	mov    %esp,%ebp
f010064a:	57                   	push   %edi
f010064b:	56                   	push   %esi
f010064c:	53                   	push   %ebx
f010064d:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100650:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100657:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065e:	5a a5 
	if (*cp != 0xA55A) {
f0100660:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100667:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100671:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100675:	0f 84 c3 00 00 00    	je     f010073e <cons_init+0xf7>
		addr_6845 = MONO_BASE;
f010067b:	89 1d 50 12 21 f0    	mov    %ebx,0xf0211250
f0100681:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100686:	89 da                	mov    %ebx,%edx
f0100688:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100689:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068c:	89 fa                	mov    %edi,%edx
f010068e:	ec                   	in     (%dx),%al
f010068f:	0f b6 c8             	movzbl %al,%ecx
f0100692:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100695:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069a:	89 da                	mov    %ebx,%edx
f010069c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006a0:	89 35 4c 12 21 f0    	mov    %esi,0xf021124c
	pos |= inb(addr_6845 + 1);
f01006a6:	0f b6 c0             	movzbl %al,%eax
f01006a9:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f01006ab:	66 a3 48 12 21 f0    	mov    %ax,0xf0211248
	kbd_intr();
f01006b1:	e8 3d ff ff ff       	call   f01005f3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006b6:	83 ec 0c             	sub    $0xc,%esp
f01006b9:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01006c0:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c5:	50                   	push   %eax
f01006c6:	e8 e9 31 00 00       	call   f01038b4 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006cb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006d0:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	89 da                	mov    %ebx,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006df:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e4:	89 fa                	mov    %edi,%edx
f01006e6:	ee                   	out    %al,(%dx)
f01006e7:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f1:	ee                   	out    %al,(%dx)
f01006f2:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006f7:	89 c8                	mov    %ecx,%eax
f01006f9:	89 f2                	mov    %esi,%edx
f01006fb:	ee                   	out    %al,(%dx)
f01006fc:	b8 03 00 00 00       	mov    $0x3,%eax
f0100701:	89 fa                	mov    %edi,%edx
f0100703:	ee                   	out    %al,(%dx)
f0100704:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100709:	89 c8                	mov    %ecx,%eax
f010070b:	ee                   	out    %al,(%dx)
f010070c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100711:	89 f2                	mov    %esi,%edx
f0100713:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100714:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100719:	ec                   	in     (%dx),%al
f010071a:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010071c:	83 c4 10             	add    $0x10,%esp
f010071f:	3c ff                	cmp    $0xff,%al
f0100721:	0f 95 05 54 12 21 f0 	setne  0xf0211254
f0100728:	89 da                	mov    %ebx,%edx
f010072a:	ec                   	in     (%dx),%al
f010072b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100730:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100731:	80 f9 ff             	cmp    $0xff,%cl
f0100734:	74 1e                	je     f0100754 <cons_init+0x10d>
		cprintf("Serial port does not exist!\n");
}
f0100736:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100739:	5b                   	pop    %ebx
f010073a:	5e                   	pop    %esi
f010073b:	5f                   	pop    %edi
f010073c:	5d                   	pop    %ebp
f010073d:	c3                   	ret    
		*cp = was;
f010073e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100745:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010074a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010074f:	e9 27 ff ff ff       	jmp    f010067b <cons_init+0x34>
		cprintf("Serial port does not exist!\n");
f0100754:	83 ec 0c             	sub    $0xc,%esp
f0100757:	68 71 5d 10 f0       	push   $0xf0105d71
f010075c:	e8 b5 32 00 00       	call   f0103a16 <cprintf>
f0100761:	83 c4 10             	add    $0x10,%esp
}
f0100764:	eb d0                	jmp    f0100736 <cons_init+0xef>

f0100766 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
f0100769:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076c:	8b 45 08             	mov    0x8(%ebp),%eax
f010076f:	e8 69 fc ff ff       	call   f01003dd <cons_putc>
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <getchar>:

int
getchar(void)
{
f0100776:	55                   	push   %ebp
f0100777:	89 e5                	mov    %esp,%ebp
f0100779:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077c:	e8 84 fe ff ff       	call   f0100605 <cons_getc>
f0100781:	85 c0                	test   %eax,%eax
f0100783:	74 f7                	je     f010077c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100785:	c9                   	leave  
f0100786:	c3                   	ret    

f0100787 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100787:	b8 01 00 00 00       	mov    $0x1,%eax
f010078c:	c3                   	ret    

f010078d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010078d:	55                   	push   %ebp
f010078e:	89 e5                	mov    %esp,%ebp
f0100790:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100793:	68 c0 5f 10 f0       	push   $0xf0105fc0
f0100798:	68 de 5f 10 f0       	push   $0xf0105fde
f010079d:	68 e3 5f 10 f0       	push   $0xf0105fe3
f01007a2:	e8 6f 32 00 00       	call   f0103a16 <cprintf>
f01007a7:	83 c4 0c             	add    $0xc,%esp
f01007aa:	68 a8 60 10 f0       	push   $0xf01060a8
f01007af:	68 ec 5f 10 f0       	push   $0xf0105fec
f01007b4:	68 e3 5f 10 f0       	push   $0xf0105fe3
f01007b9:	e8 58 32 00 00       	call   f0103a16 <cprintf>
f01007be:	83 c4 0c             	add    $0xc,%esp
f01007c1:	68 d0 60 10 f0       	push   $0xf01060d0
f01007c6:	68 f5 5f 10 f0       	push   $0xf0105ff5
f01007cb:	68 e3 5f 10 f0       	push   $0xf0105fe3
f01007d0:	e8 41 32 00 00       	call   f0103a16 <cprintf>
f01007d5:	83 c4 0c             	add    $0xc,%esp
f01007d8:	68 00 61 10 f0       	push   $0xf0106100
f01007dd:	68 ff 5f 10 f0       	push   $0xf0105fff
f01007e2:	68 e3 5f 10 f0       	push   $0xf0105fe3
f01007e7:	e8 2a 32 00 00       	call   f0103a16 <cprintf>
	return 0;
}
f01007ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f1:	c9                   	leave  
f01007f2:	c3                   	ret    

f01007f3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f3:	55                   	push   %ebp
f01007f4:	89 e5                	mov    %esp,%ebp
f01007f6:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f9:	68 04 60 10 f0       	push   $0xf0106004
f01007fe:	e8 13 32 00 00       	call   f0103a16 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100803:	83 c4 08             	add    $0x8,%esp
f0100806:	68 0c 00 10 00       	push   $0x10000c
f010080b:	68 2c 61 10 f0       	push   $0xf010612c
f0100810:	e8 01 32 00 00       	call   f0103a16 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	68 0c 00 10 00       	push   $0x10000c
f010081d:	68 0c 00 10 f0       	push   $0xf010000c
f0100822:	68 54 61 10 f0       	push   $0xf0106154
f0100827:	e8 ea 31 00 00       	call   f0103a16 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	68 81 5c 10 00       	push   $0x105c81
f0100834:	68 81 5c 10 f0       	push   $0xf0105c81
f0100839:	68 78 61 10 f0       	push   $0xf0106178
f010083e:	e8 d3 31 00 00       	call   f0103a16 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100843:	83 c4 0c             	add    $0xc,%esp
f0100846:	68 00 10 21 00       	push   $0x211000
f010084b:	68 00 10 21 f0       	push   $0xf0211000
f0100850:	68 9c 61 10 f0       	push   $0xf010619c
f0100855:	e8 bc 31 00 00       	call   f0103a16 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085a:	83 c4 0c             	add    $0xc,%esp
f010085d:	68 c8 23 25 00       	push   $0x2523c8
f0100862:	68 c8 23 25 f0       	push   $0xf02523c8
f0100867:	68 c0 61 10 f0       	push   $0xf01061c0
f010086c:	e8 a5 31 00 00       	call   f0103a16 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100874:	b8 c8 23 25 f0       	mov    $0xf02523c8,%eax
f0100879:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087e:	c1 f8 0a             	sar    $0xa,%eax
f0100881:	50                   	push   %eax
f0100882:	68 e4 61 10 f0       	push   $0xf01061e4
f0100887:	e8 8a 31 00 00       	call   f0103a16 <cprintf>
	return 0;
}
f010088c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100891:	c9                   	leave  
f0100892:	c3                   	ret    

f0100893 <mon_show>:
	return 0;
}

int
mon_show(int argc, char **argv, struct Trapframe *tf)
{
f0100893:	55                   	push   %ebp
f0100894:	89 e5                	mov    %esp,%ebp
f0100896:	83 ec 14             	sub    $0x14,%esp
	cprintf("\e[1;31m .__           .__  .__                               .__       .___\n");
f0100899:	68 10 62 10 f0       	push   $0xf0106210
f010089e:	e8 73 31 00 00       	call   f0103a16 <cprintf>
	cprintf("\e[1;32m |  |__   ____ |  | |  |   ____   __  _  _____________|  |    __| _/\n");
f01008a3:	c7 04 24 60 62 10 f0 	movl   $0xf0106260,(%esp)
f01008aa:	e8 67 31 00 00       	call   f0103a16 <cprintf>
	cprintf("\e[1;33m |  |  \\_/ __ \\|  | |  |  /  _ \\  \\ \\/ \\/ /  _ \\_  __ \\  |   / __ | \n");
f01008af:	c7 04 24 b0 62 10 f0 	movl   $0xf01062b0,(%esp)
f01008b6:	e8 5b 31 00 00       	call   f0103a16 <cprintf>
	cprintf("\e[1;34m |   Y  \\  ___/|  |_|  |_(  <_> )  \\     (  <_> )  | \\/  |__/ /_/ | \n");
f01008bb:	c7 04 24 00 63 10 f0 	movl   $0xf0106300,(%esp)
f01008c2:	e8 4f 31 00 00       	call   f0103a16 <cprintf>
	cprintf("\e[1;35m |___|  /\\___  >____/____/\\____/    \\/\\_/ \\____/|__|  |____/\\____ | \n");
f01008c7:	c7 04 24 50 63 10 f0 	movl   $0xf0106350,(%esp)
f01008ce:	e8 43 31 00 00       	call   f0103a16 <cprintf>
	cprintf("\e[1;36m      \\/     \\/                                                  \\/ \n\e[m");
f01008d3:	c7 04 24 a0 63 10 f0 	movl   $0xf01063a0,(%esp)
f01008da:	e8 37 31 00 00       	call   f0103a16 <cprintf>
	return 0;
}
f01008df:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e4:	c9                   	leave  
f01008e5:	c3                   	ret    

f01008e6 <mon_backtrace>:
{
f01008e6:	55                   	push   %ebp
f01008e7:	89 e5                	mov    %esp,%ebp
f01008e9:	57                   	push   %edi
f01008ea:	56                   	push   %esi
f01008eb:	53                   	push   %ebx
f01008ec:	83 ec 38             	sub    $0x38,%esp
	cprintf ("Stack backtrace:\n");
f01008ef:	68 1d 60 10 f0       	push   $0xf010601d
f01008f4:	e8 1d 31 00 00       	call   f0103a16 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008f9:	89 ee                	mov    %ebp,%esi
	while ((uint32_t) ebp != 0)
f01008fb:	83 c4 10             	add    $0x10,%esp
f01008fe:	eb 74                	jmp    f0100974 <mon_backtrace+0x8e>
		cprintf("  ebp %08x  eip %08x args ", ebp, *(ebp + 1));
f0100900:	83 ec 04             	sub    $0x4,%esp
f0100903:	ff 76 04             	push   0x4(%esi)
f0100906:	56                   	push   %esi
f0100907:	68 2f 60 10 f0       	push   $0xf010602f
f010090c:	e8 05 31 00 00       	call   f0103a16 <cprintf>
f0100911:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100914:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100917:	83 c4 10             	add    $0x10,%esp
			cprintf("%08x ", *(ebp+i));
f010091a:	83 ec 08             	sub    $0x8,%esp
f010091d:	ff 33                	push   (%ebx)
f010091f:	68 4a 60 10 f0       	push   $0xf010604a
f0100924:	e8 ed 30 00 00       	call   f0103a16 <cprintf>
		for (int i=2; i<7; i++)
f0100929:	83 c3 04             	add    $0x4,%ebx
f010092c:	83 c4 10             	add    $0x10,%esp
f010092f:	39 fb                	cmp    %edi,%ebx
f0100931:	75 e7                	jne    f010091a <mon_backtrace+0x34>
		cprintf("\n");
f0100933:	83 ec 0c             	sub    $0xc,%esp
f0100936:	68 cf 70 10 f0       	push   $0xf01070cf
f010093b:	e8 d6 30 00 00       	call   f0103a16 <cprintf>
		int retval = debuginfo_eip(*(ebp + 1), &info);
f0100940:	83 c4 08             	add    $0x8,%esp
f0100943:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100946:	50                   	push   %eax
f0100947:	ff 76 04             	push   0x4(%esi)
f010094a:	e8 ff 3c 00 00       	call   f010464e <debuginfo_eip>
		cprintf("          %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1)-info.eip_fn_addr);
f010094f:	83 c4 08             	add    $0x8,%esp
f0100952:	8b 46 04             	mov    0x4(%esi),%eax
f0100955:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100958:	50                   	push   %eax
f0100959:	ff 75 d8             	push   -0x28(%ebp)
f010095c:	ff 75 dc             	push   -0x24(%ebp)
f010095f:	ff 75 d4             	push   -0x2c(%ebp)
f0100962:	ff 75 d0             	push   -0x30(%ebp)
f0100965:	68 50 60 10 f0       	push   $0xf0106050
f010096a:	e8 a7 30 00 00       	call   f0103a16 <cprintf>
		ebp = (uint32_t*)* ebp;
f010096f:	8b 36                	mov    (%esi),%esi
f0100971:	83 c4 20             	add    $0x20,%esp
	while ((uint32_t) ebp != 0)
f0100974:	85 f6                	test   %esi,%esi
f0100976:	75 88                	jne    f0100900 <mon_backtrace+0x1a>
}
f0100978:	b8 00 00 00 00       	mov    $0x0,%eax
f010097d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100980:	5b                   	pop    %ebx
f0100981:	5e                   	pop    %esi
f0100982:	5f                   	pop    %edi
f0100983:	5d                   	pop    %ebp
f0100984:	c3                   	ret    

f0100985 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100985:	55                   	push   %ebp
f0100986:	89 e5                	mov    %esp,%ebp
f0100988:	57                   	push   %edi
f0100989:	56                   	push   %esi
f010098a:	53                   	push   %ebx
f010098b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010098e:	68 f0 63 10 f0       	push   $0xf01063f0
f0100993:	e8 7e 30 00 00       	call   f0103a16 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100998:	c7 04 24 14 64 10 f0 	movl   $0xf0106414,(%esp)
f010099f:	e8 72 30 00 00       	call   f0103a16 <cprintf>

	if (tf != NULL)
f01009a4:	83 c4 10             	add    $0x10,%esp
f01009a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009ab:	74 57                	je     f0100a04 <monitor+0x7f>
		print_trapframe(tf);
f01009ad:	83 ec 0c             	sub    $0xc,%esp
f01009b0:	ff 75 08             	push   0x8(%ebp)
f01009b3:	e8 d5 34 00 00       	call   f0103e8d <print_trapframe>
f01009b8:	83 c4 10             	add    $0x10,%esp
f01009bb:	eb 47                	jmp    f0100a04 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f01009bd:	83 ec 08             	sub    $0x8,%esp
f01009c0:	0f be c0             	movsbl %al,%eax
f01009c3:	50                   	push   %eax
f01009c4:	68 6e 60 10 f0       	push   $0xf010606e
f01009c9:	e8 5b 46 00 00       	call   f0105029 <strchr>
f01009ce:	83 c4 10             	add    $0x10,%esp
f01009d1:	85 c0                	test   %eax,%eax
f01009d3:	74 0a                	je     f01009df <monitor+0x5a>
			*buf++ = 0;
f01009d5:	c6 03 00             	movb   $0x0,(%ebx)
f01009d8:	89 f7                	mov    %esi,%edi
f01009da:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009dd:	eb 6b                	jmp    f0100a4a <monitor+0xc5>
		if (*buf == 0)
f01009df:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e2:	74 73                	je     f0100a57 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f01009e4:	83 fe 0f             	cmp    $0xf,%esi
f01009e7:	74 09                	je     f01009f2 <monitor+0x6d>
		argv[argc++] = buf;
f01009e9:	8d 7e 01             	lea    0x1(%esi),%edi
f01009ec:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009f0:	eb 39                	jmp    f0100a2b <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009f2:	83 ec 08             	sub    $0x8,%esp
f01009f5:	6a 10                	push   $0x10
f01009f7:	68 73 60 10 f0       	push   $0xf0106073
f01009fc:	e8 15 30 00 00       	call   f0103a16 <cprintf>
			return 0;
f0100a01:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a04:	83 ec 0c             	sub    $0xc,%esp
f0100a07:	68 6a 60 10 f0       	push   $0xf010606a
f0100a0c:	e8 ea 43 00 00       	call   f0104dfb <readline>
f0100a11:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a13:	83 c4 10             	add    $0x10,%esp
f0100a16:	85 c0                	test   %eax,%eax
f0100a18:	74 ea                	je     f0100a04 <monitor+0x7f>
	argv[argc] = 0;
f0100a1a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a21:	be 00 00 00 00       	mov    $0x0,%esi
f0100a26:	eb 24                	jmp    f0100a4c <monitor+0xc7>
			buf++;
f0100a28:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a2b:	0f b6 03             	movzbl (%ebx),%eax
f0100a2e:	84 c0                	test   %al,%al
f0100a30:	74 18                	je     f0100a4a <monitor+0xc5>
f0100a32:	83 ec 08             	sub    $0x8,%esp
f0100a35:	0f be c0             	movsbl %al,%eax
f0100a38:	50                   	push   %eax
f0100a39:	68 6e 60 10 f0       	push   $0xf010606e
f0100a3e:	e8 e6 45 00 00       	call   f0105029 <strchr>
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	85 c0                	test   %eax,%eax
f0100a48:	74 de                	je     f0100a28 <monitor+0xa3>
			*buf++ = 0;
f0100a4a:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a4c:	0f b6 03             	movzbl (%ebx),%eax
f0100a4f:	84 c0                	test   %al,%al
f0100a51:	0f 85 66 ff ff ff    	jne    f01009bd <monitor+0x38>
	argv[argc] = 0;
f0100a57:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a5e:	00 
	if (argc == 0)
f0100a5f:	85 f6                	test   %esi,%esi
f0100a61:	74 a1                	je     f0100a04 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a63:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a68:	83 ec 08             	sub    $0x8,%esp
f0100a6b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a6e:	ff 34 85 40 64 10 f0 	push   -0xfef9bc0(,%eax,4)
f0100a75:	ff 75 a8             	push   -0x58(%ebp)
f0100a78:	e8 4c 45 00 00       	call   f0104fc9 <strcmp>
f0100a7d:	83 c4 10             	add    $0x10,%esp
f0100a80:	85 c0                	test   %eax,%eax
f0100a82:	74 20                	je     f0100aa4 <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a84:	83 c3 01             	add    $0x1,%ebx
f0100a87:	83 fb 04             	cmp    $0x4,%ebx
f0100a8a:	75 dc                	jne    f0100a68 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a8c:	83 ec 08             	sub    $0x8,%esp
f0100a8f:	ff 75 a8             	push   -0x58(%ebp)
f0100a92:	68 90 60 10 f0       	push   $0xf0106090
f0100a97:	e8 7a 2f 00 00       	call   f0103a16 <cprintf>
	return 0;
f0100a9c:	83 c4 10             	add    $0x10,%esp
f0100a9f:	e9 60 ff ff ff       	jmp    f0100a04 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100aa4:	83 ec 04             	sub    $0x4,%esp
f0100aa7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aaa:	ff 75 08             	push   0x8(%ebp)
f0100aad:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab0:	52                   	push   %edx
f0100ab1:	56                   	push   %esi
f0100ab2:	ff 14 85 48 64 10 f0 	call   *-0xfef9bb8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ab9:	83 c4 10             	add    $0x10,%esp
f0100abc:	85 c0                	test   %eax,%eax
f0100abe:	0f 89 40 ff ff ff    	jns    f0100a04 <monitor+0x7f>
				break;
	}
}
f0100ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac7:	5b                   	pop    %ebx
f0100ac8:	5e                   	pop    %esi
f0100ac9:	5f                   	pop    %edi
f0100aca:	5d                   	pop    %ebp
f0100acb:	c3                   	ret    

f0100acc <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100acc:	55                   	push   %ebp
f0100acd:	89 e5                	mov    %esp,%ebp
f0100acf:	56                   	push   %esi
f0100ad0:	53                   	push   %ebx
f0100ad1:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ad3:	83 ec 0c             	sub    $0xc,%esp
f0100ad6:	50                   	push   %eax
f0100ad7:	e8 aa 2d 00 00       	call   f0103886 <mc146818_read>
f0100adc:	89 c6                	mov    %eax,%esi
f0100ade:	83 c3 01             	add    $0x1,%ebx
f0100ae1:	89 1c 24             	mov    %ebx,(%esp)
f0100ae4:	e8 9d 2d 00 00       	call   f0103886 <mc146818_read>
f0100ae9:	c1 e0 08             	shl    $0x8,%eax
f0100aec:	09 f0                	or     %esi,%eax
}
f0100aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100af1:	5b                   	pop    %ebx
f0100af2:	5e                   	pop    %esi
f0100af3:	5d                   	pop    %ebp
f0100af4:	c3                   	ret    

f0100af5 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af5:	83 3d 64 12 21 f0 00 	cmpl   $0x0,0xf0211264
f0100afc:	74 3e                	je     f0100b3c <boot_alloc+0x47>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if (n == 0)
f0100afe:	85 c0                	test   %eax,%eax
f0100b00:	74 4d                	je     f0100b4f <boot_alloc+0x5a>
{
f0100b02:	55                   	push   %ebp
f0100b03:	89 e5                	mov    %esp,%ebp
f0100b05:	83 ec 08             	sub    $0x8,%esp
	return nextfree;
	
	result = nextfree;
f0100b08:	8b 15 64 12 21 f0    	mov    0xf0211264,%edx
	if ((uint32_t)kva < KERNBASE)
f0100b0e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b14:	76 42                	jbe    f0100b58 <boot_alloc+0x63>
	return (physaddr_t)kva - KERNBASE;
f0100b16:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx

	if (PGNUM(PADDR(nextfree)) > npages) {
f0100b1c:	c1 e9 0c             	shr    $0xc,%ecx
f0100b1f:	3b 0d 60 12 21 f0    	cmp    0xf0211260,%ecx
f0100b25:	77 43                	ja     f0100b6a <boot_alloc+0x75>
		panic("boot alloc: out of memory");
	}

	nextfree += ROUNDUP(n, PGSIZE);
f0100b27:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b31:	01 d0                	add    %edx,%eax
f0100b33:	a3 64 12 21 f0       	mov    %eax,0xf0211264
	
	return result;
}
f0100b38:	89 d0                	mov    %edx,%eax
f0100b3a:	c9                   	leave  
f0100b3b:	c3                   	ret    
		nextfree = ROUNDUP((char *) end + 1, PGSIZE);
f0100b3c:	ba c8 33 25 f0       	mov    $0xf02533c8,%edx
f0100b41:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b47:	89 15 64 12 21 f0    	mov    %edx,0xf0211264
f0100b4d:	eb af                	jmp    f0100afe <boot_alloc+0x9>
	return nextfree;
f0100b4f:	8b 15 64 12 21 f0    	mov    0xf0211264,%edx
}
f0100b55:	89 d0                	mov    %edx,%eax
f0100b57:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b58:	52                   	push   %edx
f0100b59:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0100b5e:	6a 72                	push   $0x72
f0100b60:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100b65:	e8 d6 f4 ff ff       	call   f0100040 <_panic>
		panic("boot alloc: out of memory");
f0100b6a:	83 ec 04             	sub    $0x4,%esp
f0100b6d:	68 e1 6d 10 f0       	push   $0xf0106de1
f0100b72:	6a 73                	push   $0x73
f0100b74:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100b79:	e8 c2 f4 ff ff       	call   f0100040 <_panic>

f0100b7e <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b7e:	89 d1                	mov    %edx,%ecx
f0100b80:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b83:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b86:	a8 01                	test   $0x1,%al
f0100b88:	74 51                	je     f0100bdb <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b8a:	89 c1                	mov    %eax,%ecx
f0100b8c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100b92:	c1 e8 0c             	shr    $0xc,%eax
f0100b95:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0100b9b:	73 23                	jae    f0100bc0 <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100b9d:	c1 ea 0c             	shr    $0xc,%edx
f0100ba0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ba6:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bad:	89 d0                	mov    %edx,%eax
f0100baf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bb4:	f6 c2 01             	test   $0x1,%dl
f0100bb7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bbc:	0f 44 c2             	cmove  %edx,%eax
f0100bbf:	c3                   	ret    
{
f0100bc0:	55                   	push   %ebp
f0100bc1:	89 e5                	mov    %esp,%ebp
f0100bc3:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc6:	51                   	push   %ecx
f0100bc7:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0100bcc:	68 94 03 00 00       	push   $0x394
f0100bd1:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100bd6:	e8 65 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100bdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100be0:	c3                   	ret    

f0100be1 <check_page_free_list>:
{
f0100be1:	55                   	push   %ebp
f0100be2:	89 e5                	mov    %esp,%ebp
f0100be4:	57                   	push   %edi
f0100be5:	56                   	push   %esi
f0100be6:	53                   	push   %ebx
f0100be7:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bea:	84 c0                	test   %al,%al
f0100bec:	0f 85 77 02 00 00    	jne    f0100e69 <check_page_free_list+0x288>
	if (!page_free_list)
f0100bf2:	83 3d 6c 12 21 f0 00 	cmpl   $0x0,0xf021126c
f0100bf9:	74 0a                	je     f0100c05 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bfb:	be 00 04 00 00       	mov    $0x400,%esi
f0100c00:	e9 bf 02 00 00       	jmp    f0100ec4 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100c05:	83 ec 04             	sub    $0x4,%esp
f0100c08:	68 70 64 10 f0       	push   $0xf0106470
f0100c0d:	68 c7 02 00 00       	push   $0x2c7
f0100c12:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100c17:	e8 24 f4 ff ff       	call   f0100040 <_panic>
f0100c1c:	50                   	push   %eax
f0100c1d:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0100c22:	6a 58                	push   $0x58
f0100c24:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0100c29:	e8 12 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c2e:	8b 1b                	mov    (%ebx),%ebx
f0100c30:	85 db                	test   %ebx,%ebx
f0100c32:	74 41                	je     f0100c75 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c34:	89 d8                	mov    %ebx,%eax
f0100c36:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0100c3c:	c1 f8 03             	sar    $0x3,%eax
f0100c3f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c42:	89 c2                	mov    %eax,%edx
f0100c44:	c1 ea 16             	shr    $0x16,%edx
f0100c47:	39 f2                	cmp    %esi,%edx
f0100c49:	73 e3                	jae    f0100c2e <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100c4b:	89 c2                	mov    %eax,%edx
f0100c4d:	c1 ea 0c             	shr    $0xc,%edx
f0100c50:	3b 15 60 12 21 f0    	cmp    0xf0211260,%edx
f0100c56:	73 c4                	jae    f0100c1c <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100c58:	83 ec 04             	sub    $0x4,%esp
f0100c5b:	68 80 00 00 00       	push   $0x80
f0100c60:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c65:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c6a:	50                   	push   %eax
f0100c6b:	e8 f8 43 00 00       	call   f0105068 <memset>
f0100c70:	83 c4 10             	add    $0x10,%esp
f0100c73:	eb b9                	jmp    f0100c2e <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c75:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7a:	e8 76 fe ff ff       	call   f0100af5 <boot_alloc>
f0100c7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c82:	8b 15 6c 12 21 f0    	mov    0xf021126c,%edx
		assert(pp >= pages);
f0100c88:	8b 0d 58 12 21 f0    	mov    0xf0211258,%ecx
		assert(pp < pages + npages);
f0100c8e:	a1 60 12 21 f0       	mov    0xf0211260,%eax
f0100c93:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c96:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c99:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c9e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca1:	e9 f9 00 00 00       	jmp    f0100d9f <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100ca6:	68 09 6e 10 f0       	push   $0xf0106e09
f0100cab:	68 15 6e 10 f0       	push   $0xf0106e15
f0100cb0:	68 e1 02 00 00       	push   $0x2e1
f0100cb5:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100cba:	e8 81 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cbf:	68 2a 6e 10 f0       	push   $0xf0106e2a
f0100cc4:	68 15 6e 10 f0       	push   $0xf0106e15
f0100cc9:	68 e2 02 00 00       	push   $0x2e2
f0100cce:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100cd3:	e8 68 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cd8:	68 94 64 10 f0       	push   $0xf0106494
f0100cdd:	68 15 6e 10 f0       	push   $0xf0106e15
f0100ce2:	68 e3 02 00 00       	push   $0x2e3
f0100ce7:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100cec:	e8 4f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100cf1:	68 3e 6e 10 f0       	push   $0xf0106e3e
f0100cf6:	68 15 6e 10 f0       	push   $0xf0106e15
f0100cfb:	68 e6 02 00 00       	push   $0x2e6
f0100d00:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100d05:	e8 36 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d0a:	68 4f 6e 10 f0       	push   $0xf0106e4f
f0100d0f:	68 15 6e 10 f0       	push   $0xf0106e15
f0100d14:	68 e7 02 00 00       	push   $0x2e7
f0100d19:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100d1e:	e8 1d f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d23:	68 c8 64 10 f0       	push   $0xf01064c8
f0100d28:	68 15 6e 10 f0       	push   $0xf0106e15
f0100d2d:	68 e8 02 00 00       	push   $0x2e8
f0100d32:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100d37:	e8 04 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d3c:	68 68 6e 10 f0       	push   $0xf0106e68
f0100d41:	68 15 6e 10 f0       	push   $0xf0106e15
f0100d46:	68 e9 02 00 00       	push   $0x2e9
f0100d4b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100d50:	e8 eb f2 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100d55:	89 c3                	mov    %eax,%ebx
f0100d57:	c1 eb 0c             	shr    $0xc,%ebx
f0100d5a:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100d5d:	76 0f                	jbe    f0100d6e <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100d5f:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d64:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d67:	77 17                	ja     f0100d80 <check_page_free_list+0x19f>
			++nfree_extmem;
f0100d69:	83 c7 01             	add    $0x1,%edi
f0100d6c:	eb 2f                	jmp    f0100d9d <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d6e:	50                   	push   %eax
f0100d6f:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0100d74:	6a 58                	push   $0x58
f0100d76:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0100d7b:	e8 c0 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d80:	68 ec 64 10 f0       	push   $0xf01064ec
f0100d85:	68 15 6e 10 f0       	push   $0xf0106e15
f0100d8a:	68 ea 02 00 00       	push   $0x2ea
f0100d8f:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100d94:	e8 a7 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d99:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d9d:	8b 12                	mov    (%edx),%edx
f0100d9f:	85 d2                	test   %edx,%edx
f0100da1:	74 74                	je     f0100e17 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100da3:	39 d1                	cmp    %edx,%ecx
f0100da5:	0f 87 fb fe ff ff    	ja     f0100ca6 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100dab:	39 d6                	cmp    %edx,%esi
f0100dad:	0f 86 0c ff ff ff    	jbe    f0100cbf <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100db3:	89 d0                	mov    %edx,%eax
f0100db5:	29 c8                	sub    %ecx,%eax
f0100db7:	a8 07                	test   $0x7,%al
f0100db9:	0f 85 19 ff ff ff    	jne    f0100cd8 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100dbf:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100dc2:	c1 e0 0c             	shl    $0xc,%eax
f0100dc5:	0f 84 26 ff ff ff    	je     f0100cf1 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dcb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dd0:	0f 84 34 ff ff ff    	je     f0100d0a <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dd6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ddb:	0f 84 42 ff ff ff    	je     f0100d23 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100de1:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100de6:	0f 84 50 ff ff ff    	je     f0100d3c <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dec:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100df1:	0f 87 5e ff ff ff    	ja     f0100d55 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100df7:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dfc:	75 9b                	jne    f0100d99 <check_page_free_list+0x1b8>
f0100dfe:	68 82 6e 10 f0       	push   $0xf0106e82
f0100e03:	68 15 6e 10 f0       	push   $0xf0106e15
f0100e08:	68 ec 02 00 00       	push   $0x2ec
f0100e0d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100e12:	e8 29 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100e17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e1a:	85 db                	test   %ebx,%ebx
f0100e1c:	7e 19                	jle    f0100e37 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100e1e:	85 ff                	test   %edi,%edi
f0100e20:	7e 2e                	jle    f0100e50 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100e22:	83 ec 0c             	sub    $0xc,%esp
f0100e25:	68 34 65 10 f0       	push   $0xf0106534
f0100e2a:	e8 e7 2b 00 00       	call   f0103a16 <cprintf>
}
f0100e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e32:	5b                   	pop    %ebx
f0100e33:	5e                   	pop    %esi
f0100e34:	5f                   	pop    %edi
f0100e35:	5d                   	pop    %ebp
f0100e36:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e37:	68 9f 6e 10 f0       	push   $0xf0106e9f
f0100e3c:	68 15 6e 10 f0       	push   $0xf0106e15
f0100e41:	68 f4 02 00 00       	push   $0x2f4
f0100e46:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100e4b:	e8 f0 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e50:	68 b1 6e 10 f0       	push   $0xf0106eb1
f0100e55:	68 15 6e 10 f0       	push   $0xf0106e15
f0100e5a:	68 f5 02 00 00       	push   $0x2f5
f0100e5f:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100e64:	e8 d7 f1 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e69:	a1 6c 12 21 f0       	mov    0xf021126c,%eax
f0100e6e:	85 c0                	test   %eax,%eax
f0100e70:	0f 84 8f fd ff ff    	je     f0100c05 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e76:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e79:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e7c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e82:	89 c2                	mov    %eax,%edx
f0100e84:	2b 15 58 12 21 f0    	sub    0xf0211258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e8a:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e90:	0f 95 c2             	setne  %dl
f0100e93:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e96:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e9a:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e9c:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ea0:	8b 00                	mov    (%eax),%eax
f0100ea2:	85 c0                	test   %eax,%eax
f0100ea4:	75 dc                	jne    f0100e82 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ea9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100eaf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100eb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eb5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100eb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100eba:	a3 6c 12 21 f0       	mov    %eax,0xf021126c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ebf:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ec4:	8b 1d 6c 12 21 f0    	mov    0xf021126c,%ebx
f0100eca:	e9 61 fd ff ff       	jmp    f0100c30 <check_page_free_list+0x4f>

f0100ecf <page_init>:
{
f0100ecf:	55                   	push   %ebp
f0100ed0:	89 e5                	mov    %esp,%ebp
f0100ed2:	57                   	push   %edi
f0100ed3:	56                   	push   %esi
f0100ed4:	53                   	push   %ebx
f0100ed5:	83 ec 0c             	sub    $0xc,%esp
    for (i = 0; i < npages_basemem; i++) {
f0100ed8:	8b 35 70 12 21 f0    	mov    0xf0211270,%esi
f0100ede:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ee3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee8:	eb 03                	jmp    f0100eed <page_init+0x1e>
f0100eea:	83 c0 01             	add    $0x1,%eax
f0100eed:	39 c6                	cmp    %eax,%esi
f0100eef:	74 34                	je     f0100f25 <page_init+0x56>
        if (i != 0 && i != PGNUM(MPENTRY_PADDR)) {
f0100ef1:	85 c0                	test   %eax,%eax
f0100ef3:	0f 95 c1             	setne  %cl
f0100ef6:	83 f8 07             	cmp    $0x7,%eax
f0100ef9:	0f 95 c2             	setne  %dl
f0100efc:	20 d1                	and    %dl,%cl
f0100efe:	74 ea                	je     f0100eea <page_init+0x1b>
f0100f00:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
            pages[i].pp_ref = 0;
f0100f07:	89 da                	mov    %ebx,%edx
f0100f09:	03 15 58 12 21 f0    	add    0xf0211258,%edx
f0100f0f:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
            pages[i].pp_link = NULL;
f0100f15:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
            page_free_list = &pages[i];
f0100f1b:	03 1d 58 12 21 f0    	add    0xf0211258,%ebx
f0100f21:	89 cf                	mov    %ecx,%edi
f0100f23:	eb c5                	jmp    f0100eea <page_init+0x1b>
f0100f25:	89 f8                	mov    %edi,%eax
f0100f27:	84 c0                	test   %al,%al
f0100f29:	74 06                	je     f0100f31 <page_init+0x62>
f0100f2b:	89 1d 6c 12 21 f0    	mov    %ebx,0xf021126c
    pages[0].pp_ref = 1;
f0100f31:	a1 58 12 21 f0       	mov    0xf0211258,%eax
f0100f36:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    pages[0].pp_link = NULL;
f0100f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    pages[PGNUM(MPENTRY_PADDR)].pp_ref = 1;
f0100f42:	a1 58 12 21 f0       	mov    0xf0211258,%eax
f0100f47:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
    pages[PGNUM(MPENTRY_PADDR)].pp_link = NULL;
f0100f4d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100f54:	b8 00 05 00 00       	mov    $0x500,%eax
        pages[i].pp_ref = 1;
f0100f59:	89 c2                	mov    %eax,%edx
f0100f5b:	03 15 58 12 21 f0    	add    0xf0211258,%edx
f0100f61:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
        pages[i].pp_link = NULL;
f0100f67:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    for (i = PGNUM(IOPHYSMEM); i < PGNUM(EXTPHYSMEM); i++) {
f0100f6d:	83 c0 08             	add    $0x8,%eax
f0100f70:	3d 00 08 00 00       	cmp    $0x800,%eax
f0100f75:	75 e2                	jne    f0100f59 <page_init+0x8a>
    char * nextfree = boot_alloc(0);
f0100f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7c:	e8 74 fb ff ff       	call   f0100af5 <boot_alloc>
f0100f81:	89 c3                	mov    %eax,%ebx
	return (physaddr_t)kva - KERNBASE;
f0100f83:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
    for (i = PGNUM(EXTPHYSMEM); i < PGNUM(PADDR(nextfree)); i++) {
f0100f89:	c1 e8 0c             	shr    $0xc,%eax
f0100f8c:	ba 00 01 00 00       	mov    $0x100,%edx
f0100f91:	eb 18                	jmp    f0100fab <page_init+0xdc>
        pages[i].pp_ref = 1;
f0100f93:	8b 0d 58 12 21 f0    	mov    0xf0211258,%ecx
f0100f99:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100f9c:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
        pages[i].pp_link = NULL;
f0100fa2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
    for (i = PGNUM(EXTPHYSMEM); i < PGNUM(PADDR(nextfree)); i++) {
f0100fa8:	83 c2 01             	add    $0x1,%edx
	if ((uint32_t)kva < KERNBASE)
f0100fab:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100fb1:	76 16                	jbe    f0100fc9 <page_init+0xfa>
f0100fb3:	39 d0                	cmp    %edx,%eax
f0100fb5:	77 dc                	ja     f0100f93 <page_init+0xc4>
f0100fb7:	8b 1d 6c 12 21 f0    	mov    0xf021126c,%ebx
    for (int i = PGNUM(PADDR(nextfree)); i < npages;i++) {
f0100fbd:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fc2:	be 01 00 00 00       	mov    $0x1,%esi
f0100fc7:	eb 39                	jmp    f0101002 <page_init+0x133>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fc9:	53                   	push   %ebx
f0100fca:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0100fcf:	68 5a 01 00 00       	push   $0x15a
f0100fd4:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100fd9:	e8 62 f0 ff ff       	call   f0100040 <_panic>
f0100fde:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
        pages[i].pp_ref = 0;
f0100fe5:	89 d1                	mov    %edx,%ecx
f0100fe7:	03 0d 58 12 21 f0    	add    0xf0211258,%ecx
f0100fed:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100ff3:	89 19                	mov    %ebx,(%ecx)
        page_free_list = &pages[i];
f0100ff5:	89 d3                	mov    %edx,%ebx
f0100ff7:	03 1d 58 12 21 f0    	add    0xf0211258,%ebx
    for (int i = PGNUM(PADDR(nextfree)); i < npages;i++) {
f0100ffd:	83 c0 01             	add    $0x1,%eax
f0101000:	89 f2                	mov    %esi,%edx
f0101002:	39 05 60 12 21 f0    	cmp    %eax,0xf0211260
f0101008:	77 d4                	ja     f0100fde <page_init+0x10f>
f010100a:	84 d2                	test   %dl,%dl
f010100c:	74 06                	je     f0101014 <page_init+0x145>
f010100e:	89 1d 6c 12 21 f0    	mov    %ebx,0xf021126c
}
f0101014:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101017:	5b                   	pop    %ebx
f0101018:	5e                   	pop    %esi
f0101019:	5f                   	pop    %edi
f010101a:	5d                   	pop    %ebp
f010101b:	c3                   	ret    

f010101c <page_alloc>:
{
f010101c:	55                   	push   %ebp
f010101d:	89 e5                	mov    %esp,%ebp
f010101f:	53                   	push   %ebx
f0101020:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL) {
f0101023:	8b 1d 6c 12 21 f0    	mov    0xf021126c,%ebx
f0101029:	85 db                	test   %ebx,%ebx
f010102b:	74 13                	je     f0101040 <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f010102d:	8b 03                	mov    (%ebx),%eax
f010102f:	a3 6c 12 21 f0       	mov    %eax,0xf021126c
	page->pp_link = NULL;
f0101034:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f010103a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010103e:	75 07                	jne    f0101047 <page_alloc+0x2b>
}
f0101040:	89 d8                	mov    %ebx,%eax
f0101042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101045:	c9                   	leave  
f0101046:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101047:	89 d8                	mov    %ebx,%eax
f0101049:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f010104f:	c1 f8 03             	sar    $0x3,%eax
f0101052:	89 c2                	mov    %eax,%edx
f0101054:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101057:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010105c:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0101062:	73 1b                	jae    f010107f <page_alloc+0x63>
		memset(page2kva(page), '\0', PGSIZE);
f0101064:	83 ec 04             	sub    $0x4,%esp
f0101067:	68 00 10 00 00       	push   $0x1000
f010106c:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010106e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101074:	52                   	push   %edx
f0101075:	e8 ee 3f 00 00       	call   f0105068 <memset>
f010107a:	83 c4 10             	add    $0x10,%esp
f010107d:	eb c1                	jmp    f0101040 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107f:	52                   	push   %edx
f0101080:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0101085:	6a 58                	push   $0x58
f0101087:	68 fb 6d 10 f0       	push   $0xf0106dfb
f010108c:	e8 af ef ff ff       	call   f0100040 <_panic>

f0101091 <page_free>:
{
f0101091:	55                   	push   %ebp
f0101092:	89 e5                	mov    %esp,%ebp
f0101094:	83 ec 08             	sub    $0x8,%esp
f0101097:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f010109a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010109f:	75 14                	jne    f01010b5 <page_free+0x24>
f01010a1:	83 38 00             	cmpl   $0x0,(%eax)
f01010a4:	75 0f                	jne    f01010b5 <page_free+0x24>
	pp->pp_link = page_free_list;
f01010a6:	8b 15 6c 12 21 f0    	mov    0xf021126c,%edx
f01010ac:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010ae:	a3 6c 12 21 f0       	mov    %eax,0xf021126c
}
f01010b3:	c9                   	leave  
f01010b4:	c3                   	ret    
		panic("pp_ref != 0 or pp_link != NULL");
f01010b5:	83 ec 04             	sub    $0x4,%esp
f01010b8:	68 58 65 10 f0       	push   $0xf0106558
f01010bd:	68 93 01 00 00       	push   $0x193
f01010c2:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01010c7:	e8 74 ef ff ff       	call   f0100040 <_panic>

f01010cc <page_decref>:
{
f01010cc:	55                   	push   %ebp
f01010cd:	89 e5                	mov    %esp,%ebp
f01010cf:	83 ec 08             	sub    $0x8,%esp
f01010d2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010d5:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010d9:	83 e8 01             	sub    $0x1,%eax
f01010dc:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010e0:	66 85 c0             	test   %ax,%ax
f01010e3:	74 02                	je     f01010e7 <page_decref+0x1b>
}
f01010e5:	c9                   	leave  
f01010e6:	c3                   	ret    
		page_free(pp);
f01010e7:	83 ec 0c             	sub    $0xc,%esp
f01010ea:	52                   	push   %edx
f01010eb:	e8 a1 ff ff ff       	call   f0101091 <page_free>
f01010f0:	83 c4 10             	add    $0x10,%esp
}
f01010f3:	eb f0                	jmp    f01010e5 <page_decref+0x19>

f01010f5 <pgdir_walk>:
{
f01010f5:	55                   	push   %ebp
f01010f6:	89 e5                	mov    %esp,%ebp
f01010f8:	56                   	push   %esi
f01010f9:	53                   	push   %ebx
f01010fa:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t pde = pgdir[PDX(va)];
f01010fd:	89 f3                	mov    %esi,%ebx
f01010ff:	c1 eb 16             	shr    $0x16,%ebx
f0101102:	c1 e3 02             	shl    $0x2,%ebx
f0101105:	03 5d 08             	add    0x8(%ebp),%ebx
f0101108:	8b 03                	mov    (%ebx),%eax
	if (pde & PTE_P) {
f010110a:	a8 01                	test   $0x1,%al
f010110c:	75 12                	jne    f0101120 <pgdir_walk+0x2b>
	return NULL;
f010110e:	b8 00 00 00 00       	mov    $0x0,%eax
	else if (create == 1) {
f0101113:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0101117:	74 41                	je     f010115a <pgdir_walk+0x65>
}
f0101119:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010111c:	5b                   	pop    %ebx
f010111d:	5e                   	pop    %esi
f010111e:	5d                   	pop    %ebp
f010111f:	c3                   	ret    
		pde_t  * pt = (pde_t *)KADDR(PTE_ADDR(pde));
f0101120:	89 c2                	mov    %eax,%edx
f0101122:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101128:	c1 e8 0c             	shr    $0xc,%eax
f010112b:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0101131:	73 12                	jae    f0101145 <pgdir_walk+0x50>
		pte_t *pte_address = pt + PTX(va);
f0101133:	c1 ee 0a             	shr    $0xa,%esi
f0101136:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010113c:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
		return pte_address;
f0101143:	eb d4                	jmp    f0101119 <pgdir_walk+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101145:	52                   	push   %edx
f0101146:	68 c4 5c 10 f0       	push   $0xf0105cc4
f010114b:	68 c1 01 00 00       	push   $0x1c1
f0101150:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101155:	e8 e6 ee ff ff       	call   f0100040 <_panic>
		struct PageInfo * new_page = page_alloc(ALLOC_ZERO);
f010115a:	83 ec 0c             	sub    $0xc,%esp
f010115d:	6a 01                	push   $0x1
f010115f:	e8 b8 fe ff ff       	call   f010101c <page_alloc>
		if (new_page == NULL) {
f0101164:	83 c4 10             	add    $0x10,%esp
f0101167:	85 c0                	test   %eax,%eax
f0101169:	74 ae                	je     f0101119 <pgdir_walk+0x24>
		new_page->pp_ref++;
f010116b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101170:	89 c2                	mov    %eax,%edx
f0101172:	2b 15 58 12 21 f0    	sub    0xf0211258,%edx
f0101178:	c1 fa 03             	sar    $0x3,%edx
f010117b:	c1 e2 0c             	shl    $0xc,%edx
		pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f010117e:	83 ca 07             	or     $0x7,%edx
f0101181:	89 13                	mov    %edx,(%ebx)
f0101183:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101189:	c1 f8 03             	sar    $0x3,%eax
f010118c:	89 c2                	mov    %eax,%edx
f010118e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101191:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101196:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f010119c:	73 15                	jae    f01011b3 <pgdir_walk+0xbe>
		return (p + PTX(va));
f010119e:	c1 ee 0a             	shr    $0xa,%esi
f01011a1:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01011a7:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
f01011ae:	e9 66 ff ff ff       	jmp    f0101119 <pgdir_walk+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b3:	52                   	push   %edx
f01011b4:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01011b9:	6a 58                	push   $0x58
f01011bb:	68 fb 6d 10 f0       	push   $0xf0106dfb
f01011c0:	e8 7b ee ff ff       	call   f0100040 <_panic>

f01011c5 <boot_map_region>:
{
f01011c5:	55                   	push   %ebp
f01011c6:	89 e5                	mov    %esp,%ebp
f01011c8:	57                   	push   %edi
f01011c9:	56                   	push   %esi
f01011ca:	53                   	push   %ebx
f01011cb:	83 ec 1c             	sub    $0x1c,%esp
f01011ce:	89 c7                	mov    %eax,%edi
f01011d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01011d3:	89 ce                	mov    %ecx,%esi
	for (int i =0; i< size; i = i + PGSIZE) {
f01011d5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011da:	eb 2e                	jmp    f010120a <boot_map_region+0x45>
		pte_t * pte = pgdir_walk(pgdir,(const void *  )(va + i),1);
f01011dc:	83 ec 04             	sub    $0x4,%esp
f01011df:	6a 01                	push   $0x1
f01011e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011e4:	01 d8                	add    %ebx,%eax
f01011e6:	50                   	push   %eax
f01011e7:	57                   	push   %edi
f01011e8:	e8 08 ff ff ff       	call   f01010f5 <pgdir_walk>
f01011ed:	89 c2                	mov    %eax,%edx
		*pte = PTE_ADDR(pa + i) | perm | PTE_P;
f01011ef:	89 d8                	mov    %ebx,%eax
f01011f1:	03 45 08             	add    0x8(%ebp),%eax
f01011f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011f9:	0b 45 0c             	or     0xc(%ebp),%eax
f01011fc:	83 c8 01             	or     $0x1,%eax
f01011ff:	89 02                	mov    %eax,(%edx)
	for (int i =0; i< size; i = i + PGSIZE) {
f0101201:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101207:	83 c4 10             	add    $0x10,%esp
f010120a:	39 de                	cmp    %ebx,%esi
f010120c:	77 ce                	ja     f01011dc <boot_map_region+0x17>
}
f010120e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101211:	5b                   	pop    %ebx
f0101212:	5e                   	pop    %esi
f0101213:	5f                   	pop    %edi
f0101214:	5d                   	pop    %ebp
f0101215:	c3                   	ret    

f0101216 <page_lookup>:
{
f0101216:	55                   	push   %ebp
f0101217:	89 e5                	mov    %esp,%ebp
f0101219:	53                   	push   %ebx
f010121a:	83 ec 08             	sub    $0x8,%esp
f010121d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pte = pgdir_walk(pgdir,va,0);
f0101220:	6a 00                	push   $0x0
f0101222:	ff 75 0c             	push   0xc(%ebp)
f0101225:	ff 75 08             	push   0x8(%ebp)
f0101228:	e8 c8 fe ff ff       	call   f01010f5 <pgdir_walk>
	if(!pte) {
f010122d:	83 c4 10             	add    $0x10,%esp
f0101230:	85 c0                	test   %eax,%eax
f0101232:	74 21                	je     f0101255 <page_lookup+0x3f>
	else if ((*pte & PTE_P)== 0) {
f0101234:	f6 00 01             	testb  $0x1,(%eax)
f0101237:	74 35                	je     f010126e <page_lookup+0x58>
	if (pte_store != NULL) {
f0101239:	85 db                	test   %ebx,%ebx
f010123b:	74 02                	je     f010123f <page_lookup+0x29>
		*pte_store = pte;
f010123d:	89 03                	mov    %eax,(%ebx)
f010123f:	8b 00                	mov    (%eax),%eax
f0101241:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101244:	39 05 60 12 21 f0    	cmp    %eax,0xf0211260
f010124a:	76 0e                	jbe    f010125a <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010124c:	8b 15 58 12 21 f0    	mov    0xf0211258,%edx
f0101252:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101258:	c9                   	leave  
f0101259:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010125a:	83 ec 04             	sub    $0x4,%esp
f010125d:	68 78 65 10 f0       	push   $0xf0106578
f0101262:	6a 51                	push   $0x51
f0101264:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0101269:	e8 d2 ed ff ff       	call   f0100040 <_panic>
		return NULL;
f010126e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101273:	eb e0                	jmp    f0101255 <page_lookup+0x3f>

f0101275 <tlb_invalidate>:
{
f0101275:	55                   	push   %ebp
f0101276:	89 e5                	mov    %esp,%ebp
f0101278:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010127b:	e8 dc 43 00 00       	call   f010565c <cpunum>
f0101280:	6b c0 74             	imul   $0x74,%eax,%eax
f0101283:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f010128a:	74 16                	je     f01012a2 <tlb_invalidate+0x2d>
f010128c:	e8 cb 43 00 00       	call   f010565c <cpunum>
f0101291:	6b c0 74             	imul   $0x74,%eax,%eax
f0101294:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f010129a:	8b 55 08             	mov    0x8(%ebp),%edx
f010129d:	39 50 60             	cmp    %edx,0x60(%eax)
f01012a0:	75 06                	jne    f01012a8 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012a5:	0f 01 38             	invlpg (%eax)
}
f01012a8:	c9                   	leave  
f01012a9:	c3                   	ret    

f01012aa <page_remove>:
{
f01012aa:	55                   	push   %ebp
f01012ab:	89 e5                	mov    %esp,%ebp
f01012ad:	56                   	push   %esi
f01012ae:	53                   	push   %ebx
f01012af:	83 ec 14             	sub    $0x14,%esp
f01012b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo  * page = page_lookup(pgdir,va,&pte);
f01012b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012bb:	50                   	push   %eax
f01012bc:	56                   	push   %esi
f01012bd:	53                   	push   %ebx
f01012be:	e8 53 ff ff ff       	call   f0101216 <page_lookup>
	*pte = 0;
f01012c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01012c6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(page);
f01012cc:	89 04 24             	mov    %eax,(%esp)
f01012cf:	e8 f8 fd ff ff       	call   f01010cc <page_decref>
	tlb_invalidate(pgdir,va);
f01012d4:	83 c4 08             	add    $0x8,%esp
f01012d7:	56                   	push   %esi
f01012d8:	53                   	push   %ebx
f01012d9:	e8 97 ff ff ff       	call   f0101275 <tlb_invalidate>
}
f01012de:	83 c4 10             	add    $0x10,%esp
f01012e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012e4:	5b                   	pop    %ebx
f01012e5:	5e                   	pop    %esi
f01012e6:	5d                   	pop    %ebp
f01012e7:	c3                   	ret    

f01012e8 <page_insert>:
{
f01012e8:	55                   	push   %ebp
f01012e9:	89 e5                	mov    %esp,%ebp
f01012eb:	57                   	push   %edi
f01012ec:	56                   	push   %esi
f01012ed:	53                   	push   %ebx
f01012ee:	83 ec 10             	sub    $0x10,%esp
f01012f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012f4:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t * pte = pgdir_walk(pgdir,va,1);
f01012f7:	6a 01                	push   $0x1
f01012f9:	57                   	push   %edi
f01012fa:	ff 75 08             	push   0x8(%ebp)
f01012fd:	e8 f3 fd ff ff       	call   f01010f5 <pgdir_walk>
	if (pte == NULL) {
f0101302:	83 c4 10             	add    $0x10,%esp
f0101305:	85 c0                	test   %eax,%eax
f0101307:	74 4a                	je     f0101353 <page_insert+0x6b>
f0101309:	89 c6                	mov    %eax,%esi
		pp->pp_ref = pp->pp_ref + 1;
f010130b:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		if (*pte & PTE_P) {
f0101310:	f6 00 01             	testb  $0x1,(%eax)
f0101313:	75 21                	jne    f0101336 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f0101315:	2b 1d 58 12 21 f0    	sub    0xf0211258,%ebx
f010131b:	c1 fb 03             	sar    $0x3,%ebx
f010131e:	c1 e3 0c             	shl    $0xc,%ebx
		*pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f0101321:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101324:	83 cb 01             	or     $0x1,%ebx
f0101327:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101329:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010132e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101331:	5b                   	pop    %ebx
f0101332:	5e                   	pop    %esi
f0101333:	5f                   	pop    %edi
f0101334:	5d                   	pop    %ebp
f0101335:	c3                   	ret    
			page_remove(pgdir,va);
f0101336:	83 ec 08             	sub    $0x8,%esp
f0101339:	57                   	push   %edi
f010133a:	ff 75 08             	push   0x8(%ebp)
f010133d:	e8 68 ff ff ff       	call   f01012aa <page_remove>
			tlb_invalidate(pgdir,va);
f0101342:	83 c4 08             	add    $0x8,%esp
f0101345:	57                   	push   %edi
f0101346:	ff 75 08             	push   0x8(%ebp)
f0101349:	e8 27 ff ff ff       	call   f0101275 <tlb_invalidate>
f010134e:	83 c4 10             	add    $0x10,%esp
f0101351:	eb c2                	jmp    f0101315 <page_insert+0x2d>
		return -E_NO_MEM;
f0101353:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101358:	eb d4                	jmp    f010132e <page_insert+0x46>

f010135a <mmio_map_region>:
{
f010135a:	55                   	push   %ebp
f010135b:	89 e5                	mov    %esp,%ebp
f010135d:	53                   	push   %ebx
f010135e:	83 ec 04             	sub    $0x4,%esp
	if (base + ROUNDUP(size, PGSIZE) > MMIOLIM) {
f0101361:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101364:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010136a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101370:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f0101376:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101379:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010137e:	77 26                	ja     f01013a6 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, ROUNDUP(size, PGSIZE), pa, PTE_PCD | PTE_PWT | PTE_W);
f0101380:	83 ec 08             	sub    $0x8,%esp
f0101383:	6a 1a                	push   $0x1a
f0101385:	ff 75 08             	push   0x8(%ebp)
f0101388:	89 d9                	mov    %ebx,%ecx
f010138a:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f010138f:	e8 31 fe ff ff       	call   f01011c5 <boot_map_region>
	base += ROUNDUP(size, PGSIZE);
f0101394:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f0101399:	01 c3                	add    %eax,%ebx
f010139b:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
}
f01013a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013a4:	c9                   	leave  
f01013a5:	c3                   	ret    
		panic("mmio_map_region: Exceeding MMIOLIM");
f01013a6:	83 ec 04             	sub    $0x4,%esp
f01013a9:	68 98 65 10 f0       	push   $0xf0106598
f01013ae:	68 7a 02 00 00       	push   $0x27a
f01013b3:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01013b8:	e8 83 ec ff ff       	call   f0100040 <_panic>

f01013bd <mem_init>:
{
f01013bd:	55                   	push   %ebp
f01013be:	89 e5                	mov    %esp,%ebp
f01013c0:	57                   	push   %edi
f01013c1:	56                   	push   %esi
f01013c2:	53                   	push   %ebx
f01013c3:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01013c6:	b8 15 00 00 00       	mov    $0x15,%eax
f01013cb:	e8 fc f6 ff ff       	call   f0100acc <nvram_read>
f01013d0:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013d2:	b8 17 00 00 00       	mov    $0x17,%eax
f01013d7:	e8 f0 f6 ff ff       	call   f0100acc <nvram_read>
f01013dc:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013de:	b8 34 00 00 00       	mov    $0x34,%eax
f01013e3:	e8 e4 f6 ff ff       	call   f0100acc <nvram_read>
	if (ext16mem)
f01013e8:	c1 e0 06             	shl    $0x6,%eax
f01013eb:	0f 84 ed 00 00 00    	je     f01014de <mem_init+0x121>
		totalmem = 16 * 1024 + ext16mem;
f01013f1:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013f6:	89 c2                	mov    %eax,%edx
f01013f8:	c1 ea 02             	shr    $0x2,%edx
f01013fb:	89 15 60 12 21 f0    	mov    %edx,0xf0211260
	npages_basemem = basemem / (PGSIZE / 1024);
f0101401:	89 da                	mov    %ebx,%edx
f0101403:	c1 ea 02             	shr    $0x2,%edx
f0101406:	89 15 70 12 21 f0    	mov    %edx,0xf0211270
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010140c:	89 c2                	mov    %eax,%edx
f010140e:	29 da                	sub    %ebx,%edx
f0101410:	52                   	push   %edx
f0101411:	53                   	push   %ebx
f0101412:	50                   	push   %eax
f0101413:	68 bc 65 10 f0       	push   $0xf01065bc
f0101418:	e8 f9 25 00 00       	call   f0103a16 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010141d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101422:	e8 ce f6 ff ff       	call   f0100af5 <boot_alloc>
f0101427:	a3 5c 12 21 f0       	mov    %eax,0xf021125c
	memset(kern_pgdir, 0, PGSIZE);
f010142c:	83 c4 0c             	add    $0xc,%esp
f010142f:	68 00 10 00 00       	push   $0x1000
f0101434:	6a 00                	push   $0x0
f0101436:	50                   	push   %eax
f0101437:	e8 2c 3c 00 00       	call   f0105068 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010143c:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101441:	83 c4 10             	add    $0x10,%esp
f0101444:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101449:	0f 86 9f 00 00 00    	jbe    f01014ee <mem_init+0x131>
	return (physaddr_t)kva - KERNBASE;
f010144f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101455:	83 ca 05             	or     $0x5,%edx
f0101458:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE));
f010145e:	a1 60 12 21 f0       	mov    0xf0211260,%eax
f0101463:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010146a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010146f:	e8 81 f6 ff ff       	call   f0100af5 <boot_alloc>
f0101474:	a3 58 12 21 f0       	mov    %eax,0xf0211258
	memset(pages, 0, ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE));
f0101479:	83 ec 04             	sub    $0x4,%esp
f010147c:	8b 15 60 12 21 f0    	mov    0xf0211260,%edx
f0101482:	8d 14 d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edx
f0101489:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010148f:	52                   	push   %edx
f0101490:	6a 00                	push   $0x0
f0101492:	50                   	push   %eax
f0101493:	e8 d0 3b 00 00       	call   f0105068 <memset>
	envs = (struct Env *) boot_alloc(ROUNDUP(NENV * sizeof(struct Env), PGSIZE));
f0101498:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010149d:	e8 53 f6 ff ff       	call   f0100af5 <boot_alloc>
f01014a2:	a3 74 12 21 f0       	mov    %eax,0xf0211274
	memset(envs, 0, ROUNDUP(NENV * sizeof(struct Env), PGSIZE));
f01014a7:	83 c4 0c             	add    $0xc,%esp
f01014aa:	68 00 f0 01 00       	push   $0x1f000
f01014af:	6a 00                	push   $0x0
f01014b1:	50                   	push   %eax
f01014b2:	e8 b1 3b 00 00       	call   f0105068 <memset>
	page_init();
f01014b7:	e8 13 fa ff ff       	call   f0100ecf <page_init>
	check_page_free_list(1);
f01014bc:	b8 01 00 00 00       	mov    $0x1,%eax
f01014c1:	e8 1b f7 ff ff       	call   f0100be1 <check_page_free_list>
	if (!pages)
f01014c6:	83 c4 10             	add    $0x10,%esp
f01014c9:	83 3d 58 12 21 f0 00 	cmpl   $0x0,0xf0211258
f01014d0:	74 31                	je     f0101503 <mem_init+0x146>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014d2:	a1 6c 12 21 f0       	mov    0xf021126c,%eax
f01014d7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014dc:	eb 41                	jmp    f010151f <mem_init+0x162>
		totalmem = 1 * 1024 + extmem;
f01014de:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014e4:	85 f6                	test   %esi,%esi
f01014e6:	0f 44 c3             	cmove  %ebx,%eax
f01014e9:	e9 08 ff ff ff       	jmp    f01013f6 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014ee:	50                   	push   %eax
f01014ef:	68 e8 5c 10 f0       	push   $0xf0105ce8
f01014f4:	68 9c 00 00 00       	push   $0x9c
f01014f9:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01014fe:	e8 3d eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101503:	83 ec 04             	sub    $0x4,%esp
f0101506:	68 c2 6e 10 f0       	push   $0xf0106ec2
f010150b:	68 08 03 00 00       	push   $0x308
f0101510:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101515:	e8 26 eb ff ff       	call   f0100040 <_panic>
		++nfree;
f010151a:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010151d:	8b 00                	mov    (%eax),%eax
f010151f:	85 c0                	test   %eax,%eax
f0101521:	75 f7                	jne    f010151a <mem_init+0x15d>
	assert((pp0 = page_alloc(0)));
f0101523:	83 ec 0c             	sub    $0xc,%esp
f0101526:	6a 00                	push   $0x0
f0101528:	e8 ef fa ff ff       	call   f010101c <page_alloc>
f010152d:	89 c7                	mov    %eax,%edi
f010152f:	83 c4 10             	add    $0x10,%esp
f0101532:	85 c0                	test   %eax,%eax
f0101534:	0f 84 1f 02 00 00    	je     f0101759 <mem_init+0x39c>
	assert((pp1 = page_alloc(0)));
f010153a:	83 ec 0c             	sub    $0xc,%esp
f010153d:	6a 00                	push   $0x0
f010153f:	e8 d8 fa ff ff       	call   f010101c <page_alloc>
f0101544:	89 c6                	mov    %eax,%esi
f0101546:	83 c4 10             	add    $0x10,%esp
f0101549:	85 c0                	test   %eax,%eax
f010154b:	0f 84 21 02 00 00    	je     f0101772 <mem_init+0x3b5>
	assert((pp2 = page_alloc(0)));
f0101551:	83 ec 0c             	sub    $0xc,%esp
f0101554:	6a 00                	push   $0x0
f0101556:	e8 c1 fa ff ff       	call   f010101c <page_alloc>
f010155b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010155e:	83 c4 10             	add    $0x10,%esp
f0101561:	85 c0                	test   %eax,%eax
f0101563:	0f 84 22 02 00 00    	je     f010178b <mem_init+0x3ce>
	assert(pp1 && pp1 != pp0);
f0101569:	39 f7                	cmp    %esi,%edi
f010156b:	0f 84 33 02 00 00    	je     f01017a4 <mem_init+0x3e7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101571:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101574:	39 c7                	cmp    %eax,%edi
f0101576:	0f 84 41 02 00 00    	je     f01017bd <mem_init+0x400>
f010157c:	39 c6                	cmp    %eax,%esi
f010157e:	0f 84 39 02 00 00    	je     f01017bd <mem_init+0x400>
	return (pp - pages) << PGSHIFT;
f0101584:	8b 0d 58 12 21 f0    	mov    0xf0211258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010158a:	8b 15 60 12 21 f0    	mov    0xf0211260,%edx
f0101590:	c1 e2 0c             	shl    $0xc,%edx
f0101593:	89 f8                	mov    %edi,%eax
f0101595:	29 c8                	sub    %ecx,%eax
f0101597:	c1 f8 03             	sar    $0x3,%eax
f010159a:	c1 e0 0c             	shl    $0xc,%eax
f010159d:	39 d0                	cmp    %edx,%eax
f010159f:	0f 83 31 02 00 00    	jae    f01017d6 <mem_init+0x419>
f01015a5:	89 f0                	mov    %esi,%eax
f01015a7:	29 c8                	sub    %ecx,%eax
f01015a9:	c1 f8 03             	sar    $0x3,%eax
f01015ac:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015af:	39 c2                	cmp    %eax,%edx
f01015b1:	0f 86 38 02 00 00    	jbe    f01017ef <mem_init+0x432>
f01015b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015ba:	29 c8                	sub    %ecx,%eax
f01015bc:	c1 f8 03             	sar    $0x3,%eax
f01015bf:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01015c2:	39 c2                	cmp    %eax,%edx
f01015c4:	0f 86 3e 02 00 00    	jbe    f0101808 <mem_init+0x44b>
	fl = page_free_list;
f01015ca:	a1 6c 12 21 f0       	mov    0xf021126c,%eax
f01015cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015d2:	c7 05 6c 12 21 f0 00 	movl   $0x0,0xf021126c
f01015d9:	00 00 00 
	assert(!page_alloc(0));
f01015dc:	83 ec 0c             	sub    $0xc,%esp
f01015df:	6a 00                	push   $0x0
f01015e1:	e8 36 fa ff ff       	call   f010101c <page_alloc>
f01015e6:	83 c4 10             	add    $0x10,%esp
f01015e9:	85 c0                	test   %eax,%eax
f01015eb:	0f 85 30 02 00 00    	jne    f0101821 <mem_init+0x464>
	page_free(pp0);
f01015f1:	83 ec 0c             	sub    $0xc,%esp
f01015f4:	57                   	push   %edi
f01015f5:	e8 97 fa ff ff       	call   f0101091 <page_free>
	page_free(pp1);
f01015fa:	89 34 24             	mov    %esi,(%esp)
f01015fd:	e8 8f fa ff ff       	call   f0101091 <page_free>
	page_free(pp2);
f0101602:	83 c4 04             	add    $0x4,%esp
f0101605:	ff 75 d4             	push   -0x2c(%ebp)
f0101608:	e8 84 fa ff ff       	call   f0101091 <page_free>
	assert((pp0 = page_alloc(0)));
f010160d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101614:	e8 03 fa ff ff       	call   f010101c <page_alloc>
f0101619:	89 c6                	mov    %eax,%esi
f010161b:	83 c4 10             	add    $0x10,%esp
f010161e:	85 c0                	test   %eax,%eax
f0101620:	0f 84 14 02 00 00    	je     f010183a <mem_init+0x47d>
	assert((pp1 = page_alloc(0)));
f0101626:	83 ec 0c             	sub    $0xc,%esp
f0101629:	6a 00                	push   $0x0
f010162b:	e8 ec f9 ff ff       	call   f010101c <page_alloc>
f0101630:	89 c7                	mov    %eax,%edi
f0101632:	83 c4 10             	add    $0x10,%esp
f0101635:	85 c0                	test   %eax,%eax
f0101637:	0f 84 16 02 00 00    	je     f0101853 <mem_init+0x496>
	assert((pp2 = page_alloc(0)));
f010163d:	83 ec 0c             	sub    $0xc,%esp
f0101640:	6a 00                	push   $0x0
f0101642:	e8 d5 f9 ff ff       	call   f010101c <page_alloc>
f0101647:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010164a:	83 c4 10             	add    $0x10,%esp
f010164d:	85 c0                	test   %eax,%eax
f010164f:	0f 84 17 02 00 00    	je     f010186c <mem_init+0x4af>
	assert(pp1 && pp1 != pp0);
f0101655:	39 fe                	cmp    %edi,%esi
f0101657:	0f 84 28 02 00 00    	je     f0101885 <mem_init+0x4c8>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010165d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101660:	39 c7                	cmp    %eax,%edi
f0101662:	0f 84 36 02 00 00    	je     f010189e <mem_init+0x4e1>
f0101668:	39 c6                	cmp    %eax,%esi
f010166a:	0f 84 2e 02 00 00    	je     f010189e <mem_init+0x4e1>
	assert(!page_alloc(0));
f0101670:	83 ec 0c             	sub    $0xc,%esp
f0101673:	6a 00                	push   $0x0
f0101675:	e8 a2 f9 ff ff       	call   f010101c <page_alloc>
f010167a:	83 c4 10             	add    $0x10,%esp
f010167d:	85 c0                	test   %eax,%eax
f010167f:	0f 85 32 02 00 00    	jne    f01018b7 <mem_init+0x4fa>
f0101685:	89 f0                	mov    %esi,%eax
f0101687:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f010168d:	c1 f8 03             	sar    $0x3,%eax
f0101690:	89 c2                	mov    %eax,%edx
f0101692:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101695:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010169a:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f01016a0:	0f 83 2a 02 00 00    	jae    f01018d0 <mem_init+0x513>
	memset(page2kva(pp0), 1, PGSIZE);
f01016a6:	83 ec 04             	sub    $0x4,%esp
f01016a9:	68 00 10 00 00       	push   $0x1000
f01016ae:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016b0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01016b6:	52                   	push   %edx
f01016b7:	e8 ac 39 00 00       	call   f0105068 <memset>
	page_free(pp0);
f01016bc:	89 34 24             	mov    %esi,(%esp)
f01016bf:	e8 cd f9 ff ff       	call   f0101091 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016cb:	e8 4c f9 ff ff       	call   f010101c <page_alloc>
f01016d0:	83 c4 10             	add    $0x10,%esp
f01016d3:	85 c0                	test   %eax,%eax
f01016d5:	0f 84 07 02 00 00    	je     f01018e2 <mem_init+0x525>
	assert(pp && pp0 == pp);
f01016db:	39 c6                	cmp    %eax,%esi
f01016dd:	0f 85 18 02 00 00    	jne    f01018fb <mem_init+0x53e>
	return (pp - pages) << PGSHIFT;
f01016e3:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f01016e9:	c1 f8 03             	sar    $0x3,%eax
f01016ec:	89 c2                	mov    %eax,%edx
f01016ee:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016f1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016f6:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f01016fc:	0f 83 12 02 00 00    	jae    f0101914 <mem_init+0x557>
	return (void *)(pa + KERNBASE);
f0101702:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101708:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010170e:	80 38 00             	cmpb   $0x0,(%eax)
f0101711:	0f 85 0f 02 00 00    	jne    f0101926 <mem_init+0x569>
	for (i = 0; i < PGSIZE; i++)
f0101717:	83 c0 01             	add    $0x1,%eax
f010171a:	39 d0                	cmp    %edx,%eax
f010171c:	75 f0                	jne    f010170e <mem_init+0x351>
	page_free_list = fl;
f010171e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101721:	a3 6c 12 21 f0       	mov    %eax,0xf021126c
	page_free(pp0);
f0101726:	83 ec 0c             	sub    $0xc,%esp
f0101729:	56                   	push   %esi
f010172a:	e8 62 f9 ff ff       	call   f0101091 <page_free>
	page_free(pp1);
f010172f:	89 3c 24             	mov    %edi,(%esp)
f0101732:	e8 5a f9 ff ff       	call   f0101091 <page_free>
	page_free(pp2);
f0101737:	83 c4 04             	add    $0x4,%esp
f010173a:	ff 75 d4             	push   -0x2c(%ebp)
f010173d:	e8 4f f9 ff ff       	call   f0101091 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101742:	a1 6c 12 21 f0       	mov    0xf021126c,%eax
f0101747:	83 c4 10             	add    $0x10,%esp
f010174a:	85 c0                	test   %eax,%eax
f010174c:	0f 84 ed 01 00 00    	je     f010193f <mem_init+0x582>
		--nfree;
f0101752:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101755:	8b 00                	mov    (%eax),%eax
f0101757:	eb f1                	jmp    f010174a <mem_init+0x38d>
	assert((pp0 = page_alloc(0)));
f0101759:	68 dd 6e 10 f0       	push   $0xf0106edd
f010175e:	68 15 6e 10 f0       	push   $0xf0106e15
f0101763:	68 10 03 00 00       	push   $0x310
f0101768:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010176d:	e8 ce e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101772:	68 f3 6e 10 f0       	push   $0xf0106ef3
f0101777:	68 15 6e 10 f0       	push   $0xf0106e15
f010177c:	68 11 03 00 00       	push   $0x311
f0101781:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101786:	e8 b5 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010178b:	68 09 6f 10 f0       	push   $0xf0106f09
f0101790:	68 15 6e 10 f0       	push   $0xf0106e15
f0101795:	68 12 03 00 00       	push   $0x312
f010179a:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010179f:	e8 9c e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01017a4:	68 1f 6f 10 f0       	push   $0xf0106f1f
f01017a9:	68 15 6e 10 f0       	push   $0xf0106e15
f01017ae:	68 15 03 00 00       	push   $0x315
f01017b3:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01017b8:	e8 83 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017bd:	68 f8 65 10 f0       	push   $0xf01065f8
f01017c2:	68 15 6e 10 f0       	push   $0xf0106e15
f01017c7:	68 16 03 00 00       	push   $0x316
f01017cc:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01017d1:	e8 6a e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01017d6:	68 31 6f 10 f0       	push   $0xf0106f31
f01017db:	68 15 6e 10 f0       	push   $0xf0106e15
f01017e0:	68 17 03 00 00       	push   $0x317
f01017e5:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01017ea:	e8 51 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017ef:	68 4e 6f 10 f0       	push   $0xf0106f4e
f01017f4:	68 15 6e 10 f0       	push   $0xf0106e15
f01017f9:	68 18 03 00 00       	push   $0x318
f01017fe:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101803:	e8 38 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101808:	68 6b 6f 10 f0       	push   $0xf0106f6b
f010180d:	68 15 6e 10 f0       	push   $0xf0106e15
f0101812:	68 19 03 00 00       	push   $0x319
f0101817:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010181c:	e8 1f e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101821:	68 88 6f 10 f0       	push   $0xf0106f88
f0101826:	68 15 6e 10 f0       	push   $0xf0106e15
f010182b:	68 20 03 00 00       	push   $0x320
f0101830:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101835:	e8 06 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010183a:	68 dd 6e 10 f0       	push   $0xf0106edd
f010183f:	68 15 6e 10 f0       	push   $0xf0106e15
f0101844:	68 27 03 00 00       	push   $0x327
f0101849:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010184e:	e8 ed e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101853:	68 f3 6e 10 f0       	push   $0xf0106ef3
f0101858:	68 15 6e 10 f0       	push   $0xf0106e15
f010185d:	68 28 03 00 00       	push   $0x328
f0101862:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101867:	e8 d4 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010186c:	68 09 6f 10 f0       	push   $0xf0106f09
f0101871:	68 15 6e 10 f0       	push   $0xf0106e15
f0101876:	68 29 03 00 00       	push   $0x329
f010187b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101880:	e8 bb e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101885:	68 1f 6f 10 f0       	push   $0xf0106f1f
f010188a:	68 15 6e 10 f0       	push   $0xf0106e15
f010188f:	68 2b 03 00 00       	push   $0x32b
f0101894:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0101899:	e8 a2 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010189e:	68 f8 65 10 f0       	push   $0xf01065f8
f01018a3:	68 15 6e 10 f0       	push   $0xf0106e15
f01018a8:	68 2c 03 00 00       	push   $0x32c
f01018ad:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01018b2:	e8 89 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01018b7:	68 88 6f 10 f0       	push   $0xf0106f88
f01018bc:	68 15 6e 10 f0       	push   $0xf0106e15
f01018c1:	68 2d 03 00 00       	push   $0x32d
f01018c6:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01018cb:	e8 70 e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d0:	52                   	push   %edx
f01018d1:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01018d6:	6a 58                	push   $0x58
f01018d8:	68 fb 6d 10 f0       	push   $0xf0106dfb
f01018dd:	e8 5e e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018e2:	68 97 6f 10 f0       	push   $0xf0106f97
f01018e7:	68 15 6e 10 f0       	push   $0xf0106e15
f01018ec:	68 32 03 00 00       	push   $0x332
f01018f1:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01018f6:	e8 45 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018fb:	68 b5 6f 10 f0       	push   $0xf0106fb5
f0101900:	68 15 6e 10 f0       	push   $0xf0106e15
f0101905:	68 33 03 00 00       	push   $0x333
f010190a:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010190f:	e8 2c e7 ff ff       	call   f0100040 <_panic>
f0101914:	52                   	push   %edx
f0101915:	68 c4 5c 10 f0       	push   $0xf0105cc4
f010191a:	6a 58                	push   $0x58
f010191c:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0101921:	e8 1a e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101926:	68 c5 6f 10 f0       	push   $0xf0106fc5
f010192b:	68 15 6e 10 f0       	push   $0xf0106e15
f0101930:	68 36 03 00 00       	push   $0x336
f0101935:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010193a:	e8 01 e7 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f010193f:	85 db                	test   %ebx,%ebx
f0101941:	0f 85 3f 09 00 00    	jne    f0102286 <mem_init+0xec9>
	cprintf("check_page_alloc() succeeded!\n");
f0101947:	83 ec 0c             	sub    $0xc,%esp
f010194a:	68 18 66 10 f0       	push   $0xf0106618
f010194f:	e8 c2 20 00 00       	call   f0103a16 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101954:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010195b:	e8 bc f6 ff ff       	call   f010101c <page_alloc>
f0101960:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101963:	83 c4 10             	add    $0x10,%esp
f0101966:	85 c0                	test   %eax,%eax
f0101968:	0f 84 31 09 00 00    	je     f010229f <mem_init+0xee2>
	assert((pp1 = page_alloc(0)));
f010196e:	83 ec 0c             	sub    $0xc,%esp
f0101971:	6a 00                	push   $0x0
f0101973:	e8 a4 f6 ff ff       	call   f010101c <page_alloc>
f0101978:	89 c3                	mov    %eax,%ebx
f010197a:	83 c4 10             	add    $0x10,%esp
f010197d:	85 c0                	test   %eax,%eax
f010197f:	0f 84 33 09 00 00    	je     f01022b8 <mem_init+0xefb>
	assert((pp2 = page_alloc(0)));
f0101985:	83 ec 0c             	sub    $0xc,%esp
f0101988:	6a 00                	push   $0x0
f010198a:	e8 8d f6 ff ff       	call   f010101c <page_alloc>
f010198f:	89 c6                	mov    %eax,%esi
f0101991:	83 c4 10             	add    $0x10,%esp
f0101994:	85 c0                	test   %eax,%eax
f0101996:	0f 84 35 09 00 00    	je     f01022d1 <mem_init+0xf14>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010199c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010199f:	0f 84 45 09 00 00    	je     f01022ea <mem_init+0xf2d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019a5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019a8:	0f 84 55 09 00 00    	je     f0102303 <mem_init+0xf46>
f01019ae:	39 c3                	cmp    %eax,%ebx
f01019b0:	0f 84 4d 09 00 00    	je     f0102303 <mem_init+0xf46>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019b6:	a1 6c 12 21 f0       	mov    0xf021126c,%eax
f01019bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01019be:	c7 05 6c 12 21 f0 00 	movl   $0x0,0xf021126c
f01019c5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019c8:	83 ec 0c             	sub    $0xc,%esp
f01019cb:	6a 00                	push   $0x0
f01019cd:	e8 4a f6 ff ff       	call   f010101c <page_alloc>
f01019d2:	83 c4 10             	add    $0x10,%esp
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	0f 85 3f 09 00 00    	jne    f010231c <mem_init+0xf5f>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019dd:	83 ec 04             	sub    $0x4,%esp
f01019e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019e3:	50                   	push   %eax
f01019e4:	6a 00                	push   $0x0
f01019e6:	ff 35 5c 12 21 f0    	push   0xf021125c
f01019ec:	e8 25 f8 ff ff       	call   f0101216 <page_lookup>
f01019f1:	83 c4 10             	add    $0x10,%esp
f01019f4:	85 c0                	test   %eax,%eax
f01019f6:	0f 85 39 09 00 00    	jne    f0102335 <mem_init+0xf78>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019fc:	6a 02                	push   $0x2
f01019fe:	6a 00                	push   $0x0
f0101a00:	53                   	push   %ebx
f0101a01:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101a07:	e8 dc f8 ff ff       	call   f01012e8 <page_insert>
f0101a0c:	83 c4 10             	add    $0x10,%esp
f0101a0f:	85 c0                	test   %eax,%eax
f0101a11:	0f 89 37 09 00 00    	jns    f010234e <mem_init+0xf91>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a17:	83 ec 0c             	sub    $0xc,%esp
f0101a1a:	ff 75 d4             	push   -0x2c(%ebp)
f0101a1d:	e8 6f f6 ff ff       	call   f0101091 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a22:	6a 02                	push   $0x2
f0101a24:	6a 00                	push   $0x0
f0101a26:	53                   	push   %ebx
f0101a27:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101a2d:	e8 b6 f8 ff ff       	call   f01012e8 <page_insert>
f0101a32:	83 c4 20             	add    $0x20,%esp
f0101a35:	85 c0                	test   %eax,%eax
f0101a37:	0f 85 2a 09 00 00    	jne    f0102367 <mem_init+0xfaa>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a3d:	8b 3d 5c 12 21 f0    	mov    0xf021125c,%edi
	return (pp - pages) << PGSHIFT;
f0101a43:	8b 0d 58 12 21 f0    	mov    0xf0211258,%ecx
f0101a49:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101a4c:	8b 17                	mov    (%edi),%edx
f0101a4e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a57:	29 c8                	sub    %ecx,%eax
f0101a59:	c1 f8 03             	sar    $0x3,%eax
f0101a5c:	c1 e0 0c             	shl    $0xc,%eax
f0101a5f:	39 c2                	cmp    %eax,%edx
f0101a61:	0f 85 19 09 00 00    	jne    f0102380 <mem_init+0xfc3>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a67:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a6c:	89 f8                	mov    %edi,%eax
f0101a6e:	e8 0b f1 ff ff       	call   f0100b7e <check_va2pa>
f0101a73:	89 c2                	mov    %eax,%edx
f0101a75:	89 d8                	mov    %ebx,%eax
f0101a77:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101a7a:	c1 f8 03             	sar    $0x3,%eax
f0101a7d:	c1 e0 0c             	shl    $0xc,%eax
f0101a80:	39 c2                	cmp    %eax,%edx
f0101a82:	0f 85 11 09 00 00    	jne    f0102399 <mem_init+0xfdc>
	assert(pp1->pp_ref == 1);
f0101a88:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a8d:	0f 85 1f 09 00 00    	jne    f01023b2 <mem_init+0xff5>
	assert(pp0->pp_ref == 1);
f0101a93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a96:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a9b:	0f 85 2a 09 00 00    	jne    f01023cb <mem_init+0x100e>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aa1:	6a 02                	push   $0x2
f0101aa3:	68 00 10 00 00       	push   $0x1000
f0101aa8:	56                   	push   %esi
f0101aa9:	57                   	push   %edi
f0101aaa:	e8 39 f8 ff ff       	call   f01012e8 <page_insert>
f0101aaf:	83 c4 10             	add    $0x10,%esp
f0101ab2:	85 c0                	test   %eax,%eax
f0101ab4:	0f 85 2a 09 00 00    	jne    f01023e4 <mem_init+0x1027>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aba:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101abf:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0101ac4:	e8 b5 f0 ff ff       	call   f0100b7e <check_va2pa>
f0101ac9:	89 c2                	mov    %eax,%edx
f0101acb:	89 f0                	mov    %esi,%eax
f0101acd:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101ad3:	c1 f8 03             	sar    $0x3,%eax
f0101ad6:	c1 e0 0c             	shl    $0xc,%eax
f0101ad9:	39 c2                	cmp    %eax,%edx
f0101adb:	0f 85 1c 09 00 00    	jne    f01023fd <mem_init+0x1040>
	assert(pp2->pp_ref == 1);
f0101ae1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ae6:	0f 85 2a 09 00 00    	jne    f0102416 <mem_init+0x1059>

	// should be no free memory
	assert(!page_alloc(0));
f0101aec:	83 ec 0c             	sub    $0xc,%esp
f0101aef:	6a 00                	push   $0x0
f0101af1:	e8 26 f5 ff ff       	call   f010101c <page_alloc>
f0101af6:	83 c4 10             	add    $0x10,%esp
f0101af9:	85 c0                	test   %eax,%eax
f0101afb:	0f 85 2e 09 00 00    	jne    f010242f <mem_init+0x1072>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b01:	6a 02                	push   $0x2
f0101b03:	68 00 10 00 00       	push   $0x1000
f0101b08:	56                   	push   %esi
f0101b09:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101b0f:	e8 d4 f7 ff ff       	call   f01012e8 <page_insert>
f0101b14:	83 c4 10             	add    $0x10,%esp
f0101b17:	85 c0                	test   %eax,%eax
f0101b19:	0f 85 29 09 00 00    	jne    f0102448 <mem_init+0x108b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b1f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b24:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0101b29:	e8 50 f0 ff ff       	call   f0100b7e <check_va2pa>
f0101b2e:	89 c2                	mov    %eax,%edx
f0101b30:	89 f0                	mov    %esi,%eax
f0101b32:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101b38:	c1 f8 03             	sar    $0x3,%eax
f0101b3b:	c1 e0 0c             	shl    $0xc,%eax
f0101b3e:	39 c2                	cmp    %eax,%edx
f0101b40:	0f 85 1b 09 00 00    	jne    f0102461 <mem_init+0x10a4>
	assert(pp2->pp_ref == 1);
f0101b46:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b4b:	0f 85 29 09 00 00    	jne    f010247a <mem_init+0x10bd>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b51:	83 ec 0c             	sub    $0xc,%esp
f0101b54:	6a 00                	push   $0x0
f0101b56:	e8 c1 f4 ff ff       	call   f010101c <page_alloc>
f0101b5b:	83 c4 10             	add    $0x10,%esp
f0101b5e:	85 c0                	test   %eax,%eax
f0101b60:	0f 85 2d 09 00 00    	jne    f0102493 <mem_init+0x10d6>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b66:	8b 15 5c 12 21 f0    	mov    0xf021125c,%edx
f0101b6c:	8b 02                	mov    (%edx),%eax
f0101b6e:	89 c7                	mov    %eax,%edi
f0101b70:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101b76:	c1 e8 0c             	shr    $0xc,%eax
f0101b79:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0101b7f:	0f 83 27 09 00 00    	jae    f01024ac <mem_init+0x10ef>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b85:	83 ec 04             	sub    $0x4,%esp
f0101b88:	6a 00                	push   $0x0
f0101b8a:	68 00 10 00 00       	push   $0x1000
f0101b8f:	52                   	push   %edx
f0101b90:	e8 60 f5 ff ff       	call   f01010f5 <pgdir_walk>
f0101b95:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101b9b:	83 c4 10             	add    $0x10,%esp
f0101b9e:	39 f8                	cmp    %edi,%eax
f0101ba0:	0f 85 1b 09 00 00    	jne    f01024c1 <mem_init+0x1104>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ba6:	6a 06                	push   $0x6
f0101ba8:	68 00 10 00 00       	push   $0x1000
f0101bad:	56                   	push   %esi
f0101bae:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101bb4:	e8 2f f7 ff ff       	call   f01012e8 <page_insert>
f0101bb9:	83 c4 10             	add    $0x10,%esp
f0101bbc:	85 c0                	test   %eax,%eax
f0101bbe:	0f 85 16 09 00 00    	jne    f01024da <mem_init+0x111d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bc4:	8b 3d 5c 12 21 f0    	mov    0xf021125c,%edi
f0101bca:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bcf:	89 f8                	mov    %edi,%eax
f0101bd1:	e8 a8 ef ff ff       	call   f0100b7e <check_va2pa>
f0101bd6:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101bd8:	89 f0                	mov    %esi,%eax
f0101bda:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101be0:	c1 f8 03             	sar    $0x3,%eax
f0101be3:	c1 e0 0c             	shl    $0xc,%eax
f0101be6:	39 c2                	cmp    %eax,%edx
f0101be8:	0f 85 05 09 00 00    	jne    f01024f3 <mem_init+0x1136>
	assert(pp2->pp_ref == 1);
f0101bee:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bf3:	0f 85 13 09 00 00    	jne    f010250c <mem_init+0x114f>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bf9:	83 ec 04             	sub    $0x4,%esp
f0101bfc:	6a 00                	push   $0x0
f0101bfe:	68 00 10 00 00       	push   $0x1000
f0101c03:	57                   	push   %edi
f0101c04:	e8 ec f4 ff ff       	call   f01010f5 <pgdir_walk>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	f6 00 04             	testb  $0x4,(%eax)
f0101c0f:	0f 84 10 09 00 00    	je     f0102525 <mem_init+0x1168>
	assert(kern_pgdir[0] & PTE_U);
f0101c15:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0101c1a:	f6 00 04             	testb  $0x4,(%eax)
f0101c1d:	0f 84 1b 09 00 00    	je     f010253e <mem_init+0x1181>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c23:	6a 02                	push   $0x2
f0101c25:	68 00 10 00 00       	push   $0x1000
f0101c2a:	56                   	push   %esi
f0101c2b:	50                   	push   %eax
f0101c2c:	e8 b7 f6 ff ff       	call   f01012e8 <page_insert>
f0101c31:	83 c4 10             	add    $0x10,%esp
f0101c34:	85 c0                	test   %eax,%eax
f0101c36:	0f 85 1b 09 00 00    	jne    f0102557 <mem_init+0x119a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c3c:	83 ec 04             	sub    $0x4,%esp
f0101c3f:	6a 00                	push   $0x0
f0101c41:	68 00 10 00 00       	push   $0x1000
f0101c46:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101c4c:	e8 a4 f4 ff ff       	call   f01010f5 <pgdir_walk>
f0101c51:	83 c4 10             	add    $0x10,%esp
f0101c54:	f6 00 02             	testb  $0x2,(%eax)
f0101c57:	0f 84 13 09 00 00    	je     f0102570 <mem_init+0x11b3>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c5d:	83 ec 04             	sub    $0x4,%esp
f0101c60:	6a 00                	push   $0x0
f0101c62:	68 00 10 00 00       	push   $0x1000
f0101c67:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101c6d:	e8 83 f4 ff ff       	call   f01010f5 <pgdir_walk>
f0101c72:	83 c4 10             	add    $0x10,%esp
f0101c75:	f6 00 04             	testb  $0x4,(%eax)
f0101c78:	0f 85 0b 09 00 00    	jne    f0102589 <mem_init+0x11cc>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c7e:	6a 02                	push   $0x2
f0101c80:	68 00 00 40 00       	push   $0x400000
f0101c85:	ff 75 d4             	push   -0x2c(%ebp)
f0101c88:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101c8e:	e8 55 f6 ff ff       	call   f01012e8 <page_insert>
f0101c93:	83 c4 10             	add    $0x10,%esp
f0101c96:	85 c0                	test   %eax,%eax
f0101c98:	0f 89 04 09 00 00    	jns    f01025a2 <mem_init+0x11e5>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c9e:	6a 02                	push   $0x2
f0101ca0:	68 00 10 00 00       	push   $0x1000
f0101ca5:	53                   	push   %ebx
f0101ca6:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101cac:	e8 37 f6 ff ff       	call   f01012e8 <page_insert>
f0101cb1:	83 c4 10             	add    $0x10,%esp
f0101cb4:	85 c0                	test   %eax,%eax
f0101cb6:	0f 85 ff 08 00 00    	jne    f01025bb <mem_init+0x11fe>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cbc:	83 ec 04             	sub    $0x4,%esp
f0101cbf:	6a 00                	push   $0x0
f0101cc1:	68 00 10 00 00       	push   $0x1000
f0101cc6:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101ccc:	e8 24 f4 ff ff       	call   f01010f5 <pgdir_walk>
f0101cd1:	83 c4 10             	add    $0x10,%esp
f0101cd4:	f6 00 04             	testb  $0x4,(%eax)
f0101cd7:	0f 85 f7 08 00 00    	jne    f01025d4 <mem_init+0x1217>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cdd:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0101ce2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ce5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cea:	e8 8f ee ff ff       	call   f0100b7e <check_va2pa>
f0101cef:	89 df                	mov    %ebx,%edi
f0101cf1:	2b 3d 58 12 21 f0    	sub    0xf0211258,%edi
f0101cf7:	c1 ff 03             	sar    $0x3,%edi
f0101cfa:	c1 e7 0c             	shl    $0xc,%edi
f0101cfd:	39 f8                	cmp    %edi,%eax
f0101cff:	0f 85 e8 08 00 00    	jne    f01025ed <mem_init+0x1230>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d0d:	e8 6c ee ff ff       	call   f0100b7e <check_va2pa>
f0101d12:	39 c7                	cmp    %eax,%edi
f0101d14:	0f 85 ec 08 00 00    	jne    f0102606 <mem_init+0x1249>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d1a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d1f:	0f 85 fa 08 00 00    	jne    f010261f <mem_init+0x1262>
	assert(pp2->pp_ref == 0);
f0101d25:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d2a:	0f 85 08 09 00 00    	jne    f0102638 <mem_init+0x127b>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d30:	83 ec 0c             	sub    $0xc,%esp
f0101d33:	6a 00                	push   $0x0
f0101d35:	e8 e2 f2 ff ff       	call   f010101c <page_alloc>
f0101d3a:	83 c4 10             	add    $0x10,%esp
f0101d3d:	85 c0                	test   %eax,%eax
f0101d3f:	0f 84 0c 09 00 00    	je     f0102651 <mem_init+0x1294>
f0101d45:	39 c6                	cmp    %eax,%esi
f0101d47:	0f 85 04 09 00 00    	jne    f0102651 <mem_init+0x1294>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d4d:	83 ec 08             	sub    $0x8,%esp
f0101d50:	6a 00                	push   $0x0
f0101d52:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101d58:	e8 4d f5 ff ff       	call   f01012aa <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d5d:	8b 3d 5c 12 21 f0    	mov    0xf021125c,%edi
f0101d63:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d68:	89 f8                	mov    %edi,%eax
f0101d6a:	e8 0f ee ff ff       	call   f0100b7e <check_va2pa>
f0101d6f:	83 c4 10             	add    $0x10,%esp
f0101d72:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d75:	0f 85 ef 08 00 00    	jne    f010266a <mem_init+0x12ad>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d7b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d80:	89 f8                	mov    %edi,%eax
f0101d82:	e8 f7 ed ff ff       	call   f0100b7e <check_va2pa>
f0101d87:	89 c2                	mov    %eax,%edx
f0101d89:	89 d8                	mov    %ebx,%eax
f0101d8b:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101d91:	c1 f8 03             	sar    $0x3,%eax
f0101d94:	c1 e0 0c             	shl    $0xc,%eax
f0101d97:	39 c2                	cmp    %eax,%edx
f0101d99:	0f 85 e4 08 00 00    	jne    f0102683 <mem_init+0x12c6>
	assert(pp1->pp_ref == 1);
f0101d9f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101da4:	0f 85 f2 08 00 00    	jne    f010269c <mem_init+0x12df>
	assert(pp2->pp_ref == 0);
f0101daa:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101daf:	0f 85 00 09 00 00    	jne    f01026b5 <mem_init+0x12f8>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101db5:	6a 00                	push   $0x0
f0101db7:	68 00 10 00 00       	push   $0x1000
f0101dbc:	53                   	push   %ebx
f0101dbd:	57                   	push   %edi
f0101dbe:	e8 25 f5 ff ff       	call   f01012e8 <page_insert>
f0101dc3:	83 c4 10             	add    $0x10,%esp
f0101dc6:	85 c0                	test   %eax,%eax
f0101dc8:	0f 85 00 09 00 00    	jne    f01026ce <mem_init+0x1311>
	assert(pp1->pp_ref);
f0101dce:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dd3:	0f 84 0e 09 00 00    	je     f01026e7 <mem_init+0x132a>
	assert(pp1->pp_link == NULL);
f0101dd9:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ddc:	0f 85 1e 09 00 00    	jne    f0102700 <mem_init+0x1343>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101de2:	83 ec 08             	sub    $0x8,%esp
f0101de5:	68 00 10 00 00       	push   $0x1000
f0101dea:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101df0:	e8 b5 f4 ff ff       	call   f01012aa <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101df5:	8b 3d 5c 12 21 f0    	mov    0xf021125c,%edi
f0101dfb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e00:	89 f8                	mov    %edi,%eax
f0101e02:	e8 77 ed ff ff       	call   f0100b7e <check_va2pa>
f0101e07:	83 c4 10             	add    $0x10,%esp
f0101e0a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e0d:	0f 85 06 09 00 00    	jne    f0102719 <mem_init+0x135c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e13:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e18:	89 f8                	mov    %edi,%eax
f0101e1a:	e8 5f ed ff ff       	call   f0100b7e <check_va2pa>
f0101e1f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e22:	0f 85 0a 09 00 00    	jne    f0102732 <mem_init+0x1375>
	assert(pp1->pp_ref == 0);
f0101e28:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e2d:	0f 85 18 09 00 00    	jne    f010274b <mem_init+0x138e>
	assert(pp2->pp_ref == 0);
f0101e33:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e38:	0f 85 26 09 00 00    	jne    f0102764 <mem_init+0x13a7>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e3e:	83 ec 0c             	sub    $0xc,%esp
f0101e41:	6a 00                	push   $0x0
f0101e43:	e8 d4 f1 ff ff       	call   f010101c <page_alloc>
f0101e48:	83 c4 10             	add    $0x10,%esp
f0101e4b:	39 c3                	cmp    %eax,%ebx
f0101e4d:	0f 85 2a 09 00 00    	jne    f010277d <mem_init+0x13c0>
f0101e53:	85 c0                	test   %eax,%eax
f0101e55:	0f 84 22 09 00 00    	je     f010277d <mem_init+0x13c0>

	// should be no free memory
	assert(!page_alloc(0));
f0101e5b:	83 ec 0c             	sub    $0xc,%esp
f0101e5e:	6a 00                	push   $0x0
f0101e60:	e8 b7 f1 ff ff       	call   f010101c <page_alloc>
f0101e65:	83 c4 10             	add    $0x10,%esp
f0101e68:	85 c0                	test   %eax,%eax
f0101e6a:	0f 85 26 09 00 00    	jne    f0102796 <mem_init+0x13d9>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e70:	8b 0d 5c 12 21 f0    	mov    0xf021125c,%ecx
f0101e76:	8b 11                	mov    (%ecx),%edx
f0101e78:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e81:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101e87:	c1 f8 03             	sar    $0x3,%eax
f0101e8a:	c1 e0 0c             	shl    $0xc,%eax
f0101e8d:	39 c2                	cmp    %eax,%edx
f0101e8f:	0f 85 1a 09 00 00    	jne    f01027af <mem_init+0x13f2>
	kern_pgdir[0] = 0;
f0101e95:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e9e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ea3:	0f 85 1f 09 00 00    	jne    f01027c8 <mem_init+0x140b>
	pp0->pp_ref = 0;
f0101ea9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eac:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101eb2:	83 ec 0c             	sub    $0xc,%esp
f0101eb5:	50                   	push   %eax
f0101eb6:	e8 d6 f1 ff ff       	call   f0101091 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101ebb:	83 c4 0c             	add    $0xc,%esp
f0101ebe:	6a 01                	push   $0x1
f0101ec0:	68 00 10 40 00       	push   $0x401000
f0101ec5:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101ecb:	e8 25 f2 ff ff       	call   f01010f5 <pgdir_walk>
f0101ed0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ed3:	8b 0d 5c 12 21 f0    	mov    0xf021125c,%ecx
f0101ed9:	8b 41 04             	mov    0x4(%ecx),%eax
f0101edc:	89 c7                	mov    %eax,%edi
f0101ede:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101ee4:	8b 15 60 12 21 f0    	mov    0xf0211260,%edx
f0101eea:	c1 e8 0c             	shr    $0xc,%eax
f0101eed:	83 c4 10             	add    $0x10,%esp
f0101ef0:	39 d0                	cmp    %edx,%eax
f0101ef2:	0f 83 e9 08 00 00    	jae    f01027e1 <mem_init+0x1424>
	assert(ptep == ptep1 + PTX(va));
f0101ef8:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101efe:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101f01:	0f 85 ef 08 00 00    	jne    f01027f6 <mem_init+0x1439>
	kern_pgdir[PDX(va)] = 0;
f0101f07:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101f0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f11:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101f17:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101f1d:	c1 f8 03             	sar    $0x3,%eax
f0101f20:	89 c1                	mov    %eax,%ecx
f0101f22:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101f25:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f2a:	39 c2                	cmp    %eax,%edx
f0101f2c:	0f 86 dd 08 00 00    	jbe    f010280f <mem_init+0x1452>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f32:	83 ec 04             	sub    $0x4,%esp
f0101f35:	68 00 10 00 00       	push   $0x1000
f0101f3a:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f3f:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101f45:	51                   	push   %ecx
f0101f46:	e8 1d 31 00 00       	call   f0105068 <memset>
	page_free(pp0);
f0101f4b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101f4e:	89 3c 24             	mov    %edi,(%esp)
f0101f51:	e8 3b f1 ff ff       	call   f0101091 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f56:	83 c4 0c             	add    $0xc,%esp
f0101f59:	6a 01                	push   $0x1
f0101f5b:	6a 00                	push   $0x0
f0101f5d:	ff 35 5c 12 21 f0    	push   0xf021125c
f0101f63:	e8 8d f1 ff ff       	call   f01010f5 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f68:	89 f8                	mov    %edi,%eax
f0101f6a:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0101f70:	c1 f8 03             	sar    $0x3,%eax
f0101f73:	89 c2                	mov    %eax,%edx
f0101f75:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f78:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f7d:	83 c4 10             	add    $0x10,%esp
f0101f80:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0101f86:	0f 83 95 08 00 00    	jae    f0102821 <mem_init+0x1464>
	return (void *)(pa + KERNBASE);
f0101f8c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101f92:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f98:	f6 00 01             	testb  $0x1,(%eax)
f0101f9b:	0f 85 92 08 00 00    	jne    f0102833 <mem_init+0x1476>
	for(i=0; i<NPTENTRIES; i++)
f0101fa1:	83 c0 04             	add    $0x4,%eax
f0101fa4:	39 d0                	cmp    %edx,%eax
f0101fa6:	75 f0                	jne    f0101f98 <mem_init+0xbdb>
	kern_pgdir[0] = 0;
f0101fa8:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0101fad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101fb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fb6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101fbc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101fbf:	89 0d 6c 12 21 f0    	mov    %ecx,0xf021126c

	// free the pages we took
	page_free(pp0);
f0101fc5:	83 ec 0c             	sub    $0xc,%esp
f0101fc8:	50                   	push   %eax
f0101fc9:	e8 c3 f0 ff ff       	call   f0101091 <page_free>
	page_free(pp1);
f0101fce:	89 1c 24             	mov    %ebx,(%esp)
f0101fd1:	e8 bb f0 ff ff       	call   f0101091 <page_free>
	page_free(pp2);
f0101fd6:	89 34 24             	mov    %esi,(%esp)
f0101fd9:	e8 b3 f0 ff ff       	call   f0101091 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101fde:	83 c4 08             	add    $0x8,%esp
f0101fe1:	68 01 10 00 00       	push   $0x1001
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	e8 6d f3 ff ff       	call   f010135a <mmio_map_region>
f0101fed:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101fef:	83 c4 08             	add    $0x8,%esp
f0101ff2:	68 00 10 00 00       	push   $0x1000
f0101ff7:	6a 00                	push   $0x0
f0101ff9:	e8 5c f3 ff ff       	call   f010135a <mmio_map_region>
f0101ffe:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102000:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102006:	83 c4 10             	add    $0x10,%esp
f0102009:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010200f:	0f 86 37 08 00 00    	jbe    f010284c <mem_init+0x148f>
f0102015:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010201a:	0f 87 2c 08 00 00    	ja     f010284c <mem_init+0x148f>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102020:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102026:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010202c:	0f 87 33 08 00 00    	ja     f0102865 <mem_init+0x14a8>
f0102032:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102038:	0f 86 27 08 00 00    	jbe    f0102865 <mem_init+0x14a8>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010203e:	89 da                	mov    %ebx,%edx
f0102040:	09 f2                	or     %esi,%edx
f0102042:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102048:	0f 85 30 08 00 00    	jne    f010287e <mem_init+0x14c1>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010204e:	39 c6                	cmp    %eax,%esi
f0102050:	0f 82 41 08 00 00    	jb     f0102897 <mem_init+0x14da>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102056:	8b 3d 5c 12 21 f0    	mov    0xf021125c,%edi
f010205c:	89 da                	mov    %ebx,%edx
f010205e:	89 f8                	mov    %edi,%eax
f0102060:	e8 19 eb ff ff       	call   f0100b7e <check_va2pa>
f0102065:	85 c0                	test   %eax,%eax
f0102067:	0f 85 43 08 00 00    	jne    f01028b0 <mem_init+0x14f3>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010206d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102073:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102076:	89 c2                	mov    %eax,%edx
f0102078:	89 f8                	mov    %edi,%eax
f010207a:	e8 ff ea ff ff       	call   f0100b7e <check_va2pa>
f010207f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102084:	0f 85 3f 08 00 00    	jne    f01028c9 <mem_init+0x150c>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010208a:	89 f2                	mov    %esi,%edx
f010208c:	89 f8                	mov    %edi,%eax
f010208e:	e8 eb ea ff ff       	call   f0100b7e <check_va2pa>
f0102093:	85 c0                	test   %eax,%eax
f0102095:	0f 85 47 08 00 00    	jne    f01028e2 <mem_init+0x1525>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010209b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01020a1:	89 f8                	mov    %edi,%eax
f01020a3:	e8 d6 ea ff ff       	call   f0100b7e <check_va2pa>
f01020a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020ab:	0f 85 4a 08 00 00    	jne    f01028fb <mem_init+0x153e>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01020b1:	83 ec 04             	sub    $0x4,%esp
f01020b4:	6a 00                	push   $0x0
f01020b6:	53                   	push   %ebx
f01020b7:	57                   	push   %edi
f01020b8:	e8 38 f0 ff ff       	call   f01010f5 <pgdir_walk>
f01020bd:	83 c4 10             	add    $0x10,%esp
f01020c0:	f6 00 1a             	testb  $0x1a,(%eax)
f01020c3:	0f 84 4b 08 00 00    	je     f0102914 <mem_init+0x1557>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01020c9:	83 ec 04             	sub    $0x4,%esp
f01020cc:	6a 00                	push   $0x0
f01020ce:	53                   	push   %ebx
f01020cf:	ff 35 5c 12 21 f0    	push   0xf021125c
f01020d5:	e8 1b f0 ff ff       	call   f01010f5 <pgdir_walk>
f01020da:	8b 00                	mov    (%eax),%eax
f01020dc:	83 c4 10             	add    $0x10,%esp
f01020df:	83 e0 04             	and    $0x4,%eax
f01020e2:	89 c7                	mov    %eax,%edi
f01020e4:	0f 85 43 08 00 00    	jne    f010292d <mem_init+0x1570>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01020ea:	83 ec 04             	sub    $0x4,%esp
f01020ed:	6a 00                	push   $0x0
f01020ef:	53                   	push   %ebx
f01020f0:	ff 35 5c 12 21 f0    	push   0xf021125c
f01020f6:	e8 fa ef ff ff       	call   f01010f5 <pgdir_walk>
f01020fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102101:	83 c4 0c             	add    $0xc,%esp
f0102104:	6a 00                	push   $0x0
f0102106:	ff 75 d4             	push   -0x2c(%ebp)
f0102109:	ff 35 5c 12 21 f0    	push   0xf021125c
f010210f:	e8 e1 ef ff ff       	call   f01010f5 <pgdir_walk>
f0102114:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010211a:	83 c4 0c             	add    $0xc,%esp
f010211d:	6a 00                	push   $0x0
f010211f:	56                   	push   %esi
f0102120:	ff 35 5c 12 21 f0    	push   0xf021125c
f0102126:	e8 ca ef ff ff       	call   f01010f5 <pgdir_walk>
f010212b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102131:	c7 04 24 b8 70 10 f0 	movl   $0xf01070b8,(%esp)
f0102138:	e8 d9 18 00 00       	call   f0103a16 <cprintf>
	boot_map_region(kern_pgdir,UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U | PTE_P);
f010213d:	a1 58 12 21 f0       	mov    0xf0211258,%eax
	if ((uint32_t)kva < KERNBASE)
f0102142:	83 c4 10             	add    $0x10,%esp
f0102145:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010214a:	0f 86 f6 07 00 00    	jbe    f0102946 <mem_init+0x1589>
f0102150:	8b 15 60 12 21 f0    	mov    0xf0211260,%edx
f0102156:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f010215d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102163:	83 ec 08             	sub    $0x8,%esp
f0102166:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102168:	05 00 00 00 10       	add    $0x10000000,%eax
f010216d:	50                   	push   %eax
f010216e:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102173:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0102178:	e8 48 f0 ff ff       	call   f01011c5 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010217d:	a1 74 12 21 f0       	mov    0xf0211274,%eax
	if ((uint32_t)kva < KERNBASE)
f0102182:	83 c4 10             	add    $0x10,%esp
f0102185:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010218a:	0f 86 cb 07 00 00    	jbe    f010295b <mem_init+0x159e>
f0102190:	83 ec 08             	sub    $0x8,%esp
f0102193:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102195:	05 00 00 00 10       	add    $0x10000000,%eax
f010219a:	50                   	push   %eax
f010219b:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01021a0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021a5:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f01021aa:	e8 16 f0 ff ff       	call   f01011c5 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021af:	83 c4 10             	add    $0x10,%esp
f01021b2:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01021b7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021bc:	0f 86 ae 07 00 00    	jbe    f0102970 <mem_init+0x15b3>
	boot_map_region(kern_pgdir,KSTACKTOP - KSTKSIZE,KSTKSIZE,PADDR(bootstack), PTE_W | PTE_P);
f01021c2:	83 ec 08             	sub    $0x8,%esp
f01021c5:	6a 03                	push   $0x3
f01021c7:	68 00 90 11 00       	push   $0x119000
f01021cc:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021d1:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021d6:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f01021db:	e8 e5 ef ff ff       	call   f01011c5 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_P | PTE_W);
f01021e0:	83 c4 08             	add    $0x8,%esp
f01021e3:	6a 03                	push   $0x3
f01021e5:	6a 00                	push   $0x0
f01021e7:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01021ec:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021f1:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f01021f6:	e8 ca ef ff ff       	call   f01011c5 <boot_map_region>
f01021fb:	c7 45 d0 00 20 21 f0 	movl   $0xf0212000,-0x30(%ebp)
f0102202:	83 c4 10             	add    $0x10,%esp
f0102205:	bb 00 20 21 f0       	mov    $0xf0212000,%ebx
f010220a:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010220f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102215:	0f 86 6a 07 00 00    	jbe    f0102985 <mem_init+0x15c8>
        boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f010221b:	83 ec 08             	sub    $0x8,%esp
f010221e:	6a 02                	push   $0x2
f0102220:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102226:	50                   	push   %eax
f0102227:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010222c:	89 f2                	mov    %esi,%edx
f010222e:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0102233:	e8 8d ef ff ff       	call   f01011c5 <boot_map_region>
	 for (int i =0;i<NCPU;i++) {
f0102238:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010223e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102244:	83 c4 10             	add    $0x10,%esp
f0102247:	81 fb 00 20 25 f0    	cmp    $0xf0252000,%ebx
f010224d:	75 c0                	jne    f010220f <mem_init+0xe52>
	pgdir = kern_pgdir;
f010224f:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
f0102254:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102257:	a1 60 12 21 f0       	mov    0xf0211260,%eax
f010225c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010225f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102266:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010226b:	8b 35 58 12 21 f0    	mov    0xf0211258,%esi
	return (physaddr_t)kva - KERNBASE;
f0102271:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f0102277:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010227a:	89 fb                	mov    %edi,%ebx
f010227c:	89 7d c8             	mov    %edi,-0x38(%ebp)
f010227f:	89 c7                	mov    %eax,%edi
f0102281:	e9 2f 07 00 00       	jmp    f01029b5 <mem_init+0x15f8>
	assert(nfree == 0);
f0102286:	68 cf 6f 10 f0       	push   $0xf0106fcf
f010228b:	68 15 6e 10 f0       	push   $0xf0106e15
f0102290:	68 43 03 00 00       	push   $0x343
f0102295:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010229a:	e8 a1 dd ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010229f:	68 dd 6e 10 f0       	push   $0xf0106edd
f01022a4:	68 15 6e 10 f0       	push   $0xf0106e15
f01022a9:	68 a9 03 00 00       	push   $0x3a9
f01022ae:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01022b3:	e8 88 dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01022b8:	68 f3 6e 10 f0       	push   $0xf0106ef3
f01022bd:	68 15 6e 10 f0       	push   $0xf0106e15
f01022c2:	68 aa 03 00 00       	push   $0x3aa
f01022c7:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01022cc:	e8 6f dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01022d1:	68 09 6f 10 f0       	push   $0xf0106f09
f01022d6:	68 15 6e 10 f0       	push   $0xf0106e15
f01022db:	68 ab 03 00 00       	push   $0x3ab
f01022e0:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01022e5:	e8 56 dd ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01022ea:	68 1f 6f 10 f0       	push   $0xf0106f1f
f01022ef:	68 15 6e 10 f0       	push   $0xf0106e15
f01022f4:	68 ae 03 00 00       	push   $0x3ae
f01022f9:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01022fe:	e8 3d dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102303:	68 f8 65 10 f0       	push   $0xf01065f8
f0102308:	68 15 6e 10 f0       	push   $0xf0106e15
f010230d:	68 af 03 00 00       	push   $0x3af
f0102312:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102317:	e8 24 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010231c:	68 88 6f 10 f0       	push   $0xf0106f88
f0102321:	68 15 6e 10 f0       	push   $0xf0106e15
f0102326:	68 b6 03 00 00       	push   $0x3b6
f010232b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102330:	e8 0b dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102335:	68 38 66 10 f0       	push   $0xf0106638
f010233a:	68 15 6e 10 f0       	push   $0xf0106e15
f010233f:	68 b9 03 00 00       	push   $0x3b9
f0102344:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102349:	e8 f2 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010234e:	68 70 66 10 f0       	push   $0xf0106670
f0102353:	68 15 6e 10 f0       	push   $0xf0106e15
f0102358:	68 bc 03 00 00       	push   $0x3bc
f010235d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102362:	e8 d9 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102367:	68 a0 66 10 f0       	push   $0xf01066a0
f010236c:	68 15 6e 10 f0       	push   $0xf0106e15
f0102371:	68 c0 03 00 00       	push   $0x3c0
f0102376:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010237b:	e8 c0 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102380:	68 d0 66 10 f0       	push   $0xf01066d0
f0102385:	68 15 6e 10 f0       	push   $0xf0106e15
f010238a:	68 c1 03 00 00       	push   $0x3c1
f010238f:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102394:	e8 a7 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102399:	68 f8 66 10 f0       	push   $0xf01066f8
f010239e:	68 15 6e 10 f0       	push   $0xf0106e15
f01023a3:	68 c2 03 00 00       	push   $0x3c2
f01023a8:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01023ad:	e8 8e dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023b2:	68 da 6f 10 f0       	push   $0xf0106fda
f01023b7:	68 15 6e 10 f0       	push   $0xf0106e15
f01023bc:	68 c3 03 00 00       	push   $0x3c3
f01023c1:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01023cb:	68 eb 6f 10 f0       	push   $0xf0106feb
f01023d0:	68 15 6e 10 f0       	push   $0xf0106e15
f01023d5:	68 c4 03 00 00       	push   $0x3c4
f01023da:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01023df:	e8 5c dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023e4:	68 28 67 10 f0       	push   $0xf0106728
f01023e9:	68 15 6e 10 f0       	push   $0xf0106e15
f01023ee:	68 c7 03 00 00       	push   $0x3c7
f01023f3:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01023f8:	e8 43 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023fd:	68 64 67 10 f0       	push   $0xf0106764
f0102402:	68 15 6e 10 f0       	push   $0xf0106e15
f0102407:	68 c8 03 00 00       	push   $0x3c8
f010240c:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102411:	e8 2a dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102416:	68 fc 6f 10 f0       	push   $0xf0106ffc
f010241b:	68 15 6e 10 f0       	push   $0xf0106e15
f0102420:	68 c9 03 00 00       	push   $0x3c9
f0102425:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010242a:	e8 11 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010242f:	68 88 6f 10 f0       	push   $0xf0106f88
f0102434:	68 15 6e 10 f0       	push   $0xf0106e15
f0102439:	68 cc 03 00 00       	push   $0x3cc
f010243e:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102443:	e8 f8 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102448:	68 28 67 10 f0       	push   $0xf0106728
f010244d:	68 15 6e 10 f0       	push   $0xf0106e15
f0102452:	68 cf 03 00 00       	push   $0x3cf
f0102457:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010245c:	e8 df db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102461:	68 64 67 10 f0       	push   $0xf0106764
f0102466:	68 15 6e 10 f0       	push   $0xf0106e15
f010246b:	68 d0 03 00 00       	push   $0x3d0
f0102470:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102475:	e8 c6 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010247a:	68 fc 6f 10 f0       	push   $0xf0106ffc
f010247f:	68 15 6e 10 f0       	push   $0xf0106e15
f0102484:	68 d1 03 00 00       	push   $0x3d1
f0102489:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010248e:	e8 ad db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102493:	68 88 6f 10 f0       	push   $0xf0106f88
f0102498:	68 15 6e 10 f0       	push   $0xf0106e15
f010249d:	68 d5 03 00 00       	push   $0x3d5
f01024a2:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01024a7:	e8 94 db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ac:	57                   	push   %edi
f01024ad:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01024b2:	68 d8 03 00 00       	push   $0x3d8
f01024b7:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01024bc:	e8 7f db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024c1:	68 94 67 10 f0       	push   $0xf0106794
f01024c6:	68 15 6e 10 f0       	push   $0xf0106e15
f01024cb:	68 d9 03 00 00       	push   $0x3d9
f01024d0:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01024d5:	e8 66 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024da:	68 d4 67 10 f0       	push   $0xf01067d4
f01024df:	68 15 6e 10 f0       	push   $0xf0106e15
f01024e4:	68 dc 03 00 00       	push   $0x3dc
f01024e9:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01024ee:	e8 4d db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024f3:	68 64 67 10 f0       	push   $0xf0106764
f01024f8:	68 15 6e 10 f0       	push   $0xf0106e15
f01024fd:	68 dd 03 00 00       	push   $0x3dd
f0102502:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102507:	e8 34 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010250c:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0102511:	68 15 6e 10 f0       	push   $0xf0106e15
f0102516:	68 de 03 00 00       	push   $0x3de
f010251b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102520:	e8 1b db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102525:	68 14 68 10 f0       	push   $0xf0106814
f010252a:	68 15 6e 10 f0       	push   $0xf0106e15
f010252f:	68 df 03 00 00       	push   $0x3df
f0102534:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102539:	e8 02 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010253e:	68 0d 70 10 f0       	push   $0xf010700d
f0102543:	68 15 6e 10 f0       	push   $0xf0106e15
f0102548:	68 e0 03 00 00       	push   $0x3e0
f010254d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102552:	e8 e9 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102557:	68 28 67 10 f0       	push   $0xf0106728
f010255c:	68 15 6e 10 f0       	push   $0xf0106e15
f0102561:	68 e3 03 00 00       	push   $0x3e3
f0102566:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010256b:	e8 d0 da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102570:	68 48 68 10 f0       	push   $0xf0106848
f0102575:	68 15 6e 10 f0       	push   $0xf0106e15
f010257a:	68 e4 03 00 00       	push   $0x3e4
f010257f:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102584:	e8 b7 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102589:	68 7c 68 10 f0       	push   $0xf010687c
f010258e:	68 15 6e 10 f0       	push   $0xf0106e15
f0102593:	68 e5 03 00 00       	push   $0x3e5
f0102598:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010259d:	e8 9e da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025a2:	68 b4 68 10 f0       	push   $0xf01068b4
f01025a7:	68 15 6e 10 f0       	push   $0xf0106e15
f01025ac:	68 e8 03 00 00       	push   $0x3e8
f01025b1:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01025b6:	e8 85 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025bb:	68 ec 68 10 f0       	push   $0xf01068ec
f01025c0:	68 15 6e 10 f0       	push   $0xf0106e15
f01025c5:	68 eb 03 00 00       	push   $0x3eb
f01025ca:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01025cf:	e8 6c da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025d4:	68 7c 68 10 f0       	push   $0xf010687c
f01025d9:	68 15 6e 10 f0       	push   $0xf0106e15
f01025de:	68 ec 03 00 00       	push   $0x3ec
f01025e3:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01025e8:	e8 53 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025ed:	68 28 69 10 f0       	push   $0xf0106928
f01025f2:	68 15 6e 10 f0       	push   $0xf0106e15
f01025f7:	68 ef 03 00 00       	push   $0x3ef
f01025fc:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102601:	e8 3a da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102606:	68 54 69 10 f0       	push   $0xf0106954
f010260b:	68 15 6e 10 f0       	push   $0xf0106e15
f0102610:	68 f0 03 00 00       	push   $0x3f0
f0102615:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010261a:	e8 21 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f010261f:	68 23 70 10 f0       	push   $0xf0107023
f0102624:	68 15 6e 10 f0       	push   $0xf0106e15
f0102629:	68 f2 03 00 00       	push   $0x3f2
f010262e:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102633:	e8 08 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102638:	68 34 70 10 f0       	push   $0xf0107034
f010263d:	68 15 6e 10 f0       	push   $0xf0106e15
f0102642:	68 f3 03 00 00       	push   $0x3f3
f0102647:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010264c:	e8 ef d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102651:	68 84 69 10 f0       	push   $0xf0106984
f0102656:	68 15 6e 10 f0       	push   $0xf0106e15
f010265b:	68 f6 03 00 00       	push   $0x3f6
f0102660:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102665:	e8 d6 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010266a:	68 a8 69 10 f0       	push   $0xf01069a8
f010266f:	68 15 6e 10 f0       	push   $0xf0106e15
f0102674:	68 fa 03 00 00       	push   $0x3fa
f0102679:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010267e:	e8 bd d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102683:	68 54 69 10 f0       	push   $0xf0106954
f0102688:	68 15 6e 10 f0       	push   $0xf0106e15
f010268d:	68 fb 03 00 00       	push   $0x3fb
f0102692:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102697:	e8 a4 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010269c:	68 da 6f 10 f0       	push   $0xf0106fda
f01026a1:	68 15 6e 10 f0       	push   $0xf0106e15
f01026a6:	68 fc 03 00 00       	push   $0x3fc
f01026ab:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01026b0:	e8 8b d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026b5:	68 34 70 10 f0       	push   $0xf0107034
f01026ba:	68 15 6e 10 f0       	push   $0xf0106e15
f01026bf:	68 fd 03 00 00       	push   $0x3fd
f01026c4:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01026c9:	e8 72 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026ce:	68 cc 69 10 f0       	push   $0xf01069cc
f01026d3:	68 15 6e 10 f0       	push   $0xf0106e15
f01026d8:	68 00 04 00 00       	push   $0x400
f01026dd:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01026e2:	e8 59 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01026e7:	68 45 70 10 f0       	push   $0xf0107045
f01026ec:	68 15 6e 10 f0       	push   $0xf0106e15
f01026f1:	68 01 04 00 00       	push   $0x401
f01026f6:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01026fb:	e8 40 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102700:	68 51 70 10 f0       	push   $0xf0107051
f0102705:	68 15 6e 10 f0       	push   $0xf0106e15
f010270a:	68 02 04 00 00       	push   $0x402
f010270f:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102714:	e8 27 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102719:	68 a8 69 10 f0       	push   $0xf01069a8
f010271e:	68 15 6e 10 f0       	push   $0xf0106e15
f0102723:	68 06 04 00 00       	push   $0x406
f0102728:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010272d:	e8 0e d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102732:	68 04 6a 10 f0       	push   $0xf0106a04
f0102737:	68 15 6e 10 f0       	push   $0xf0106e15
f010273c:	68 07 04 00 00       	push   $0x407
f0102741:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102746:	e8 f5 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010274b:	68 66 70 10 f0       	push   $0xf0107066
f0102750:	68 15 6e 10 f0       	push   $0xf0106e15
f0102755:	68 08 04 00 00       	push   $0x408
f010275a:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010275f:	e8 dc d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102764:	68 34 70 10 f0       	push   $0xf0107034
f0102769:	68 15 6e 10 f0       	push   $0xf0106e15
f010276e:	68 09 04 00 00       	push   $0x409
f0102773:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102778:	e8 c3 d8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010277d:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0102782:	68 15 6e 10 f0       	push   $0xf0106e15
f0102787:	68 0c 04 00 00       	push   $0x40c
f010278c:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102791:	e8 aa d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102796:	68 88 6f 10 f0       	push   $0xf0106f88
f010279b:	68 15 6e 10 f0       	push   $0xf0106e15
f01027a0:	68 0f 04 00 00       	push   $0x40f
f01027a5:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01027aa:	e8 91 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027af:	68 d0 66 10 f0       	push   $0xf01066d0
f01027b4:	68 15 6e 10 f0       	push   $0xf0106e15
f01027b9:	68 12 04 00 00       	push   $0x412
f01027be:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01027c3:	e8 78 d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01027c8:	68 eb 6f 10 f0       	push   $0xf0106feb
f01027cd:	68 15 6e 10 f0       	push   $0xf0106e15
f01027d2:	68 14 04 00 00       	push   $0x414
f01027d7:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01027dc:	e8 5f d8 ff ff       	call   f0100040 <_panic>
f01027e1:	57                   	push   %edi
f01027e2:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01027e7:	68 1b 04 00 00       	push   $0x41b
f01027ec:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01027f1:	e8 4a d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027f6:	68 77 70 10 f0       	push   $0xf0107077
f01027fb:	68 15 6e 10 f0       	push   $0xf0106e15
f0102800:	68 1c 04 00 00       	push   $0x41c
f0102805:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010280a:	e8 31 d8 ff ff       	call   f0100040 <_panic>
f010280f:	51                   	push   %ecx
f0102810:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102815:	6a 58                	push   $0x58
f0102817:	68 fb 6d 10 f0       	push   $0xf0106dfb
f010281c:	e8 1f d8 ff ff       	call   f0100040 <_panic>
f0102821:	52                   	push   %edx
f0102822:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102827:	6a 58                	push   $0x58
f0102829:	68 fb 6d 10 f0       	push   $0xf0106dfb
f010282e:	e8 0d d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102833:	68 8f 70 10 f0       	push   $0xf010708f
f0102838:	68 15 6e 10 f0       	push   $0xf0106e15
f010283d:	68 26 04 00 00       	push   $0x426
f0102842:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102847:	e8 f4 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010284c:	68 50 6a 10 f0       	push   $0xf0106a50
f0102851:	68 15 6e 10 f0       	push   $0xf0106e15
f0102856:	68 36 04 00 00       	push   $0x436
f010285b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102860:	e8 db d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102865:	68 78 6a 10 f0       	push   $0xf0106a78
f010286a:	68 15 6e 10 f0       	push   $0xf0106e15
f010286f:	68 37 04 00 00       	push   $0x437
f0102874:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102879:	e8 c2 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010287e:	68 a0 6a 10 f0       	push   $0xf0106aa0
f0102883:	68 15 6e 10 f0       	push   $0xf0106e15
f0102888:	68 39 04 00 00       	push   $0x439
f010288d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102892:	e8 a9 d7 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102897:	68 a6 70 10 f0       	push   $0xf01070a6
f010289c:	68 15 6e 10 f0       	push   $0xf0106e15
f01028a1:	68 3b 04 00 00       	push   $0x43b
f01028a6:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01028ab:	e8 90 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01028b0:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01028b5:	68 15 6e 10 f0       	push   $0xf0106e15
f01028ba:	68 3d 04 00 00       	push   $0x43d
f01028bf:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01028c4:	e8 77 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01028c9:	68 ec 6a 10 f0       	push   $0xf0106aec
f01028ce:	68 15 6e 10 f0       	push   $0xf0106e15
f01028d3:	68 3e 04 00 00       	push   $0x43e
f01028d8:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01028dd:	e8 5e d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01028e2:	68 1c 6b 10 f0       	push   $0xf0106b1c
f01028e7:	68 15 6e 10 f0       	push   $0xf0106e15
f01028ec:	68 3f 04 00 00       	push   $0x43f
f01028f1:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01028f6:	e8 45 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01028fb:	68 40 6b 10 f0       	push   $0xf0106b40
f0102900:	68 15 6e 10 f0       	push   $0xf0106e15
f0102905:	68 40 04 00 00       	push   $0x440
f010290a:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010290f:	e8 2c d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102914:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0102919:	68 15 6e 10 f0       	push   $0xf0106e15
f010291e:	68 42 04 00 00       	push   $0x442
f0102923:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102928:	e8 13 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010292d:	68 b0 6b 10 f0       	push   $0xf0106bb0
f0102932:	68 15 6e 10 f0       	push   $0xf0106e15
f0102937:	68 43 04 00 00       	push   $0x443
f010293c:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102941:	e8 fa d6 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102946:	50                   	push   %eax
f0102947:	68 e8 5c 10 f0       	push   $0xf0105ce8
f010294c:	68 c4 00 00 00       	push   $0xc4
f0102951:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102956:	e8 e5 d6 ff ff       	call   f0100040 <_panic>
f010295b:	50                   	push   %eax
f010295c:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0102961:	68 cd 00 00 00       	push   $0xcd
f0102966:	68 d5 6d 10 f0       	push   $0xf0106dd5
f010296b:	e8 d0 d6 ff ff       	call   f0100040 <_panic>
f0102970:	50                   	push   %eax
f0102971:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0102976:	68 da 00 00 00       	push   $0xda
f010297b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102980:	e8 bb d6 ff ff       	call   f0100040 <_panic>
f0102985:	53                   	push   %ebx
f0102986:	68 e8 5c 10 f0       	push   $0xf0105ce8
f010298b:	68 19 01 00 00       	push   $0x119
f0102990:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102995:	e8 a6 d6 ff ff       	call   f0100040 <_panic>
f010299a:	56                   	push   %esi
f010299b:	68 e8 5c 10 f0       	push   $0xf0105ce8
f01029a0:	68 5b 03 00 00       	push   $0x35b
f01029a5:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01029aa:	e8 91 d6 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f01029af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029b5:	39 df                	cmp    %ebx,%edi
f01029b7:	76 39                	jbe    f01029f2 <mem_init+0x1635>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01029b9:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01029bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029c2:	e8 b7 e1 ff ff       	call   f0100b7e <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029c7:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029cd:	76 cb                	jbe    f010299a <mem_init+0x15dd>
f01029cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01029d2:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01029d5:	39 d0                	cmp    %edx,%eax
f01029d7:	74 d6                	je     f01029af <mem_init+0x15f2>
f01029d9:	68 e4 6b 10 f0       	push   $0xf0106be4
f01029de:	68 15 6e 10 f0       	push   $0xf0106e15
f01029e3:	68 5b 03 00 00       	push   $0x35b
f01029e8:	68 d5 6d 10 f0       	push   $0xf0106dd5
f01029ed:	e8 4e d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029f2:	8b 35 74 12 21 f0    	mov    0xf0211274,%esi
f01029f8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029fd:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f0102a03:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102a06:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a09:	89 da                	mov    %ebx,%edx
f0102a0b:	89 f8                	mov    %edi,%eax
f0102a0d:	e8 6c e1 ff ff       	call   f0100b7e <check_va2pa>
f0102a12:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a18:	76 46                	jbe    f0102a60 <mem_init+0x16a3>
f0102a1a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102a1d:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a20:	39 d0                	cmp    %edx,%eax
f0102a22:	75 51                	jne    f0102a75 <mem_init+0x16b8>
	for (i = 0; i < n; i += PGSIZE)
f0102a24:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a2a:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102a30:	75 d7                	jne    f0102a09 <mem_init+0x164c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a32:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102a35:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a38:	c1 e6 0c             	shl    $0xc,%esi
f0102a3b:	89 fb                	mov    %edi,%ebx
f0102a3d:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0102a40:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102a43:	39 f3                	cmp    %esi,%ebx
f0102a45:	73 60                	jae    f0102aa7 <mem_init+0x16ea>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a47:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a4d:	89 f8                	mov    %edi,%eax
f0102a4f:	e8 2a e1 ff ff       	call   f0100b7e <check_va2pa>
f0102a54:	39 c3                	cmp    %eax,%ebx
f0102a56:	75 36                	jne    f0102a8e <mem_init+0x16d1>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a58:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a5e:	eb e3                	jmp    f0102a43 <mem_init+0x1686>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a60:	56                   	push   %esi
f0102a61:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0102a66:	68 60 03 00 00       	push   $0x360
f0102a6b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102a70:	e8 cb d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a75:	68 18 6c 10 f0       	push   $0xf0106c18
f0102a7a:	68 15 6e 10 f0       	push   $0xf0106e15
f0102a7f:	68 60 03 00 00       	push   $0x360
f0102a84:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102a89:	e8 b2 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a8e:	68 4c 6c 10 f0       	push   $0xf0106c4c
f0102a93:	68 15 6e 10 f0       	push   $0xf0106e15
f0102a98:	68 64 03 00 00       	push   $0x364
f0102a9d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102aa2:	e8 99 d5 ff ff       	call   f0100040 <_panic>
f0102aa7:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102aaa:	c7 45 c0 00 20 22 00 	movl   $0x222000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ab1:	c7 45 c4 00 00 00 f0 	movl   $0xf0000000,-0x3c(%ebp)
f0102ab8:	c7 45 c8 00 80 ff ef 	movl   $0xefff8000,-0x38(%ebp)
f0102abf:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0102ac2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102ac5:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0102ac8:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ace:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ad1:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0102ad4:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0102ad7:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102adc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102adf:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0102ae2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102ae5:	89 da                	mov    %ebx,%edx
f0102ae7:	89 f8                	mov    %edi,%eax
f0102ae9:	e8 90 e0 ff ff       	call   f0100b7e <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102aee:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102af5:	76 67                	jbe    f0102b5e <mem_init+0x17a1>
f0102af7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102afa:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102afd:	39 d0                	cmp    %edx,%eax
f0102aff:	75 74                	jne    f0102b75 <mem_init+0x17b8>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b01:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b07:	39 f3                	cmp    %esi,%ebx
f0102b09:	75 da                	jne    f0102ae5 <mem_init+0x1728>
f0102b0b:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0102b0e:	8b 5d c8             	mov    -0x38(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b11:	89 f2                	mov    %esi,%edx
f0102b13:	89 f8                	mov    %edi,%eax
f0102b15:	e8 64 e0 ff ff       	call   f0100b7e <check_va2pa>
f0102b1a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b1d:	75 6f                	jne    f0102b8e <mem_init+0x17d1>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b1f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102b25:	39 de                	cmp    %ebx,%esi
f0102b27:	75 e8                	jne    f0102b11 <mem_init+0x1754>
	for (n = 0; n < NCPU; n++) {
f0102b29:	89 d8                	mov    %ebx,%eax
f0102b2b:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102b30:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102b33:	81 6d c4 00 00 01 00 	subl   $0x10000,-0x3c(%ebp)
f0102b3a:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102b41:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b44:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102b4b:	3d 00 20 25 f0       	cmp    $0xf0252000,%eax
f0102b50:	0f 85 6f ff ff ff    	jne    f0102ac5 <mem_init+0x1708>
f0102b56:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102b59:	e9 84 00 00 00       	jmp    f0102be2 <mem_init+0x1825>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b5e:	ff 75 b8             	push   -0x48(%ebp)
f0102b61:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0102b66:	68 6c 03 00 00       	push   $0x36c
f0102b6b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102b70:	e8 cb d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b75:	68 74 6c 10 f0       	push   $0xf0106c74
f0102b7a:	68 15 6e 10 f0       	push   $0xf0106e15
f0102b7f:	68 6b 03 00 00       	push   $0x36b
f0102b84:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102b89:	e8 b2 d4 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b8e:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0102b93:	68 15 6e 10 f0       	push   $0xf0106e15
f0102b98:	68 6e 03 00 00       	push   $0x36e
f0102b9d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102ba2:	e8 99 d4 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102ba7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102baa:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102bae:	75 4e                	jne    f0102bfe <mem_init+0x1841>
f0102bb0:	68 d1 70 10 f0       	push   $0xf01070d1
f0102bb5:	68 15 6e 10 f0       	push   $0xf0106e15
f0102bba:	68 79 03 00 00       	push   $0x379
f0102bbf:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102bc4:	e8 77 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102bc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bcc:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102bcf:	a8 01                	test   $0x1,%al
f0102bd1:	74 30                	je     f0102c03 <mem_init+0x1846>
				assert(pgdir[i] & PTE_W);
f0102bd3:	a8 02                	test   $0x2,%al
f0102bd5:	74 45                	je     f0102c1c <mem_init+0x185f>
	for (i = 0; i < NPDENTRIES; i++) {
f0102bd7:	83 c7 01             	add    $0x1,%edi
f0102bda:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102be0:	74 6c                	je     f0102c4e <mem_init+0x1891>
		switch (i) {
f0102be2:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102be8:	83 f8 04             	cmp    $0x4,%eax
f0102beb:	76 ba                	jbe    f0102ba7 <mem_init+0x17ea>
			if (i >= PDX(KERNBASE)) {
f0102bed:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102bf3:	77 d4                	ja     f0102bc9 <mem_init+0x180c>
				assert(pgdir[i] == 0);
f0102bf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf8:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102bfc:	75 37                	jne    f0102c35 <mem_init+0x1878>
	for (i = 0; i < NPDENTRIES; i++) {
f0102bfe:	83 c7 01             	add    $0x1,%edi
f0102c01:	eb df                	jmp    f0102be2 <mem_init+0x1825>
				assert(pgdir[i] & PTE_P);
f0102c03:	68 d1 70 10 f0       	push   $0xf01070d1
f0102c08:	68 15 6e 10 f0       	push   $0xf0106e15
f0102c0d:	68 7d 03 00 00       	push   $0x37d
f0102c12:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102c17:	e8 24 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102c1c:	68 e2 70 10 f0       	push   $0xf01070e2
f0102c21:	68 15 6e 10 f0       	push   $0xf0106e15
f0102c26:	68 7e 03 00 00       	push   $0x37e
f0102c2b:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102c30:	e8 0b d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102c35:	68 f3 70 10 f0       	push   $0xf01070f3
f0102c3a:	68 15 6e 10 f0       	push   $0xf0106e15
f0102c3f:	68 80 03 00 00       	push   $0x380
f0102c44:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102c49:	e8 f2 d3 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c4e:	83 ec 0c             	sub    $0xc,%esp
f0102c51:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0102c56:	e8 bb 0d 00 00       	call   f0103a16 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c5b:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c60:	83 c4 10             	add    $0x10,%esp
f0102c63:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c68:	0f 86 03 02 00 00    	jbe    f0102e71 <mem_init+0x1ab4>
	return (physaddr_t)kva - KERNBASE;
f0102c6e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c73:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102c76:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c7b:	e8 61 df ff ff       	call   f0100be1 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c80:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c83:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c86:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c8b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c8e:	83 ec 0c             	sub    $0xc,%esp
f0102c91:	6a 00                	push   $0x0
f0102c93:	e8 84 e3 ff ff       	call   f010101c <page_alloc>
f0102c98:	89 c3                	mov    %eax,%ebx
f0102c9a:	83 c4 10             	add    $0x10,%esp
f0102c9d:	85 c0                	test   %eax,%eax
f0102c9f:	0f 84 e1 01 00 00    	je     f0102e86 <mem_init+0x1ac9>
	assert((pp1 = page_alloc(0)));
f0102ca5:	83 ec 0c             	sub    $0xc,%esp
f0102ca8:	6a 00                	push   $0x0
f0102caa:	e8 6d e3 ff ff       	call   f010101c <page_alloc>
f0102caf:	89 c7                	mov    %eax,%edi
f0102cb1:	83 c4 10             	add    $0x10,%esp
f0102cb4:	85 c0                	test   %eax,%eax
f0102cb6:	0f 84 e3 01 00 00    	je     f0102e9f <mem_init+0x1ae2>
	assert((pp2 = page_alloc(0)));
f0102cbc:	83 ec 0c             	sub    $0xc,%esp
f0102cbf:	6a 00                	push   $0x0
f0102cc1:	e8 56 e3 ff ff       	call   f010101c <page_alloc>
f0102cc6:	89 c6                	mov    %eax,%esi
f0102cc8:	83 c4 10             	add    $0x10,%esp
f0102ccb:	85 c0                	test   %eax,%eax
f0102ccd:	0f 84 e5 01 00 00    	je     f0102eb8 <mem_init+0x1afb>
	page_free(pp0);
f0102cd3:	83 ec 0c             	sub    $0xc,%esp
f0102cd6:	53                   	push   %ebx
f0102cd7:	e8 b5 e3 ff ff       	call   f0101091 <page_free>
	return (pp - pages) << PGSHIFT;
f0102cdc:	89 f8                	mov    %edi,%eax
f0102cde:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0102ce4:	c1 f8 03             	sar    $0x3,%eax
f0102ce7:	89 c2                	mov    %eax,%edx
f0102ce9:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cec:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cf1:	83 c4 10             	add    $0x10,%esp
f0102cf4:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0102cfa:	0f 83 d1 01 00 00    	jae    f0102ed1 <mem_init+0x1b14>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d00:	83 ec 04             	sub    $0x4,%esp
f0102d03:	68 00 10 00 00       	push   $0x1000
f0102d08:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d0a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d10:	52                   	push   %edx
f0102d11:	e8 52 23 00 00       	call   f0105068 <memset>
	return (pp - pages) << PGSHIFT;
f0102d16:	89 f0                	mov    %esi,%eax
f0102d18:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0102d1e:	c1 f8 03             	sar    $0x3,%eax
f0102d21:	89 c2                	mov    %eax,%edx
f0102d23:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d26:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d2b:	83 c4 10             	add    $0x10,%esp
f0102d2e:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0102d34:	0f 83 a9 01 00 00    	jae    f0102ee3 <mem_init+0x1b26>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d3a:	83 ec 04             	sub    $0x4,%esp
f0102d3d:	68 00 10 00 00       	push   $0x1000
f0102d42:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d44:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d4a:	52                   	push   %edx
f0102d4b:	e8 18 23 00 00       	call   f0105068 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d50:	6a 02                	push   $0x2
f0102d52:	68 00 10 00 00       	push   $0x1000
f0102d57:	57                   	push   %edi
f0102d58:	ff 35 5c 12 21 f0    	push   0xf021125c
f0102d5e:	e8 85 e5 ff ff       	call   f01012e8 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d63:	83 c4 20             	add    $0x20,%esp
f0102d66:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d6b:	0f 85 84 01 00 00    	jne    f0102ef5 <mem_init+0x1b38>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d71:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d78:	01 01 01 
f0102d7b:	0f 85 8d 01 00 00    	jne    f0102f0e <mem_init+0x1b51>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d81:	6a 02                	push   $0x2
f0102d83:	68 00 10 00 00       	push   $0x1000
f0102d88:	56                   	push   %esi
f0102d89:	ff 35 5c 12 21 f0    	push   0xf021125c
f0102d8f:	e8 54 e5 ff ff       	call   f01012e8 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d94:	83 c4 10             	add    $0x10,%esp
f0102d97:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d9e:	02 02 02 
f0102da1:	0f 85 80 01 00 00    	jne    f0102f27 <mem_init+0x1b6a>
	assert(pp2->pp_ref == 1);
f0102da7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dac:	0f 85 8e 01 00 00    	jne    f0102f40 <mem_init+0x1b83>
	assert(pp1->pp_ref == 0);
f0102db2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102db7:	0f 85 9c 01 00 00    	jne    f0102f59 <mem_init+0x1b9c>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102dbd:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102dc4:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102dc7:	89 f0                	mov    %esi,%eax
f0102dc9:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0102dcf:	c1 f8 03             	sar    $0x3,%eax
f0102dd2:	89 c2                	mov    %eax,%edx
f0102dd4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102dd7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102ddc:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0102de2:	0f 83 8a 01 00 00    	jae    f0102f72 <mem_init+0x1bb5>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102de8:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102def:	03 03 03 
f0102df2:	0f 85 8c 01 00 00    	jne    f0102f84 <mem_init+0x1bc7>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102df8:	83 ec 08             	sub    $0x8,%esp
f0102dfb:	68 00 10 00 00       	push   $0x1000
f0102e00:	ff 35 5c 12 21 f0    	push   0xf021125c
f0102e06:	e8 9f e4 ff ff       	call   f01012aa <page_remove>
	assert(pp2->pp_ref == 0);
f0102e0b:	83 c4 10             	add    $0x10,%esp
f0102e0e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e13:	0f 85 84 01 00 00    	jne    f0102f9d <mem_init+0x1be0>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e19:	8b 0d 5c 12 21 f0    	mov    0xf021125c,%ecx
f0102e1f:	8b 11                	mov    (%ecx),%edx
f0102e21:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102e27:	89 d8                	mov    %ebx,%eax
f0102e29:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f0102e2f:	c1 f8 03             	sar    $0x3,%eax
f0102e32:	c1 e0 0c             	shl    $0xc,%eax
f0102e35:	39 c2                	cmp    %eax,%edx
f0102e37:	0f 85 79 01 00 00    	jne    f0102fb6 <mem_init+0x1bf9>
	kern_pgdir[0] = 0;
f0102e3d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e43:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e48:	0f 85 81 01 00 00    	jne    f0102fcf <mem_init+0x1c12>
	pp0->pp_ref = 0;
f0102e4e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e54:	83 ec 0c             	sub    $0xc,%esp
f0102e57:	53                   	push   %ebx
f0102e58:	e8 34 e2 ff ff       	call   f0101091 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e5d:	c7 04 24 74 6d 10 f0 	movl   $0xf0106d74,(%esp)
f0102e64:	e8 ad 0b 00 00       	call   f0103a16 <cprintf>
}
f0102e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e6c:	5b                   	pop    %ebx
f0102e6d:	5e                   	pop    %esi
f0102e6e:	5f                   	pop    %edi
f0102e6f:	5d                   	pop    %ebp
f0102e70:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e71:	50                   	push   %eax
f0102e72:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0102e77:	68 f1 00 00 00       	push   $0xf1
f0102e7c:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102e81:	e8 ba d1 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e86:	68 dd 6e 10 f0       	push   $0xf0106edd
f0102e8b:	68 15 6e 10 f0       	push   $0xf0106e15
f0102e90:	68 58 04 00 00       	push   $0x458
f0102e95:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102e9a:	e8 a1 d1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e9f:	68 f3 6e 10 f0       	push   $0xf0106ef3
f0102ea4:	68 15 6e 10 f0       	push   $0xf0106e15
f0102ea9:	68 59 04 00 00       	push   $0x459
f0102eae:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102eb3:	e8 88 d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102eb8:	68 09 6f 10 f0       	push   $0xf0106f09
f0102ebd:	68 15 6e 10 f0       	push   $0xf0106e15
f0102ec2:	68 5a 04 00 00       	push   $0x45a
f0102ec7:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102ecc:	e8 6f d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ed1:	52                   	push   %edx
f0102ed2:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102ed7:	6a 58                	push   $0x58
f0102ed9:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0102ede:	e8 5d d1 ff ff       	call   f0100040 <_panic>
f0102ee3:	52                   	push   %edx
f0102ee4:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102ee9:	6a 58                	push   $0x58
f0102eeb:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0102ef0:	e8 4b d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102ef5:	68 da 6f 10 f0       	push   $0xf0106fda
f0102efa:	68 15 6e 10 f0       	push   $0xf0106e15
f0102eff:	68 5f 04 00 00       	push   $0x45f
f0102f04:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102f09:	e8 32 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f0e:	68 00 6d 10 f0       	push   $0xf0106d00
f0102f13:	68 15 6e 10 f0       	push   $0xf0106e15
f0102f18:	68 60 04 00 00       	push   $0x460
f0102f1d:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102f22:	e8 19 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f27:	68 24 6d 10 f0       	push   $0xf0106d24
f0102f2c:	68 15 6e 10 f0       	push   $0xf0106e15
f0102f31:	68 62 04 00 00       	push   $0x462
f0102f36:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102f3b:	e8 00 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102f40:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0102f45:	68 15 6e 10 f0       	push   $0xf0106e15
f0102f4a:	68 63 04 00 00       	push   $0x463
f0102f4f:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102f54:	e8 e7 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102f59:	68 66 70 10 f0       	push   $0xf0107066
f0102f5e:	68 15 6e 10 f0       	push   $0xf0106e15
f0102f63:	68 64 04 00 00       	push   $0x464
f0102f68:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102f6d:	e8 ce d0 ff ff       	call   f0100040 <_panic>
f0102f72:	52                   	push   %edx
f0102f73:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102f78:	6a 58                	push   $0x58
f0102f7a:	68 fb 6d 10 f0       	push   $0xf0106dfb
f0102f7f:	e8 bc d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f84:	68 48 6d 10 f0       	push   $0xf0106d48
f0102f89:	68 15 6e 10 f0       	push   $0xf0106e15
f0102f8e:	68 66 04 00 00       	push   $0x466
f0102f93:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102f98:	e8 a3 d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102f9d:	68 34 70 10 f0       	push   $0xf0107034
f0102fa2:	68 15 6e 10 f0       	push   $0xf0106e15
f0102fa7:	68 68 04 00 00       	push   $0x468
f0102fac:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102fb1:	e8 8a d0 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fb6:	68 d0 66 10 f0       	push   $0xf01066d0
f0102fbb:	68 15 6e 10 f0       	push   $0xf0106e15
f0102fc0:	68 6b 04 00 00       	push   $0x46b
f0102fc5:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102fca:	e8 71 d0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102fcf:	68 eb 6f 10 f0       	push   $0xf0106feb
f0102fd4:	68 15 6e 10 f0       	push   $0xf0106e15
f0102fd9:	68 6d 04 00 00       	push   $0x46d
f0102fde:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0102fe3:	e8 58 d0 ff ff       	call   f0100040 <_panic>

f0102fe8 <user_mem_check>:
{
f0102fe8:	55                   	push   %ebp
f0102fe9:	89 e5                	mov    %esp,%ebp
f0102feb:	57                   	push   %edi
f0102fec:	56                   	push   %esi
f0102fed:	53                   	push   %ebx
f0102fee:	83 ec 0c             	sub    $0xc,%esp
	for (uintptr_t i = ROUNDDOWN((uintptr_t ) va,PGSIZE);i < (uintptr_t ) (va + len);i=i+PGSIZE) {
f0102ff1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ff4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102ffa:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102ffd:	03 7d 10             	add    0x10(%ebp),%edi
        if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) {
f0103000:	8b 75 14             	mov    0x14(%ebp),%esi
f0103003:	83 ce 01             	or     $0x1,%esi
	for (uintptr_t i = ROUNDDOWN((uintptr_t ) va,PGSIZE);i < (uintptr_t ) (va + len);i=i+PGSIZE) {
f0103006:	eb 06                	jmp    f010300e <user_mem_check+0x26>
f0103008:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010300e:	39 df                	cmp    %ebx,%edi
f0103010:	76 3b                	jbe    f010304d <user_mem_check+0x65>
        pte_t *pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f0103012:	83 ec 04             	sub    $0x4,%esp
f0103015:	6a 00                	push   $0x0
f0103017:	53                   	push   %ebx
f0103018:	8b 45 08             	mov    0x8(%ebp),%eax
f010301b:	ff 70 60             	push   0x60(%eax)
f010301e:	e8 d2 e0 ff ff       	call   f01010f5 <pgdir_walk>
        if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) {
f0103023:	83 c4 10             	add    $0x10,%esp
f0103026:	85 c0                	test   %eax,%eax
f0103028:	74 08                	je     f0103032 <user_mem_check+0x4a>
f010302a:	89 f2                	mov    %esi,%edx
f010302c:	23 10                	and    (%eax),%edx
f010302e:	39 d6                	cmp    %edx,%esi
f0103030:	74 d6                	je     f0103008 <user_mem_check+0x20>
            user_mem_check_addr = (i < (uintptr_t)va) ? (uintptr_t)va : i;
f0103032:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0103035:	89 d8                	mov    %ebx,%eax
f0103037:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f010303b:	a3 68 12 21 f0       	mov    %eax,0xf0211268
            return -E_FAULT;
f0103040:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0103045:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103048:	5b                   	pop    %ebx
f0103049:	5e                   	pop    %esi
f010304a:	5f                   	pop    %edi
f010304b:	5d                   	pop    %ebp
f010304c:	c3                   	ret    
	return 0;
f010304d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103052:	eb f1                	jmp    f0103045 <user_mem_check+0x5d>

f0103054 <user_mem_assert>:
{
f0103054:	55                   	push   %ebp
f0103055:	89 e5                	mov    %esp,%ebp
f0103057:	53                   	push   %ebx
f0103058:	83 ec 04             	sub    $0x4,%esp
f010305b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010305e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103061:	83 c8 04             	or     $0x4,%eax
f0103064:	50                   	push   %eax
f0103065:	ff 75 10             	push   0x10(%ebp)
f0103068:	ff 75 0c             	push   0xc(%ebp)
f010306b:	53                   	push   %ebx
f010306c:	e8 77 ff ff ff       	call   f0102fe8 <user_mem_check>
f0103071:	83 c4 10             	add    $0x10,%esp
f0103074:	85 c0                	test   %eax,%eax
f0103076:	78 05                	js     f010307d <user_mem_assert+0x29>
}
f0103078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010307b:	c9                   	leave  
f010307c:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010307d:	83 ec 04             	sub    $0x4,%esp
f0103080:	ff 35 68 12 21 f0    	push   0xf0211268
f0103086:	ff 73 48             	push   0x48(%ebx)
f0103089:	68 a0 6d 10 f0       	push   $0xf0106da0
f010308e:	e8 83 09 00 00       	call   f0103a16 <cprintf>
		env_destroy(env);	// may not return
f0103093:	89 1c 24             	mov    %ebx,(%esp)
f0103096:	e8 75 06 00 00       	call   f0103710 <env_destroy>
f010309b:	83 c4 10             	add    $0x10,%esp
}
f010309e:	eb d8                	jmp    f0103078 <user_mem_assert+0x24>

f01030a0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01030a0:	55                   	push   %ebp
f01030a1:	89 e5                	mov    %esp,%ebp
f01030a3:	57                   	push   %edi
f01030a4:	56                   	push   %esi
f01030a5:	53                   	push   %ebx
f01030a6:	83 ec 0c             	sub    $0xc,%esp
f01030a9:	89 c7                	mov    %eax,%edi
f01030ab:	89 d3                	mov    %edx,%ebx
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	uint32_t upper_bound = ROUNDUP((uint32_t) va + (uint32_t) len, PGSIZE);
f01030ad:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01030b4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uint32_t lower_bound = ROUNDDOWN((uint32_t) va, PGSIZE);
f01030ba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	if (upper_bound > UTOP) {
f01030c0:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
f01030c6:	77 30                	ja     f01030f8 <region_alloc+0x58>
		panic("region alloc: Trying to allocate above UTOP");
	}

	for (; lower_bound < upper_bound; lower_bound+=PGSIZE) {
f01030c8:	39 f3                	cmp    %esi,%ebx
f01030ca:	73 71                	jae    f010313d <region_alloc+0x9d>
		struct PageInfo* new_page = page_alloc(ALLOC_ZERO);
f01030cc:	83 ec 0c             	sub    $0xc,%esp
f01030cf:	6a 01                	push   $0x1
f01030d1:	e8 46 df ff ff       	call   f010101c <page_alloc>
		if (new_page == NULL) {
f01030d6:	83 c4 10             	add    $0x10,%esp
f01030d9:	85 c0                	test   %eax,%eax
f01030db:	74 32                	je     f010310f <region_alloc+0x6f>
			panic("region_alloc: page alloc fail");
		}
		int pg_insert = page_insert(e->env_pgdir, new_page, (void*) lower_bound, PTE_W | PTE_U | PTE_P);
f01030dd:	6a 07                	push   $0x7
f01030df:	53                   	push   %ebx
f01030e0:	50                   	push   %eax
f01030e1:	ff 77 60             	push   0x60(%edi)
f01030e4:	e8 ff e1 ff ff       	call   f01012e8 <page_insert>
		if (pg_insert != 0) {
f01030e9:	83 c4 10             	add    $0x10,%esp
f01030ec:	85 c0                	test   %eax,%eax
f01030ee:	75 36                	jne    f0103126 <region_alloc+0x86>
	for (; lower_bound < upper_bound; lower_bound+=PGSIZE) {
f01030f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030f6:	eb d0                	jmp    f01030c8 <region_alloc+0x28>
		panic("region alloc: Trying to allocate above UTOP");
f01030f8:	83 ec 04             	sub    $0x4,%esp
f01030fb:	68 04 71 10 f0       	push   $0xf0107104
f0103100:	68 31 01 00 00       	push   $0x131
f0103105:	68 b8 71 10 f0       	push   $0xf01071b8
f010310a:	e8 31 cf ff ff       	call   f0100040 <_panic>
			panic("region_alloc: page alloc fail");
f010310f:	83 ec 04             	sub    $0x4,%esp
f0103112:	68 c3 71 10 f0       	push   $0xf01071c3
f0103117:	68 37 01 00 00       	push   $0x137
f010311c:	68 b8 71 10 f0       	push   $0xf01071b8
f0103121:	e8 1a cf ff ff       	call   f0100040 <_panic>
			panic("region_alloc: page insert failed");
f0103126:	83 ec 04             	sub    $0x4,%esp
f0103129:	68 30 71 10 f0       	push   $0xf0107130
f010312e:	68 3b 01 00 00       	push   $0x13b
f0103133:	68 b8 71 10 f0       	push   $0xf01071b8
f0103138:	e8 03 cf ff ff       	call   f0100040 <_panic>
		}
	}
}
f010313d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103140:	5b                   	pop    %ebx
f0103141:	5e                   	pop    %esi
f0103142:	5f                   	pop    %edi
f0103143:	5d                   	pop    %ebp
f0103144:	c3                   	ret    

f0103145 <envid2env>:
{
f0103145:	55                   	push   %ebp
f0103146:	89 e5                	mov    %esp,%ebp
f0103148:	56                   	push   %esi
f0103149:	53                   	push   %ebx
f010314a:	8b 75 08             	mov    0x8(%ebp),%esi
f010314d:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0103150:	85 f6                	test   %esi,%esi
f0103152:	74 2e                	je     f0103182 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0103154:	89 f3                	mov    %esi,%ebx
f0103156:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010315c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010315f:	03 1d 74 12 21 f0    	add    0xf0211274,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103165:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103169:	74 5b                	je     f01031c6 <envid2env+0x81>
f010316b:	39 73 48             	cmp    %esi,0x48(%ebx)
f010316e:	75 62                	jne    f01031d2 <envid2env+0x8d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103170:	84 c0                	test   %al,%al
f0103172:	75 20                	jne    f0103194 <envid2env+0x4f>
	return 0;
f0103174:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f0103179:	8b 55 0c             	mov    0xc(%ebp),%edx
f010317c:	89 1a                	mov    %ebx,(%edx)
}
f010317e:	5b                   	pop    %ebx
f010317f:	5e                   	pop    %esi
f0103180:	5d                   	pop    %ebp
f0103181:	c3                   	ret    
		*env_store = curenv;
f0103182:	e8 d5 24 00 00       	call   f010565c <cpunum>
f0103187:	6b c0 74             	imul   $0x74,%eax,%eax
f010318a:	8b 98 28 20 25 f0    	mov    -0xfdadfd8(%eax),%ebx
		return 0;
f0103190:	89 f0                	mov    %esi,%eax
f0103192:	eb e5                	jmp    f0103179 <envid2env+0x34>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103194:	e8 c3 24 00 00       	call   f010565c <cpunum>
f0103199:	6b c0 74             	imul   $0x74,%eax,%eax
f010319c:	39 98 28 20 25 f0    	cmp    %ebx,-0xfdadfd8(%eax)
f01031a2:	74 d0                	je     f0103174 <envid2env+0x2f>
f01031a4:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01031a7:	e8 b0 24 00 00       	call   f010565c <cpunum>
f01031ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01031af:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f01031b5:	3b 70 48             	cmp    0x48(%eax),%esi
f01031b8:	74 ba                	je     f0103174 <envid2env+0x2f>
f01031ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f01031bf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031c4:	eb b3                	jmp    f0103179 <envid2env+0x34>
f01031c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f01031cb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031d0:	eb a7                	jmp    f0103179 <envid2env+0x34>
f01031d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01031d7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031dc:	eb 9b                	jmp    f0103179 <envid2env+0x34>

f01031de <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f01031de:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f01031e3:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01031e6:	b8 23 00 00 00       	mov    $0x23,%eax
f01031eb:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01031ed:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01031ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01031f4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031f6:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031f8:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031fa:	ea 01 32 10 f0 08 00 	ljmp   $0x8,$0xf0103201
	asm volatile("lldt %0" : : "r" (sel));
f0103201:	b8 00 00 00 00       	mov    $0x0,%eax
f0103206:	0f 00 d0             	lldt   %ax
}
f0103209:	c3                   	ret    

f010320a <env_init>:
{
f010320a:	55                   	push   %ebp
f010320b:	89 e5                	mov    %esp,%ebp
f010320d:	53                   	push   %ebx
f010320e:	83 ec 04             	sub    $0x4,%esp
		envs[i].env_status = ENV_FREE; //mark all environments as free
f0103211:	8b 1d 74 12 21 f0    	mov    0xf0211274,%ebx
f0103217:	8b 15 78 12 21 f0    	mov    0xf0211278,%edx
f010321d:	8d 83 84 ef 01 00    	lea    0x1ef84(%ebx),%eax
f0103223:	89 d1                	mov    %edx,%ecx
f0103225:	89 c2                	mov    %eax,%edx
f0103227:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0; //set all env_ids to 0
f010322e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list; //put environments in env_free_list
f0103235:	89 48 44             	mov    %ecx,0x44(%eax)
	for(i=NENV-1; i >= 0; i--) {
f0103238:	83 e8 7c             	sub    $0x7c,%eax
f010323b:	39 da                	cmp    %ebx,%edx
f010323d:	75 e4                	jne    f0103223 <env_init+0x19>
f010323f:	89 1d 78 12 21 f0    	mov    %ebx,0xf0211278
	env_init_percpu();
f0103245:	e8 94 ff ff ff       	call   f01031de <env_init_percpu>
}
f010324a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010324d:	c9                   	leave  
f010324e:	c3                   	ret    

f010324f <env_alloc>:
{
f010324f:	55                   	push   %ebp
f0103250:	89 e5                	mov    %esp,%ebp
f0103252:	56                   	push   %esi
f0103253:	53                   	push   %ebx
	if (!(e = env_free_list))
f0103254:	8b 1d 78 12 21 f0    	mov    0xf0211278,%ebx
f010325a:	85 db                	test   %ebx,%ebx
f010325c:	0f 84 74 01 00 00    	je     f01033d6 <env_alloc+0x187>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103262:	83 ec 0c             	sub    $0xc,%esp
f0103265:	6a 01                	push   $0x1
f0103267:	e8 b0 dd ff ff       	call   f010101c <page_alloc>
f010326c:	89 c6                	mov    %eax,%esi
f010326e:	83 c4 10             	add    $0x10,%esp
f0103271:	85 c0                	test   %eax,%eax
f0103273:	0f 84 64 01 00 00    	je     f01033dd <env_alloc+0x18e>
	return (pp - pages) << PGSHIFT;
f0103279:	2b 05 58 12 21 f0    	sub    0xf0211258,%eax
f010327f:	c1 f8 03             	sar    $0x3,%eax
f0103282:	89 c2                	mov    %eax,%edx
f0103284:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103287:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010328c:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0103292:	0f 83 17 01 00 00    	jae    f01033af <env_alloc+0x160>
	return (void *)(pa + KERNBASE);
f0103298:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t*) page2kva(p);
f010329e:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01032a1:	83 ec 04             	sub    $0x4,%esp
f01032a4:	68 00 10 00 00       	push   $0x1000
f01032a9:	ff 35 5c 12 21 f0    	push   0xf021125c
f01032af:	50                   	push   %eax
f01032b0:	e8 5b 1e 00 00       	call   f0105110 <memcpy>
	p->pp_ref++;
f01032b5:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032ba:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01032bd:	83 c4 10             	add    $0x10,%esp
f01032c0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032c5:	0f 86 f6 00 00 00    	jbe    f01033c1 <env_alloc+0x172>
	return (physaddr_t)kva - KERNBASE;
f01032cb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032d1:	83 ca 05             	or     $0x5,%edx
f01032d4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032da:	8b 43 48             	mov    0x48(%ebx),%eax
f01032dd:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f01032e2:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01032e7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032ec:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032ef:	89 da                	mov    %ebx,%edx
f01032f1:	2b 15 74 12 21 f0    	sub    0xf0211274,%edx
f01032f7:	c1 fa 02             	sar    $0x2,%edx
f01032fa:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103300:	09 d0                	or     %edx,%eax
f0103302:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103305:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103308:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010330b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103312:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103319:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103320:	83 ec 04             	sub    $0x4,%esp
f0103323:	6a 44                	push   $0x44
f0103325:	6a 00                	push   $0x0
f0103327:	53                   	push   %ebx
f0103328:	e8 3b 1d 00 00       	call   f0105068 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010332d:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103333:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103339:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010333f:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103346:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f010334c:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103353:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103357:	8b 43 44             	mov    0x44(%ebx),%eax
f010335a:	a3 78 12 21 f0       	mov    %eax,0xf0211278
	*newenv_store = e;
f010335f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103362:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103364:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103367:	e8 f0 22 00 00       	call   f010565c <cpunum>
f010336c:	6b c0 74             	imul   $0x74,%eax,%eax
f010336f:	83 c4 10             	add    $0x10,%esp
f0103372:	ba 00 00 00 00       	mov    $0x0,%edx
f0103377:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f010337e:	74 11                	je     f0103391 <env_alloc+0x142>
f0103380:	e8 d7 22 00 00       	call   f010565c <cpunum>
f0103385:	6b c0 74             	imul   $0x74,%eax,%eax
f0103388:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f010338e:	8b 50 48             	mov    0x48(%eax),%edx
f0103391:	83 ec 04             	sub    $0x4,%esp
f0103394:	53                   	push   %ebx
f0103395:	52                   	push   %edx
f0103396:	68 e1 71 10 f0       	push   $0xf01071e1
f010339b:	e8 76 06 00 00       	call   f0103a16 <cprintf>
	return 0;
f01033a0:	83 c4 10             	add    $0x10,%esp
f01033a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01033ab:	5b                   	pop    %ebx
f01033ac:	5e                   	pop    %esi
f01033ad:	5d                   	pop    %ebp
f01033ae:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033af:	52                   	push   %edx
f01033b0:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01033b5:	6a 58                	push   $0x58
f01033b7:	68 fb 6d 10 f0       	push   $0xf0106dfb
f01033bc:	e8 7f cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033c1:	50                   	push   %eax
f01033c2:	68 e8 5c 10 f0       	push   $0xf0105ce8
f01033c7:	68 ce 00 00 00       	push   $0xce
f01033cc:	68 b8 71 10 f0       	push   $0xf01071b8
f01033d1:	e8 6a cc ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01033d6:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033db:	eb cb                	jmp    f01033a8 <env_alloc+0x159>
		return -E_NO_MEM;
f01033dd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01033e2:	eb c4                	jmp    f01033a8 <env_alloc+0x159>

f01033e4 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033e4:	55                   	push   %ebp
f01033e5:	89 e5                	mov    %esp,%ebp
f01033e7:	57                   	push   %edi
f01033e8:	56                   	push   %esi
f01033e9:	53                   	push   %ebx
f01033ea:	83 ec 34             	sub    $0x34,%esp
f01033ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env* new_env = NULL;
f01033f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	env_alloc(&new_env, 0);
f01033f7:	6a 00                	push   $0x0
f01033f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01033fc:	50                   	push   %eax
f01033fd:	e8 4d fe ff ff       	call   f010324f <env_alloc>
	load_icode(new_env, binary);
f0103402:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103405:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (elf->e_magic != ELF_MAGIC) {
f0103408:	83 c4 10             	add    $0x10,%esp
f010340b:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103411:	75 25                	jne    f0103438 <env_create+0x54>
	struct Proghdr* ph = (struct Proghdr*) ((uint8_t*) elf + elf->e_phoff);
f0103413:	89 fb                	mov    %edi,%ebx
f0103415:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* end_ph = ph + elf->e_phnum;
f0103418:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010341c:	c1 e6 05             	shl    $0x5,%esi
f010341f:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f0103421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103424:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103427:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010342c:	76 21                	jbe    f010344f <env_create+0x6b>
	return (physaddr_t)kva - KERNBASE;
f010342e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103433:	0f 22 d8             	mov    %eax,%cr3
}
f0103436:	eb 61                	jmp    f0103499 <env_create+0xb5>
		panic("load icode: elf file e_magic != ELF_MAGIC");
f0103438:	83 ec 04             	sub    $0x4,%esp
f010343b:	68 54 71 10 f0       	push   $0xf0107154
f0103440:	68 78 01 00 00       	push   $0x178
f0103445:	68 b8 71 10 f0       	push   $0xf01071b8
f010344a:	e8 f1 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010344f:	50                   	push   %eax
f0103450:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0103455:	68 7e 01 00 00       	push   $0x17e
f010345a:	68 b8 71 10 f0       	push   $0xf01071b8
f010345f:	e8 dc cb ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0103464:	8b 53 08             	mov    0x8(%ebx),%edx
f0103467:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010346a:	e8 31 fc ff ff       	call   f01030a0 <region_alloc>
			memset((void*) ph->p_va, 0, ph->p_memsz);
f010346f:	83 ec 04             	sub    $0x4,%esp
f0103472:	ff 73 14             	push   0x14(%ebx)
f0103475:	6a 00                	push   $0x0
f0103477:	ff 73 08             	push   0x8(%ebx)
f010347a:	e8 e9 1b 00 00       	call   f0105068 <memset>
			memcpy((void*) ph->p_va, (binary + ph->p_offset), ph->p_filesz);
f010347f:	83 c4 0c             	add    $0xc,%esp
f0103482:	ff 73 10             	push   0x10(%ebx)
f0103485:	89 f8                	mov    %edi,%eax
f0103487:	03 43 04             	add    0x4(%ebx),%eax
f010348a:	50                   	push   %eax
f010348b:	ff 73 08             	push   0x8(%ebx)
f010348e:	e8 7d 1c 00 00       	call   f0105110 <memcpy>
f0103493:	83 c4 10             	add    $0x10,%esp
	for (; ph < end_ph; ph++) {
f0103496:	83 c3 20             	add    $0x20,%ebx
f0103499:	39 de                	cmp    %ebx,%esi
f010349b:	76 24                	jbe    f01034c1 <env_create+0xdd>
		if (ph->p_type == ELF_PROG_LOAD) {
f010349d:	83 3b 01             	cmpl   $0x1,(%ebx)
f01034a0:	75 f4                	jne    f0103496 <env_create+0xb2>
			if (ph->p_filesz > ph->p_memsz) {
f01034a2:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01034a5:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01034a8:	76 ba                	jbe    f0103464 <env_create+0x80>
				panic("load icode: program header file size and mem size error");
f01034aa:	83 ec 04             	sub    $0x4,%esp
f01034ad:	68 80 71 10 f0       	push   $0xf0107180
f01034b2:	68 82 01 00 00       	push   $0x182
f01034b7:	68 b8 71 10 f0       	push   $0xf01071b8
f01034bc:	e8 7f cb ff ff       	call   f0100040 <_panic>
	e->env_tf.tf_eip = elf->e_entry;
f01034c1:	8b 47 18             	mov    0x18(%edi),%eax
f01034c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01034c7:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*)(USTACKTOP) - PGSIZE, PGSIZE);
f01034ca:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01034cf:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01034d4:	89 f8                	mov    %edi,%eax
f01034d6:	e8 c5 fb ff ff       	call   f01030a0 <region_alloc>
	memset((void*)(USTACKTOP) - PGSIZE, 0, PGSIZE);
f01034db:	83 ec 04             	sub    $0x4,%esp
f01034de:	68 00 10 00 00       	push   $0x1000
f01034e3:	6a 00                	push   $0x0
f01034e5:	68 00 d0 bf ee       	push   $0xeebfd000
f01034ea:	e8 79 1b 00 00       	call   f0105068 <memset>
	lcr3(PADDR(kern_pgdir));
f01034ef:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034f4:	83 c4 10             	add    $0x10,%esp
f01034f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034fc:	76 20                	jbe    f010351e <env_create+0x13a>
	return (physaddr_t)kva - KERNBASE;
f01034fe:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103503:	0f 22 d8             	mov    %eax,%cr3
	new_env->env_type = type;
f0103506:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103509:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010350c:	89 42 50             	mov    %eax,0x50(%edx)
	new_env->env_parent_id = 0;
f010350f:	c7 42 4c 00 00 00 00 	movl   $0x0,0x4c(%edx)
}
f0103516:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103519:	5b                   	pop    %ebx
f010351a:	5e                   	pop    %esi
f010351b:	5f                   	pop    %edi
f010351c:	5d                   	pop    %ebp
f010351d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010351e:	50                   	push   %eax
f010351f:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0103524:	68 91 01 00 00       	push   $0x191
f0103529:	68 b8 71 10 f0       	push   $0xf01071b8
f010352e:	e8 0d cb ff ff       	call   f0100040 <_panic>

f0103533 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103533:	55                   	push   %ebp
f0103534:	89 e5                	mov    %esp,%ebp
f0103536:	57                   	push   %edi
f0103537:	56                   	push   %esi
f0103538:	53                   	push   %ebx
f0103539:	83 ec 1c             	sub    $0x1c,%esp
f010353c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010353f:	e8 18 21 00 00       	call   f010565c <cpunum>
f0103544:	6b c0 74             	imul   $0x74,%eax,%eax
f0103547:	39 b8 28 20 25 f0    	cmp    %edi,-0xfdadfd8(%eax)
f010354d:	74 48                	je     f0103597 <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010354f:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103552:	e8 05 21 00 00       	call   f010565c <cpunum>
f0103557:	6b c0 74             	imul   $0x74,%eax,%eax
f010355a:	ba 00 00 00 00       	mov    $0x0,%edx
f010355f:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f0103566:	74 11                	je     f0103579 <env_free+0x46>
f0103568:	e8 ef 20 00 00       	call   f010565c <cpunum>
f010356d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103570:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f0103576:	8b 50 48             	mov    0x48(%eax),%edx
f0103579:	83 ec 04             	sub    $0x4,%esp
f010357c:	53                   	push   %ebx
f010357d:	52                   	push   %edx
f010357e:	68 f6 71 10 f0       	push   $0xf01071f6
f0103583:	e8 8e 04 00 00       	call   f0103a16 <cprintf>
f0103588:	83 c4 10             	add    $0x10,%esp
f010358b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103592:	e9 a9 00 00 00       	jmp    f0103640 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f0103597:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
	if ((uint32_t)kva < KERNBASE)
f010359c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a1:	76 0a                	jbe    f01035ad <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01035a3:	05 00 00 00 10       	add    $0x10000000,%eax
f01035a8:	0f 22 d8             	mov    %eax,%cr3
}
f01035ab:	eb a2                	jmp    f010354f <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035ad:	50                   	push   %eax
f01035ae:	68 e8 5c 10 f0       	push   $0xf0105ce8
f01035b3:	68 b4 01 00 00       	push   $0x1b4
f01035b8:	68 b8 71 10 f0       	push   $0xf01071b8
f01035bd:	e8 7e ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035c2:	56                   	push   %esi
f01035c3:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01035c8:	68 c3 01 00 00       	push   $0x1c3
f01035cd:	68 b8 71 10 f0       	push   $0xf01071b8
f01035d2:	e8 69 ca ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01035d7:	83 c6 04             	add    $0x4,%esi
f01035da:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035e0:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f01035e6:	74 1b                	je     f0103603 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f01035e8:	f6 06 01             	testb  $0x1,(%esi)
f01035eb:	74 ea                	je     f01035d7 <env_free+0xa4>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035ed:	83 ec 08             	sub    $0x8,%esp
f01035f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035f3:	09 d8                	or     %ebx,%eax
f01035f5:	50                   	push   %eax
f01035f6:	ff 77 60             	push   0x60(%edi)
f01035f9:	e8 ac dc ff ff       	call   f01012aa <page_remove>
f01035fe:	83 c4 10             	add    $0x10,%esp
f0103601:	eb d4                	jmp    f01035d7 <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103603:	8b 47 60             	mov    0x60(%edi),%eax
f0103606:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103609:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103610:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103613:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0103619:	73 65                	jae    f0103680 <env_free+0x14d>
		page_decref(pa2page(pa));
f010361b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010361e:	a1 58 12 21 f0       	mov    0xf0211258,%eax
f0103623:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103626:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103629:	50                   	push   %eax
f010362a:	e8 9d da ff ff       	call   f01010cc <page_decref>
f010362f:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103632:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103636:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103639:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010363e:	74 54                	je     f0103694 <env_free+0x161>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103640:	8b 47 60             	mov    0x60(%edi),%eax
f0103643:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103646:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0103649:	a8 01                	test   $0x1,%al
f010364b:	74 e5                	je     f0103632 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010364d:	89 c6                	mov    %eax,%esi
f010364f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103655:	c1 e8 0c             	shr    $0xc,%eax
f0103658:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010365b:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f0103661:	0f 83 5b ff ff ff    	jae    f01035c2 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f0103667:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f010366d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103670:	c1 e0 14             	shl    $0x14,%eax
f0103673:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103676:	bb 00 00 00 00       	mov    $0x0,%ebx
f010367b:	e9 68 ff ff ff       	jmp    f01035e8 <env_free+0xb5>
		panic("pa2page called with invalid pa");
f0103680:	83 ec 04             	sub    $0x4,%esp
f0103683:	68 78 65 10 f0       	push   $0xf0106578
f0103688:	6a 51                	push   $0x51
f010368a:	68 fb 6d 10 f0       	push   $0xf0106dfb
f010368f:	e8 ac c9 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103694:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103697:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010369c:	76 49                	jbe    f01036e7 <env_free+0x1b4>
	e->env_pgdir = 0;
f010369e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01036a5:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01036aa:	c1 e8 0c             	shr    $0xc,%eax
f01036ad:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f01036b3:	73 47                	jae    f01036fc <env_free+0x1c9>
	page_decref(pa2page(pa));
f01036b5:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01036b8:	8b 15 58 12 21 f0    	mov    0xf0211258,%edx
f01036be:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01036c1:	50                   	push   %eax
f01036c2:	e8 05 da ff ff       	call   f01010cc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01036c7:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01036ce:	a1 78 12 21 f0       	mov    0xf0211278,%eax
f01036d3:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01036d6:	89 3d 78 12 21 f0    	mov    %edi,0xf0211278
}
f01036dc:	83 c4 10             	add    $0x10,%esp
f01036df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036e2:	5b                   	pop    %ebx
f01036e3:	5e                   	pop    %esi
f01036e4:	5f                   	pop    %edi
f01036e5:	5d                   	pop    %ebp
f01036e6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036e7:	50                   	push   %eax
f01036e8:	68 e8 5c 10 f0       	push   $0xf0105ce8
f01036ed:	68 d1 01 00 00       	push   $0x1d1
f01036f2:	68 b8 71 10 f0       	push   $0xf01071b8
f01036f7:	e8 44 c9 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01036fc:	83 ec 04             	sub    $0x4,%esp
f01036ff:	68 78 65 10 f0       	push   $0xf0106578
f0103704:	6a 51                	push   $0x51
f0103706:	68 fb 6d 10 f0       	push   $0xf0106dfb
f010370b:	e8 30 c9 ff ff       	call   f0100040 <_panic>

f0103710 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103710:	55                   	push   %ebp
f0103711:	89 e5                	mov    %esp,%ebp
f0103713:	53                   	push   %ebx
f0103714:	83 ec 04             	sub    $0x4,%esp
f0103717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010371a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010371e:	74 21                	je     f0103741 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103720:	83 ec 0c             	sub    $0xc,%esp
f0103723:	53                   	push   %ebx
f0103724:	e8 0a fe ff ff       	call   f0103533 <env_free>

	if (curenv == e) {
f0103729:	e8 2e 1f 00 00       	call   f010565c <cpunum>
f010372e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103731:	83 c4 10             	add    $0x10,%esp
f0103734:	39 98 28 20 25 f0    	cmp    %ebx,-0xfdadfd8(%eax)
f010373a:	74 1e                	je     f010375a <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f010373c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010373f:	c9                   	leave  
f0103740:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103741:	e8 16 1f 00 00       	call   f010565c <cpunum>
f0103746:	6b c0 74             	imul   $0x74,%eax,%eax
f0103749:	39 98 28 20 25 f0    	cmp    %ebx,-0xfdadfd8(%eax)
f010374f:	74 cf                	je     f0103720 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103751:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103758:	eb e2                	jmp    f010373c <env_destroy+0x2c>
		curenv = NULL;
f010375a:	e8 fd 1e 00 00       	call   f010565c <cpunum>
f010375f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103762:	c7 80 28 20 25 f0 00 	movl   $0x0,-0xfdadfd8(%eax)
f0103769:	00 00 00 
		sched_yield();
f010376c:	e8 4e 0c 00 00       	call   f01043bf <sched_yield>

f0103771 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103771:	55                   	push   %ebp
f0103772:	89 e5                	mov    %esp,%ebp
f0103774:	53                   	push   %ebx
f0103775:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103778:	e8 df 1e 00 00       	call   f010565c <cpunum>
f010377d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103780:	8b 98 28 20 25 f0    	mov    -0xfdadfd8(%eax),%ebx
f0103786:	e8 d1 1e 00 00       	call   f010565c <cpunum>
f010378b:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010378e:	8b 65 08             	mov    0x8(%ebp),%esp
f0103791:	61                   	popa   
f0103792:	07                   	pop    %es
f0103793:	1f                   	pop    %ds
f0103794:	83 c4 08             	add    $0x8,%esp
f0103797:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103798:	83 ec 04             	sub    $0x4,%esp
f010379b:	68 0c 72 10 f0       	push   $0xf010720c
f01037a0:	68 08 02 00 00       	push   $0x208
f01037a5:	68 b8 71 10 f0       	push   $0xf01071b8
f01037aa:	e8 91 c8 ff ff       	call   f0100040 <_panic>

f01037af <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01037af:	55                   	push   %ebp
f01037b0:	89 e5                	mov    %esp,%ebp
f01037b2:	83 ec 08             	sub    $0x8,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f01037b5:	e8 a2 1e 00 00       	call   f010565c <cpunum>
f01037ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01037bd:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f01037c4:	74 14                	je     f01037da <env_run+0x2b>
f01037c6:	e8 91 1e 00 00       	call   f010565c <cpunum>
f01037cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ce:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f01037d4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01037d8:	74 7d                	je     f0103857 <env_run+0xa8>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f01037da:	e8 7d 1e 00 00       	call   f010565c <cpunum>
f01037df:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e2:	8b 55 08             	mov    0x8(%ebp),%edx
f01037e5:	89 90 28 20 25 f0    	mov    %edx,-0xfdadfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f01037eb:	e8 6c 1e 00 00       	call   f010565c <cpunum>
f01037f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f3:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f01037f9:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103800:	e8 57 1e 00 00       	call   f010565c <cpunum>
f0103805:	6b c0 74             	imul   $0x74,%eax,%eax
f0103808:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f010380e:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103812:	e8 45 1e 00 00       	call   f010565c <cpunum>
f0103817:	6b c0 74             	imul   $0x74,%eax,%eax
f010381a:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f0103820:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103823:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103828:	76 47                	jbe    f0103871 <env_run+0xc2>
	return (physaddr_t)kva - KERNBASE;
f010382a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010382f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103832:	83 ec 0c             	sub    $0xc,%esp
f0103835:	68 c0 33 12 f0       	push   $0xf01233c0
f010383a:	e8 27 21 00 00       	call   f0105966 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010383f:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&(curenv->env_tf));
f0103841:	e8 16 1e 00 00       	call   f010565c <cpunum>
f0103846:	83 c4 04             	add    $0x4,%esp
f0103849:	6b c0 74             	imul   $0x74,%eax,%eax
f010384c:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f0103852:	e8 1a ff ff ff       	call   f0103771 <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f0103857:	e8 00 1e 00 00       	call   f010565c <cpunum>
f010385c:	6b c0 74             	imul   $0x74,%eax,%eax
f010385f:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f0103865:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010386c:	e9 69 ff ff ff       	jmp    f01037da <env_run+0x2b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103871:	50                   	push   %eax
f0103872:	68 e8 5c 10 f0       	push   $0xf0105ce8
f0103877:	68 2d 02 00 00       	push   $0x22d
f010387c:	68 b8 71 10 f0       	push   $0xf01071b8
f0103881:	e8 ba c7 ff ff       	call   f0100040 <_panic>

f0103886 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103886:	55                   	push   %ebp
f0103887:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103889:	8b 45 08             	mov    0x8(%ebp),%eax
f010388c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103891:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103892:	ba 71 00 00 00       	mov    $0x71,%edx
f0103897:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103898:	0f b6 c0             	movzbl %al,%eax
}
f010389b:	5d                   	pop    %ebp
f010389c:	c3                   	ret    

f010389d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010389d:	55                   	push   %ebp
f010389e:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01038a8:	ee                   	out    %al,(%dx)
f01038a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038ac:	ba 71 00 00 00       	mov    $0x71,%edx
f01038b1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01038b2:	5d                   	pop    %ebp
f01038b3:	c3                   	ret    

f01038b4 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01038b4:	55                   	push   %ebp
f01038b5:	89 e5                	mov    %esp,%ebp
f01038b7:	56                   	push   %esi
f01038b8:	53                   	push   %ebx
f01038b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f01038bc:	66 89 0d a8 33 12 f0 	mov    %cx,0xf01233a8
	if (!didinit)
f01038c3:	80 3d 7c 12 21 f0 00 	cmpb   $0x0,0xf021127c
f01038ca:	75 07                	jne    f01038d3 <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01038cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01038cf:	5b                   	pop    %ebx
f01038d0:	5e                   	pop    %esi
f01038d1:	5d                   	pop    %ebp
f01038d2:	c3                   	ret    
f01038d3:	89 ce                	mov    %ecx,%esi
f01038d5:	ba 21 00 00 00       	mov    $0x21,%edx
f01038da:	89 c8                	mov    %ecx,%eax
f01038dc:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01038dd:	89 c8                	mov    %ecx,%eax
f01038df:	66 c1 e8 08          	shr    $0x8,%ax
f01038e3:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038e8:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01038e9:	83 ec 0c             	sub    $0xc,%esp
f01038ec:	68 18 72 10 f0       	push   $0xf0107218
f01038f1:	e8 20 01 00 00       	call   f0103a16 <cprintf>
f01038f6:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01038f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01038fe:	0f b7 f6             	movzwl %si,%esi
f0103901:	f7 d6                	not    %esi
f0103903:	eb 08                	jmp    f010390d <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f0103905:	83 c3 01             	add    $0x1,%ebx
f0103908:	83 fb 10             	cmp    $0x10,%ebx
f010390b:	74 18                	je     f0103925 <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f010390d:	0f a3 de             	bt     %ebx,%esi
f0103910:	73 f3                	jae    f0103905 <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f0103912:	83 ec 08             	sub    $0x8,%esp
f0103915:	53                   	push   %ebx
f0103916:	68 d3 76 10 f0       	push   $0xf01076d3
f010391b:	e8 f6 00 00 00       	call   f0103a16 <cprintf>
f0103920:	83 c4 10             	add    $0x10,%esp
f0103923:	eb e0                	jmp    f0103905 <irq_setmask_8259A+0x51>
	cprintf("\n");
f0103925:	83 ec 0c             	sub    $0xc,%esp
f0103928:	68 cf 70 10 f0       	push   $0xf01070cf
f010392d:	e8 e4 00 00 00       	call   f0103a16 <cprintf>
f0103932:	83 c4 10             	add    $0x10,%esp
f0103935:	eb 95                	jmp    f01038cc <irq_setmask_8259A+0x18>

f0103937 <pic_init>:
{
f0103937:	55                   	push   %ebp
f0103938:	89 e5                	mov    %esp,%ebp
f010393a:	57                   	push   %edi
f010393b:	56                   	push   %esi
f010393c:	53                   	push   %ebx
f010393d:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103940:	c6 05 7c 12 21 f0 01 	movb   $0x1,0xf021127c
f0103947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010394c:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103951:	89 da                	mov    %ebx,%edx
f0103953:	ee                   	out    %al,(%dx)
f0103954:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103959:	89 ca                	mov    %ecx,%edx
f010395b:	ee                   	out    %al,(%dx)
f010395c:	bf 11 00 00 00       	mov    $0x11,%edi
f0103961:	be 20 00 00 00       	mov    $0x20,%esi
f0103966:	89 f8                	mov    %edi,%eax
f0103968:	89 f2                	mov    %esi,%edx
f010396a:	ee                   	out    %al,(%dx)
f010396b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103970:	89 da                	mov    %ebx,%edx
f0103972:	ee                   	out    %al,(%dx)
f0103973:	b8 04 00 00 00       	mov    $0x4,%eax
f0103978:	ee                   	out    %al,(%dx)
f0103979:	b8 03 00 00 00       	mov    $0x3,%eax
f010397e:	ee                   	out    %al,(%dx)
f010397f:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103984:	89 f8                	mov    %edi,%eax
f0103986:	89 da                	mov    %ebx,%edx
f0103988:	ee                   	out    %al,(%dx)
f0103989:	b8 28 00 00 00       	mov    $0x28,%eax
f010398e:	89 ca                	mov    %ecx,%edx
f0103990:	ee                   	out    %al,(%dx)
f0103991:	b8 02 00 00 00       	mov    $0x2,%eax
f0103996:	ee                   	out    %al,(%dx)
f0103997:	b8 01 00 00 00       	mov    $0x1,%eax
f010399c:	ee                   	out    %al,(%dx)
f010399d:	bf 68 00 00 00       	mov    $0x68,%edi
f01039a2:	89 f8                	mov    %edi,%eax
f01039a4:	89 f2                	mov    %esi,%edx
f01039a6:	ee                   	out    %al,(%dx)
f01039a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01039ac:	89 c8                	mov    %ecx,%eax
f01039ae:	ee                   	out    %al,(%dx)
f01039af:	89 f8                	mov    %edi,%eax
f01039b1:	89 da                	mov    %ebx,%edx
f01039b3:	ee                   	out    %al,(%dx)
f01039b4:	89 c8                	mov    %ecx,%eax
f01039b6:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01039b7:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01039be:	66 83 f8 ff          	cmp    $0xffff,%ax
f01039c2:	75 08                	jne    f01039cc <pic_init+0x95>
}
f01039c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039c7:	5b                   	pop    %ebx
f01039c8:	5e                   	pop    %esi
f01039c9:	5f                   	pop    %edi
f01039ca:	5d                   	pop    %ebp
f01039cb:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01039cc:	83 ec 0c             	sub    $0xc,%esp
f01039cf:	0f b7 c0             	movzwl %ax,%eax
f01039d2:	50                   	push   %eax
f01039d3:	e8 dc fe ff ff       	call   f01038b4 <irq_setmask_8259A>
f01039d8:	83 c4 10             	add    $0x10,%esp
}
f01039db:	eb e7                	jmp    f01039c4 <pic_init+0x8d>

f01039dd <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01039dd:	55                   	push   %ebp
f01039de:	89 e5                	mov    %esp,%ebp
f01039e0:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01039e3:	ff 75 08             	push   0x8(%ebp)
f01039e6:	e8 7b cd ff ff       	call   f0100766 <cputchar>
	*cnt++;
}
f01039eb:	83 c4 10             	add    $0x10,%esp
f01039ee:	c9                   	leave  
f01039ef:	c3                   	ret    

f01039f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039f0:	55                   	push   %ebp
f01039f1:	89 e5                	mov    %esp,%ebp
f01039f3:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01039f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039fd:	ff 75 0c             	push   0xc(%ebp)
f0103a00:	ff 75 08             	push   0x8(%ebp)
f0103a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a06:	50                   	push   %eax
f0103a07:	68 dd 39 10 f0       	push   $0xf01039dd
f0103a0c:	e8 42 0f 00 00       	call   f0104953 <vprintfmt>
	return cnt;
}
f0103a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a14:	c9                   	leave  
f0103a15:	c3                   	ret    

f0103a16 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a16:	55                   	push   %ebp
f0103a17:	89 e5                	mov    %esp,%ebp
f0103a19:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103a1c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103a1f:	50                   	push   %eax
f0103a20:	ff 75 08             	push   0x8(%ebp)
f0103a23:	e8 c8 ff ff ff       	call   f01039f0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a28:	c9                   	leave  
f0103a29:	c3                   	ret    

f0103a2a <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103a2a:	55                   	push   %ebp
f0103a2b:	89 e5                	mov    %esp,%ebp
f0103a2d:	57                   	push   %edi
f0103a2e:	56                   	push   %esi
f0103a2f:	53                   	push   %ebx
f0103a30:	83 ec 1c             	sub    $0x1c,%esp
    // LAB 4: Your code here:


    // Setup a TSS so that we get the right stack
    // when we trap to the kernel
    int32_t i = cpunum();
f0103a33:	e8 24 1c 00 00       	call   f010565c <cpunum>
f0103a38:	89 c6                	mov    %eax,%esi
    struct Taskstate tscurr= thiscpu->cpu_ts;
f0103a3a:	e8 1d 1c 00 00       	call   f010565c <cpunum>
    tscurr.ts_ss0 = GD_KD;
    tscurr.ts_iomb = sizeof(struct Taskstate);


    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103a3f:	8d 7e 05             	lea    0x5(%esi),%edi
f0103a42:	e8 15 1c 00 00       	call   f010565c <cpunum>
f0103a47:	89 c3                	mov    %eax,%ebx
f0103a49:	e8 0e 1c 00 00       	call   f010565c <cpunum>
f0103a4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a51:	e8 06 1c 00 00       	call   f010565c <cpunum>
f0103a56:	66 c7 04 fd 40 33 12 	movw   $0x67,-0xfedccc0(,%edi,8)
f0103a5d:	f0 67 00 
f0103a60:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103a63:	81 c3 2c 20 25 f0    	add    $0xf025202c,%ebx
f0103a69:	66 89 1c fd 42 33 12 	mov    %bx,-0xfedccbe(,%edi,8)
f0103a70:	f0 
f0103a71:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103a75:	81 c2 2c 20 25 f0    	add    $0xf025202c,%edx
f0103a7b:	c1 ea 10             	shr    $0x10,%edx
f0103a7e:	88 14 fd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%edi,8)
f0103a85:	c6 04 fd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%edi,8)
f0103a8c:	40 
f0103a8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a90:	05 2c 20 25 f0       	add    $0xf025202c,%eax
f0103a95:	c1 e8 18             	shr    $0x18,%eax
f0103a98:	88 04 fd 47 33 12 f0 	mov    %al,-0xfedccb9(,%edi,8)
                    sizeof(struct Taskstate) - 1, 0);
    gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103a9f:	c6 04 fd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%edi,8)
f0103aa6:	89 


    // Load the TSS selector (like other segment selectors, the
    // bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (i << 3));
f0103aa7:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	asm volatile("ltr %0" : : "r" (sel));
f0103aae:	0f 00 de             	ltr    %si
	asm volatile("lidt (%0)" : : "r" (p));
f0103ab1:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103ab6:	0f 01 18             	lidtl  (%eax)


    // Load the IDT
    lidt(&idt_pd);
}
f0103ab9:	83 c4 1c             	add    $0x1c,%esp
f0103abc:	5b                   	pop    %ebx
f0103abd:	5e                   	pop    %esi
f0103abe:	5f                   	pop    %edi
f0103abf:	5d                   	pop    %ebp
f0103ac0:	c3                   	ret    

f0103ac1 <trap_init>:
{
f0103ac1:	55                   	push   %ebp
f0103ac2:	89 e5                	mov    %esp,%ebp
f0103ac4:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103ac7:	b8 80 42 10 f0       	mov    $0xf0104280,%eax
f0103acc:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f0103ad2:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f0103ad9:	08 00 
f0103adb:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f0103ae2:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f0103ae9:	c1 e8 10             	shr    $0x10,%eax
f0103aec:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103af2:	b8 86 42 10 f0       	mov    $0xf0104286,%eax
f0103af7:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f0103afd:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f0103b04:	08 00 
f0103b06:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f0103b0d:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f0103b14:	c1 e8 10             	shr    $0x10,%eax
f0103b17:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103b1d:	b8 8c 42 10 f0       	mov    $0xf010428c,%eax
f0103b22:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f0103b28:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f0103b2f:	08 00 
f0103b31:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f0103b38:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f0103b3f:	c1 e8 10             	shr    $0x10,%eax
f0103b42:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103b48:	b8 92 42 10 f0       	mov    $0xf0104292,%eax
f0103b4d:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f0103b53:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f0103b5a:	08 00 
f0103b5c:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f0103b63:	c6 05 9d 12 21 f0 ee 	movb   $0xee,0xf021129d
f0103b6a:	c1 e8 10             	shr    $0x10,%eax
f0103b6d:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103b73:	b8 98 42 10 f0       	mov    $0xf0104298,%eax
f0103b78:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f0103b7e:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f0103b85:	08 00 
f0103b87:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f0103b8e:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f0103b95:	c1 e8 10             	shr    $0x10,%eax
f0103b98:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103b9e:	b8 9e 42 10 f0       	mov    $0xf010429e,%eax
f0103ba3:	66 a3 a8 12 21 f0    	mov    %ax,0xf02112a8
f0103ba9:	66 c7 05 aa 12 21 f0 	movw   $0x8,0xf02112aa
f0103bb0:	08 00 
f0103bb2:	c6 05 ac 12 21 f0 00 	movb   $0x0,0xf02112ac
f0103bb9:	c6 05 ad 12 21 f0 8e 	movb   $0x8e,0xf02112ad
f0103bc0:	c1 e8 10             	shr    $0x10,%eax
f0103bc3:	66 a3 ae 12 21 f0    	mov    %ax,0xf02112ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103bc9:	b8 a4 42 10 f0       	mov    $0xf01042a4,%eax
f0103bce:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f0103bd4:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f0103bdb:	08 00 
f0103bdd:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f0103be4:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f0103beb:	c1 e8 10             	shr    $0x10,%eax
f0103bee:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103bf4:	b8 aa 42 10 f0       	mov    $0xf01042aa,%eax
f0103bf9:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f0103bff:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f0103c06:	08 00 
f0103c08:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f0103c0f:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f0103c16:	c1 e8 10             	shr    $0x10,%eax
f0103c19:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103c1f:	b8 b0 42 10 f0       	mov    $0xf01042b0,%eax
f0103c24:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103c2a:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f0103c31:	08 00 
f0103c33:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f0103c3a:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f0103c41:	c1 e8 10             	shr    $0x10,%eax
f0103c44:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103c4a:	b8 b4 42 10 f0       	mov    $0xf01042b4,%eax
f0103c4f:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f0103c55:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f0103c5c:	08 00 
f0103c5e:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f0103c65:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103c6c:	c1 e8 10             	shr    $0x10,%eax
f0103c6f:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103c75:	b8 b8 42 10 f0       	mov    $0xf01042b8,%eax
f0103c7a:	66 a3 d8 12 21 f0    	mov    %ax,0xf02112d8
f0103c80:	66 c7 05 da 12 21 f0 	movw   $0x8,0xf02112da
f0103c87:	08 00 
f0103c89:	c6 05 dc 12 21 f0 00 	movb   $0x0,0xf02112dc
f0103c90:	c6 05 dd 12 21 f0 8e 	movb   $0x8e,0xf02112dd
f0103c97:	c1 e8 10             	shr    $0x10,%eax
f0103c9a:	66 a3 de 12 21 f0    	mov    %ax,0xf02112de
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103ca0:	b8 bc 42 10 f0       	mov    $0xf01042bc,%eax
f0103ca5:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f0103cab:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f0103cb2:	08 00 
f0103cb4:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f0103cbb:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f0103cc2:	c1 e8 10             	shr    $0x10,%eax
f0103cc5:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103ccb:	b8 c0 42 10 f0       	mov    $0xf01042c0,%eax
f0103cd0:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f0103cd6:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f0103cdd:	08 00 
f0103cdf:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f0103ce6:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f0103ced:	c1 e8 10             	shr    $0x10,%eax
f0103cf0:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103cf6:	b8 c4 42 10 f0       	mov    $0xf01042c4,%eax
f0103cfb:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103d01:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103d08:	08 00 
f0103d0a:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103d11:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103d18:	c1 e8 10             	shr    $0x10,%eax
f0103d1b:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103d21:	b8 c8 42 10 f0       	mov    $0xf01042c8,%eax
f0103d26:	66 a3 00 13 21 f0    	mov    %ax,0xf0211300
f0103d2c:	66 c7 05 02 13 21 f0 	movw   $0x8,0xf0211302
f0103d33:	08 00 
f0103d35:	c6 05 04 13 21 f0 00 	movb   $0x0,0xf0211304
f0103d3c:	c6 05 05 13 21 f0 8e 	movb   $0x8e,0xf0211305
f0103d43:	c1 e8 10             	shr    $0x10,%eax
f0103d46:	66 a3 06 13 21 f0    	mov    %ax,0xf0211306
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103d4c:	b8 ce 42 10 f0       	mov    $0xf01042ce,%eax
f0103d51:	66 a3 08 13 21 f0    	mov    %ax,0xf0211308
f0103d57:	66 c7 05 0a 13 21 f0 	movw   $0x8,0xf021130a
f0103d5e:	08 00 
f0103d60:	c6 05 0c 13 21 f0 00 	movb   $0x0,0xf021130c
f0103d67:	c6 05 0d 13 21 f0 8e 	movb   $0x8e,0xf021130d
f0103d6e:	c1 e8 10             	shr    $0x10,%eax
f0103d71:	66 a3 0e 13 21 f0    	mov    %ax,0xf021130e
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103d77:	b8 d2 42 10 f0       	mov    $0xf01042d2,%eax
f0103d7c:	66 a3 10 13 21 f0    	mov    %ax,0xf0211310
f0103d82:	66 c7 05 12 13 21 f0 	movw   $0x8,0xf0211312
f0103d89:	08 00 
f0103d8b:	c6 05 14 13 21 f0 00 	movb   $0x0,0xf0211314
f0103d92:	c6 05 15 13 21 f0 8e 	movb   $0x8e,0xf0211315
f0103d99:	c1 e8 10             	shr    $0x10,%eax
f0103d9c:	66 a3 16 13 21 f0    	mov    %ax,0xf0211316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103da2:	b8 d8 42 10 f0       	mov    $0xf01042d8,%eax
f0103da7:	66 a3 18 13 21 f0    	mov    %ax,0xf0211318
f0103dad:	66 c7 05 1a 13 21 f0 	movw   $0x8,0xf021131a
f0103db4:	08 00 
f0103db6:	c6 05 1c 13 21 f0 00 	movb   $0x0,0xf021131c
f0103dbd:	c6 05 1d 13 21 f0 8e 	movb   $0x8e,0xf021131d
f0103dc4:	c1 e8 10             	shr    $0x10,%eax
f0103dc7:	66 a3 1e 13 21 f0    	mov    %ax,0xf021131e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103dcd:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f0103dd2:	66 a3 00 14 21 f0    	mov    %ax,0xf0211400
f0103dd8:	66 c7 05 02 14 21 f0 	movw   $0x8,0xf0211402
f0103ddf:	08 00 
f0103de1:	c6 05 04 14 21 f0 00 	movb   $0x0,0xf0211404
f0103de8:	c6 05 05 14 21 f0 ee 	movb   $0xee,0xf0211405
f0103def:	c1 e8 10             	shr    $0x10,%eax
f0103df2:	66 a3 06 14 21 f0    	mov    %ax,0xf0211406
	trap_init_percpu();
f0103df8:	e8 2d fc ff ff       	call   f0103a2a <trap_init_percpu>
}
f0103dfd:	c9                   	leave  
f0103dfe:	c3                   	ret    

f0103dff <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103dff:	55                   	push   %ebp
f0103e00:	89 e5                	mov    %esp,%ebp
f0103e02:	53                   	push   %ebx
f0103e03:	83 ec 0c             	sub    $0xc,%esp
f0103e06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e09:	ff 33                	push   (%ebx)
f0103e0b:	68 2c 72 10 f0       	push   $0xf010722c
f0103e10:	e8 01 fc ff ff       	call   f0103a16 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e15:	83 c4 08             	add    $0x8,%esp
f0103e18:	ff 73 04             	push   0x4(%ebx)
f0103e1b:	68 3b 72 10 f0       	push   $0xf010723b
f0103e20:	e8 f1 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e25:	83 c4 08             	add    $0x8,%esp
f0103e28:	ff 73 08             	push   0x8(%ebx)
f0103e2b:	68 4a 72 10 f0       	push   $0xf010724a
f0103e30:	e8 e1 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e35:	83 c4 08             	add    $0x8,%esp
f0103e38:	ff 73 0c             	push   0xc(%ebx)
f0103e3b:	68 59 72 10 f0       	push   $0xf0107259
f0103e40:	e8 d1 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e45:	83 c4 08             	add    $0x8,%esp
f0103e48:	ff 73 10             	push   0x10(%ebx)
f0103e4b:	68 68 72 10 f0       	push   $0xf0107268
f0103e50:	e8 c1 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e55:	83 c4 08             	add    $0x8,%esp
f0103e58:	ff 73 14             	push   0x14(%ebx)
f0103e5b:	68 77 72 10 f0       	push   $0xf0107277
f0103e60:	e8 b1 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e65:	83 c4 08             	add    $0x8,%esp
f0103e68:	ff 73 18             	push   0x18(%ebx)
f0103e6b:	68 86 72 10 f0       	push   $0xf0107286
f0103e70:	e8 a1 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e75:	83 c4 08             	add    $0x8,%esp
f0103e78:	ff 73 1c             	push   0x1c(%ebx)
f0103e7b:	68 95 72 10 f0       	push   $0xf0107295
f0103e80:	e8 91 fb ff ff       	call   f0103a16 <cprintf>
}
f0103e85:	83 c4 10             	add    $0x10,%esp
f0103e88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e8b:	c9                   	leave  
f0103e8c:	c3                   	ret    

f0103e8d <print_trapframe>:
{
f0103e8d:	55                   	push   %ebp
f0103e8e:	89 e5                	mov    %esp,%ebp
f0103e90:	56                   	push   %esi
f0103e91:	53                   	push   %ebx
f0103e92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e95:	e8 c2 17 00 00       	call   f010565c <cpunum>
f0103e9a:	83 ec 04             	sub    $0x4,%esp
f0103e9d:	50                   	push   %eax
f0103e9e:	53                   	push   %ebx
f0103e9f:	68 f9 72 10 f0       	push   $0xf01072f9
f0103ea4:	e8 6d fb ff ff       	call   f0103a16 <cprintf>
	print_regs(&tf->tf_regs);
f0103ea9:	89 1c 24             	mov    %ebx,(%esp)
f0103eac:	e8 4e ff ff ff       	call   f0103dff <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eb1:	83 c4 08             	add    $0x8,%esp
f0103eb4:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103eb8:	50                   	push   %eax
f0103eb9:	68 17 73 10 f0       	push   $0xf0107317
f0103ebe:	e8 53 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ec3:	83 c4 08             	add    $0x8,%esp
f0103ec6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103eca:	50                   	push   %eax
f0103ecb:	68 2a 73 10 f0       	push   $0xf010732a
f0103ed0:	e8 41 fb ff ff       	call   f0103a16 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ed5:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103ed8:	83 c4 10             	add    $0x10,%esp
f0103edb:	83 f8 13             	cmp    $0x13,%eax
f0103ede:	0f 86 da 00 00 00    	jbe    f0103fbe <print_trapframe+0x131>
		return "System call";
f0103ee4:	ba a4 72 10 f0       	mov    $0xf01072a4,%edx
	if (trapno == T_SYSCALL)
f0103ee9:	83 f8 30             	cmp    $0x30,%eax
f0103eec:	74 13                	je     f0103f01 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103eee:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103ef1:	83 fa 0f             	cmp    $0xf,%edx
f0103ef4:	ba b0 72 10 f0       	mov    $0xf01072b0,%edx
f0103ef9:	b9 bf 72 10 f0       	mov    $0xf01072bf,%ecx
f0103efe:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f01:	83 ec 04             	sub    $0x4,%esp
f0103f04:	52                   	push   %edx
f0103f05:	50                   	push   %eax
f0103f06:	68 3d 73 10 f0       	push   $0xf010733d
f0103f0b:	e8 06 fb ff ff       	call   f0103a16 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f10:	83 c4 10             	add    $0x10,%esp
f0103f13:	39 1d 80 1a 21 f0    	cmp    %ebx,0xf0211a80
f0103f19:	0f 84 ab 00 00 00    	je     f0103fca <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f1f:	83 ec 08             	sub    $0x8,%esp
f0103f22:	ff 73 2c             	push   0x2c(%ebx)
f0103f25:	68 5e 73 10 f0       	push   $0xf010735e
f0103f2a:	e8 e7 fa ff ff       	call   f0103a16 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f2f:	83 c4 10             	add    $0x10,%esp
f0103f32:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f36:	0f 85 b1 00 00 00    	jne    f0103fed <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f3c:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f3f:	a8 01                	test   $0x1,%al
f0103f41:	b9 d2 72 10 f0       	mov    $0xf01072d2,%ecx
f0103f46:	ba dd 72 10 f0       	mov    $0xf01072dd,%edx
f0103f4b:	0f 44 ca             	cmove  %edx,%ecx
f0103f4e:	a8 02                	test   $0x2,%al
f0103f50:	ba e9 72 10 f0       	mov    $0xf01072e9,%edx
f0103f55:	be ef 72 10 f0       	mov    $0xf01072ef,%esi
f0103f5a:	0f 44 d6             	cmove  %esi,%edx
f0103f5d:	a8 04                	test   $0x4,%al
f0103f5f:	b8 f4 72 10 f0       	mov    $0xf01072f4,%eax
f0103f64:	be 29 74 10 f0       	mov    $0xf0107429,%esi
f0103f69:	0f 44 c6             	cmove  %esi,%eax
f0103f6c:	51                   	push   %ecx
f0103f6d:	52                   	push   %edx
f0103f6e:	50                   	push   %eax
f0103f6f:	68 6c 73 10 f0       	push   $0xf010736c
f0103f74:	e8 9d fa ff ff       	call   f0103a16 <cprintf>
f0103f79:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f7c:	83 ec 08             	sub    $0x8,%esp
f0103f7f:	ff 73 30             	push   0x30(%ebx)
f0103f82:	68 7b 73 10 f0       	push   $0xf010737b
f0103f87:	e8 8a fa ff ff       	call   f0103a16 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f8c:	83 c4 08             	add    $0x8,%esp
f0103f8f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f93:	50                   	push   %eax
f0103f94:	68 8a 73 10 f0       	push   $0xf010738a
f0103f99:	e8 78 fa ff ff       	call   f0103a16 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f9e:	83 c4 08             	add    $0x8,%esp
f0103fa1:	ff 73 38             	push   0x38(%ebx)
f0103fa4:	68 9d 73 10 f0       	push   $0xf010739d
f0103fa9:	e8 68 fa ff ff       	call   f0103a16 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fae:	83 c4 10             	add    $0x10,%esp
f0103fb1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fb5:	75 4b                	jne    f0104002 <print_trapframe+0x175>
}
f0103fb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fba:	5b                   	pop    %ebx
f0103fbb:	5e                   	pop    %esi
f0103fbc:	5d                   	pop    %ebp
f0103fbd:	c3                   	ret    
		return excnames[trapno];
f0103fbe:	8b 14 85 c0 75 10 f0 	mov    -0xfef8a40(,%eax,4),%edx
f0103fc5:	e9 37 ff ff ff       	jmp    f0103f01 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fca:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fce:	0f 85 4b ff ff ff    	jne    f0103f1f <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103fd4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103fd7:	83 ec 08             	sub    $0x8,%esp
f0103fda:	50                   	push   %eax
f0103fdb:	68 4f 73 10 f0       	push   $0xf010734f
f0103fe0:	e8 31 fa ff ff       	call   f0103a16 <cprintf>
f0103fe5:	83 c4 10             	add    $0x10,%esp
f0103fe8:	e9 32 ff ff ff       	jmp    f0103f1f <print_trapframe+0x92>
		cprintf("\n");
f0103fed:	83 ec 0c             	sub    $0xc,%esp
f0103ff0:	68 cf 70 10 f0       	push   $0xf01070cf
f0103ff5:	e8 1c fa ff ff       	call   f0103a16 <cprintf>
f0103ffa:	83 c4 10             	add    $0x10,%esp
f0103ffd:	e9 7a ff ff ff       	jmp    f0103f7c <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104002:	83 ec 08             	sub    $0x8,%esp
f0104005:	ff 73 3c             	push   0x3c(%ebx)
f0104008:	68 ac 73 10 f0       	push   $0xf01073ac
f010400d:	e8 04 fa ff ff       	call   f0103a16 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104012:	83 c4 08             	add    $0x8,%esp
f0104015:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104019:	50                   	push   %eax
f010401a:	68 bb 73 10 f0       	push   $0xf01073bb
f010401f:	e8 f2 f9 ff ff       	call   f0103a16 <cprintf>
f0104024:	83 c4 10             	add    $0x10,%esp
}
f0104027:	eb 8e                	jmp    f0103fb7 <print_trapframe+0x12a>

f0104029 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104029:	55                   	push   %ebp
f010402a:	89 e5                	mov    %esp,%ebp
f010402c:	57                   	push   %edi
f010402d:	56                   	push   %esi
f010402e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104031:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104032:	83 3d 00 10 21 f0 00 	cmpl   $0x0,0xf0211000
f0104039:	74 01                	je     f010403c <trap+0x13>
		asm volatile("hlt");
f010403b:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010403c:	e8 1b 16 00 00       	call   f010565c <cpunum>
f0104041:	6b d0 74             	imul   $0x74,%eax,%edx
f0104044:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104047:	b8 01 00 00 00       	mov    $0x1,%eax
f010404c:	f0 87 82 20 20 25 f0 	lock xchg %eax,-0xfdadfe0(%edx)
f0104053:	83 f8 02             	cmp    $0x2,%eax
f0104056:	0f 84 8a 00 00 00    	je     f01040e6 <trap+0xbd>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010405c:	9c                   	pushf  
f010405d:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010405e:	f6 c4 02             	test   $0x2,%ah
f0104061:	0f 85 94 00 00 00    	jne    f01040fb <trap+0xd2>

	if ((tf->tf_cs & 3) == 3) {
f0104067:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010406b:	83 e0 03             	and    $0x3,%eax
f010406e:	66 83 f8 03          	cmp    $0x3,%ax
f0104072:	0f 84 9c 00 00 00    	je     f0104114 <trap+0xeb>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104078:	89 35 80 1a 21 f0    	mov    %esi,0xf0211a80
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010407e:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0104082:	0f 84 31 01 00 00    	je     f01041b9 <trap+0x190>
	print_trapframe(tf);
f0104088:	83 ec 0c             	sub    $0xc,%esp
f010408b:	56                   	push   %esi
f010408c:	e8 fc fd ff ff       	call   f0103e8d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104091:	83 c4 10             	add    $0x10,%esp
f0104094:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104099:	0f 84 37 01 00 00    	je     f01041d6 <trap+0x1ad>
		env_destroy(curenv);
f010409f:	e8 b8 15 00 00       	call   f010565c <cpunum>
f01040a4:	83 ec 0c             	sub    $0xc,%esp
f01040a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040aa:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f01040b0:	e8 5b f6 ff ff       	call   f0103710 <env_destroy>
		return;
f01040b5:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01040b8:	e8 9f 15 00 00       	call   f010565c <cpunum>
f01040bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c0:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f01040c7:	74 18                	je     f01040e1 <trap+0xb8>
f01040c9:	e8 8e 15 00 00       	call   f010565c <cpunum>
f01040ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d1:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f01040d7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01040db:	0f 84 0c 01 00 00    	je     f01041ed <trap+0x1c4>
		env_run(curenv);
	else
		sched_yield();
f01040e1:	e8 d9 02 00 00       	call   f01043bf <sched_yield>
	spin_lock(&kernel_lock);
f01040e6:	83 ec 0c             	sub    $0xc,%esp
f01040e9:	68 c0 33 12 f0       	push   $0xf01233c0
f01040ee:	e8 d9 17 00 00       	call   f01058cc <spin_lock>
}
f01040f3:	83 c4 10             	add    $0x10,%esp
f01040f6:	e9 61 ff ff ff       	jmp    f010405c <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01040fb:	68 ce 73 10 f0       	push   $0xf01073ce
f0104100:	68 15 6e 10 f0       	push   $0xf0106e15
f0104105:	68 18 01 00 00       	push   $0x118
f010410a:	68 e7 73 10 f0       	push   $0xf01073e7
f010410f:	e8 2c bf ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f0104114:	83 ec 0c             	sub    $0xc,%esp
f0104117:	68 c0 33 12 f0       	push   $0xf01233c0
f010411c:	e8 ab 17 00 00       	call   f01058cc <spin_lock>
		assert(curenv);
f0104121:	e8 36 15 00 00       	call   f010565c <cpunum>
f0104126:	6b c0 74             	imul   $0x74,%eax,%eax
f0104129:	83 c4 10             	add    $0x10,%esp
f010412c:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f0104133:	74 3e                	je     f0104173 <trap+0x14a>
		if (curenv->env_status == ENV_DYING) {
f0104135:	e8 22 15 00 00       	call   f010565c <cpunum>
f010413a:	6b c0 74             	imul   $0x74,%eax,%eax
f010413d:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f0104143:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104147:	74 43                	je     f010418c <trap+0x163>
		curenv->env_tf = *tf;
f0104149:	e8 0e 15 00 00       	call   f010565c <cpunum>
f010414e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104151:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f0104157:	b9 11 00 00 00       	mov    $0x11,%ecx
f010415c:	89 c7                	mov    %eax,%edi
f010415e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104160:	e8 f7 14 00 00       	call   f010565c <cpunum>
f0104165:	6b c0 74             	imul   $0x74,%eax,%eax
f0104168:	8b b0 28 20 25 f0    	mov    -0xfdadfd8(%eax),%esi
f010416e:	e9 05 ff ff ff       	jmp    f0104078 <trap+0x4f>
		assert(curenv);
f0104173:	68 f3 73 10 f0       	push   $0xf01073f3
f0104178:	68 15 6e 10 f0       	push   $0xf0106e15
f010417d:	68 20 01 00 00       	push   $0x120
f0104182:	68 e7 73 10 f0       	push   $0xf01073e7
f0104187:	e8 b4 be ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f010418c:	e8 cb 14 00 00       	call   f010565c <cpunum>
f0104191:	83 ec 0c             	sub    $0xc,%esp
f0104194:	6b c0 74             	imul   $0x74,%eax,%eax
f0104197:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f010419d:	e8 91 f3 ff ff       	call   f0103533 <env_free>
			curenv = NULL;
f01041a2:	e8 b5 14 00 00       	call   f010565c <cpunum>
f01041a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041aa:	c7 80 28 20 25 f0 00 	movl   $0x0,-0xfdadfd8(%eax)
f01041b1:	00 00 00 
			sched_yield();
f01041b4:	e8 06 02 00 00       	call   f01043bf <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f01041b9:	83 ec 0c             	sub    $0xc,%esp
f01041bc:	68 fa 73 10 f0       	push   $0xf01073fa
f01041c1:	e8 50 f8 ff ff       	call   f0103a16 <cprintf>
		print_trapframe(tf);
f01041c6:	89 34 24             	mov    %esi,(%esp)
f01041c9:	e8 bf fc ff ff       	call   f0103e8d <print_trapframe>
		return;
f01041ce:	83 c4 10             	add    $0x10,%esp
f01041d1:	e9 e2 fe ff ff       	jmp    f01040b8 <trap+0x8f>
		panic("unhandled trap in kernel");
f01041d6:	83 ec 04             	sub    $0x4,%esp
f01041d9:	68 17 74 10 f0       	push   $0xf0107417
f01041de:	68 fe 00 00 00       	push   $0xfe
f01041e3:	68 e7 73 10 f0       	push   $0xf01073e7
f01041e8:	e8 53 be ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01041ed:	e8 6a 14 00 00       	call   f010565c <cpunum>
f01041f2:	83 ec 0c             	sub    $0xc,%esp
f01041f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f8:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f01041fe:	e8 ac f5 ff ff       	call   f01037af <env_run>

f0104203 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104203:	55                   	push   %ebp
f0104204:	89 e5                	mov    %esp,%ebp
f0104206:	57                   	push   %edi
f0104207:	56                   	push   %esi
f0104208:	53                   	push   %ebx
f0104209:	83 ec 0c             	sub    $0xc,%esp
f010420c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010420f:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 0x3) == 0) {
f0104212:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104216:	74 49                	je     f0104261 <page_fault_handler+0x5e>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104218:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010421b:	e8 3c 14 00 00       	call   f010565c <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104220:	57                   	push   %edi
f0104221:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104222:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104225:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f010422b:	ff 70 48             	push   0x48(%eax)
f010422e:	68 9c 75 10 f0       	push   $0xf010759c
f0104233:	e8 de f7 ff ff       	call   f0103a16 <cprintf>
	print_trapframe(tf);
f0104238:	89 1c 24             	mov    %ebx,(%esp)
f010423b:	e8 4d fc ff ff       	call   f0103e8d <print_trapframe>
	env_destroy(curenv);
f0104240:	e8 17 14 00 00       	call   f010565c <cpunum>
f0104245:	83 c4 04             	add    $0x4,%esp
f0104248:	6b c0 74             	imul   $0x74,%eax,%eax
f010424b:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f0104251:	e8 ba f4 ff ff       	call   f0103710 <env_destroy>
}
f0104256:	83 c4 10             	add    $0x10,%esp
f0104259:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010425c:	5b                   	pop    %ebx
f010425d:	5e                   	pop    %esi
f010425e:	5f                   	pop    %edi
f010425f:	5d                   	pop    %ebp
f0104260:	c3                   	ret    
		print_trapframe(tf);
f0104261:	83 ec 0c             	sub    $0xc,%esp
f0104264:	53                   	push   %ebx
f0104265:	e8 23 fc ff ff       	call   f0103e8d <print_trapframe>
		panic("page_fault_handler: page fault at %x", fault_va);
f010426a:	56                   	push   %esi
f010426b:	68 74 75 10 f0       	push   $0xf0107574
f0104270:	68 4f 01 00 00       	push   $0x14f
f0104275:	68 e7 73 10 f0       	push   $0xf01073e7
f010427a:	e8 c1 bd ff ff       	call   f0100040 <_panic>
f010427f:	90                   	nop

f0104280 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);
f0104280:	6a 00                	push   $0x0
f0104282:	6a 00                	push   $0x0
f0104284:	eb 5e                	jmp    f01042e4 <_alltraps>

f0104286 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);
f0104286:	6a 00                	push   $0x0
f0104288:	6a 01                	push   $0x1
f010428a:	eb 58                	jmp    f01042e4 <_alltraps>

f010428c <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);
f010428c:	6a 00                	push   $0x0
f010428e:	6a 02                	push   $0x2
f0104290:	eb 52                	jmp    f01042e4 <_alltraps>

f0104292 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);
f0104292:	6a 00                	push   $0x0
f0104294:	6a 03                	push   $0x3
f0104296:	eb 4c                	jmp    f01042e4 <_alltraps>

f0104298 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);
f0104298:	6a 00                	push   $0x0
f010429a:	6a 04                	push   $0x4
f010429c:	eb 46                	jmp    f01042e4 <_alltraps>

f010429e <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);
f010429e:	6a 00                	push   $0x0
f01042a0:	6a 05                	push   $0x5
f01042a2:	eb 40                	jmp    f01042e4 <_alltraps>

f01042a4 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);
f01042a4:	6a 00                	push   $0x0
f01042a6:	6a 06                	push   $0x6
f01042a8:	eb 3a                	jmp    f01042e4 <_alltraps>

f01042aa <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);
f01042aa:	6a 00                	push   $0x0
f01042ac:	6a 07                	push   $0x7
f01042ae:	eb 34                	jmp    f01042e4 <_alltraps>

f01042b0 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT);
f01042b0:	6a 08                	push   $0x8
f01042b2:	eb 30                	jmp    f01042e4 <_alltraps>

f01042b4 <t_tss>:
# //TRAPHANDLER_NOEC(t_coproc, T_COPROC);
TRAPHANDLER(t_tss, T_TSS);
f01042b4:	6a 0a                	push   $0xa
f01042b6:	eb 2c                	jmp    f01042e4 <_alltraps>

f01042b8 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);
f01042b8:	6a 0b                	push   $0xb
f01042ba:	eb 28                	jmp    f01042e4 <_alltraps>

f01042bc <t_stack>:
TRAPHANDLER(t_stack, T_STACK);
f01042bc:	6a 0c                	push   $0xc
f01042be:	eb 24                	jmp    f01042e4 <_alltraps>

f01042c0 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);
f01042c0:	6a 0d                	push   $0xd
f01042c2:	eb 20                	jmp    f01042e4 <_alltraps>

f01042c4 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);
f01042c4:	6a 0e                	push   $0xe
f01042c6:	eb 1c                	jmp    f01042e4 <_alltraps>

f01042c8 <t_fperr>:
# TRAPHANDLER_NOEC(t_res, T_RES);
TRAPHANDLER_NOEC(t_fperr, T_FPERR);
f01042c8:	6a 00                	push   $0x0
f01042ca:	6a 10                	push   $0x10
f01042cc:	eb 16                	jmp    f01042e4 <_alltraps>

f01042ce <t_align>:
TRAPHANDLER(t_align, T_ALIGN);
f01042ce:	6a 11                	push   $0x11
f01042d0:	eb 12                	jmp    f01042e4 <_alltraps>

f01042d2 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK);
f01042d2:	6a 00                	push   $0x0
f01042d4:	6a 12                	push   $0x12
f01042d6:	eb 0c                	jmp    f01042e4 <_alltraps>

f01042d8 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);
f01042d8:	6a 00                	push   $0x0
f01042da:	6a 13                	push   $0x13
f01042dc:	eb 06                	jmp    f01042e4 <_alltraps>

f01042de <t_syscall>:
// Unsure about syscall and default
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);
f01042de:	6a 00                	push   $0x0
f01042e0:	6a 30                	push   $0x30
f01042e2:	eb 00                	jmp    f01042e4 <_alltraps>

f01042e4 <_alltraps>:

_alltraps:
	pushl %ds
f01042e4:	1e                   	push   %ds
	pushl %es
f01042e5:	06                   	push   %es
	pushal
f01042e6:	60                   	pusha  
	movl $GD_KD, %eax
f01042e7:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01042ec:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01042ee:	8e c0                	mov    %eax,%es
	pushl %esp
f01042f0:	54                   	push   %esp
	call trap
f01042f1:	e8 33 fd ff ff       	call   f0104029 <trap>

f01042f6 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01042f6:	55                   	push   %ebp
f01042f7:	89 e5                	mov    %esp,%ebp
f01042f9:	83 ec 08             	sub    $0x8,%esp
f01042fc:	a1 74 12 21 f0       	mov    0xf0211274,%eax
f0104301:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104304:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104309:	8b 02                	mov    (%edx),%eax
f010430b:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010430e:	83 f8 02             	cmp    $0x2,%eax
f0104311:	76 2d                	jbe    f0104340 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104313:	83 c1 01             	add    $0x1,%ecx
f0104316:	83 c2 7c             	add    $0x7c,%edx
f0104319:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010431f:	75 e8                	jne    f0104309 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104321:	83 ec 0c             	sub    $0xc,%esp
f0104324:	68 10 76 10 f0       	push   $0xf0107610
f0104329:	e8 e8 f6 ff ff       	call   f0103a16 <cprintf>
f010432e:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104331:	83 ec 0c             	sub    $0xc,%esp
f0104334:	6a 00                	push   $0x0
f0104336:	e8 4a c6 ff ff       	call   f0100985 <monitor>
f010433b:	83 c4 10             	add    $0x10,%esp
f010433e:	eb f1                	jmp    f0104331 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104340:	e8 17 13 00 00       	call   f010565c <cpunum>
f0104345:	6b c0 74             	imul   $0x74,%eax,%eax
f0104348:	c7 80 28 20 25 f0 00 	movl   $0x0,-0xfdadfd8(%eax)
f010434f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104352:	a1 5c 12 21 f0       	mov    0xf021125c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104357:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010435c:	76 4f                	jbe    f01043ad <sched_halt+0xb7>
	return (physaddr_t)kva - KERNBASE;
f010435e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104363:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104366:	e8 f1 12 00 00       	call   f010565c <cpunum>
f010436b:	6b d0 74             	imul   $0x74,%eax,%edx
f010436e:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104371:	b8 02 00 00 00       	mov    $0x2,%eax
f0104376:	f0 87 82 20 20 25 f0 	lock xchg %eax,-0xfdadfe0(%edx)
	spin_unlock(&kernel_lock);
f010437d:	83 ec 0c             	sub    $0xc,%esp
f0104380:	68 c0 33 12 f0       	push   $0xf01233c0
f0104385:	e8 dc 15 00 00       	call   f0105966 <spin_unlock>
	asm volatile("pause");
f010438a:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010438c:	e8 cb 12 00 00       	call   f010565c <cpunum>
f0104391:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104394:	8b 80 30 20 25 f0    	mov    -0xfdadfd0(%eax),%eax
f010439a:	bd 00 00 00 00       	mov    $0x0,%ebp
f010439f:	89 c4                	mov    %eax,%esp
f01043a1:	6a 00                	push   $0x0
f01043a3:	6a 00                	push   $0x0
f01043a5:	f4                   	hlt    
f01043a6:	eb fd                	jmp    f01043a5 <sched_halt+0xaf>
}
f01043a8:	83 c4 10             	add    $0x10,%esp
f01043ab:	c9                   	leave  
f01043ac:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043ad:	50                   	push   %eax
f01043ae:	68 e8 5c 10 f0       	push   $0xf0105ce8
f01043b3:	6a 4e                	push   $0x4e
f01043b5:	68 39 76 10 f0       	push   $0xf0107639
f01043ba:	e8 81 bc ff ff       	call   f0100040 <_panic>

f01043bf <sched_yield>:
{
f01043bf:	55                   	push   %ebp
f01043c0:	89 e5                	mov    %esp,%ebp
f01043c2:	56                   	push   %esi
f01043c3:	53                   	push   %ebx
	if (curenv) {
f01043c4:	e8 93 12 00 00       	call   f010565c <cpunum>
f01043c9:	6b c0 74             	imul   $0x74,%eax,%eax
		start_env = 0;
f01043cc:	b9 00 00 00 00       	mov    $0x0,%ecx
	if (curenv) {
f01043d1:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f01043d8:	74 17                	je     f01043f1 <sched_yield+0x32>
		start_env = ENVX(curenv->env_id);
f01043da:	e8 7d 12 00 00       	call   f010565c <cpunum>
f01043df:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e2:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f01043e8:	8b 48 48             	mov    0x48(%eax),%ecx
f01043eb:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		if (envs[(start_env + i) % NENV].env_status == ENV_RUNNABLE) {
f01043f1:	8b 1d 74 12 21 f0    	mov    0xf0211274,%ebx
f01043f7:	8d 51 01             	lea    0x1(%ecx),%edx
f01043fa:	81 c1 01 04 00 00    	add    $0x401,%ecx
f0104400:	89 d6                	mov    %edx,%esi
f0104402:	c1 fe 1f             	sar    $0x1f,%esi
f0104405:	c1 ee 16             	shr    $0x16,%esi
f0104408:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010440b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104410:	29 f0                	sub    %esi,%eax
f0104412:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104415:	01 d8                	add    %ebx,%eax
f0104417:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010441b:	74 38                	je     f0104455 <sched_yield+0x96>
	for (int i=1; i<NENV+1; i++) {
f010441d:	83 c2 01             	add    $0x1,%edx
f0104420:	39 ca                	cmp    %ecx,%edx
f0104422:	75 dc                	jne    f0104400 <sched_yield+0x41>
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104424:	e8 33 12 00 00       	call   f010565c <cpunum>
f0104429:	6b c0 74             	imul   $0x74,%eax,%eax
f010442c:	83 b8 28 20 25 f0 00 	cmpl   $0x0,-0xfdadfd8(%eax)
f0104433:	74 14                	je     f0104449 <sched_yield+0x8a>
f0104435:	e8 22 12 00 00       	call   f010565c <cpunum>
f010443a:	6b c0 74             	imul   $0x74,%eax,%eax
f010443d:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f0104443:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104447:	74 15                	je     f010445e <sched_yield+0x9f>
	sched_halt();
f0104449:	e8 a8 fe ff ff       	call   f01042f6 <sched_halt>
}
f010444e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104451:	5b                   	pop    %ebx
f0104452:	5e                   	pop    %esi
f0104453:	5d                   	pop    %ebp
f0104454:	c3                   	ret    
			env_run(&envs[(start_env + i) % NENV]);
f0104455:	83 ec 0c             	sub    $0xc,%esp
f0104458:	50                   	push   %eax
f0104459:	e8 51 f3 ff ff       	call   f01037af <env_run>
		env_run(curenv);
f010445e:	e8 f9 11 00 00       	call   f010565c <cpunum>
f0104463:	83 ec 0c             	sub    $0xc,%esp
f0104466:	6b c0 74             	imul   $0x74,%eax,%eax
f0104469:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f010446f:	e8 3b f3 ff ff       	call   f01037af <env_run>

f0104474 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104474:	55                   	push   %ebp
f0104475:	89 e5                	mov    %esp,%ebp
f0104477:	53                   	push   %ebx
f0104478:	83 ec 14             	sub    $0x14,%esp
f010447b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	int32_t res = 0;
	switch (syscallno) {
f010447e:	83 f8 0a             	cmp    $0xa,%eax
f0104481:	0f 87 c8 00 00 00    	ja     f010454f <syscall+0xdb>
f0104487:	ff 24 85 80 76 10 f0 	jmp    *-0xfef8980(,%eax,4)
	if ((r = envid2env(envid, &e, 1)) < 0)
f010448e:	83 ec 04             	sub    $0x4,%esp
f0104491:	6a 01                	push   $0x1
f0104493:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104496:	50                   	push   %eax
f0104497:	ff 75 0c             	push   0xc(%ebp)
f010449a:	e8 a6 ec ff ff       	call   f0103145 <envid2env>
f010449f:	83 c4 10             	add    $0x10,%esp
f01044a2:	85 c0                	test   %eax,%eax
f01044a4:	78 46                	js     f01044ec <syscall+0x78>
	if (e == curenv)
f01044a6:	e8 b1 11 00 00       	call   f010565c <cpunum>
f01044ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01044ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b1:	39 90 28 20 25 f0    	cmp    %edx,-0xfdadfd8(%eax)
f01044b7:	74 73                	je     f010452c <syscall+0xb8>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01044b9:	8b 5a 48             	mov    0x48(%edx),%ebx
f01044bc:	e8 9b 11 00 00       	call   f010565c <cpunum>
f01044c1:	83 ec 04             	sub    $0x4,%esp
f01044c4:	53                   	push   %ebx
f01044c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c8:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f01044ce:	ff 70 48             	push   0x48(%eax)
f01044d1:	68 61 76 10 f0       	push   $0xf0107661
f01044d6:	e8 3b f5 ff ff       	call   f0103a16 <cprintf>
f01044db:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044de:	83 ec 0c             	sub    $0xc,%esp
f01044e1:	ff 75 f4             	push   -0xc(%ebp)
f01044e4:	e8 27 f2 ff ff       	call   f0103710 <env_destroy>
	return 0;
f01044e9:	83 c4 10             	add    $0x10,%esp
	return cons_getc();
f01044ec:	e8 14 c1 ff ff       	call   f0100605 <cons_getc>
	return curenv->env_id;
f01044f1:	e8 66 11 00 00       	call   f010565c <cpunum>
	user_mem_assert(curenv,s,len,0);
f01044f6:	e8 61 11 00 00       	call   f010565c <cpunum>
f01044fb:	6a 00                	push   $0x0
f01044fd:	ff 75 10             	push   0x10(%ebp)
f0104500:	ff 75 0c             	push   0xc(%ebp)
f0104503:	6b c0 74             	imul   $0x74,%eax,%eax
f0104506:	ff b0 28 20 25 f0    	push   -0xfdadfd8(%eax)
f010450c:	e8 43 eb ff ff       	call   f0103054 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104511:	83 c4 0c             	add    $0xc,%esp
f0104514:	ff 75 0c             	push   0xc(%ebp)
f0104517:	ff 75 10             	push   0x10(%ebp)
f010451a:	68 79 76 10 f0       	push   $0xf0107679
f010451f:	e8 f2 f4 ff ff       	call   f0103a16 <cprintf>
}
f0104524:	83 c4 10             	add    $0x10,%esp
	sched_yield();
f0104527:	e8 93 fe ff ff       	call   f01043bf <sched_yield>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010452c:	e8 2b 11 00 00       	call   f010565c <cpunum>
f0104531:	83 ec 08             	sub    $0x8,%esp
f0104534:	6b c0 74             	imul   $0x74,%eax,%eax
f0104537:	8b 80 28 20 25 f0    	mov    -0xfdadfd8(%eax),%eax
f010453d:	ff 70 48             	push   0x48(%eax)
f0104540:	68 46 76 10 f0       	push   $0xf0107646
f0104545:	e8 cc f4 ff ff       	call   f0103a16 <cprintf>
f010454a:	83 c4 10             	add    $0x10,%esp
f010454d:	eb 8f                	jmp    f01044de <syscall+0x6a>
		case SYS_cputs: res = 0; sys_cputs((const char*) a1, (size_t) a2);
		case SYS_yield: sys_yield();
		default: res =  -E_INVAL;
	}
	return res;
}
f010454f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104557:	c9                   	leave  
f0104558:	c3                   	ret    

f0104559 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104559:	55                   	push   %ebp
f010455a:	89 e5                	mov    %esp,%ebp
f010455c:	57                   	push   %edi
f010455d:	56                   	push   %esi
f010455e:	53                   	push   %ebx
f010455f:	83 ec 14             	sub    $0x14,%esp
f0104562:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104565:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104568:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010456b:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010456e:	8b 1a                	mov    (%edx),%ebx
f0104570:	8b 01                	mov    (%ecx),%eax
f0104572:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104575:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010457c:	eb 2f                	jmp    f01045ad <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010457e:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104581:	39 c3                	cmp    %eax,%ebx
f0104583:	7f 4e                	jg     f01045d3 <stab_binsearch+0x7a>
f0104585:	0f b6 0a             	movzbl (%edx),%ecx
f0104588:	83 ea 0c             	sub    $0xc,%edx
f010458b:	39 f1                	cmp    %esi,%ecx
f010458d:	75 ef                	jne    f010457e <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010458f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104592:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104595:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104599:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010459c:	73 3a                	jae    f01045d8 <stab_binsearch+0x7f>
			*region_left = m;
f010459e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01045a1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01045a3:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01045a6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01045ad:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01045b0:	7f 53                	jg     f0104605 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01045b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045b5:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01045b8:	89 d0                	mov    %edx,%eax
f01045ba:	c1 e8 1f             	shr    $0x1f,%eax
f01045bd:	01 d0                	add    %edx,%eax
f01045bf:	89 c7                	mov    %eax,%edi
f01045c1:	d1 ff                	sar    %edi
f01045c3:	83 e0 fe             	and    $0xfffffffe,%eax
f01045c6:	01 f8                	add    %edi,%eax
f01045c8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01045cb:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01045cf:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01045d1:	eb ae                	jmp    f0104581 <stab_binsearch+0x28>
			l = true_m + 1;
f01045d3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01045d6:	eb d5                	jmp    f01045ad <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01045d8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01045db:	76 14                	jbe    f01045f1 <stab_binsearch+0x98>
			*region_right = m - 1;
f01045dd:	83 e8 01             	sub    $0x1,%eax
f01045e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01045e6:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01045e8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01045ef:	eb bc                	jmp    f01045ad <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01045f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01045f4:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01045f6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01045fa:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01045fc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104603:	eb a8                	jmp    f01045ad <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104605:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104609:	75 15                	jne    f0104620 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010460b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010460e:	8b 00                	mov    (%eax),%eax
f0104610:	83 e8 01             	sub    $0x1,%eax
f0104613:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104616:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104618:	83 c4 14             	add    $0x14,%esp
f010461b:	5b                   	pop    %ebx
f010461c:	5e                   	pop    %esi
f010461d:	5f                   	pop    %edi
f010461e:	5d                   	pop    %ebp
f010461f:	c3                   	ret    
		for (l = *region_right;
f0104620:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104623:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104628:	8b 0f                	mov    (%edi),%ecx
f010462a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010462d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104630:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104634:	39 c1                	cmp    %eax,%ecx
f0104636:	7d 0f                	jge    f0104647 <stab_binsearch+0xee>
f0104638:	0f b6 1a             	movzbl (%edx),%ebx
f010463b:	83 ea 0c             	sub    $0xc,%edx
f010463e:	39 f3                	cmp    %esi,%ebx
f0104640:	74 05                	je     f0104647 <stab_binsearch+0xee>
		     l--)
f0104642:	83 e8 01             	sub    $0x1,%eax
f0104645:	eb ed                	jmp    f0104634 <stab_binsearch+0xdb>
		*region_left = l;
f0104647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010464a:	89 07                	mov    %eax,(%edi)
}
f010464c:	eb ca                	jmp    f0104618 <stab_binsearch+0xbf>

f010464e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010464e:	55                   	push   %ebp
f010464f:	89 e5                	mov    %esp,%ebp
f0104651:	57                   	push   %edi
f0104652:	56                   	push   %esi
f0104653:	53                   	push   %ebx
f0104654:	83 ec 4c             	sub    $0x4c,%esp
f0104657:	8b 7d 08             	mov    0x8(%ebp),%edi
f010465a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010465d:	c7 03 ac 76 10 f0    	movl   $0xf01076ac,(%ebx)
	info->eip_line = 0;
f0104663:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010466a:	c7 43 08 ac 76 10 f0 	movl   $0xf01076ac,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104671:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104678:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010467b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104682:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104688:	0f 87 25 01 00 00    	ja     f01047b3 <debuginfo_eip+0x165>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010468e:	a1 00 00 20 00       	mov    0x200000,%eax
f0104693:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104696:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010469b:	8b 35 08 00 20 00    	mov    0x200008,%esi
f01046a1:	89 75 bc             	mov    %esi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01046a4:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f01046aa:	89 75 c0             	mov    %esi,-0x40(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01046ad:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01046b0:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01046b3:	0f 83 8e 01 00 00    	jae    f0104847 <debuginfo_eip+0x1f9>
f01046b9:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01046bd:	0f 85 8b 01 00 00    	jne    f010484e <debuginfo_eip+0x200>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01046c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01046ca:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01046cd:	29 f0                	sub    %esi,%eax
f01046cf:	c1 f8 02             	sar    $0x2,%eax
f01046d2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01046d8:	83 e8 01             	sub    $0x1,%eax
f01046db:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01046de:	57                   	push   %edi
f01046df:	6a 64                	push   $0x64
f01046e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01046e4:	89 c1                	mov    %eax,%ecx
f01046e6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01046e9:	89 f0                	mov    %esi,%eax
f01046eb:	e8 69 fe ff ff       	call   f0104559 <stab_binsearch>
	if (lfile == 0)
f01046f0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01046f3:	83 c4 08             	add    $0x8,%esp
f01046f6:	85 f6                	test   %esi,%esi
f01046f8:	0f 84 57 01 00 00    	je     f0104855 <debuginfo_eip+0x207>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01046fe:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0104701:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104704:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104707:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010470a:	57                   	push   %edi
f010470b:	6a 24                	push   $0x24
f010470d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104710:	89 d1                	mov    %edx,%ecx
f0104712:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104715:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104718:	e8 3c fe ff ff       	call   f0104559 <stab_binsearch>

	if (lfun <= rfun) {
f010471d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104720:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104723:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104726:	89 c1                	mov    %eax,%ecx
f0104728:	89 45 b0             	mov    %eax,-0x50(%ebp)
f010472b:	83 c4 08             	add    $0x8,%esp
f010472e:	89 f0                	mov    %esi,%eax
f0104730:	39 ca                	cmp    %ecx,%edx
f0104732:	7f 2c                	jg     f0104760 <debuginfo_eip+0x112>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104734:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104737:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010473a:	8d 14 82             	lea    (%edx,%eax,4),%edx
f010473d:	8b 02                	mov    (%edx),%eax
f010473f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104742:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104745:	39 c8                	cmp    %ecx,%eax
f0104747:	73 06                	jae    f010474f <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104749:	03 45 bc             	add    -0x44(%ebp),%eax
f010474c:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010474f:	8b 42 08             	mov    0x8(%edx),%eax
f0104752:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104755:	29 c7                	sub    %eax,%edi
f0104757:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f010475a:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f010475d:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104763:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104766:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104769:	83 ec 08             	sub    $0x8,%esp
f010476c:	6a 3a                	push   $0x3a
f010476e:	ff 73 08             	push   0x8(%ebx)
f0104771:	e8 d6 08 00 00       	call   f010504c <strfind>
f0104776:	2b 43 08             	sub    0x8(%ebx),%eax
f0104779:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010477c:	83 c4 08             	add    $0x8,%esp
f010477f:	57                   	push   %edi
f0104780:	6a 44                	push   $0x44
f0104782:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104785:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104788:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010478b:	89 f8                	mov    %edi,%eax
f010478d:	e8 c7 fd ff ff       	call   f0104559 <stab_binsearch>
	if (lline == 0)
f0104792:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104795:	83 c4 10             	add    $0x10,%esp
f0104798:	85 c0                	test   %eax,%eax
f010479a:	0f 84 bc 00 00 00    	je     f010485c <debuginfo_eip+0x20e>
	{
		return -1;
	}
	else
	{
		info->eip_line = stabs[lline].n_desc;
f01047a0:	89 c2                	mov    %eax,%edx
f01047a2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01047a5:	0f b7 4c 87 06       	movzwl 0x6(%edi,%eax,4),%ecx
f01047aa:	89 4b 04             	mov    %ecx,0x4(%ebx)
f01047ad:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01047b1:	eb 25                	jmp    f01047d8 <debuginfo_eip+0x18a>
		stabstr_end = __STABSTR_END__;
f01047b3:	c7 45 c0 34 8f 11 f0 	movl   $0xf0118f34,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01047ba:	c7 45 bc 4d 27 11 f0 	movl   $0xf011274d,-0x44(%ebp)
		stab_end = __STAB_END__;
f01047c1:	b8 4c 27 11 f0       	mov    $0xf011274c,%eax
		stabs = __STAB_BEGIN__;
f01047c6:	c7 45 c4 74 7b 10 f0 	movl   $0xf0107b74,-0x3c(%ebp)
f01047cd:	e9 db fe ff ff       	jmp    f01046ad <debuginfo_eip+0x5f>
f01047d2:	83 ea 01             	sub    $0x1,%edx
f01047d5:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01047d8:	39 d6                	cmp    %edx,%esi
f01047da:	7f 2e                	jg     f010480a <debuginfo_eip+0x1bc>
	       && stabs[lline].n_type != N_SOL
f01047dc:	0f b6 08             	movzbl (%eax),%ecx
f01047df:	80 f9 84             	cmp    $0x84,%cl
f01047e2:	74 0b                	je     f01047ef <debuginfo_eip+0x1a1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01047e4:	80 f9 64             	cmp    $0x64,%cl
f01047e7:	75 e9                	jne    f01047d2 <debuginfo_eip+0x184>
f01047e9:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f01047ed:	74 e3                	je     f01047d2 <debuginfo_eip+0x184>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01047ef:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01047f2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01047f5:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01047f8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01047fb:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01047fe:	29 f0                	sub    %esi,%eax
f0104800:	39 c2                	cmp    %eax,%edx
f0104802:	73 06                	jae    f010480a <debuginfo_eip+0x1bc>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104804:	89 f0                	mov    %esi,%eax
f0104806:	01 d0                	add    %edx,%eax
f0104808:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010480a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010480f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104812:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0104815:	39 f7                	cmp    %esi,%edi
f0104817:	7d 4f                	jge    f0104868 <debuginfo_eip+0x21a>
		for (lline = lfun + 1;
f0104819:	83 c7 01             	add    $0x1,%edi
f010481c:	89 f8                	mov    %edi,%eax
f010481e:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0104821:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104824:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104828:	eb 04                	jmp    f010482e <debuginfo_eip+0x1e0>
			info->eip_fn_narg++;
f010482a:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010482e:	39 c6                	cmp    %eax,%esi
f0104830:	7e 31                	jle    f0104863 <debuginfo_eip+0x215>
f0104832:	0f b6 0a             	movzbl (%edx),%ecx
f0104835:	83 c0 01             	add    $0x1,%eax
f0104838:	83 c2 0c             	add    $0xc,%edx
f010483b:	80 f9 a0             	cmp    $0xa0,%cl
f010483e:	74 ea                	je     f010482a <debuginfo_eip+0x1dc>
	return 0;
f0104840:	b8 00 00 00 00       	mov    $0x0,%eax
f0104845:	eb 21                	jmp    f0104868 <debuginfo_eip+0x21a>
		return -1;
f0104847:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010484c:	eb 1a                	jmp    f0104868 <debuginfo_eip+0x21a>
f010484e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104853:	eb 13                	jmp    f0104868 <debuginfo_eip+0x21a>
		return -1;
f0104855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010485a:	eb 0c                	jmp    f0104868 <debuginfo_eip+0x21a>
		return -1;
f010485c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104861:	eb 05                	jmp    f0104868 <debuginfo_eip+0x21a>
	return 0;
f0104863:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104868:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010486b:	5b                   	pop    %ebx
f010486c:	5e                   	pop    %esi
f010486d:	5f                   	pop    %edi
f010486e:	5d                   	pop    %ebp
f010486f:	c3                   	ret    

f0104870 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104870:	55                   	push   %ebp
f0104871:	89 e5                	mov    %esp,%ebp
f0104873:	57                   	push   %edi
f0104874:	56                   	push   %esi
f0104875:	53                   	push   %ebx
f0104876:	83 ec 1c             	sub    $0x1c,%esp
f0104879:	89 c7                	mov    %eax,%edi
f010487b:	89 d6                	mov    %edx,%esi
f010487d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104880:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104883:	89 d1                	mov    %edx,%ecx
f0104885:	89 c2                	mov    %eax,%edx
f0104887:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010488a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010488d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104890:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104893:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104896:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010489d:	39 c2                	cmp    %eax,%edx
f010489f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01048a2:	72 3e                	jb     f01048e2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01048a4:	83 ec 0c             	sub    $0xc,%esp
f01048a7:	ff 75 18             	push   0x18(%ebp)
f01048aa:	83 eb 01             	sub    $0x1,%ebx
f01048ad:	53                   	push   %ebx
f01048ae:	50                   	push   %eax
f01048af:	83 ec 08             	sub    $0x8,%esp
f01048b2:	ff 75 e4             	push   -0x1c(%ebp)
f01048b5:	ff 75 e0             	push   -0x20(%ebp)
f01048b8:	ff 75 dc             	push   -0x24(%ebp)
f01048bb:	ff 75 d8             	push   -0x28(%ebp)
f01048be:	e8 8d 11 00 00       	call   f0105a50 <__udivdi3>
f01048c3:	83 c4 18             	add    $0x18,%esp
f01048c6:	52                   	push   %edx
f01048c7:	50                   	push   %eax
f01048c8:	89 f2                	mov    %esi,%edx
f01048ca:	89 f8                	mov    %edi,%eax
f01048cc:	e8 9f ff ff ff       	call   f0104870 <printnum>
f01048d1:	83 c4 20             	add    $0x20,%esp
f01048d4:	eb 13                	jmp    f01048e9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01048d6:	83 ec 08             	sub    $0x8,%esp
f01048d9:	56                   	push   %esi
f01048da:	ff 75 18             	push   0x18(%ebp)
f01048dd:	ff d7                	call   *%edi
f01048df:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01048e2:	83 eb 01             	sub    $0x1,%ebx
f01048e5:	85 db                	test   %ebx,%ebx
f01048e7:	7f ed                	jg     f01048d6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01048e9:	83 ec 08             	sub    $0x8,%esp
f01048ec:	56                   	push   %esi
f01048ed:	83 ec 04             	sub    $0x4,%esp
f01048f0:	ff 75 e4             	push   -0x1c(%ebp)
f01048f3:	ff 75 e0             	push   -0x20(%ebp)
f01048f6:	ff 75 dc             	push   -0x24(%ebp)
f01048f9:	ff 75 d8             	push   -0x28(%ebp)
f01048fc:	e8 6f 12 00 00       	call   f0105b70 <__umoddi3>
f0104901:	83 c4 14             	add    $0x14,%esp
f0104904:	0f be 80 b6 76 10 f0 	movsbl -0xfef894a(%eax),%eax
f010490b:	50                   	push   %eax
f010490c:	ff d7                	call   *%edi
}
f010490e:	83 c4 10             	add    $0x10,%esp
f0104911:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104914:	5b                   	pop    %ebx
f0104915:	5e                   	pop    %esi
f0104916:	5f                   	pop    %edi
f0104917:	5d                   	pop    %ebp
f0104918:	c3                   	ret    

f0104919 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104919:	55                   	push   %ebp
f010491a:	89 e5                	mov    %esp,%ebp
f010491c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010491f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104923:	8b 10                	mov    (%eax),%edx
f0104925:	3b 50 04             	cmp    0x4(%eax),%edx
f0104928:	73 0a                	jae    f0104934 <sprintputch+0x1b>
		*b->buf++ = ch;
f010492a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010492d:	89 08                	mov    %ecx,(%eax)
f010492f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104932:	88 02                	mov    %al,(%edx)
}
f0104934:	5d                   	pop    %ebp
f0104935:	c3                   	ret    

f0104936 <printfmt>:
{
f0104936:	55                   	push   %ebp
f0104937:	89 e5                	mov    %esp,%ebp
f0104939:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010493c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010493f:	50                   	push   %eax
f0104940:	ff 75 10             	push   0x10(%ebp)
f0104943:	ff 75 0c             	push   0xc(%ebp)
f0104946:	ff 75 08             	push   0x8(%ebp)
f0104949:	e8 05 00 00 00       	call   f0104953 <vprintfmt>
}
f010494e:	83 c4 10             	add    $0x10,%esp
f0104951:	c9                   	leave  
f0104952:	c3                   	ret    

f0104953 <vprintfmt>:
{
f0104953:	55                   	push   %ebp
f0104954:	89 e5                	mov    %esp,%ebp
f0104956:	57                   	push   %edi
f0104957:	56                   	push   %esi
f0104958:	53                   	push   %ebx
f0104959:	83 ec 3c             	sub    $0x3c,%esp
f010495c:	8b 75 08             	mov    0x8(%ebp),%esi
f010495f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104962:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104965:	eb 0a                	jmp    f0104971 <vprintfmt+0x1e>
			putch(ch, putdat);
f0104967:	83 ec 08             	sub    $0x8,%esp
f010496a:	53                   	push   %ebx
f010496b:	50                   	push   %eax
f010496c:	ff d6                	call   *%esi
f010496e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104971:	83 c7 01             	add    $0x1,%edi
f0104974:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104978:	83 f8 25             	cmp    $0x25,%eax
f010497b:	74 0c                	je     f0104989 <vprintfmt+0x36>
			if (ch == '\0')
f010497d:	85 c0                	test   %eax,%eax
f010497f:	75 e6                	jne    f0104967 <vprintfmt+0x14>
}
f0104981:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104984:	5b                   	pop    %ebx
f0104985:	5e                   	pop    %esi
f0104986:	5f                   	pop    %edi
f0104987:	5d                   	pop    %ebp
f0104988:	c3                   	ret    
		padc = ' ';
f0104989:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010498d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0104994:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010499b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01049a2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01049a7:	8d 47 01             	lea    0x1(%edi),%eax
f01049aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049ad:	0f b6 17             	movzbl (%edi),%edx
f01049b0:	8d 42 dd             	lea    -0x23(%edx),%eax
f01049b3:	3c 55                	cmp    $0x55,%al
f01049b5:	0f 87 bb 03 00 00    	ja     f0104d76 <vprintfmt+0x423>
f01049bb:	0f b6 c0             	movzbl %al,%eax
f01049be:	ff 24 85 60 77 10 f0 	jmp    *-0xfef88a0(,%eax,4)
f01049c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01049c8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f01049cc:	eb d9                	jmp    f01049a7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f01049ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01049d1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f01049d5:	eb d0                	jmp    f01049a7 <vprintfmt+0x54>
f01049d7:	0f b6 d2             	movzbl %dl,%edx
f01049da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01049dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01049e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01049e5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01049e8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01049ec:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01049ef:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01049f2:	83 f9 09             	cmp    $0x9,%ecx
f01049f5:	77 55                	ja     f0104a4c <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f01049f7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01049fa:	eb e9                	jmp    f01049e5 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f01049fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01049ff:	8b 00                	mov    (%eax),%eax
f0104a01:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a04:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a07:	8d 40 04             	lea    0x4(%eax),%eax
f0104a0a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104a10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104a14:	79 91                	jns    f01049a7 <vprintfmt+0x54>
				width = precision, precision = -1;
f0104a16:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104a19:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104a1c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104a23:	eb 82                	jmp    f01049a7 <vprintfmt+0x54>
f0104a25:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104a28:	85 d2                	test   %edx,%edx
f0104a2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a2f:	0f 49 c2             	cmovns %edx,%eax
f0104a32:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104a38:	e9 6a ff ff ff       	jmp    f01049a7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104a3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104a40:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0104a47:	e9 5b ff ff ff       	jmp    f01049a7 <vprintfmt+0x54>
f0104a4c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104a4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a52:	eb bc                	jmp    f0104a10 <vprintfmt+0xbd>
			lflag++;
f0104a54:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104a57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104a5a:	e9 48 ff ff ff       	jmp    f01049a7 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f0104a5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a62:	8d 78 04             	lea    0x4(%eax),%edi
f0104a65:	83 ec 08             	sub    $0x8,%esp
f0104a68:	53                   	push   %ebx
f0104a69:	ff 30                	push   (%eax)
f0104a6b:	ff d6                	call   *%esi
			break;
f0104a6d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104a70:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104a73:	e9 9d 02 00 00       	jmp    f0104d15 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f0104a78:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a7b:	8d 78 04             	lea    0x4(%eax),%edi
f0104a7e:	8b 10                	mov    (%eax),%edx
f0104a80:	89 d0                	mov    %edx,%eax
f0104a82:	f7 d8                	neg    %eax
f0104a84:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104a87:	83 f8 08             	cmp    $0x8,%eax
f0104a8a:	7f 23                	jg     f0104aaf <vprintfmt+0x15c>
f0104a8c:	8b 14 85 c0 78 10 f0 	mov    -0xfef8740(,%eax,4),%edx
f0104a93:	85 d2                	test   %edx,%edx
f0104a95:	74 18                	je     f0104aaf <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f0104a97:	52                   	push   %edx
f0104a98:	68 27 6e 10 f0       	push   $0xf0106e27
f0104a9d:	53                   	push   %ebx
f0104a9e:	56                   	push   %esi
f0104a9f:	e8 92 fe ff ff       	call   f0104936 <printfmt>
f0104aa4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104aa7:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104aaa:	e9 66 02 00 00       	jmp    f0104d15 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f0104aaf:	50                   	push   %eax
f0104ab0:	68 ce 76 10 f0       	push   $0xf01076ce
f0104ab5:	53                   	push   %ebx
f0104ab6:	56                   	push   %esi
f0104ab7:	e8 7a fe ff ff       	call   f0104936 <printfmt>
f0104abc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104abf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104ac2:	e9 4e 02 00 00       	jmp    f0104d15 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f0104ac7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aca:	83 c0 04             	add    $0x4,%eax
f0104acd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104ad0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ad3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104ad5:	85 d2                	test   %edx,%edx
f0104ad7:	b8 c7 76 10 f0       	mov    $0xf01076c7,%eax
f0104adc:	0f 45 c2             	cmovne %edx,%eax
f0104adf:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0104ae2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ae6:	7e 06                	jle    f0104aee <vprintfmt+0x19b>
f0104ae8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104aec:	75 0d                	jne    f0104afb <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104aee:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104af1:	89 c7                	mov    %eax,%edi
f0104af3:	03 45 e0             	add    -0x20(%ebp),%eax
f0104af6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104af9:	eb 55                	jmp    f0104b50 <vprintfmt+0x1fd>
f0104afb:	83 ec 08             	sub    $0x8,%esp
f0104afe:	ff 75 d8             	push   -0x28(%ebp)
f0104b01:	ff 75 cc             	push   -0x34(%ebp)
f0104b04:	e8 ec 03 00 00       	call   f0104ef5 <strnlen>
f0104b09:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b0c:	29 c1                	sub    %eax,%ecx
f0104b0e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104b11:	83 c4 10             	add    $0x10,%esp
f0104b14:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f0104b16:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104b1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b1d:	eb 0f                	jmp    f0104b2e <vprintfmt+0x1db>
					putch(padc, putdat);
f0104b1f:	83 ec 08             	sub    $0x8,%esp
f0104b22:	53                   	push   %ebx
f0104b23:	ff 75 e0             	push   -0x20(%ebp)
f0104b26:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b28:	83 ef 01             	sub    $0x1,%edi
f0104b2b:	83 c4 10             	add    $0x10,%esp
f0104b2e:	85 ff                	test   %edi,%edi
f0104b30:	7f ed                	jg     f0104b1f <vprintfmt+0x1cc>
f0104b32:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104b35:	85 d2                	test   %edx,%edx
f0104b37:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b3c:	0f 49 c2             	cmovns %edx,%eax
f0104b3f:	29 c2                	sub    %eax,%edx
f0104b41:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104b44:	eb a8                	jmp    f0104aee <vprintfmt+0x19b>
					putch(ch, putdat);
f0104b46:	83 ec 08             	sub    $0x8,%esp
f0104b49:	53                   	push   %ebx
f0104b4a:	52                   	push   %edx
f0104b4b:	ff d6                	call   *%esi
f0104b4d:	83 c4 10             	add    $0x10,%esp
f0104b50:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b53:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104b55:	83 c7 01             	add    $0x1,%edi
f0104b58:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104b5c:	0f be d0             	movsbl %al,%edx
f0104b5f:	85 d2                	test   %edx,%edx
f0104b61:	74 4b                	je     f0104bae <vprintfmt+0x25b>
f0104b63:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104b67:	78 06                	js     f0104b6f <vprintfmt+0x21c>
f0104b69:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104b6d:	78 1e                	js     f0104b8d <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f0104b6f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104b73:	74 d1                	je     f0104b46 <vprintfmt+0x1f3>
f0104b75:	0f be c0             	movsbl %al,%eax
f0104b78:	83 e8 20             	sub    $0x20,%eax
f0104b7b:	83 f8 5e             	cmp    $0x5e,%eax
f0104b7e:	76 c6                	jbe    f0104b46 <vprintfmt+0x1f3>
					putch('?', putdat);
f0104b80:	83 ec 08             	sub    $0x8,%esp
f0104b83:	53                   	push   %ebx
f0104b84:	6a 3f                	push   $0x3f
f0104b86:	ff d6                	call   *%esi
f0104b88:	83 c4 10             	add    $0x10,%esp
f0104b8b:	eb c3                	jmp    f0104b50 <vprintfmt+0x1fd>
f0104b8d:	89 cf                	mov    %ecx,%edi
f0104b8f:	eb 0e                	jmp    f0104b9f <vprintfmt+0x24c>
				putch(' ', putdat);
f0104b91:	83 ec 08             	sub    $0x8,%esp
f0104b94:	53                   	push   %ebx
f0104b95:	6a 20                	push   $0x20
f0104b97:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104b99:	83 ef 01             	sub    $0x1,%edi
f0104b9c:	83 c4 10             	add    $0x10,%esp
f0104b9f:	85 ff                	test   %edi,%edi
f0104ba1:	7f ee                	jg     f0104b91 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f0104ba3:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ba6:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ba9:	e9 67 01 00 00       	jmp    f0104d15 <vprintfmt+0x3c2>
f0104bae:	89 cf                	mov    %ecx,%edi
f0104bb0:	eb ed                	jmp    f0104b9f <vprintfmt+0x24c>
	if (lflag >= 2)
f0104bb2:	83 f9 01             	cmp    $0x1,%ecx
f0104bb5:	7f 1b                	jg     f0104bd2 <vprintfmt+0x27f>
	else if (lflag)
f0104bb7:	85 c9                	test   %ecx,%ecx
f0104bb9:	74 63                	je     f0104c1e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f0104bbb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bbe:	8b 00                	mov    (%eax),%eax
f0104bc0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104bc3:	99                   	cltd   
f0104bc4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104bc7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bca:	8d 40 04             	lea    0x4(%eax),%eax
f0104bcd:	89 45 14             	mov    %eax,0x14(%ebp)
f0104bd0:	eb 17                	jmp    f0104be9 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0104bd2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bd5:	8b 50 04             	mov    0x4(%eax),%edx
f0104bd8:	8b 00                	mov    (%eax),%eax
f0104bda:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104bdd:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104be0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104be3:	8d 40 08             	lea    0x8(%eax),%eax
f0104be6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104be9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104bec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104bef:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f0104bf4:	85 c9                	test   %ecx,%ecx
f0104bf6:	0f 89 ff 00 00 00    	jns    f0104cfb <vprintfmt+0x3a8>
				putch('-', putdat);
f0104bfc:	83 ec 08             	sub    $0x8,%esp
f0104bff:	53                   	push   %ebx
f0104c00:	6a 2d                	push   $0x2d
f0104c02:	ff d6                	call   *%esi
				num = -(long long) num;
f0104c04:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c07:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104c0a:	f7 da                	neg    %edx
f0104c0c:	83 d1 00             	adc    $0x0,%ecx
f0104c0f:	f7 d9                	neg    %ecx
f0104c11:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104c14:	bf 0a 00 00 00       	mov    $0xa,%edi
f0104c19:	e9 dd 00 00 00       	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f0104c1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c21:	8b 00                	mov    (%eax),%eax
f0104c23:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c26:	99                   	cltd   
f0104c27:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c2d:	8d 40 04             	lea    0x4(%eax),%eax
f0104c30:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c33:	eb b4                	jmp    f0104be9 <vprintfmt+0x296>
	if (lflag >= 2)
f0104c35:	83 f9 01             	cmp    $0x1,%ecx
f0104c38:	7f 1e                	jg     f0104c58 <vprintfmt+0x305>
	else if (lflag)
f0104c3a:	85 c9                	test   %ecx,%ecx
f0104c3c:	74 32                	je     f0104c70 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f0104c3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c41:	8b 10                	mov    (%eax),%edx
f0104c43:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c48:	8d 40 04             	lea    0x4(%eax),%eax
f0104c4b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104c4e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f0104c53:	e9 a3 00 00 00       	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0104c58:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c5b:	8b 10                	mov    (%eax),%edx
f0104c5d:	8b 48 04             	mov    0x4(%eax),%ecx
f0104c60:	8d 40 08             	lea    0x8(%eax),%eax
f0104c63:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104c66:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f0104c6b:	e9 8b 00 00 00       	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0104c70:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c73:	8b 10                	mov    (%eax),%edx
f0104c75:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c7a:	8d 40 04             	lea    0x4(%eax),%eax
f0104c7d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104c80:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f0104c85:	eb 74                	jmp    f0104cfb <vprintfmt+0x3a8>
	if (lflag >= 2)
f0104c87:	83 f9 01             	cmp    $0x1,%ecx
f0104c8a:	7f 1b                	jg     f0104ca7 <vprintfmt+0x354>
	else if (lflag)
f0104c8c:	85 c9                	test   %ecx,%ecx
f0104c8e:	74 2c                	je     f0104cbc <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f0104c90:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c93:	8b 10                	mov    (%eax),%edx
f0104c95:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c9a:	8d 40 04             	lea    0x4(%eax),%eax
f0104c9d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104ca0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f0104ca5:	eb 54                	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0104ca7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104caa:	8b 10                	mov    (%eax),%edx
f0104cac:	8b 48 04             	mov    0x4(%eax),%ecx
f0104caf:	8d 40 08             	lea    0x8(%eax),%eax
f0104cb2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104cb5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f0104cba:	eb 3f                	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0104cbc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cbf:	8b 10                	mov    (%eax),%edx
f0104cc1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cc6:	8d 40 04             	lea    0x4(%eax),%eax
f0104cc9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104ccc:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f0104cd1:	eb 28                	jmp    f0104cfb <vprintfmt+0x3a8>
			putch('0', putdat);
f0104cd3:	83 ec 08             	sub    $0x8,%esp
f0104cd6:	53                   	push   %ebx
f0104cd7:	6a 30                	push   $0x30
f0104cd9:	ff d6                	call   *%esi
			putch('x', putdat);
f0104cdb:	83 c4 08             	add    $0x8,%esp
f0104cde:	53                   	push   %ebx
f0104cdf:	6a 78                	push   $0x78
f0104ce1:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104ce3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ce6:	8b 10                	mov    (%eax),%edx
f0104ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104ced:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104cf0:	8d 40 04             	lea    0x4(%eax),%eax
f0104cf3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104cf6:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f0104cfb:	83 ec 0c             	sub    $0xc,%esp
f0104cfe:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104d02:	50                   	push   %eax
f0104d03:	ff 75 e0             	push   -0x20(%ebp)
f0104d06:	57                   	push   %edi
f0104d07:	51                   	push   %ecx
f0104d08:	52                   	push   %edx
f0104d09:	89 da                	mov    %ebx,%edx
f0104d0b:	89 f0                	mov    %esi,%eax
f0104d0d:	e8 5e fb ff ff       	call   f0104870 <printnum>
			break;
f0104d12:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104d15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104d18:	e9 54 fc ff ff       	jmp    f0104971 <vprintfmt+0x1e>
	if (lflag >= 2)
f0104d1d:	83 f9 01             	cmp    $0x1,%ecx
f0104d20:	7f 1b                	jg     f0104d3d <vprintfmt+0x3ea>
	else if (lflag)
f0104d22:	85 c9                	test   %ecx,%ecx
f0104d24:	74 2c                	je     f0104d52 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f0104d26:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d29:	8b 10                	mov    (%eax),%edx
f0104d2b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d30:	8d 40 04             	lea    0x4(%eax),%eax
f0104d33:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104d36:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f0104d3b:	eb be                	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0104d3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d40:	8b 10                	mov    (%eax),%edx
f0104d42:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d45:	8d 40 08             	lea    0x8(%eax),%eax
f0104d48:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104d4b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f0104d50:	eb a9                	jmp    f0104cfb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0104d52:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d55:	8b 10                	mov    (%eax),%edx
f0104d57:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d5c:	8d 40 04             	lea    0x4(%eax),%eax
f0104d5f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104d62:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f0104d67:	eb 92                	jmp    f0104cfb <vprintfmt+0x3a8>
			putch(ch, putdat);
f0104d69:	83 ec 08             	sub    $0x8,%esp
f0104d6c:	53                   	push   %ebx
f0104d6d:	6a 25                	push   $0x25
f0104d6f:	ff d6                	call   *%esi
			break;
f0104d71:	83 c4 10             	add    $0x10,%esp
f0104d74:	eb 9f                	jmp    f0104d15 <vprintfmt+0x3c2>
			putch('%', putdat);
f0104d76:	83 ec 08             	sub    $0x8,%esp
f0104d79:	53                   	push   %ebx
f0104d7a:	6a 25                	push   $0x25
f0104d7c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104d7e:	83 c4 10             	add    $0x10,%esp
f0104d81:	89 f8                	mov    %edi,%eax
f0104d83:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104d87:	74 05                	je     f0104d8e <vprintfmt+0x43b>
f0104d89:	83 e8 01             	sub    $0x1,%eax
f0104d8c:	eb f5                	jmp    f0104d83 <vprintfmt+0x430>
f0104d8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d91:	eb 82                	jmp    f0104d15 <vprintfmt+0x3c2>

f0104d93 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104d93:	55                   	push   %ebp
f0104d94:	89 e5                	mov    %esp,%ebp
f0104d96:	83 ec 18             	sub    $0x18,%esp
f0104d99:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104d9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104da2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104da6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104da9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104db0:	85 c0                	test   %eax,%eax
f0104db2:	74 26                	je     f0104dda <vsnprintf+0x47>
f0104db4:	85 d2                	test   %edx,%edx
f0104db6:	7e 22                	jle    f0104dda <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104db8:	ff 75 14             	push   0x14(%ebp)
f0104dbb:	ff 75 10             	push   0x10(%ebp)
f0104dbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104dc1:	50                   	push   %eax
f0104dc2:	68 19 49 10 f0       	push   $0xf0104919
f0104dc7:	e8 87 fb ff ff       	call   f0104953 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104dcf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104dd5:	83 c4 10             	add    $0x10,%esp
}
f0104dd8:	c9                   	leave  
f0104dd9:	c3                   	ret    
		return -E_INVAL;
f0104dda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ddf:	eb f7                	jmp    f0104dd8 <vsnprintf+0x45>

f0104de1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104de1:	55                   	push   %ebp
f0104de2:	89 e5                	mov    %esp,%ebp
f0104de4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104de7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104dea:	50                   	push   %eax
f0104deb:	ff 75 10             	push   0x10(%ebp)
f0104dee:	ff 75 0c             	push   0xc(%ebp)
f0104df1:	ff 75 08             	push   0x8(%ebp)
f0104df4:	e8 9a ff ff ff       	call   f0104d93 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104df9:	c9                   	leave  
f0104dfa:	c3                   	ret    

f0104dfb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104dfb:	55                   	push   %ebp
f0104dfc:	89 e5                	mov    %esp,%ebp
f0104dfe:	57                   	push   %edi
f0104dff:	56                   	push   %esi
f0104e00:	53                   	push   %ebx
f0104e01:	83 ec 0c             	sub    $0xc,%esp
f0104e04:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104e07:	85 c0                	test   %eax,%eax
f0104e09:	74 11                	je     f0104e1c <readline+0x21>
		cprintf("%s", prompt);
f0104e0b:	83 ec 08             	sub    $0x8,%esp
f0104e0e:	50                   	push   %eax
f0104e0f:	68 27 6e 10 f0       	push   $0xf0106e27
f0104e14:	e8 fd eb ff ff       	call   f0103a16 <cprintf>
f0104e19:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104e1c:	83 ec 0c             	sub    $0xc,%esp
f0104e1f:	6a 00                	push   $0x0
f0104e21:	e8 61 b9 ff ff       	call   f0100787 <iscons>
f0104e26:	89 c7                	mov    %eax,%edi
f0104e28:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104e2b:	be 00 00 00 00       	mov    $0x0,%esi
f0104e30:	eb 3f                	jmp    f0104e71 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104e32:	83 ec 08             	sub    $0x8,%esp
f0104e35:	50                   	push   %eax
f0104e36:	68 e4 78 10 f0       	push   $0xf01078e4
f0104e3b:	e8 d6 eb ff ff       	call   f0103a16 <cprintf>
			return NULL;
f0104e40:	83 c4 10             	add    $0x10,%esp
f0104e43:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e4b:	5b                   	pop    %ebx
f0104e4c:	5e                   	pop    %esi
f0104e4d:	5f                   	pop    %edi
f0104e4e:	5d                   	pop    %ebp
f0104e4f:	c3                   	ret    
			if (echoing)
f0104e50:	85 ff                	test   %edi,%edi
f0104e52:	75 05                	jne    f0104e59 <readline+0x5e>
			i--;
f0104e54:	83 ee 01             	sub    $0x1,%esi
f0104e57:	eb 18                	jmp    f0104e71 <readline+0x76>
				cputchar('\b');
f0104e59:	83 ec 0c             	sub    $0xc,%esp
f0104e5c:	6a 08                	push   $0x8
f0104e5e:	e8 03 b9 ff ff       	call   f0100766 <cputchar>
f0104e63:	83 c4 10             	add    $0x10,%esp
f0104e66:	eb ec                	jmp    f0104e54 <readline+0x59>
			buf[i++] = c;
f0104e68:	88 9e a0 1a 21 f0    	mov    %bl,-0xfdee560(%esi)
f0104e6e:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0104e71:	e8 00 b9 ff ff       	call   f0100776 <getchar>
f0104e76:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104e78:	85 c0                	test   %eax,%eax
f0104e7a:	78 b6                	js     f0104e32 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104e7c:	83 f8 08             	cmp    $0x8,%eax
f0104e7f:	0f 94 c0             	sete   %al
f0104e82:	83 fb 7f             	cmp    $0x7f,%ebx
f0104e85:	0f 94 c2             	sete   %dl
f0104e88:	08 d0                	or     %dl,%al
f0104e8a:	74 04                	je     f0104e90 <readline+0x95>
f0104e8c:	85 f6                	test   %esi,%esi
f0104e8e:	7f c0                	jg     f0104e50 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104e90:	83 fb 1f             	cmp    $0x1f,%ebx
f0104e93:	7e 1a                	jle    f0104eaf <readline+0xb4>
f0104e95:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104e9b:	7f 12                	jg     f0104eaf <readline+0xb4>
			if (echoing)
f0104e9d:	85 ff                	test   %edi,%edi
f0104e9f:	74 c7                	je     f0104e68 <readline+0x6d>
				cputchar(c);
f0104ea1:	83 ec 0c             	sub    $0xc,%esp
f0104ea4:	53                   	push   %ebx
f0104ea5:	e8 bc b8 ff ff       	call   f0100766 <cputchar>
f0104eaa:	83 c4 10             	add    $0x10,%esp
f0104ead:	eb b9                	jmp    f0104e68 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0104eaf:	83 fb 0a             	cmp    $0xa,%ebx
f0104eb2:	74 05                	je     f0104eb9 <readline+0xbe>
f0104eb4:	83 fb 0d             	cmp    $0xd,%ebx
f0104eb7:	75 b8                	jne    f0104e71 <readline+0x76>
			if (echoing)
f0104eb9:	85 ff                	test   %edi,%edi
f0104ebb:	75 11                	jne    f0104ece <readline+0xd3>
			buf[i] = 0;
f0104ebd:	c6 86 a0 1a 21 f0 00 	movb   $0x0,-0xfdee560(%esi)
			return buf;
f0104ec4:	b8 a0 1a 21 f0       	mov    $0xf0211aa0,%eax
f0104ec9:	e9 7a ff ff ff       	jmp    f0104e48 <readline+0x4d>
				cputchar('\n');
f0104ece:	83 ec 0c             	sub    $0xc,%esp
f0104ed1:	6a 0a                	push   $0xa
f0104ed3:	e8 8e b8 ff ff       	call   f0100766 <cputchar>
f0104ed8:	83 c4 10             	add    $0x10,%esp
f0104edb:	eb e0                	jmp    f0104ebd <readline+0xc2>

f0104edd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104edd:	55                   	push   %ebp
f0104ede:	89 e5                	mov    %esp,%ebp
f0104ee0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104ee3:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ee8:	eb 03                	jmp    f0104eed <strlen+0x10>
		n++;
f0104eea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104eed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104ef1:	75 f7                	jne    f0104eea <strlen+0xd>
	return n;
}
f0104ef3:	5d                   	pop    %ebp
f0104ef4:	c3                   	ret    

f0104ef5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104ef5:	55                   	push   %ebp
f0104ef6:	89 e5                	mov    %esp,%ebp
f0104ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104efb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104efe:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f03:	eb 03                	jmp    f0104f08 <strnlen+0x13>
		n++;
f0104f05:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f08:	39 d0                	cmp    %edx,%eax
f0104f0a:	74 08                	je     f0104f14 <strnlen+0x1f>
f0104f0c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104f10:	75 f3                	jne    f0104f05 <strnlen+0x10>
f0104f12:	89 c2                	mov    %eax,%edx
	return n;
}
f0104f14:	89 d0                	mov    %edx,%eax
f0104f16:	5d                   	pop    %ebp
f0104f17:	c3                   	ret    

f0104f18 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104f18:	55                   	push   %ebp
f0104f19:	89 e5                	mov    %esp,%ebp
f0104f1b:	53                   	push   %ebx
f0104f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104f22:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f27:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0104f2b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104f2e:	83 c0 01             	add    $0x1,%eax
f0104f31:	84 d2                	test   %dl,%dl
f0104f33:	75 f2                	jne    f0104f27 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104f35:	89 c8                	mov    %ecx,%eax
f0104f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f3a:	c9                   	leave  
f0104f3b:	c3                   	ret    

f0104f3c <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104f3c:	55                   	push   %ebp
f0104f3d:	89 e5                	mov    %esp,%ebp
f0104f3f:	53                   	push   %ebx
f0104f40:	83 ec 10             	sub    $0x10,%esp
f0104f43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104f46:	53                   	push   %ebx
f0104f47:	e8 91 ff ff ff       	call   f0104edd <strlen>
f0104f4c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104f4f:	ff 75 0c             	push   0xc(%ebp)
f0104f52:	01 d8                	add    %ebx,%eax
f0104f54:	50                   	push   %eax
f0104f55:	e8 be ff ff ff       	call   f0104f18 <strcpy>
	return dst;
}
f0104f5a:	89 d8                	mov    %ebx,%eax
f0104f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f5f:	c9                   	leave  
f0104f60:	c3                   	ret    

f0104f61 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104f61:	55                   	push   %ebp
f0104f62:	89 e5                	mov    %esp,%ebp
f0104f64:	56                   	push   %esi
f0104f65:	53                   	push   %ebx
f0104f66:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f69:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f6c:	89 f3                	mov    %esi,%ebx
f0104f6e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104f71:	89 f0                	mov    %esi,%eax
f0104f73:	eb 0f                	jmp    f0104f84 <strncpy+0x23>
		*dst++ = *src;
f0104f75:	83 c0 01             	add    $0x1,%eax
f0104f78:	0f b6 0a             	movzbl (%edx),%ecx
f0104f7b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104f7e:	80 f9 01             	cmp    $0x1,%cl
f0104f81:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104f84:	39 d8                	cmp    %ebx,%eax
f0104f86:	75 ed                	jne    f0104f75 <strncpy+0x14>
	}
	return ret;
}
f0104f88:	89 f0                	mov    %esi,%eax
f0104f8a:	5b                   	pop    %ebx
f0104f8b:	5e                   	pop    %esi
f0104f8c:	5d                   	pop    %ebp
f0104f8d:	c3                   	ret    

f0104f8e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104f8e:	55                   	push   %ebp
f0104f8f:	89 e5                	mov    %esp,%ebp
f0104f91:	56                   	push   %esi
f0104f92:	53                   	push   %ebx
f0104f93:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f99:	8b 55 10             	mov    0x10(%ebp),%edx
f0104f9c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104f9e:	85 d2                	test   %edx,%edx
f0104fa0:	74 21                	je     f0104fc3 <strlcpy+0x35>
f0104fa2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104fa6:	89 f2                	mov    %esi,%edx
f0104fa8:	eb 09                	jmp    f0104fb3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104faa:	83 c1 01             	add    $0x1,%ecx
f0104fad:	83 c2 01             	add    $0x1,%edx
f0104fb0:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104fb3:	39 c2                	cmp    %eax,%edx
f0104fb5:	74 09                	je     f0104fc0 <strlcpy+0x32>
f0104fb7:	0f b6 19             	movzbl (%ecx),%ebx
f0104fba:	84 db                	test   %bl,%bl
f0104fbc:	75 ec                	jne    f0104faa <strlcpy+0x1c>
f0104fbe:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104fc0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104fc3:	29 f0                	sub    %esi,%eax
}
f0104fc5:	5b                   	pop    %ebx
f0104fc6:	5e                   	pop    %esi
f0104fc7:	5d                   	pop    %ebp
f0104fc8:	c3                   	ret    

f0104fc9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104fc9:	55                   	push   %ebp
f0104fca:	89 e5                	mov    %esp,%ebp
f0104fcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104fcf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104fd2:	eb 06                	jmp    f0104fda <strcmp+0x11>
		p++, q++;
f0104fd4:	83 c1 01             	add    $0x1,%ecx
f0104fd7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104fda:	0f b6 01             	movzbl (%ecx),%eax
f0104fdd:	84 c0                	test   %al,%al
f0104fdf:	74 04                	je     f0104fe5 <strcmp+0x1c>
f0104fe1:	3a 02                	cmp    (%edx),%al
f0104fe3:	74 ef                	je     f0104fd4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104fe5:	0f b6 c0             	movzbl %al,%eax
f0104fe8:	0f b6 12             	movzbl (%edx),%edx
f0104feb:	29 d0                	sub    %edx,%eax
}
f0104fed:	5d                   	pop    %ebp
f0104fee:	c3                   	ret    

f0104fef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104fef:	55                   	push   %ebp
f0104ff0:	89 e5                	mov    %esp,%ebp
f0104ff2:	53                   	push   %ebx
f0104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ff9:	89 c3                	mov    %eax,%ebx
f0104ffb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104ffe:	eb 06                	jmp    f0105006 <strncmp+0x17>
		n--, p++, q++;
f0105000:	83 c0 01             	add    $0x1,%eax
f0105003:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105006:	39 d8                	cmp    %ebx,%eax
f0105008:	74 18                	je     f0105022 <strncmp+0x33>
f010500a:	0f b6 08             	movzbl (%eax),%ecx
f010500d:	84 c9                	test   %cl,%cl
f010500f:	74 04                	je     f0105015 <strncmp+0x26>
f0105011:	3a 0a                	cmp    (%edx),%cl
f0105013:	74 eb                	je     f0105000 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105015:	0f b6 00             	movzbl (%eax),%eax
f0105018:	0f b6 12             	movzbl (%edx),%edx
f010501b:	29 d0                	sub    %edx,%eax
}
f010501d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105020:	c9                   	leave  
f0105021:	c3                   	ret    
		return 0;
f0105022:	b8 00 00 00 00       	mov    $0x0,%eax
f0105027:	eb f4                	jmp    f010501d <strncmp+0x2e>

f0105029 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105029:	55                   	push   %ebp
f010502a:	89 e5                	mov    %esp,%ebp
f010502c:	8b 45 08             	mov    0x8(%ebp),%eax
f010502f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105033:	eb 03                	jmp    f0105038 <strchr+0xf>
f0105035:	83 c0 01             	add    $0x1,%eax
f0105038:	0f b6 10             	movzbl (%eax),%edx
f010503b:	84 d2                	test   %dl,%dl
f010503d:	74 06                	je     f0105045 <strchr+0x1c>
		if (*s == c)
f010503f:	38 ca                	cmp    %cl,%dl
f0105041:	75 f2                	jne    f0105035 <strchr+0xc>
f0105043:	eb 05                	jmp    f010504a <strchr+0x21>
			return (char *) s;
	return 0;
f0105045:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010504a:	5d                   	pop    %ebp
f010504b:	c3                   	ret    

f010504c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010504c:	55                   	push   %ebp
f010504d:	89 e5                	mov    %esp,%ebp
f010504f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105052:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105056:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105059:	38 ca                	cmp    %cl,%dl
f010505b:	74 09                	je     f0105066 <strfind+0x1a>
f010505d:	84 d2                	test   %dl,%dl
f010505f:	74 05                	je     f0105066 <strfind+0x1a>
	for (; *s; s++)
f0105061:	83 c0 01             	add    $0x1,%eax
f0105064:	eb f0                	jmp    f0105056 <strfind+0xa>
			break;
	return (char *) s;
}
f0105066:	5d                   	pop    %ebp
f0105067:	c3                   	ret    

f0105068 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105068:	55                   	push   %ebp
f0105069:	89 e5                	mov    %esp,%ebp
f010506b:	57                   	push   %edi
f010506c:	56                   	push   %esi
f010506d:	53                   	push   %ebx
f010506e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105071:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105074:	85 c9                	test   %ecx,%ecx
f0105076:	74 2f                	je     f01050a7 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105078:	89 f8                	mov    %edi,%eax
f010507a:	09 c8                	or     %ecx,%eax
f010507c:	a8 03                	test   $0x3,%al
f010507e:	75 21                	jne    f01050a1 <memset+0x39>
		c &= 0xFF;
f0105080:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105084:	89 d0                	mov    %edx,%eax
f0105086:	c1 e0 08             	shl    $0x8,%eax
f0105089:	89 d3                	mov    %edx,%ebx
f010508b:	c1 e3 18             	shl    $0x18,%ebx
f010508e:	89 d6                	mov    %edx,%esi
f0105090:	c1 e6 10             	shl    $0x10,%esi
f0105093:	09 f3                	or     %esi,%ebx
f0105095:	09 da                	or     %ebx,%edx
f0105097:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105099:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010509c:	fc                   	cld    
f010509d:	f3 ab                	rep stos %eax,%es:(%edi)
f010509f:	eb 06                	jmp    f01050a7 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01050a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050a4:	fc                   	cld    
f01050a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01050a7:	89 f8                	mov    %edi,%eax
f01050a9:	5b                   	pop    %ebx
f01050aa:	5e                   	pop    %esi
f01050ab:	5f                   	pop    %edi
f01050ac:	5d                   	pop    %ebp
f01050ad:	c3                   	ret    

f01050ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01050ae:	55                   	push   %ebp
f01050af:	89 e5                	mov    %esp,%ebp
f01050b1:	57                   	push   %edi
f01050b2:	56                   	push   %esi
f01050b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01050b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01050b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01050bc:	39 c6                	cmp    %eax,%esi
f01050be:	73 32                	jae    f01050f2 <memmove+0x44>
f01050c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01050c3:	39 c2                	cmp    %eax,%edx
f01050c5:	76 2b                	jbe    f01050f2 <memmove+0x44>
		s += n;
		d += n;
f01050c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01050ca:	89 d6                	mov    %edx,%esi
f01050cc:	09 fe                	or     %edi,%esi
f01050ce:	09 ce                	or     %ecx,%esi
f01050d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01050d6:	75 0e                	jne    f01050e6 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01050d8:	83 ef 04             	sub    $0x4,%edi
f01050db:	8d 72 fc             	lea    -0x4(%edx),%esi
f01050de:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01050e1:	fd                   	std    
f01050e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01050e4:	eb 09                	jmp    f01050ef <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01050e6:	83 ef 01             	sub    $0x1,%edi
f01050e9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01050ec:	fd                   	std    
f01050ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01050ef:	fc                   	cld    
f01050f0:	eb 1a                	jmp    f010510c <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01050f2:	89 f2                	mov    %esi,%edx
f01050f4:	09 c2                	or     %eax,%edx
f01050f6:	09 ca                	or     %ecx,%edx
f01050f8:	f6 c2 03             	test   $0x3,%dl
f01050fb:	75 0a                	jne    f0105107 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01050fd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105100:	89 c7                	mov    %eax,%edi
f0105102:	fc                   	cld    
f0105103:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105105:	eb 05                	jmp    f010510c <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105107:	89 c7                	mov    %eax,%edi
f0105109:	fc                   	cld    
f010510a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010510c:	5e                   	pop    %esi
f010510d:	5f                   	pop    %edi
f010510e:	5d                   	pop    %ebp
f010510f:	c3                   	ret    

f0105110 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105110:	55                   	push   %ebp
f0105111:	89 e5                	mov    %esp,%ebp
f0105113:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105116:	ff 75 10             	push   0x10(%ebp)
f0105119:	ff 75 0c             	push   0xc(%ebp)
f010511c:	ff 75 08             	push   0x8(%ebp)
f010511f:	e8 8a ff ff ff       	call   f01050ae <memmove>
}
f0105124:	c9                   	leave  
f0105125:	c3                   	ret    

f0105126 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105126:	55                   	push   %ebp
f0105127:	89 e5                	mov    %esp,%ebp
f0105129:	56                   	push   %esi
f010512a:	53                   	push   %ebx
f010512b:	8b 45 08             	mov    0x8(%ebp),%eax
f010512e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105131:	89 c6                	mov    %eax,%esi
f0105133:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105136:	eb 06                	jmp    f010513e <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105138:	83 c0 01             	add    $0x1,%eax
f010513b:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f010513e:	39 f0                	cmp    %esi,%eax
f0105140:	74 14                	je     f0105156 <memcmp+0x30>
		if (*s1 != *s2)
f0105142:	0f b6 08             	movzbl (%eax),%ecx
f0105145:	0f b6 1a             	movzbl (%edx),%ebx
f0105148:	38 d9                	cmp    %bl,%cl
f010514a:	74 ec                	je     f0105138 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f010514c:	0f b6 c1             	movzbl %cl,%eax
f010514f:	0f b6 db             	movzbl %bl,%ebx
f0105152:	29 d8                	sub    %ebx,%eax
f0105154:	eb 05                	jmp    f010515b <memcmp+0x35>
	}

	return 0;
f0105156:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010515b:	5b                   	pop    %ebx
f010515c:	5e                   	pop    %esi
f010515d:	5d                   	pop    %ebp
f010515e:	c3                   	ret    

f010515f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010515f:	55                   	push   %ebp
f0105160:	89 e5                	mov    %esp,%ebp
f0105162:	8b 45 08             	mov    0x8(%ebp),%eax
f0105165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105168:	89 c2                	mov    %eax,%edx
f010516a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010516d:	eb 03                	jmp    f0105172 <memfind+0x13>
f010516f:	83 c0 01             	add    $0x1,%eax
f0105172:	39 d0                	cmp    %edx,%eax
f0105174:	73 04                	jae    f010517a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105176:	38 08                	cmp    %cl,(%eax)
f0105178:	75 f5                	jne    f010516f <memfind+0x10>
			break;
	return (void *) s;
}
f010517a:	5d                   	pop    %ebp
f010517b:	c3                   	ret    

f010517c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010517c:	55                   	push   %ebp
f010517d:	89 e5                	mov    %esp,%ebp
f010517f:	57                   	push   %edi
f0105180:	56                   	push   %esi
f0105181:	53                   	push   %ebx
f0105182:	8b 55 08             	mov    0x8(%ebp),%edx
f0105185:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105188:	eb 03                	jmp    f010518d <strtol+0x11>
		s++;
f010518a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010518d:	0f b6 02             	movzbl (%edx),%eax
f0105190:	3c 20                	cmp    $0x20,%al
f0105192:	74 f6                	je     f010518a <strtol+0xe>
f0105194:	3c 09                	cmp    $0x9,%al
f0105196:	74 f2                	je     f010518a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105198:	3c 2b                	cmp    $0x2b,%al
f010519a:	74 2a                	je     f01051c6 <strtol+0x4a>
	int neg = 0;
f010519c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01051a1:	3c 2d                	cmp    $0x2d,%al
f01051a3:	74 2b                	je     f01051d0 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01051a5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01051ab:	75 0f                	jne    f01051bc <strtol+0x40>
f01051ad:	80 3a 30             	cmpb   $0x30,(%edx)
f01051b0:	74 28                	je     f01051da <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01051b2:	85 db                	test   %ebx,%ebx
f01051b4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051b9:	0f 44 d8             	cmove  %eax,%ebx
f01051bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051c1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01051c4:	eb 46                	jmp    f010520c <strtol+0x90>
		s++;
f01051c6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01051c9:	bf 00 00 00 00       	mov    $0x0,%edi
f01051ce:	eb d5                	jmp    f01051a5 <strtol+0x29>
		s++, neg = 1;
f01051d0:	83 c2 01             	add    $0x1,%edx
f01051d3:	bf 01 00 00 00       	mov    $0x1,%edi
f01051d8:	eb cb                	jmp    f01051a5 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01051da:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01051de:	74 0e                	je     f01051ee <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01051e0:	85 db                	test   %ebx,%ebx
f01051e2:	75 d8                	jne    f01051bc <strtol+0x40>
		s++, base = 8;
f01051e4:	83 c2 01             	add    $0x1,%edx
f01051e7:	bb 08 00 00 00       	mov    $0x8,%ebx
f01051ec:	eb ce                	jmp    f01051bc <strtol+0x40>
		s += 2, base = 16;
f01051ee:	83 c2 02             	add    $0x2,%edx
f01051f1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01051f6:	eb c4                	jmp    f01051bc <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01051f8:	0f be c0             	movsbl %al,%eax
f01051fb:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01051fe:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105201:	7d 3a                	jge    f010523d <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105203:	83 c2 01             	add    $0x1,%edx
f0105206:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f010520a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010520c:	0f b6 02             	movzbl (%edx),%eax
f010520f:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105212:	89 f3                	mov    %esi,%ebx
f0105214:	80 fb 09             	cmp    $0x9,%bl
f0105217:	76 df                	jbe    f01051f8 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105219:	8d 70 9f             	lea    -0x61(%eax),%esi
f010521c:	89 f3                	mov    %esi,%ebx
f010521e:	80 fb 19             	cmp    $0x19,%bl
f0105221:	77 08                	ja     f010522b <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105223:	0f be c0             	movsbl %al,%eax
f0105226:	83 e8 57             	sub    $0x57,%eax
f0105229:	eb d3                	jmp    f01051fe <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010522b:	8d 70 bf             	lea    -0x41(%eax),%esi
f010522e:	89 f3                	mov    %esi,%ebx
f0105230:	80 fb 19             	cmp    $0x19,%bl
f0105233:	77 08                	ja     f010523d <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105235:	0f be c0             	movsbl %al,%eax
f0105238:	83 e8 37             	sub    $0x37,%eax
f010523b:	eb c1                	jmp    f01051fe <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f010523d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105241:	74 05                	je     f0105248 <strtol+0xcc>
		*endptr = (char *) s;
f0105243:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105246:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105248:	89 c8                	mov    %ecx,%eax
f010524a:	f7 d8                	neg    %eax
f010524c:	85 ff                	test   %edi,%edi
f010524e:	0f 45 c8             	cmovne %eax,%ecx
}
f0105251:	89 c8                	mov    %ecx,%eax
f0105253:	5b                   	pop    %ebx
f0105254:	5e                   	pop    %esi
f0105255:	5f                   	pop    %edi
f0105256:	5d                   	pop    %ebp
f0105257:	c3                   	ret    

f0105258 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105258:	fa                   	cli    

	xorw    %ax, %ax
f0105259:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010525b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010525d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010525f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105261:	0f 01 16             	lgdtl  (%esi)
f0105264:	74 70                	je     f01052d6 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105266:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105269:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010526d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105270:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105276:	08 00                	or     %al,(%eax)

f0105278 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105278:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010527c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010527e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105280:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105282:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105286:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105288:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010528a:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f010528f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105292:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105295:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010529a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010529d:	8b 25 04 10 21 f0    	mov    0xf0211004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01052a3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01052a8:	b8 c2 01 10 f0       	mov    $0xf01001c2,%eax
	call    *%eax
f01052ad:	ff d0                	call   *%eax

f01052af <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01052af:	eb fe                	jmp    f01052af <spin>
f01052b1:	8d 76 00             	lea    0x0(%esi),%esi

f01052b4 <gdt>:
	...
f01052bc:	ff                   	(bad)  
f01052bd:	ff 00                	incl   (%eax)
f01052bf:	00 00                	add    %al,(%eax)
f01052c1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01052c8:	00                   	.byte 0x0
f01052c9:	92                   	xchg   %eax,%edx
f01052ca:	cf                   	iret   
	...

f01052cc <gdtdesc>:
f01052cc:	17                   	pop    %ss
f01052cd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01052d2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01052d2:	90                   	nop

f01052d3 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01052d3:	55                   	push   %ebp
f01052d4:	89 e5                	mov    %esp,%ebp
f01052d6:	57                   	push   %edi
f01052d7:	56                   	push   %esi
f01052d8:	53                   	push   %ebx
f01052d9:	83 ec 1c             	sub    $0x1c,%esp
f01052dc:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f01052de:	8b 0d 60 12 21 f0    	mov    0xf0211260,%ecx
f01052e4:	c1 e8 0c             	shr    $0xc,%eax
f01052e7:	39 c8                	cmp    %ecx,%eax
f01052e9:	73 22                	jae    f010530d <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f01052eb:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01052f1:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f01052f4:	89 c2                	mov    %eax,%edx
f01052f6:	c1 ea 0c             	shr    $0xc,%edx
f01052f9:	39 ca                	cmp    %ecx,%edx
f01052fb:	73 22                	jae    f010531f <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f01052fd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105305:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f010530b:	eb 2a                	jmp    f0105337 <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010530d:	56                   	push   %esi
f010530e:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0105313:	6a 57                	push   $0x57
f0105315:	68 81 7a 10 f0       	push   $0xf0107a81
f010531a:	e8 21 ad ff ff       	call   f0100040 <_panic>
f010531f:	50                   	push   %eax
f0105320:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0105325:	6a 57                	push   $0x57
f0105327:	68 81 7a 10 f0       	push   $0xf0107a81
f010532c:	e8 0f ad ff ff       	call   f0100040 <_panic>
f0105331:	83 c7 10             	add    $0x10,%edi
f0105334:	83 c6 10             	add    $0x10,%esi
f0105337:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f010533a:	73 2b                	jae    f0105367 <mpsearch1+0x94>
f010533c:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010533e:	83 ec 04             	sub    $0x4,%esp
f0105341:	6a 04                	push   $0x4
f0105343:	68 91 7a 10 f0       	push   $0xf0107a91
f0105348:	57                   	push   %edi
f0105349:	e8 d8 fd ff ff       	call   f0105126 <memcmp>
f010534e:	83 c4 10             	add    $0x10,%esp
f0105351:	85 c0                	test   %eax,%eax
f0105353:	75 dc                	jne    f0105331 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105355:	0f b6 13             	movzbl (%ebx),%edx
f0105358:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f010535a:	83 c3 01             	add    $0x1,%ebx
f010535d:	39 f3                	cmp    %esi,%ebx
f010535f:	75 f4                	jne    f0105355 <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105361:	84 c0                	test   %al,%al
f0105363:	75 cc                	jne    f0105331 <mpsearch1+0x5e>
f0105365:	eb 05                	jmp    f010536c <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105367:	bf 00 00 00 00       	mov    $0x0,%edi
}
f010536c:	89 f8                	mov    %edi,%eax
f010536e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105371:	5b                   	pop    %ebx
f0105372:	5e                   	pop    %esi
f0105373:	5f                   	pop    %edi
f0105374:	5d                   	pop    %ebp
f0105375:	c3                   	ret    

f0105376 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105376:	55                   	push   %ebp
f0105377:	89 e5                	mov    %esp,%ebp
f0105379:	57                   	push   %edi
f010537a:	56                   	push   %esi
f010537b:	53                   	push   %ebx
f010537c:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010537f:	c7 05 08 20 25 f0 20 	movl   $0xf0252020,0xf0252008
f0105386:	20 25 f0 
	if (PGNUM(pa) >= npages)
f0105389:	83 3d 60 12 21 f0 00 	cmpl   $0x0,0xf0211260
f0105390:	0f 84 86 00 00 00    	je     f010541c <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105396:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010539d:	85 c0                	test   %eax,%eax
f010539f:	0f 84 8d 00 00 00    	je     f0105432 <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f01053a5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01053a8:	ba 00 04 00 00       	mov    $0x400,%edx
f01053ad:	e8 21 ff ff ff       	call   f01052d3 <mpsearch1>
f01053b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01053b5:	85 c0                	test   %eax,%eax
f01053b7:	75 1a                	jne    f01053d3 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f01053b9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01053be:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01053c3:	e8 0b ff ff ff       	call   f01052d3 <mpsearch1>
f01053c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01053cb:	85 c0                	test   %eax,%eax
f01053cd:	0f 84 20 02 00 00    	je     f01055f3 <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f01053d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053d6:	8b 58 04             	mov    0x4(%eax),%ebx
f01053d9:	85 db                	test   %ebx,%ebx
f01053db:	74 7a                	je     f0105457 <mp_init+0xe1>
f01053dd:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01053e1:	75 74                	jne    f0105457 <mp_init+0xe1>
f01053e3:	89 d8                	mov    %ebx,%eax
f01053e5:	c1 e8 0c             	shr    $0xc,%eax
f01053e8:	3b 05 60 12 21 f0    	cmp    0xf0211260,%eax
f01053ee:	73 7c                	jae    f010546c <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f01053f0:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f01053f6:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01053f8:	83 ec 04             	sub    $0x4,%esp
f01053fb:	6a 04                	push   $0x4
f01053fd:	68 96 7a 10 f0       	push   $0xf0107a96
f0105402:	53                   	push   %ebx
f0105403:	e8 1e fd ff ff       	call   f0105126 <memcmp>
f0105408:	83 c4 10             	add    $0x10,%esp
f010540b:	85 c0                	test   %eax,%eax
f010540d:	75 72                	jne    f0105481 <mp_init+0x10b>
f010540f:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105413:	01 df                	add    %ebx,%edi
	sum = 0;
f0105415:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105417:	e9 82 00 00 00       	jmp    f010549e <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010541c:	68 00 04 00 00       	push   $0x400
f0105421:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0105426:	6a 6f                	push   $0x6f
f0105428:	68 81 7a 10 f0       	push   $0xf0107a81
f010542d:	e8 0e ac ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105432:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105439:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010543c:	2d 00 04 00 00       	sub    $0x400,%eax
f0105441:	ba 00 04 00 00       	mov    $0x400,%edx
f0105446:	e8 88 fe ff ff       	call   f01052d3 <mpsearch1>
f010544b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010544e:	85 c0                	test   %eax,%eax
f0105450:	75 81                	jne    f01053d3 <mp_init+0x5d>
f0105452:	e9 62 ff ff ff       	jmp    f01053b9 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105457:	83 ec 0c             	sub    $0xc,%esp
f010545a:	68 f4 78 10 f0       	push   $0xf01078f4
f010545f:	e8 b2 e5 ff ff       	call   f0103a16 <cprintf>
		return NULL;
f0105464:	83 c4 10             	add    $0x10,%esp
f0105467:	e9 87 01 00 00       	jmp    f01055f3 <mp_init+0x27d>
f010546c:	53                   	push   %ebx
f010546d:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0105472:	68 90 00 00 00       	push   $0x90
f0105477:	68 81 7a 10 f0       	push   $0xf0107a81
f010547c:	e8 bf ab ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105481:	83 ec 0c             	sub    $0xc,%esp
f0105484:	68 24 79 10 f0       	push   $0xf0107924
f0105489:	e8 88 e5 ff ff       	call   f0103a16 <cprintf>
		return NULL;
f010548e:	83 c4 10             	add    $0x10,%esp
f0105491:	e9 5d 01 00 00       	jmp    f01055f3 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105496:	0f b6 0b             	movzbl (%ebx),%ecx
f0105499:	01 ca                	add    %ecx,%edx
f010549b:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f010549e:	39 fb                	cmp    %edi,%ebx
f01054a0:	75 f4                	jne    f0105496 <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f01054a2:	84 d2                	test   %dl,%dl
f01054a4:	75 16                	jne    f01054bc <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f01054a6:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f01054aa:	80 fa 01             	cmp    $0x1,%dl
f01054ad:	74 05                	je     f01054b4 <mp_init+0x13e>
f01054af:	80 fa 04             	cmp    $0x4,%dl
f01054b2:	75 1d                	jne    f01054d1 <mp_init+0x15b>
f01054b4:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f01054b8:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f01054ba:	eb 36                	jmp    f01054f2 <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f01054bc:	83 ec 0c             	sub    $0xc,%esp
f01054bf:	68 58 79 10 f0       	push   $0xf0107958
f01054c4:	e8 4d e5 ff ff       	call   f0103a16 <cprintf>
		return NULL;
f01054c9:	83 c4 10             	add    $0x10,%esp
f01054cc:	e9 22 01 00 00       	jmp    f01055f3 <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01054d1:	83 ec 08             	sub    $0x8,%esp
f01054d4:	0f b6 d2             	movzbl %dl,%edx
f01054d7:	52                   	push   %edx
f01054d8:	68 7c 79 10 f0       	push   $0xf010797c
f01054dd:	e8 34 e5 ff ff       	call   f0103a16 <cprintf>
		return NULL;
f01054e2:	83 c4 10             	add    $0x10,%esp
f01054e5:	e9 09 01 00 00       	jmp    f01055f3 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f01054ea:	0f b6 13             	movzbl (%ebx),%edx
f01054ed:	01 d0                	add    %edx,%eax
f01054ef:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f01054f2:	39 d9                	cmp    %ebx,%ecx
f01054f4:	75 f4                	jne    f01054ea <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01054f6:	02 46 2a             	add    0x2a(%esi),%al
f01054f9:	75 1c                	jne    f0105517 <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f01054fb:	c7 05 04 20 25 f0 01 	movl   $0x1,0xf0252004
f0105502:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105505:	8b 46 24             	mov    0x24(%esi),%eax
f0105508:	a3 c4 23 25 f0       	mov    %eax,0xf02523c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010550d:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105510:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105515:	eb 4d                	jmp    f0105564 <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105517:	83 ec 0c             	sub    $0xc,%esp
f010551a:	68 9c 79 10 f0       	push   $0xf010799c
f010551f:	e8 f2 e4 ff ff       	call   f0103a16 <cprintf>
		return NULL;
f0105524:	83 c4 10             	add    $0x10,%esp
f0105527:	e9 c7 00 00 00       	jmp    f01055f3 <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010552c:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105530:	74 11                	je     f0105543 <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0105532:	6b 05 00 20 25 f0 74 	imul   $0x74,0xf0252000,%eax
f0105539:	05 20 20 25 f0       	add    $0xf0252020,%eax
f010553e:	a3 08 20 25 f0       	mov    %eax,0xf0252008
			if (ncpu < NCPU) {
f0105543:	a1 00 20 25 f0       	mov    0xf0252000,%eax
f0105548:	83 f8 07             	cmp    $0x7,%eax
f010554b:	7f 33                	jg     f0105580 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f010554d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105550:	88 82 20 20 25 f0    	mov    %al,-0xfdadfe0(%edx)
				ncpu++;
f0105556:	83 c0 01             	add    $0x1,%eax
f0105559:	a3 00 20 25 f0       	mov    %eax,0xf0252000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010555e:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105561:	83 c3 01             	add    $0x1,%ebx
f0105564:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105568:	39 d8                	cmp    %ebx,%eax
f010556a:	76 4f                	jbe    f01055bb <mp_init+0x245>
		switch (*p) {
f010556c:	0f b6 07             	movzbl (%edi),%eax
f010556f:	84 c0                	test   %al,%al
f0105571:	74 b9                	je     f010552c <mp_init+0x1b6>
f0105573:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105576:	80 fa 03             	cmp    $0x3,%dl
f0105579:	77 1c                	ja     f0105597 <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010557b:	83 c7 08             	add    $0x8,%edi
			continue;
f010557e:	eb e1                	jmp    f0105561 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105580:	83 ec 08             	sub    $0x8,%esp
f0105583:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105587:	50                   	push   %eax
f0105588:	68 cc 79 10 f0       	push   $0xf01079cc
f010558d:	e8 84 e4 ff ff       	call   f0103a16 <cprintf>
f0105592:	83 c4 10             	add    $0x10,%esp
f0105595:	eb c7                	jmp    f010555e <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105597:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f010559a:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010559d:	50                   	push   %eax
f010559e:	68 f4 79 10 f0       	push   $0xf01079f4
f01055a3:	e8 6e e4 ff ff       	call   f0103a16 <cprintf>
			ismp = 0;
f01055a8:	c7 05 04 20 25 f0 00 	movl   $0x0,0xf0252004
f01055af:	00 00 00 
			i = conf->entry;
f01055b2:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01055b6:	83 c4 10             	add    $0x10,%esp
f01055b9:	eb a6                	jmp    f0105561 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01055bb:	a1 08 20 25 f0       	mov    0xf0252008,%eax
f01055c0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01055c7:	83 3d 04 20 25 f0 00 	cmpl   $0x0,0xf0252004
f01055ce:	74 2b                	je     f01055fb <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01055d0:	83 ec 04             	sub    $0x4,%esp
f01055d3:	ff 35 00 20 25 f0    	push   0xf0252000
f01055d9:	0f b6 00             	movzbl (%eax),%eax
f01055dc:	50                   	push   %eax
f01055dd:	68 9b 7a 10 f0       	push   $0xf0107a9b
f01055e2:	e8 2f e4 ff ff       	call   f0103a16 <cprintf>

	if (mp->imcrp) {
f01055e7:	83 c4 10             	add    $0x10,%esp
f01055ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055ed:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01055f1:	75 2e                	jne    f0105621 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01055f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055f6:	5b                   	pop    %ebx
f01055f7:	5e                   	pop    %esi
f01055f8:	5f                   	pop    %edi
f01055f9:	5d                   	pop    %ebp
f01055fa:	c3                   	ret    
		ncpu = 1;
f01055fb:	c7 05 00 20 25 f0 01 	movl   $0x1,0xf0252000
f0105602:	00 00 00 
		lapicaddr = 0;
f0105605:	c7 05 c4 23 25 f0 00 	movl   $0x0,0xf02523c4
f010560c:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010560f:	83 ec 0c             	sub    $0xc,%esp
f0105612:	68 14 7a 10 f0       	push   $0xf0107a14
f0105617:	e8 fa e3 ff ff       	call   f0103a16 <cprintf>
		return;
f010561c:	83 c4 10             	add    $0x10,%esp
f010561f:	eb d2                	jmp    f01055f3 <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105621:	83 ec 0c             	sub    $0xc,%esp
f0105624:	68 40 7a 10 f0       	push   $0xf0107a40
f0105629:	e8 e8 e3 ff ff       	call   f0103a16 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010562e:	b8 70 00 00 00       	mov    $0x70,%eax
f0105633:	ba 22 00 00 00       	mov    $0x22,%edx
f0105638:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105639:	ba 23 00 00 00       	mov    $0x23,%edx
f010563e:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010563f:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105642:	ee                   	out    %al,(%dx)
}
f0105643:	83 c4 10             	add    $0x10,%esp
f0105646:	eb ab                	jmp    f01055f3 <mp_init+0x27d>

f0105648 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105648:	8b 0d c0 23 25 f0    	mov    0xf02523c0,%ecx
f010564e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105651:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105653:	a1 c0 23 25 f0       	mov    0xf02523c0,%eax
f0105658:	8b 40 20             	mov    0x20(%eax),%eax
}
f010565b:	c3                   	ret    

f010565c <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f010565c:	8b 15 c0 23 25 f0    	mov    0xf02523c0,%edx
		return lapic[ID] >> 24;
	return 0;
f0105662:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105667:	85 d2                	test   %edx,%edx
f0105669:	74 06                	je     f0105671 <cpunum+0x15>
		return lapic[ID] >> 24;
f010566b:	8b 42 20             	mov    0x20(%edx),%eax
f010566e:	c1 e8 18             	shr    $0x18,%eax
}
f0105671:	c3                   	ret    

f0105672 <lapic_init>:
	if (!lapicaddr)
f0105672:	a1 c4 23 25 f0       	mov    0xf02523c4,%eax
f0105677:	85 c0                	test   %eax,%eax
f0105679:	75 01                	jne    f010567c <lapic_init+0xa>
f010567b:	c3                   	ret    
{
f010567c:	55                   	push   %ebp
f010567d:	89 e5                	mov    %esp,%ebp
f010567f:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105682:	68 00 10 00 00       	push   $0x1000
f0105687:	50                   	push   %eax
f0105688:	e8 cd bc ff ff       	call   f010135a <mmio_map_region>
f010568d:	a3 c0 23 25 f0       	mov    %eax,0xf02523c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105692:	ba 27 01 00 00       	mov    $0x127,%edx
f0105697:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010569c:	e8 a7 ff ff ff       	call   f0105648 <lapicw>
	lapicw(TDCR, X1);
f01056a1:	ba 0b 00 00 00       	mov    $0xb,%edx
f01056a6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01056ab:	e8 98 ff ff ff       	call   f0105648 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01056b0:	ba 20 00 02 00       	mov    $0x20020,%edx
f01056b5:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01056ba:	e8 89 ff ff ff       	call   f0105648 <lapicw>
	lapicw(TICR, 10000000); 
f01056bf:	ba 80 96 98 00       	mov    $0x989680,%edx
f01056c4:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01056c9:	e8 7a ff ff ff       	call   f0105648 <lapicw>
	if (thiscpu != bootcpu)
f01056ce:	e8 89 ff ff ff       	call   f010565c <cpunum>
f01056d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01056d6:	05 20 20 25 f0       	add    $0xf0252020,%eax
f01056db:	83 c4 10             	add    $0x10,%esp
f01056de:	39 05 08 20 25 f0    	cmp    %eax,0xf0252008
f01056e4:	74 0f                	je     f01056f5 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f01056e6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01056eb:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01056f0:	e8 53 ff ff ff       	call   f0105648 <lapicw>
	lapicw(LINT1, MASKED);
f01056f5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01056fa:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01056ff:	e8 44 ff ff ff       	call   f0105648 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105704:	a1 c0 23 25 f0       	mov    0xf02523c0,%eax
f0105709:	8b 40 30             	mov    0x30(%eax),%eax
f010570c:	c1 e8 10             	shr    $0x10,%eax
f010570f:	a8 fc                	test   $0xfc,%al
f0105711:	75 7c                	jne    f010578f <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105713:	ba 33 00 00 00       	mov    $0x33,%edx
f0105718:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010571d:	e8 26 ff ff ff       	call   f0105648 <lapicw>
	lapicw(ESR, 0);
f0105722:	ba 00 00 00 00       	mov    $0x0,%edx
f0105727:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010572c:	e8 17 ff ff ff       	call   f0105648 <lapicw>
	lapicw(ESR, 0);
f0105731:	ba 00 00 00 00       	mov    $0x0,%edx
f0105736:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010573b:	e8 08 ff ff ff       	call   f0105648 <lapicw>
	lapicw(EOI, 0);
f0105740:	ba 00 00 00 00       	mov    $0x0,%edx
f0105745:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010574a:	e8 f9 fe ff ff       	call   f0105648 <lapicw>
	lapicw(ICRHI, 0);
f010574f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105754:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105759:	e8 ea fe ff ff       	call   f0105648 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010575e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105763:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105768:	e8 db fe ff ff       	call   f0105648 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010576d:	8b 15 c0 23 25 f0    	mov    0xf02523c0,%edx
f0105773:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105779:	f6 c4 10             	test   $0x10,%ah
f010577c:	75 f5                	jne    f0105773 <lapic_init+0x101>
	lapicw(TPR, 0);
f010577e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105783:	b8 20 00 00 00       	mov    $0x20,%eax
f0105788:	e8 bb fe ff ff       	call   f0105648 <lapicw>
}
f010578d:	c9                   	leave  
f010578e:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010578f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105794:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105799:	e8 aa fe ff ff       	call   f0105648 <lapicw>
f010579e:	e9 70 ff ff ff       	jmp    f0105713 <lapic_init+0xa1>

f01057a3 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01057a3:	83 3d c0 23 25 f0 00 	cmpl   $0x0,0xf02523c0
f01057aa:	74 17                	je     f01057c3 <lapic_eoi+0x20>
{
f01057ac:	55                   	push   %ebp
f01057ad:	89 e5                	mov    %esp,%ebp
f01057af:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01057b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01057b7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01057bc:	e8 87 fe ff ff       	call   f0105648 <lapicw>
}
f01057c1:	c9                   	leave  
f01057c2:	c3                   	ret    
f01057c3:	c3                   	ret    

f01057c4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01057c4:	55                   	push   %ebp
f01057c5:	89 e5                	mov    %esp,%ebp
f01057c7:	56                   	push   %esi
f01057c8:	53                   	push   %ebx
f01057c9:	8b 75 08             	mov    0x8(%ebp),%esi
f01057cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01057cf:	b8 0f 00 00 00       	mov    $0xf,%eax
f01057d4:	ba 70 00 00 00       	mov    $0x70,%edx
f01057d9:	ee                   	out    %al,(%dx)
f01057da:	b8 0a 00 00 00       	mov    $0xa,%eax
f01057df:	ba 71 00 00 00       	mov    $0x71,%edx
f01057e4:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01057e5:	83 3d 60 12 21 f0 00 	cmpl   $0x0,0xf0211260
f01057ec:	74 7e                	je     f010586c <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01057ee:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01057f5:	00 00 
	wrv[1] = addr >> 4;
f01057f7:	89 d8                	mov    %ebx,%eax
f01057f9:	c1 e8 04             	shr    $0x4,%eax
f01057fc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105802:	c1 e6 18             	shl    $0x18,%esi
f0105805:	89 f2                	mov    %esi,%edx
f0105807:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010580c:	e8 37 fe ff ff       	call   f0105648 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105811:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105816:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010581b:	e8 28 fe ff ff       	call   f0105648 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105820:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105825:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010582a:	e8 19 fe ff ff       	call   f0105648 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010582f:	c1 eb 0c             	shr    $0xc,%ebx
f0105832:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105835:	89 f2                	mov    %esi,%edx
f0105837:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010583c:	e8 07 fe ff ff       	call   f0105648 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105841:	89 da                	mov    %ebx,%edx
f0105843:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105848:	e8 fb fd ff ff       	call   f0105648 <lapicw>
		lapicw(ICRHI, apicid << 24);
f010584d:	89 f2                	mov    %esi,%edx
f010584f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105854:	e8 ef fd ff ff       	call   f0105648 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105859:	89 da                	mov    %ebx,%edx
f010585b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105860:	e8 e3 fd ff ff       	call   f0105648 <lapicw>
		microdelay(200);
	}
}
f0105865:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105868:	5b                   	pop    %ebx
f0105869:	5e                   	pop    %esi
f010586a:	5d                   	pop    %ebp
f010586b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010586c:	68 67 04 00 00       	push   $0x467
f0105871:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0105876:	68 98 00 00 00       	push   $0x98
f010587b:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0105880:	e8 bb a7 ff ff       	call   f0100040 <_panic>

f0105885 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105885:	55                   	push   %ebp
f0105886:	89 e5                	mov    %esp,%ebp
f0105888:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010588b:	8b 55 08             	mov    0x8(%ebp),%edx
f010588e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105894:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105899:	e8 aa fd ff ff       	call   f0105648 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010589e:	8b 15 c0 23 25 f0    	mov    0xf02523c0,%edx
f01058a4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01058aa:	f6 c4 10             	test   $0x10,%ah
f01058ad:	75 f5                	jne    f01058a4 <lapic_ipi+0x1f>
		;
}
f01058af:	c9                   	leave  
f01058b0:	c3                   	ret    

f01058b1 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01058b1:	55                   	push   %ebp
f01058b2:	89 e5                	mov    %esp,%ebp
f01058b4:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01058b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01058bd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058c0:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01058c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01058ca:	5d                   	pop    %ebp
f01058cb:	c3                   	ret    

f01058cc <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01058cc:	55                   	push   %ebp
f01058cd:	89 e5                	mov    %esp,%ebp
f01058cf:	56                   	push   %esi
f01058d0:	53                   	push   %ebx
f01058d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01058d4:	83 3b 00             	cmpl   $0x0,(%ebx)
f01058d7:	75 07                	jne    f01058e0 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01058d9:	ba 01 00 00 00       	mov    $0x1,%edx
f01058de:	eb 34                	jmp    f0105914 <spin_lock+0x48>
f01058e0:	8b 73 08             	mov    0x8(%ebx),%esi
f01058e3:	e8 74 fd ff ff       	call   f010565c <cpunum>
f01058e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01058eb:	05 20 20 25 f0       	add    $0xf0252020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01058f0:	39 c6                	cmp    %eax,%esi
f01058f2:	75 e5                	jne    f01058d9 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01058f4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01058f7:	e8 60 fd ff ff       	call   f010565c <cpunum>
f01058fc:	83 ec 0c             	sub    $0xc,%esp
f01058ff:	53                   	push   %ebx
f0105900:	50                   	push   %eax
f0105901:	68 c8 7a 10 f0       	push   $0xf0107ac8
f0105906:	6a 41                	push   $0x41
f0105908:	68 2a 7b 10 f0       	push   $0xf0107b2a
f010590d:	e8 2e a7 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105912:	f3 90                	pause  
f0105914:	89 d0                	mov    %edx,%eax
f0105916:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0105919:	85 c0                	test   %eax,%eax
f010591b:	75 f5                	jne    f0105912 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010591d:	e8 3a fd ff ff       	call   f010565c <cpunum>
f0105922:	6b c0 74             	imul   $0x74,%eax,%eax
f0105925:	05 20 20 25 f0       	add    $0xf0252020,%eax
f010592a:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010592d:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010592f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105934:	83 f8 09             	cmp    $0x9,%eax
f0105937:	7f 21                	jg     f010595a <spin_lock+0x8e>
f0105939:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010593f:	76 19                	jbe    f010595a <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f0105941:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105944:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105948:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f010594a:	83 c0 01             	add    $0x1,%eax
f010594d:	eb e5                	jmp    f0105934 <spin_lock+0x68>
		pcs[i] = 0;
f010594f:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0105956:	00 
	for (; i < 10; i++)
f0105957:	83 c0 01             	add    $0x1,%eax
f010595a:	83 f8 09             	cmp    $0x9,%eax
f010595d:	7e f0                	jle    f010594f <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f010595f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105962:	5b                   	pop    %ebx
f0105963:	5e                   	pop    %esi
f0105964:	5d                   	pop    %ebp
f0105965:	c3                   	ret    

f0105966 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105966:	55                   	push   %ebp
f0105967:	89 e5                	mov    %esp,%ebp
f0105969:	57                   	push   %edi
f010596a:	56                   	push   %esi
f010596b:	53                   	push   %ebx
f010596c:	83 ec 4c             	sub    $0x4c,%esp
f010596f:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105972:	83 3e 00             	cmpl   $0x0,(%esi)
f0105975:	75 35                	jne    f01059ac <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105977:	83 ec 04             	sub    $0x4,%esp
f010597a:	6a 28                	push   $0x28
f010597c:	8d 46 0c             	lea    0xc(%esi),%eax
f010597f:	50                   	push   %eax
f0105980:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105983:	53                   	push   %ebx
f0105984:	e8 25 f7 ff ff       	call   f01050ae <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105989:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010598c:	0f b6 38             	movzbl (%eax),%edi
f010598f:	8b 76 04             	mov    0x4(%esi),%esi
f0105992:	e8 c5 fc ff ff       	call   f010565c <cpunum>
f0105997:	57                   	push   %edi
f0105998:	56                   	push   %esi
f0105999:	50                   	push   %eax
f010599a:	68 f4 7a 10 f0       	push   $0xf0107af4
f010599f:	e8 72 e0 ff ff       	call   f0103a16 <cprintf>
f01059a4:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01059a7:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01059aa:	eb 4e                	jmp    f01059fa <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f01059ac:	8b 5e 08             	mov    0x8(%esi),%ebx
f01059af:	e8 a8 fc ff ff       	call   f010565c <cpunum>
f01059b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01059b7:	05 20 20 25 f0       	add    $0xf0252020,%eax
	if (!holding(lk)) {
f01059bc:	39 c3                	cmp    %eax,%ebx
f01059be:	75 b7                	jne    f0105977 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01059c0:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01059c7:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01059ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d3:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01059d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059d9:	5b                   	pop    %ebx
f01059da:	5e                   	pop    %esi
f01059db:	5f                   	pop    %edi
f01059dc:	5d                   	pop    %ebp
f01059dd:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f01059de:	83 ec 08             	sub    $0x8,%esp
f01059e1:	ff 36                	push   (%esi)
f01059e3:	68 51 7b 10 f0       	push   $0xf0107b51
f01059e8:	e8 29 e0 ff ff       	call   f0103a16 <cprintf>
f01059ed:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f01059f0:	83 c3 04             	add    $0x4,%ebx
f01059f3:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01059f6:	39 c3                	cmp    %eax,%ebx
f01059f8:	74 40                	je     f0105a3a <spin_unlock+0xd4>
f01059fa:	89 de                	mov    %ebx,%esi
f01059fc:	8b 03                	mov    (%ebx),%eax
f01059fe:	85 c0                	test   %eax,%eax
f0105a00:	74 38                	je     f0105a3a <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105a02:	83 ec 08             	sub    $0x8,%esp
f0105a05:	57                   	push   %edi
f0105a06:	50                   	push   %eax
f0105a07:	e8 42 ec ff ff       	call   f010464e <debuginfo_eip>
f0105a0c:	83 c4 10             	add    $0x10,%esp
f0105a0f:	85 c0                	test   %eax,%eax
f0105a11:	78 cb                	js     f01059de <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0105a13:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105a15:	83 ec 04             	sub    $0x4,%esp
f0105a18:	89 c2                	mov    %eax,%edx
f0105a1a:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105a1d:	52                   	push   %edx
f0105a1e:	ff 75 b0             	push   -0x50(%ebp)
f0105a21:	ff 75 b4             	push   -0x4c(%ebp)
f0105a24:	ff 75 ac             	push   -0x54(%ebp)
f0105a27:	ff 75 a8             	push   -0x58(%ebp)
f0105a2a:	50                   	push   %eax
f0105a2b:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0105a30:	e8 e1 df ff ff       	call   f0103a16 <cprintf>
f0105a35:	83 c4 20             	add    $0x20,%esp
f0105a38:	eb b6                	jmp    f01059f0 <spin_unlock+0x8a>
		panic("spin_unlock");
f0105a3a:	83 ec 04             	sub    $0x4,%esp
f0105a3d:	68 59 7b 10 f0       	push   $0xf0107b59
f0105a42:	6a 67                	push   $0x67
f0105a44:	68 2a 7b 10 f0       	push   $0xf0107b2a
f0105a49:	e8 f2 a5 ff ff       	call   f0100040 <_panic>
f0105a4e:	66 90                	xchg   %ax,%ax

f0105a50 <__udivdi3>:
f0105a50:	f3 0f 1e fb          	endbr32 
f0105a54:	55                   	push   %ebp
f0105a55:	57                   	push   %edi
f0105a56:	56                   	push   %esi
f0105a57:	53                   	push   %ebx
f0105a58:	83 ec 1c             	sub    $0x1c,%esp
f0105a5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105a5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105a63:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105a67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105a6b:	85 c0                	test   %eax,%eax
f0105a6d:	75 19                	jne    f0105a88 <__udivdi3+0x38>
f0105a6f:	39 f3                	cmp    %esi,%ebx
f0105a71:	76 4d                	jbe    f0105ac0 <__udivdi3+0x70>
f0105a73:	31 ff                	xor    %edi,%edi
f0105a75:	89 e8                	mov    %ebp,%eax
f0105a77:	89 f2                	mov    %esi,%edx
f0105a79:	f7 f3                	div    %ebx
f0105a7b:	89 fa                	mov    %edi,%edx
f0105a7d:	83 c4 1c             	add    $0x1c,%esp
f0105a80:	5b                   	pop    %ebx
f0105a81:	5e                   	pop    %esi
f0105a82:	5f                   	pop    %edi
f0105a83:	5d                   	pop    %ebp
f0105a84:	c3                   	ret    
f0105a85:	8d 76 00             	lea    0x0(%esi),%esi
f0105a88:	39 f0                	cmp    %esi,%eax
f0105a8a:	76 14                	jbe    f0105aa0 <__udivdi3+0x50>
f0105a8c:	31 ff                	xor    %edi,%edi
f0105a8e:	31 c0                	xor    %eax,%eax
f0105a90:	89 fa                	mov    %edi,%edx
f0105a92:	83 c4 1c             	add    $0x1c,%esp
f0105a95:	5b                   	pop    %ebx
f0105a96:	5e                   	pop    %esi
f0105a97:	5f                   	pop    %edi
f0105a98:	5d                   	pop    %ebp
f0105a99:	c3                   	ret    
f0105a9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105aa0:	0f bd f8             	bsr    %eax,%edi
f0105aa3:	83 f7 1f             	xor    $0x1f,%edi
f0105aa6:	75 48                	jne    f0105af0 <__udivdi3+0xa0>
f0105aa8:	39 f0                	cmp    %esi,%eax
f0105aaa:	72 06                	jb     f0105ab2 <__udivdi3+0x62>
f0105aac:	31 c0                	xor    %eax,%eax
f0105aae:	39 eb                	cmp    %ebp,%ebx
f0105ab0:	77 de                	ja     f0105a90 <__udivdi3+0x40>
f0105ab2:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ab7:	eb d7                	jmp    f0105a90 <__udivdi3+0x40>
f0105ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ac0:	89 d9                	mov    %ebx,%ecx
f0105ac2:	85 db                	test   %ebx,%ebx
f0105ac4:	75 0b                	jne    f0105ad1 <__udivdi3+0x81>
f0105ac6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105acb:	31 d2                	xor    %edx,%edx
f0105acd:	f7 f3                	div    %ebx
f0105acf:	89 c1                	mov    %eax,%ecx
f0105ad1:	31 d2                	xor    %edx,%edx
f0105ad3:	89 f0                	mov    %esi,%eax
f0105ad5:	f7 f1                	div    %ecx
f0105ad7:	89 c6                	mov    %eax,%esi
f0105ad9:	89 e8                	mov    %ebp,%eax
f0105adb:	89 f7                	mov    %esi,%edi
f0105add:	f7 f1                	div    %ecx
f0105adf:	89 fa                	mov    %edi,%edx
f0105ae1:	83 c4 1c             	add    $0x1c,%esp
f0105ae4:	5b                   	pop    %ebx
f0105ae5:	5e                   	pop    %esi
f0105ae6:	5f                   	pop    %edi
f0105ae7:	5d                   	pop    %ebp
f0105ae8:	c3                   	ret    
f0105ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105af0:	89 f9                	mov    %edi,%ecx
f0105af2:	ba 20 00 00 00       	mov    $0x20,%edx
f0105af7:	29 fa                	sub    %edi,%edx
f0105af9:	d3 e0                	shl    %cl,%eax
f0105afb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105aff:	89 d1                	mov    %edx,%ecx
f0105b01:	89 d8                	mov    %ebx,%eax
f0105b03:	d3 e8                	shr    %cl,%eax
f0105b05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105b09:	09 c1                	or     %eax,%ecx
f0105b0b:	89 f0                	mov    %esi,%eax
f0105b0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105b11:	89 f9                	mov    %edi,%ecx
f0105b13:	d3 e3                	shl    %cl,%ebx
f0105b15:	89 d1                	mov    %edx,%ecx
f0105b17:	d3 e8                	shr    %cl,%eax
f0105b19:	89 f9                	mov    %edi,%ecx
f0105b1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105b1f:	89 eb                	mov    %ebp,%ebx
f0105b21:	d3 e6                	shl    %cl,%esi
f0105b23:	89 d1                	mov    %edx,%ecx
f0105b25:	d3 eb                	shr    %cl,%ebx
f0105b27:	09 f3                	or     %esi,%ebx
f0105b29:	89 c6                	mov    %eax,%esi
f0105b2b:	89 f2                	mov    %esi,%edx
f0105b2d:	89 d8                	mov    %ebx,%eax
f0105b2f:	f7 74 24 08          	divl   0x8(%esp)
f0105b33:	89 d6                	mov    %edx,%esi
f0105b35:	89 c3                	mov    %eax,%ebx
f0105b37:	f7 64 24 0c          	mull   0xc(%esp)
f0105b3b:	39 d6                	cmp    %edx,%esi
f0105b3d:	72 19                	jb     f0105b58 <__udivdi3+0x108>
f0105b3f:	89 f9                	mov    %edi,%ecx
f0105b41:	d3 e5                	shl    %cl,%ebp
f0105b43:	39 c5                	cmp    %eax,%ebp
f0105b45:	73 04                	jae    f0105b4b <__udivdi3+0xfb>
f0105b47:	39 d6                	cmp    %edx,%esi
f0105b49:	74 0d                	je     f0105b58 <__udivdi3+0x108>
f0105b4b:	89 d8                	mov    %ebx,%eax
f0105b4d:	31 ff                	xor    %edi,%edi
f0105b4f:	e9 3c ff ff ff       	jmp    f0105a90 <__udivdi3+0x40>
f0105b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105b58:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105b5b:	31 ff                	xor    %edi,%edi
f0105b5d:	e9 2e ff ff ff       	jmp    f0105a90 <__udivdi3+0x40>
f0105b62:	66 90                	xchg   %ax,%ax
f0105b64:	66 90                	xchg   %ax,%ax
f0105b66:	66 90                	xchg   %ax,%ax
f0105b68:	66 90                	xchg   %ax,%ax
f0105b6a:	66 90                	xchg   %ax,%ax
f0105b6c:	66 90                	xchg   %ax,%ax
f0105b6e:	66 90                	xchg   %ax,%ax

f0105b70 <__umoddi3>:
f0105b70:	f3 0f 1e fb          	endbr32 
f0105b74:	55                   	push   %ebp
f0105b75:	57                   	push   %edi
f0105b76:	56                   	push   %esi
f0105b77:	53                   	push   %ebx
f0105b78:	83 ec 1c             	sub    $0x1c,%esp
f0105b7b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105b7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105b83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0105b87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0105b8b:	89 f0                	mov    %esi,%eax
f0105b8d:	89 da                	mov    %ebx,%edx
f0105b8f:	85 ff                	test   %edi,%edi
f0105b91:	75 15                	jne    f0105ba8 <__umoddi3+0x38>
f0105b93:	39 dd                	cmp    %ebx,%ebp
f0105b95:	76 39                	jbe    f0105bd0 <__umoddi3+0x60>
f0105b97:	f7 f5                	div    %ebp
f0105b99:	89 d0                	mov    %edx,%eax
f0105b9b:	31 d2                	xor    %edx,%edx
f0105b9d:	83 c4 1c             	add    $0x1c,%esp
f0105ba0:	5b                   	pop    %ebx
f0105ba1:	5e                   	pop    %esi
f0105ba2:	5f                   	pop    %edi
f0105ba3:	5d                   	pop    %ebp
f0105ba4:	c3                   	ret    
f0105ba5:	8d 76 00             	lea    0x0(%esi),%esi
f0105ba8:	39 df                	cmp    %ebx,%edi
f0105baa:	77 f1                	ja     f0105b9d <__umoddi3+0x2d>
f0105bac:	0f bd cf             	bsr    %edi,%ecx
f0105baf:	83 f1 1f             	xor    $0x1f,%ecx
f0105bb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105bb6:	75 40                	jne    f0105bf8 <__umoddi3+0x88>
f0105bb8:	39 df                	cmp    %ebx,%edi
f0105bba:	72 04                	jb     f0105bc0 <__umoddi3+0x50>
f0105bbc:	39 f5                	cmp    %esi,%ebp
f0105bbe:	77 dd                	ja     f0105b9d <__umoddi3+0x2d>
f0105bc0:	89 da                	mov    %ebx,%edx
f0105bc2:	89 f0                	mov    %esi,%eax
f0105bc4:	29 e8                	sub    %ebp,%eax
f0105bc6:	19 fa                	sbb    %edi,%edx
f0105bc8:	eb d3                	jmp    f0105b9d <__umoddi3+0x2d>
f0105bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105bd0:	89 e9                	mov    %ebp,%ecx
f0105bd2:	85 ed                	test   %ebp,%ebp
f0105bd4:	75 0b                	jne    f0105be1 <__umoddi3+0x71>
f0105bd6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105bdb:	31 d2                	xor    %edx,%edx
f0105bdd:	f7 f5                	div    %ebp
f0105bdf:	89 c1                	mov    %eax,%ecx
f0105be1:	89 d8                	mov    %ebx,%eax
f0105be3:	31 d2                	xor    %edx,%edx
f0105be5:	f7 f1                	div    %ecx
f0105be7:	89 f0                	mov    %esi,%eax
f0105be9:	f7 f1                	div    %ecx
f0105beb:	89 d0                	mov    %edx,%eax
f0105bed:	31 d2                	xor    %edx,%edx
f0105bef:	eb ac                	jmp    f0105b9d <__umoddi3+0x2d>
f0105bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105bf8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105bfc:	ba 20 00 00 00       	mov    $0x20,%edx
f0105c01:	29 c2                	sub    %eax,%edx
f0105c03:	89 c1                	mov    %eax,%ecx
f0105c05:	89 e8                	mov    %ebp,%eax
f0105c07:	d3 e7                	shl    %cl,%edi
f0105c09:	89 d1                	mov    %edx,%ecx
f0105c0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105c0f:	d3 e8                	shr    %cl,%eax
f0105c11:	89 c1                	mov    %eax,%ecx
f0105c13:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105c17:	09 f9                	or     %edi,%ecx
f0105c19:	89 df                	mov    %ebx,%edi
f0105c1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105c1f:	89 c1                	mov    %eax,%ecx
f0105c21:	d3 e5                	shl    %cl,%ebp
f0105c23:	89 d1                	mov    %edx,%ecx
f0105c25:	d3 ef                	shr    %cl,%edi
f0105c27:	89 c1                	mov    %eax,%ecx
f0105c29:	89 f0                	mov    %esi,%eax
f0105c2b:	d3 e3                	shl    %cl,%ebx
f0105c2d:	89 d1                	mov    %edx,%ecx
f0105c2f:	89 fa                	mov    %edi,%edx
f0105c31:	d3 e8                	shr    %cl,%eax
f0105c33:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105c38:	09 d8                	or     %ebx,%eax
f0105c3a:	f7 74 24 08          	divl   0x8(%esp)
f0105c3e:	89 d3                	mov    %edx,%ebx
f0105c40:	d3 e6                	shl    %cl,%esi
f0105c42:	f7 e5                	mul    %ebp
f0105c44:	89 c7                	mov    %eax,%edi
f0105c46:	89 d1                	mov    %edx,%ecx
f0105c48:	39 d3                	cmp    %edx,%ebx
f0105c4a:	72 06                	jb     f0105c52 <__umoddi3+0xe2>
f0105c4c:	75 0e                	jne    f0105c5c <__umoddi3+0xec>
f0105c4e:	39 c6                	cmp    %eax,%esi
f0105c50:	73 0a                	jae    f0105c5c <__umoddi3+0xec>
f0105c52:	29 e8                	sub    %ebp,%eax
f0105c54:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105c58:	89 d1                	mov    %edx,%ecx
f0105c5a:	89 c7                	mov    %eax,%edi
f0105c5c:	89 f5                	mov    %esi,%ebp
f0105c5e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105c62:	29 fd                	sub    %edi,%ebp
f0105c64:	19 cb                	sbb    %ecx,%ebx
f0105c66:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105c6b:	89 d8                	mov    %ebx,%eax
f0105c6d:	d3 e0                	shl    %cl,%eax
f0105c6f:	89 f1                	mov    %esi,%ecx
f0105c71:	d3 ed                	shr    %cl,%ebp
f0105c73:	d3 eb                	shr    %cl,%ebx
f0105c75:	09 e8                	or     %ebp,%eax
f0105c77:	89 da                	mov    %ebx,%edx
f0105c79:	83 c4 1c             	add    $0x1c,%esp
f0105c7c:	5b                   	pop    %ebx
f0105c7d:	5e                   	pop    %esi
f0105c7e:	5f                   	pop    %edi
f0105c7f:	5d                   	pop    %ebp
f0105c80:	c3                   	ret    
