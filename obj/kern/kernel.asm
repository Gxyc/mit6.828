
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 b4 01 00 00       	call   f01001fe <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 18 08 ff ff    	lea    -0xf7e8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 c2 0a 00 00       	call   f0100b25 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 34 08 ff ff    	lea    -0xf7cc(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 9c 0a 00 00       	call   f0100b25 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 18 08 00 00       	call   f01008b9 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 18             	sub    $0x18,%esp
f01000ad:	e8 4c 01 00 00       	call   f01001fe <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 0c 16 00 00       	call   f01016db <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 80 05 00 00       	call   f0100654 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 4f 08 ff ff    	lea    -0xf7b1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 3d 0a 00 00       	call   f0100b25 <cprintf>

	//lab1 e8.3 start
	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n", x, y, z);
f01000e8:	6a 04                	push   $0x4
f01000ea:	6a 03                	push   $0x3
f01000ec:	6a 01                	push   $0x1
f01000ee:	8d 83 6a 08 ff ff    	lea    -0xf796(%ebx),%eax
f01000f4:	50                   	push   %eax
f01000f5:	e8 2b 0a 00 00       	call   f0100b25 <cprintf>
	//lab1 e8.3 end

	//lab1 e8.4 start
	unsigned int i = 0x00646c72;
f01000fa:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf("H%x Wo%s", 57616, &i);
f0100101:	83 c4 1c             	add    $0x1c,%esp
f0100104:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100107:	50                   	push   %eax
f0100108:	68 10 e1 00 00       	push   $0xe110
f010010d:	8d 83 7c 08 ff ff    	lea    -0xf784(%ebx),%eax
f0100113:	50                   	push   %eax
f0100114:	e8 0c 0a 00 00       	call   f0100b25 <cprintf>
	//lab1 e8.4 end

	//lab1 e8.5 start
	cprintf("x=%d y=%d", 3);
f0100119:	83 c4 08             	add    $0x8,%esp
f010011c:	6a 03                	push   $0x3
f010011e:	8d 83 85 08 ff ff    	lea    -0xf77b(%ebx),%eax
f0100124:	50                   	push   %eax
f0100125:	e8 fb 09 00 00       	call   f0100b25 <cprintf>
	//lab1 e8.5 end

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010012a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100131:	e8 0a ff ff ff       	call   f0100040 <test_backtrace>
f0100136:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100139:	83 ec 0c             	sub    $0xc,%esp
f010013c:	6a 00                	push   $0x0
f010013e:	e8 26 08 00 00       	call   f0100969 <monitor>
f0100143:	83 c4 10             	add    $0x10,%esp
f0100146:	eb f1                	jmp    f0100139 <i386_init+0x93>

f0100148 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100148:	55                   	push   %ebp
f0100149:	89 e5                	mov    %esp,%ebp
f010014b:	56                   	push   %esi
f010014c:	53                   	push   %ebx
f010014d:	e8 ac 00 00 00       	call   f01001fe <__x86.get_pc_thunk.bx>
f0100152:	81 c3 b6 11 01 00    	add    $0x111b6,%ebx
	va_list ap;

	if (panicstr)
f0100158:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f010015f:	74 0f                	je     f0100170 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100161:	83 ec 0c             	sub    $0xc,%esp
f0100164:	6a 00                	push   $0x0
f0100166:	e8 fe 07 00 00       	call   f0100969 <monitor>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb f1                	jmp    f0100161 <_panic+0x19>
	panicstr = fmt;
f0100170:	8b 45 10             	mov    0x10(%ebp),%eax
f0100173:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f0100179:	fa                   	cli    
f010017a:	fc                   	cld    
	va_start(ap, fmt);
f010017b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010017e:	83 ec 04             	sub    $0x4,%esp
f0100181:	ff 75 0c             	push   0xc(%ebp)
f0100184:	ff 75 08             	push   0x8(%ebp)
f0100187:	8d 83 8f 08 ff ff    	lea    -0xf771(%ebx),%eax
f010018d:	50                   	push   %eax
f010018e:	e8 92 09 00 00       	call   f0100b25 <cprintf>
	vcprintf(fmt, ap);
f0100193:	83 c4 08             	add    $0x8,%esp
f0100196:	56                   	push   %esi
f0100197:	ff 75 10             	push   0x10(%ebp)
f010019a:	e8 4f 09 00 00       	call   f0100aee <vcprintf>
	cprintf("\n");
f010019f:	8d 83 cb 08 ff ff    	lea    -0xf735(%ebx),%eax
f01001a5:	89 04 24             	mov    %eax,(%esp)
f01001a8:	e8 78 09 00 00       	call   f0100b25 <cprintf>
f01001ad:	83 c4 10             	add    $0x10,%esp
f01001b0:	eb af                	jmp    f0100161 <_panic+0x19>

f01001b2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001b2:	55                   	push   %ebp
f01001b3:	89 e5                	mov    %esp,%ebp
f01001b5:	56                   	push   %esi
f01001b6:	53                   	push   %ebx
f01001b7:	e8 42 00 00 00       	call   f01001fe <__x86.get_pc_thunk.bx>
f01001bc:	81 c3 4c 11 01 00    	add    $0x1114c,%ebx
	va_list ap;

	va_start(ap, fmt);
f01001c2:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001c5:	83 ec 04             	sub    $0x4,%esp
f01001c8:	ff 75 0c             	push   0xc(%ebp)
f01001cb:	ff 75 08             	push   0x8(%ebp)
f01001ce:	8d 83 a7 08 ff ff    	lea    -0xf759(%ebx),%eax
f01001d4:	50                   	push   %eax
f01001d5:	e8 4b 09 00 00       	call   f0100b25 <cprintf>
	vcprintf(fmt, ap);
f01001da:	83 c4 08             	add    $0x8,%esp
f01001dd:	56                   	push   %esi
f01001de:	ff 75 10             	push   0x10(%ebp)
f01001e1:	e8 08 09 00 00       	call   f0100aee <vcprintf>
	cprintf("\n");
f01001e6:	8d 83 cb 08 ff ff    	lea    -0xf735(%ebx),%eax
f01001ec:	89 04 24             	mov    %eax,(%esp)
f01001ef:	e8 31 09 00 00       	call   f0100b25 <cprintf>
	va_end(ap);
}
f01001f4:	83 c4 10             	add    $0x10,%esp
f01001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001fa:	5b                   	pop    %ebx
f01001fb:	5e                   	pop    %esi
f01001fc:	5d                   	pop    %ebp
f01001fd:	c3                   	ret    

f01001fe <__x86.get_pc_thunk.bx>:
f01001fe:	8b 1c 24             	mov    (%esp),%ebx
f0100201:	c3                   	ret    

f0100202 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100202:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100207:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100208:	a8 01                	test   $0x1,%al
f010020a:	74 0a                	je     f0100216 <serial_proc_data+0x14>
f010020c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100211:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100212:	0f b6 c0             	movzbl %al,%eax
f0100215:	c3                   	ret    
		return -1;
f0100216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010021b:	c3                   	ret    

f010021c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010021c:	55                   	push   %ebp
f010021d:	89 e5                	mov    %esp,%ebp
f010021f:	57                   	push   %edi
f0100220:	56                   	push   %esi
f0100221:	53                   	push   %ebx
f0100222:	83 ec 1c             	sub    $0x1c,%esp
f0100225:	e8 6a 05 00 00       	call   f0100794 <__x86.get_pc_thunk.si>
f010022a:	81 c6 de 10 01 00    	add    $0x110de,%esi
f0100230:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100232:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f0100238:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010023e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100241:	eb 25                	jmp    f0100268 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100243:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f010024a:	8d 51 01             	lea    0x1(%ecx),%edx
f010024d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100250:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100253:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100259:	b8 00 00 00 00       	mov    $0x0,%eax
f010025e:	0f 44 d0             	cmove  %eax,%edx
f0100261:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010026b:	ff d0                	call   *%eax
f010026d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100270:	74 06                	je     f0100278 <cons_intr+0x5c>
		if (c == 0)
f0100272:	85 c0                	test   %eax,%eax
f0100274:	75 cd                	jne    f0100243 <cons_intr+0x27>
f0100276:	eb f0                	jmp    f0100268 <cons_intr+0x4c>
	}
}
f0100278:	83 c4 1c             	add    $0x1c,%esp
f010027b:	5b                   	pop    %ebx
f010027c:	5e                   	pop    %esi
f010027d:	5f                   	pop    %edi
f010027e:	5d                   	pop    %ebp
f010027f:	c3                   	ret    

f0100280 <kbd_proc_data>:
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	56                   	push   %esi
f0100284:	53                   	push   %ebx
f0100285:	e8 74 ff ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f010028a:	81 c3 7e 10 01 00    	add    $0x1107e,%ebx
f0100290:	ba 64 00 00 00       	mov    $0x64,%edx
f0100295:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100296:	a8 01                	test   $0x1,%al
f0100298:	0f 84 f7 00 00 00    	je     f0100395 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010029e:	a8 20                	test   $0x20,%al
f01002a0:	0f 85 f6 00 00 00    	jne    f010039c <kbd_proc_data+0x11c>
f01002a6:	ba 60 00 00 00       	mov    $0x60,%edx
f01002ab:	ec                   	in     (%dx),%al
f01002ac:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002ae:	3c e0                	cmp    $0xe0,%al
f01002b0:	74 64                	je     f0100316 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f01002b2:	84 c0                	test   %al,%al
f01002b4:	78 75                	js     f010032b <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f01002b6:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002bc:	f6 c1 40             	test   $0x40,%cl
f01002bf:	74 0e                	je     f01002cf <kbd_proc_data+0x4f>
		data |= 0x80;
f01002c1:	83 c8 80             	or     $0xffffff80,%eax
f01002c4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002c6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002c9:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f01002cf:	0f b6 d2             	movzbl %dl,%edx
f01002d2:	0f b6 84 13 f8 09 ff 	movzbl -0xf608(%ebx,%edx,1),%eax
f01002d9:	ff 
f01002da:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f01002e0:	0f b6 8c 13 f8 08 ff 	movzbl -0xf708(%ebx,%edx,1),%ecx
f01002e7:	ff 
f01002e8:	31 c8                	xor    %ecx,%eax
f01002ea:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002f0:	89 c1                	mov    %eax,%ecx
f01002f2:	83 e1 03             	and    $0x3,%ecx
f01002f5:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002fc:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100300:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100303:	a8 08                	test   $0x8,%al
f0100305:	74 61                	je     f0100368 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f0100307:	89 f2                	mov    %esi,%edx
f0100309:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f010030c:	83 f9 19             	cmp    $0x19,%ecx
f010030f:	77 4b                	ja     f010035c <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f0100311:	83 ee 20             	sub    $0x20,%esi
f0100314:	eb 0c                	jmp    f0100322 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f0100316:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f010031d:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100322:	89 f0                	mov    %esi,%eax
f0100324:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100327:	5b                   	pop    %ebx
f0100328:	5e                   	pop    %esi
f0100329:	5d                   	pop    %ebp
f010032a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010032b:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f0100331:	83 e0 7f             	and    $0x7f,%eax
f0100334:	f6 c1 40             	test   $0x40,%cl
f0100337:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010033a:	0f b6 d2             	movzbl %dl,%edx
f010033d:	0f b6 84 13 f8 09 ff 	movzbl -0xf608(%ebx,%edx,1),%eax
f0100344:	ff 
f0100345:	83 c8 40             	or     $0x40,%eax
f0100348:	0f b6 c0             	movzbl %al,%eax
f010034b:	f7 d0                	not    %eax
f010034d:	21 c8                	and    %ecx,%eax
f010034f:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100355:	be 00 00 00 00       	mov    $0x0,%esi
f010035a:	eb c6                	jmp    f0100322 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010035c:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010035f:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100362:	83 fa 1a             	cmp    $0x1a,%edx
f0100365:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100368:	f7 d0                	not    %eax
f010036a:	a8 06                	test   $0x6,%al
f010036c:	75 b4                	jne    f0100322 <kbd_proc_data+0xa2>
f010036e:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100374:	75 ac                	jne    f0100322 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100376:	83 ec 0c             	sub    $0xc,%esp
f0100379:	8d 83 c1 08 ff ff    	lea    -0xf73f(%ebx),%eax
f010037f:	50                   	push   %eax
f0100380:	e8 a0 07 00 00       	call   f0100b25 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	b8 03 00 00 00       	mov    $0x3,%eax
f010038a:	ba 92 00 00 00       	mov    $0x92,%edx
f010038f:	ee                   	out    %al,(%dx)
}
f0100390:	83 c4 10             	add    $0x10,%esp
f0100393:	eb 8d                	jmp    f0100322 <kbd_proc_data+0xa2>
		return -1;
f0100395:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010039a:	eb 86                	jmp    f0100322 <kbd_proc_data+0xa2>
		return -1;
f010039c:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01003a1:	e9 7c ff ff ff       	jmp    f0100322 <kbd_proc_data+0xa2>

f01003a6 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003a6:	55                   	push   %ebp
f01003a7:	89 e5                	mov    %esp,%ebp
f01003a9:	57                   	push   %edi
f01003aa:	56                   	push   %esi
f01003ab:	53                   	push   %ebx
f01003ac:	83 ec 1c             	sub    $0x1c,%esp
f01003af:	e8 4a fe ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f01003b4:	81 c3 54 0f 01 00    	add    $0x10f54,%ebx
f01003ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f01003bd:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c2:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003c7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003cc:	89 fa                	mov    %edi,%edx
f01003ce:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003cf:	a8 20                	test   $0x20,%al
f01003d1:	75 13                	jne    f01003e6 <cons_putc+0x40>
f01003d3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003d9:	7f 0b                	jg     f01003e6 <cons_putc+0x40>
f01003db:	89 ca                	mov    %ecx,%edx
f01003dd:	ec                   	in     (%dx),%al
f01003de:	ec                   	in     (%dx),%al
f01003df:	ec                   	in     (%dx),%al
f01003e0:	ec                   	in     (%dx),%al
	     i++)
f01003e1:	83 c6 01             	add    $0x1,%esi
f01003e4:	eb e6                	jmp    f01003cc <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003e6:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003ea:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ed:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003f2:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003f3:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f8:	bf 79 03 00 00       	mov    $0x379,%edi
f01003fd:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100402:	89 fa                	mov    %edi,%edx
f0100404:	ec                   	in     (%dx),%al
f0100405:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010040b:	7f 0f                	jg     f010041c <cons_putc+0x76>
f010040d:	84 c0                	test   %al,%al
f010040f:	78 0b                	js     f010041c <cons_putc+0x76>
f0100411:	89 ca                	mov    %ecx,%edx
f0100413:	ec                   	in     (%dx),%al
f0100414:	ec                   	in     (%dx),%al
f0100415:	ec                   	in     (%dx),%al
f0100416:	ec                   	in     (%dx),%al
f0100417:	83 c6 01             	add    $0x1,%esi
f010041a:	eb e6                	jmp    f0100402 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100421:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100425:	ee                   	out    %al,(%dx)
f0100426:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010042b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100430:	ee                   	out    %al,(%dx)
f0100431:	b8 08 00 00 00       	mov    $0x8,%eax
f0100436:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010043a:	89 f8                	mov    %edi,%eax
f010043c:	80 cc 07             	or     $0x7,%ah
f010043f:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100445:	0f 45 c7             	cmovne %edi,%eax
f0100448:	89 c7                	mov    %eax,%edi
f010044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010044d:	0f b6 c0             	movzbl %al,%eax
f0100450:	89 f9                	mov    %edi,%ecx
f0100452:	80 f9 0a             	cmp    $0xa,%cl
f0100455:	0f 84 e4 00 00 00    	je     f010053f <cons_putc+0x199>
f010045b:	83 f8 0a             	cmp    $0xa,%eax
f010045e:	7f 46                	jg     f01004a6 <cons_putc+0x100>
f0100460:	83 f8 08             	cmp    $0x8,%eax
f0100463:	0f 84 a8 00 00 00    	je     f0100511 <cons_putc+0x16b>
f0100469:	83 f8 09             	cmp    $0x9,%eax
f010046c:	0f 85 da 00 00 00    	jne    f010054c <cons_putc+0x1a6>
		cons_putc(' ');
f0100472:	b8 20 00 00 00       	mov    $0x20,%eax
f0100477:	e8 2a ff ff ff       	call   f01003a6 <cons_putc>
		cons_putc(' ');
f010047c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100481:	e8 20 ff ff ff       	call   f01003a6 <cons_putc>
		cons_putc(' ');
f0100486:	b8 20 00 00 00       	mov    $0x20,%eax
f010048b:	e8 16 ff ff ff       	call   f01003a6 <cons_putc>
		cons_putc(' ');
f0100490:	b8 20 00 00 00       	mov    $0x20,%eax
f0100495:	e8 0c ff ff ff       	call   f01003a6 <cons_putc>
		cons_putc(' ');
f010049a:	b8 20 00 00 00       	mov    $0x20,%eax
f010049f:	e8 02 ff ff ff       	call   f01003a6 <cons_putc>
		break;
f01004a4:	eb 26                	jmp    f01004cc <cons_putc+0x126>
	switch (c & 0xff) {
f01004a6:	83 f8 0d             	cmp    $0xd,%eax
f01004a9:	0f 85 9d 00 00 00    	jne    f010054c <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01004af:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004b6:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004bc:	c1 e8 16             	shr    $0x16,%eax
f01004bf:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004c2:	c1 e0 04             	shl    $0x4,%eax
f01004c5:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004cc:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f01004d3:	cf 07 
f01004d5:	0f 87 98 00 00 00    	ja     f0100573 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f01004db:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f01004e1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004e6:	89 ca                	mov    %ecx,%edx
f01004e8:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e9:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004f0:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f3:	89 d8                	mov    %ebx,%eax
f01004f5:	66 c1 e8 08          	shr    $0x8,%ax
f01004f9:	89 f2                	mov    %esi,%edx
f01004fb:	ee                   	out    %al,(%dx)
f01004fc:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100501:	89 ca                	mov    %ecx,%edx
f0100503:	ee                   	out    %al,(%dx)
f0100504:	89 d8                	mov    %ebx,%eax
f0100506:	89 f2                	mov    %esi,%edx
f0100508:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100509:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010050c:	5b                   	pop    %ebx
f010050d:	5e                   	pop    %esi
f010050e:	5f                   	pop    %edi
f010050f:	5d                   	pop    %ebp
f0100510:	c3                   	ret    
		if (crt_pos > 0) {
f0100511:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100518:	66 85 c0             	test   %ax,%ax
f010051b:	74 be                	je     f01004db <cons_putc+0x135>
			crt_pos--;
f010051d:	83 e8 01             	sub    $0x1,%eax
f0100520:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100527:	0f b7 c0             	movzwl %ax,%eax
f010052a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f010052e:	b2 00                	mov    $0x0,%dl
f0100530:	83 ca 20             	or     $0x20,%edx
f0100533:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f0100539:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010053d:	eb 8d                	jmp    f01004cc <cons_putc+0x126>
		crt_pos += CRT_COLS;
f010053f:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f0100546:	50 
f0100547:	e9 63 ff ff ff       	jmp    f01004af <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010054c:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100553:	8d 50 01             	lea    0x1(%eax),%edx
f0100556:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f010055d:	0f b7 c0             	movzwl %ax,%eax
f0100560:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100566:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010056a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010056e:	e9 59 ff ff ff       	jmp    f01004cc <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100573:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f0100579:	83 ec 04             	sub    $0x4,%esp
f010057c:	68 00 0f 00 00       	push   $0xf00
f0100581:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100587:	52                   	push   %edx
f0100588:	50                   	push   %eax
f0100589:	e8 93 11 00 00       	call   f0101721 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010058e:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100594:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010059a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005a0:	83 c4 10             	add    $0x10,%esp
f01005a3:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a8:	83 c0 02             	add    $0x2,%eax
f01005ab:	39 d0                	cmp    %edx,%eax
f01005ad:	75 f4                	jne    f01005a3 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f01005af:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f01005b6:	50 
f01005b7:	e9 1f ff ff ff       	jmp    f01004db <cons_putc+0x135>

f01005bc <serial_intr>:
{
f01005bc:	e8 cf 01 00 00       	call   f0100790 <__x86.get_pc_thunk.ax>
f01005c1:	05 47 0d 01 00       	add    $0x10d47,%eax
	if (serial_exists)
f01005c6:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f01005cd:	75 01                	jne    f01005d0 <serial_intr+0x14>
f01005cf:	c3                   	ret    
{
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005d6:	8d 80 fa ee fe ff    	lea    -0x11106(%eax),%eax
f01005dc:	e8 3b fc ff ff       	call   f010021c <cons_intr>
}
f01005e1:	c9                   	leave  
f01005e2:	c3                   	ret    

f01005e3 <kbd_intr>:
{
f01005e3:	55                   	push   %ebp
f01005e4:	89 e5                	mov    %esp,%ebp
f01005e6:	83 ec 08             	sub    $0x8,%esp
f01005e9:	e8 a2 01 00 00       	call   f0100790 <__x86.get_pc_thunk.ax>
f01005ee:	05 1a 0d 01 00       	add    $0x10d1a,%eax
	cons_intr(kbd_proc_data);
f01005f3:	8d 80 78 ef fe ff    	lea    -0x11088(%eax),%eax
f01005f9:	e8 1e fc ff ff       	call   f010021c <cons_intr>
}
f01005fe:	c9                   	leave  
f01005ff:	c3                   	ret    

f0100600 <cons_getc>:
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	53                   	push   %ebx
f0100604:	83 ec 04             	sub    $0x4,%esp
f0100607:	e8 f2 fb ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f010060c:	81 c3 fc 0c 01 00    	add    $0x10cfc,%ebx
	serial_intr();
f0100612:	e8 a5 ff ff ff       	call   f01005bc <serial_intr>
	kbd_intr();
f0100617:	e8 c7 ff ff ff       	call   f01005e3 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010061c:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f0100622:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100627:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f010062d:	74 1e                	je     f010064d <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f010062f:	8d 48 01             	lea    0x1(%eax),%ecx
f0100632:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f0100639:	00 
			cons.rpos = 0;
f010063a:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f010063f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100644:	0f 45 c1             	cmovne %ecx,%eax
f0100647:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f010064d:	89 d0                	mov    %edx,%eax
f010064f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100652:	c9                   	leave  
f0100653:	c3                   	ret    

f0100654 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100654:	55                   	push   %ebp
f0100655:	89 e5                	mov    %esp,%ebp
f0100657:	57                   	push   %edi
f0100658:	56                   	push   %esi
f0100659:	53                   	push   %ebx
f010065a:	83 ec 1c             	sub    $0x1c,%esp
f010065d:	e8 9c fb ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f0100662:	81 c3 a6 0c 01 00    	add    $0x10ca6,%ebx
	was = *cp;
f0100668:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010066f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100676:	5a a5 
	if (*cp != 0xA55A) {
f0100678:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010067f:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100684:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100689:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010068d:	0f 84 ac 00 00 00    	je     f010073f <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100693:	89 8b a8 1f 00 00    	mov    %ecx,0x1fa8(%ebx)
f0100699:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069e:	89 ca                	mov    %ecx,%edx
f01006a0:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a1:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a4:	89 f2                	mov    %esi,%edx
f01006a6:	ec                   	in     (%dx),%al
f01006a7:	0f b6 c0             	movzbl %al,%eax
f01006aa:	c1 e0 08             	shl    $0x8,%eax
f01006ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b5:	89 ca                	mov    %ecx,%edx
f01006b7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b8:	89 f2                	mov    %esi,%edx
f01006ba:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006bb:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f01006c1:	0f b6 c0             	movzbl %al,%eax
f01006c4:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f01006c7:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ce:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006d3:	89 c8                	mov    %ecx,%eax
f01006d5:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006e0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e5:	89 fa                	mov    %edi,%edx
f01006e7:	ee                   	out    %al,(%dx)
f01006e8:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ed:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006f8:	89 c8                	mov    %ecx,%eax
f01006fa:	89 f2                	mov    %esi,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	b8 03 00 00 00       	mov    $0x3,%eax
f0100702:	89 fa                	mov    %edi,%edx
f0100704:	ee                   	out    %al,(%dx)
f0100705:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010070a:	89 c8                	mov    %ecx,%eax
f010070c:	ee                   	out    %al,(%dx)
f010070d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100712:	89 f2                	mov    %esi,%edx
f0100714:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100715:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010071a:	ec                   	in     (%dx),%al
f010071b:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010071d:	3c ff                	cmp    $0xff,%al
f010071f:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f0100726:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010072b:	ec                   	in     (%dx),%al
f010072c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100731:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100732:	80 f9 ff             	cmp    $0xff,%cl
f0100735:	74 1e                	je     f0100755 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f0100737:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010073a:	5b                   	pop    %ebx
f010073b:	5e                   	pop    %esi
f010073c:	5f                   	pop    %edi
f010073d:	5d                   	pop    %ebp
f010073e:	c3                   	ret    
		*cp = was;
f010073f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100746:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010074b:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f0100750:	e9 3e ff ff ff       	jmp    f0100693 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100755:	83 ec 0c             	sub    $0xc,%esp
f0100758:	8d 83 cd 08 ff ff    	lea    -0xf733(%ebx),%eax
f010075e:	50                   	push   %eax
f010075f:	e8 c1 03 00 00       	call   f0100b25 <cprintf>
f0100764:	83 c4 10             	add    $0x10,%esp
}
f0100767:	eb ce                	jmp    f0100737 <cons_init+0xe3>

f0100769 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100769:	55                   	push   %ebp
f010076a:	89 e5                	mov    %esp,%ebp
f010076c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100772:	e8 2f fc ff ff       	call   f01003a6 <cons_putc>
}
f0100777:	c9                   	leave  
f0100778:	c3                   	ret    

f0100779 <getchar>:

int
getchar(void)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077f:	e8 7c fe ff ff       	call   f0100600 <cons_getc>
f0100784:	85 c0                	test   %eax,%eax
f0100786:	74 f7                	je     f010077f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010078a:	b8 01 00 00 00       	mov    $0x1,%eax
f010078f:	c3                   	ret    

f0100790 <__x86.get_pc_thunk.ax>:
f0100790:	8b 04 24             	mov    (%esp),%eax
f0100793:	c3                   	ret    

f0100794 <__x86.get_pc_thunk.si>:
f0100794:	8b 34 24             	mov    (%esp),%esi
f0100797:	c3                   	ret    

f0100798 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100798:	55                   	push   %ebp
f0100799:	89 e5                	mov    %esp,%ebp
f010079b:	56                   	push   %esi
f010079c:	53                   	push   %ebx
f010079d:	e8 5c fa ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f01007a2:	81 c3 66 0b 01 00    	add    $0x10b66,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007a8:	83 ec 04             	sub    $0x4,%esp
f01007ab:	8d 83 f8 0a ff ff    	lea    -0xf508(%ebx),%eax
f01007b1:	50                   	push   %eax
f01007b2:	8d 83 16 0b ff ff    	lea    -0xf4ea(%ebx),%eax
f01007b8:	50                   	push   %eax
f01007b9:	8d b3 1b 0b ff ff    	lea    -0xf4e5(%ebx),%esi
f01007bf:	56                   	push   %esi
f01007c0:	e8 60 03 00 00       	call   f0100b25 <cprintf>
f01007c5:	83 c4 0c             	add    $0xc,%esp
f01007c8:	8d 83 a8 0b ff ff    	lea    -0xf458(%ebx),%eax
f01007ce:	50                   	push   %eax
f01007cf:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f01007d5:	50                   	push   %eax
f01007d6:	56                   	push   %esi
f01007d7:	e8 49 03 00 00       	call   f0100b25 <cprintf>
	return 0;
}
f01007dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007e4:	5b                   	pop    %ebx
f01007e5:	5e                   	pop    %esi
f01007e6:	5d                   	pop    %ebp
f01007e7:	c3                   	ret    

f01007e8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e8:	55                   	push   %ebp
f01007e9:	89 e5                	mov    %esp,%ebp
f01007eb:	57                   	push   %edi
f01007ec:	56                   	push   %esi
f01007ed:	53                   	push   %ebx
f01007ee:	83 ec 18             	sub    $0x18,%esp
f01007f1:	e8 08 fa ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f01007f6:	81 c3 12 0b 01 00    	add    $0x10b12,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007fc:	8d 83 2d 0b ff ff    	lea    -0xf4d3(%ebx),%eax
f0100802:	50                   	push   %eax
f0100803:	e8 1d 03 00 00       	call   f0100b25 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100808:	83 c4 08             	add    $0x8,%esp
f010080b:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f0100811:	8d 83 d0 0b ff ff    	lea    -0xf430(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 08 03 00 00       	call   f0100b25 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081d:	83 c4 0c             	add    $0xc,%esp
f0100820:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100826:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010082c:	50                   	push   %eax
f010082d:	57                   	push   %edi
f010082e:	8d 83 f8 0b ff ff    	lea    -0xf408(%ebx),%eax
f0100834:	50                   	push   %eax
f0100835:	e8 eb 02 00 00       	call   f0100b25 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083a:	83 c4 0c             	add    $0xc,%esp
f010083d:	c7 c0 01 1b 10 f0    	mov    $0xf0101b01,%eax
f0100843:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100849:	52                   	push   %edx
f010084a:	50                   	push   %eax
f010084b:	8d 83 1c 0c ff ff    	lea    -0xf3e4(%ebx),%eax
f0100851:	50                   	push   %eax
f0100852:	e8 ce 02 00 00       	call   f0100b25 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100857:	83 c4 0c             	add    $0xc,%esp
f010085a:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100860:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100866:	52                   	push   %edx
f0100867:	50                   	push   %eax
f0100868:	8d 83 40 0c ff ff    	lea    -0xf3c0(%ebx),%eax
f010086e:	50                   	push   %eax
f010086f:	e8 b1 02 00 00       	call   f0100b25 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100874:	83 c4 0c             	add    $0xc,%esp
f0100877:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f010087d:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100883:	50                   	push   %eax
f0100884:	56                   	push   %esi
f0100885:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f010088b:	50                   	push   %eax
f010088c:	e8 94 02 00 00       	call   f0100b25 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100891:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100894:	29 fe                	sub    %edi,%esi
f0100896:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089c:	c1 fe 0a             	sar    $0xa,%esi
f010089f:	56                   	push   %esi
f01008a0:	8d 83 88 0c ff ff    	lea    -0xf378(%ebx),%eax
f01008a6:	50                   	push   %eax
f01008a7:	e8 79 02 00 00       	call   f0100b25 <cprintf>
	return 0;
}
f01008ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008b4:	5b                   	pop    %ebx
f01008b5:	5e                   	pop    %esi
f01008b6:	5f                   	pop    %edi
f01008b7:	5d                   	pop    %ebp
f01008b8:	c3                   	ret    

f01008b9 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b9:	55                   	push   %ebp
f01008ba:	89 e5                	mov    %esp,%ebp
f01008bc:	57                   	push   %edi
f01008bd:	56                   	push   %esi
f01008be:	53                   	push   %ebx
f01008bf:	83 ec 3c             	sub    $0x3c,%esp
f01008c2:	e8 37 f9 ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f01008c7:	81 c3 41 0a 01 00    	add    $0x10a41,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008cd:	89 ee                	mov    %ebp,%esi
	char fun_name[32] = "";
	int i = 0;
	while(ebp != NULL)
	{
		//cprintf("ebp %x eip %x args %08x\n", ebp, *(ebp+1), *(ebp+2));
		cprintf("ebp %x eip %x args %08x\n",ebp,*(ebp + 1),*(ebp+2));
f01008cf:	8d bb 46 0b ff ff    	lea    -0xf4ba(%ebx),%edi
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
			cprintf("+%d\n", (*(ebp+1)) - (uint32_t)info.eip_fn_addr);
		}
		else
			cprintf("Error happened when reading symbol table\n");
f01008d5:	8d 83 b4 0c ff ff    	lea    -0xf34c(%ebx),%eax
f01008db:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while(ebp != NULL)
f01008de:	eb 10                	jmp    f01008f0 <mon_backtrace+0x37>
			cprintf("Error happened when reading symbol table\n");
f01008e0:	83 ec 0c             	sub    $0xc,%esp
f01008e3:	ff 75 c4             	push   -0x3c(%ebp)
f01008e6:	e8 3a 02 00 00       	call   f0100b25 <cprintf>
f01008eb:	83 c4 10             	add    $0x10,%esp

		ebp = (uint32_t*)(*ebp);
f01008ee:	8b 36                	mov    (%esi),%esi
	while(ebp != NULL)
f01008f0:	85 f6                	test   %esi,%esi
f01008f2:	74 68                	je     f010095c <mon_backtrace+0xa3>
		cprintf("ebp %x eip %x args %08x\n",ebp,*(ebp + 1),*(ebp+2));
f01008f4:	ff 76 08             	push   0x8(%esi)
f01008f7:	ff 76 04             	push   0x4(%esi)
f01008fa:	56                   	push   %esi
f01008fb:	57                   	push   %edi
f01008fc:	e8 24 02 00 00       	call   f0100b25 <cprintf>
if(debuginfo_eip(*(ebp+1), &info) == 0)
f0100901:	83 c4 08             	add    $0x8,%esp
f0100904:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100907:	50                   	push   %eax
f0100908:	ff 76 04             	push   0x4(%esi)
f010090b:	e8 1e 03 00 00       	call   f0100c2e <debuginfo_eip>
f0100910:	83 c4 10             	add    $0x10,%esp
f0100913:	85 c0                	test   %eax,%eax
f0100915:	75 c9                	jne    f01008e0 <mon_backtrace+0x27>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
f0100917:	83 ec 04             	sub    $0x4,%esp
f010091a:	ff 75 d4             	push   -0x2c(%ebp)
f010091d:	ff 75 d0             	push   -0x30(%ebp)
f0100920:	8d 83 9f 08 ff ff    	lea    -0xf761(%ebx),%eax
f0100926:	50                   	push   %eax
f0100927:	e8 f9 01 00 00       	call   f0100b25 <cprintf>
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f010092c:	83 c4 0c             	add    $0xc,%esp
f010092f:	ff 75 d8             	push   -0x28(%ebp)
f0100932:	ff 75 dc             	push   -0x24(%ebp)
f0100935:	8d 83 5f 0b ff ff    	lea    -0xf4a1(%ebx),%eax
f010093b:	50                   	push   %eax
f010093c:	e8 e4 01 00 00       	call   f0100b25 <cprintf>
			cprintf("+%d\n", (*(ebp+1)) - (uint32_t)info.eip_fn_addr);
f0100941:	83 c4 08             	add    $0x8,%esp
f0100944:	8b 46 04             	mov    0x4(%esi),%eax
f0100947:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010094a:	50                   	push   %eax
f010094b:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f0100951:	50                   	push   %eax
f0100952:	e8 ce 01 00 00       	call   f0100b25 <cprintf>
f0100957:	83 c4 10             	add    $0x10,%esp
f010095a:	eb 92                	jmp    f01008ee <mon_backtrace+0x35>
	}
	//lab1 e11 end
	
	return 0;
}
f010095c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100961:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100964:	5b                   	pop    %ebx
f0100965:	5e                   	pop    %esi
f0100966:	5f                   	pop    %edi
f0100967:	5d                   	pop    %ebp
f0100968:	c3                   	ret    

f0100969 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100969:	55                   	push   %ebp
f010096a:	89 e5                	mov    %esp,%ebp
f010096c:	57                   	push   %edi
f010096d:	56                   	push   %esi
f010096e:	53                   	push   %ebx
f010096f:	83 ec 68             	sub    $0x68,%esp
f0100972:	e8 87 f8 ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f0100977:	81 c3 91 09 01 00    	add    $0x10991,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010097d:	8d 83 e0 0c ff ff    	lea    -0xf320(%ebx),%eax
f0100983:	50                   	push   %eax
f0100984:	e8 9c 01 00 00       	call   f0100b25 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100989:	8d 83 04 0d ff ff    	lea    -0xf2fc(%ebx),%eax
f010098f:	89 04 24             	mov    %eax,(%esp)
f0100992:	e8 8e 01 00 00       	call   f0100b25 <cprintf>
f0100997:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010099a:	8d bb 6d 0b ff ff    	lea    -0xf493(%ebx),%edi
f01009a0:	eb 4a                	jmp    f01009ec <monitor+0x83>
f01009a2:	83 ec 08             	sub    $0x8,%esp
f01009a5:	0f be c0             	movsbl %al,%eax
f01009a8:	50                   	push   %eax
f01009a9:	57                   	push   %edi
f01009aa:	e8 ed 0c 00 00       	call   f010169c <strchr>
f01009af:	83 c4 10             	add    $0x10,%esp
f01009b2:	85 c0                	test   %eax,%eax
f01009b4:	74 08                	je     f01009be <monitor+0x55>
			*buf++ = 0;
f01009b6:	c6 06 00             	movb   $0x0,(%esi)
f01009b9:	8d 76 01             	lea    0x1(%esi),%esi
f01009bc:	eb 79                	jmp    f0100a37 <monitor+0xce>
		if (*buf == 0)
f01009be:	80 3e 00             	cmpb   $0x0,(%esi)
f01009c1:	74 7f                	je     f0100a42 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01009c3:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009c7:	74 0f                	je     f01009d8 <monitor+0x6f>
		argv[argc++] = buf;
f01009c9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009cc:	8d 48 01             	lea    0x1(%eax),%ecx
f01009cf:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009d2:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009d6:	eb 44                	jmp    f0100a1c <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009d8:	83 ec 08             	sub    $0x8,%esp
f01009db:	6a 10                	push   $0x10
f01009dd:	8d 83 72 0b ff ff    	lea    -0xf48e(%ebx),%eax
f01009e3:	50                   	push   %eax
f01009e4:	e8 3c 01 00 00       	call   f0100b25 <cprintf>
			return 0;
f01009e9:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009ec:	8d 83 69 0b ff ff    	lea    -0xf497(%ebx),%eax
f01009f2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009f5:	83 ec 0c             	sub    $0xc,%esp
f01009f8:	ff 75 a4             	push   -0x5c(%ebp)
f01009fb:	e8 4b 0a 00 00       	call   f010144b <readline>
f0100a00:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a02:	83 c4 10             	add    $0x10,%esp
f0100a05:	85 c0                	test   %eax,%eax
f0100a07:	74 ec                	je     f01009f5 <monitor+0x8c>
	argv[argc] = 0;
f0100a09:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a10:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a17:	eb 1e                	jmp    f0100a37 <monitor+0xce>
			buf++;
f0100a19:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a1c:	0f b6 06             	movzbl (%esi),%eax
f0100a1f:	84 c0                	test   %al,%al
f0100a21:	74 14                	je     f0100a37 <monitor+0xce>
f0100a23:	83 ec 08             	sub    $0x8,%esp
f0100a26:	0f be c0             	movsbl %al,%eax
f0100a29:	50                   	push   %eax
f0100a2a:	57                   	push   %edi
f0100a2b:	e8 6c 0c 00 00       	call   f010169c <strchr>
f0100a30:	83 c4 10             	add    $0x10,%esp
f0100a33:	85 c0                	test   %eax,%eax
f0100a35:	74 e2                	je     f0100a19 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a37:	0f b6 06             	movzbl (%esi),%eax
f0100a3a:	84 c0                	test   %al,%al
f0100a3c:	0f 85 60 ff ff ff    	jne    f01009a2 <monitor+0x39>
	argv[argc] = 0;
f0100a42:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a45:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a4c:	00 
	if (argc == 0)
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	74 9b                	je     f01009ec <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a51:	83 ec 08             	sub    $0x8,%esp
f0100a54:	8d 83 16 0b ff ff    	lea    -0xf4ea(%ebx),%eax
f0100a5a:	50                   	push   %eax
f0100a5b:	ff 75 a8             	push   -0x58(%ebp)
f0100a5e:	e8 d9 0b 00 00       	call   f010163c <strcmp>
f0100a63:	83 c4 10             	add    $0x10,%esp
f0100a66:	85 c0                	test   %eax,%eax
f0100a68:	74 38                	je     f0100aa2 <monitor+0x139>
f0100a6a:	83 ec 08             	sub    $0x8,%esp
f0100a6d:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f0100a73:	50                   	push   %eax
f0100a74:	ff 75 a8             	push   -0x58(%ebp)
f0100a77:	e8 c0 0b 00 00       	call   f010163c <strcmp>
f0100a7c:	83 c4 10             	add    $0x10,%esp
f0100a7f:	85 c0                	test   %eax,%eax
f0100a81:	74 1a                	je     f0100a9d <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a83:	83 ec 08             	sub    $0x8,%esp
f0100a86:	ff 75 a8             	push   -0x58(%ebp)
f0100a89:	8d 83 8f 0b ff ff    	lea    -0xf471(%ebx),%eax
f0100a8f:	50                   	push   %eax
f0100a90:	e8 90 00 00 00       	call   f0100b25 <cprintf>
	return 0;
f0100a95:	83 c4 10             	add    $0x10,%esp
f0100a98:	e9 4f ff ff ff       	jmp    f01009ec <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a9d:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100aa2:	83 ec 04             	sub    $0x4,%esp
f0100aa5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aa8:	ff 75 08             	push   0x8(%ebp)
f0100aab:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aae:	52                   	push   %edx
f0100aaf:	ff 75 a4             	push   -0x5c(%ebp)
f0100ab2:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ab9:	83 c4 10             	add    $0x10,%esp
f0100abc:	85 c0                	test   %eax,%eax
f0100abe:	0f 89 28 ff ff ff    	jns    f01009ec <monitor+0x83>
				break;
	}
}
f0100ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac7:	5b                   	pop    %ebx
f0100ac8:	5e                   	pop    %esi
f0100ac9:	5f                   	pop    %edi
f0100aca:	5d                   	pop    %ebp
f0100acb:	c3                   	ret    

f0100acc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100acc:	55                   	push   %ebp
f0100acd:	89 e5                	mov    %esp,%ebp
f0100acf:	53                   	push   %ebx
f0100ad0:	83 ec 10             	sub    $0x10,%esp
f0100ad3:	e8 26 f7 ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f0100ad8:	81 c3 30 08 01 00    	add    $0x10830,%ebx
	cputchar(ch);
f0100ade:	ff 75 08             	push   0x8(%ebp)
f0100ae1:	e8 83 fc ff ff       	call   f0100769 <cputchar>
	*cnt++;
}
f0100ae6:	83 c4 10             	add    $0x10,%esp
f0100ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aec:	c9                   	leave  
f0100aed:	c3                   	ret    

f0100aee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100aee:	55                   	push   %ebp
f0100aef:	89 e5                	mov    %esp,%ebp
f0100af1:	53                   	push   %ebx
f0100af2:	83 ec 14             	sub    $0x14,%esp
f0100af5:	e8 04 f7 ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f0100afa:	81 c3 0e 08 01 00    	add    $0x1080e,%ebx
	int cnt = 0;
f0100b00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b07:	ff 75 0c             	push   0xc(%ebp)
f0100b0a:	ff 75 08             	push   0x8(%ebp)
f0100b0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b10:	50                   	push   %eax
f0100b11:	8d 83 c4 f7 fe ff    	lea    -0x1083c(%ebx),%eax
f0100b17:	50                   	push   %eax
f0100b18:	e8 0d 04 00 00       	call   f0100f2a <vprintfmt>
	return cnt;
}
f0100b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b23:	c9                   	leave  
f0100b24:	c3                   	ret    

f0100b25 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b25:	55                   	push   %ebp
f0100b26:	89 e5                	mov    %esp,%ebp
f0100b28:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b2b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b2e:	50                   	push   %eax
f0100b2f:	ff 75 08             	push   0x8(%ebp)
f0100b32:	e8 b7 ff ff ff       	call   f0100aee <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b37:	c9                   	leave  
f0100b38:	c3                   	ret    

f0100b39 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b39:	55                   	push   %ebp
f0100b3a:	89 e5                	mov    %esp,%ebp
f0100b3c:	57                   	push   %edi
f0100b3d:	56                   	push   %esi
f0100b3e:	53                   	push   %ebx
f0100b3f:	83 ec 14             	sub    $0x14,%esp
f0100b42:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b48:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b4b:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b4e:	8b 1a                	mov    (%edx),%ebx
f0100b50:	8b 01                	mov    (%ecx),%eax
f0100b52:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b55:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b5c:	eb 2f                	jmp    f0100b8d <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b5e:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b61:	39 c3                	cmp    %eax,%ebx
f0100b63:	7f 4e                	jg     f0100bb3 <stab_binsearch+0x7a>
f0100b65:	0f b6 0a             	movzbl (%edx),%ecx
f0100b68:	83 ea 0c             	sub    $0xc,%edx
f0100b6b:	39 f1                	cmp    %esi,%ecx
f0100b6d:	75 ef                	jne    f0100b5e <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b6f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b72:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b75:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b79:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b7c:	73 3a                	jae    f0100bb8 <stab_binsearch+0x7f>
			*region_left = m;
f0100b7e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b81:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b83:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100b86:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b8d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b90:	7f 53                	jg     f0100be5 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b95:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100b98:	89 d0                	mov    %edx,%eax
f0100b9a:	c1 e8 1f             	shr    $0x1f,%eax
f0100b9d:	01 d0                	add    %edx,%eax
f0100b9f:	89 c7                	mov    %eax,%edi
f0100ba1:	d1 ff                	sar    %edi
f0100ba3:	83 e0 fe             	and    $0xfffffffe,%eax
f0100ba6:	01 f8                	add    %edi,%eax
f0100ba8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bab:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100baf:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bb1:	eb ae                	jmp    f0100b61 <stab_binsearch+0x28>
			l = true_m + 1;
f0100bb3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100bb6:	eb d5                	jmp    f0100b8d <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100bb8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bbb:	76 14                	jbe    f0100bd1 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100bbd:	83 e8 01             	sub    $0x1,%eax
f0100bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bc3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bc6:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100bc8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bcf:	eb bc                	jmp    f0100b8d <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bd4:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100bd6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bda:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100bdc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100be3:	eb a8                	jmp    f0100b8d <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100be5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100be9:	75 15                	jne    f0100c00 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bee:	8b 00                	mov    (%eax),%eax
f0100bf0:	83 e8 01             	sub    $0x1,%eax
f0100bf3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bf6:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100bf8:	83 c4 14             	add    $0x14,%esp
f0100bfb:	5b                   	pop    %ebx
f0100bfc:	5e                   	pop    %esi
f0100bfd:	5f                   	pop    %edi
f0100bfe:	5d                   	pop    %ebp
f0100bff:	c3                   	ret    
		for (l = *region_right;
f0100c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c03:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c08:	8b 0f                	mov    (%edi),%ecx
f0100c0a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c0d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c10:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100c14:	39 c1                	cmp    %eax,%ecx
f0100c16:	7d 0f                	jge    f0100c27 <stab_binsearch+0xee>
f0100c18:	0f b6 1a             	movzbl (%edx),%ebx
f0100c1b:	83 ea 0c             	sub    $0xc,%edx
f0100c1e:	39 f3                	cmp    %esi,%ebx
f0100c20:	74 05                	je     f0100c27 <stab_binsearch+0xee>
		     l--)
f0100c22:	83 e8 01             	sub    $0x1,%eax
f0100c25:	eb ed                	jmp    f0100c14 <stab_binsearch+0xdb>
		*region_left = l;
f0100c27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c2a:	89 07                	mov    %eax,(%edi)
}
f0100c2c:	eb ca                	jmp    f0100bf8 <stab_binsearch+0xbf>

f0100c2e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c2e:	55                   	push   %ebp
f0100c2f:	89 e5                	mov    %esp,%ebp
f0100c31:	57                   	push   %edi
f0100c32:	56                   	push   %esi
f0100c33:	53                   	push   %ebx
f0100c34:	83 ec 2c             	sub    $0x2c,%esp
f0100c37:	e8 c2 f5 ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f0100c3c:	81 c3 cc 06 01 00    	add    $0x106cc,%ebx
f0100c42:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c45:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c48:	8d 83 29 0d ff ff    	lea    -0xf2d7(%ebx),%eax
f0100c4e:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100c50:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100c57:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100c5a:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100c61:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0100c64:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c6b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100c71:	0f 86 f9 00 00 00    	jbe    f0100d70 <debuginfo_eip+0x142>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c77:	c7 c0 31 5b 10 f0    	mov    $0xf0105b31,%eax
f0100c7d:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c83:	0f 86 87 01 00 00    	jbe    f0100e10 <debuginfo_eip+0x1e2>
f0100c89:	c7 c0 71 71 10 f0    	mov    $0xf0107171,%eax
f0100c8f:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c93:	0f 85 7e 01 00 00    	jne    f0100e17 <debuginfo_eip+0x1e9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ca0:	c7 c0 48 22 10 f0    	mov    $0xf0102248,%eax
f0100ca6:	c7 c2 30 5b 10 f0    	mov    $0xf0105b30,%edx
f0100cac:	29 c2                	sub    %eax,%edx
f0100cae:	c1 fa 02             	sar    $0x2,%edx
f0100cb1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100cb7:	83 ea 01             	sub    $0x1,%edx
f0100cba:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cbd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cc0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cc3:	83 ec 08             	sub    $0x8,%esp
f0100cc6:	56                   	push   %esi
f0100cc7:	6a 64                	push   $0x64
f0100cc9:	e8 6b fe ff ff       	call   f0100b39 <stab_binsearch>
	if (lfile == 0)
f0100cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100cd4:	83 c4 10             	add    $0x10,%esp
f0100cd7:	85 c0                	test   %eax,%eax
f0100cd9:	0f 84 3f 01 00 00    	je     f0100e1e <debuginfo_eip+0x1f0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cdf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ce8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ceb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cee:	83 ec 08             	sub    $0x8,%esp
f0100cf1:	56                   	push   %esi
f0100cf2:	6a 24                	push   $0x24
f0100cf4:	c7 c0 48 22 10 f0    	mov    $0xf0102248,%eax
f0100cfa:	e8 3a fe ff ff       	call   f0100b39 <stab_binsearch>

	if (lfun <= rfun) {
f0100cff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100d02:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100d05:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d08:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0100d0b:	83 c4 10             	add    $0x10,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f0100d0e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
	if (lfun <= rfun) {
f0100d11:	39 d1                	cmp    %edx,%ecx
f0100d13:	7f 30                	jg     f0100d45 <debuginfo_eip+0x117>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d15:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100d18:	c7 c2 48 22 10 f0    	mov    $0xf0102248,%edx
f0100d1e:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100d21:	8b 11                	mov    (%ecx),%edx
f0100d23:	c7 c0 71 71 10 f0    	mov    $0xf0107171,%eax
f0100d29:	81 e8 31 5b 10 f0    	sub    $0xf0105b31,%eax
f0100d2f:	39 c2                	cmp    %eax,%edx
f0100d31:	73 09                	jae    f0100d3c <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d33:	81 c2 31 5b 10 f0    	add    $0xf0105b31,%edx
f0100d39:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d3c:	8b 41 08             	mov    0x8(%ecx),%eax
f0100d3f:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f0100d42:	8b 75 d0             	mov    -0x30(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d45:	83 ec 08             	sub    $0x8,%esp
f0100d48:	6a 3a                	push   $0x3a
f0100d4a:	ff 77 08             	push   0x8(%edi)
f0100d4d:	e8 6d 09 00 00       	call   f01016bf <strfind>
f0100d52:	2b 47 08             	sub    0x8(%edi),%eax
f0100d55:	89 47 0c             	mov    %eax,0xc(%edi)
f0100d58:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100d5b:	c7 c2 48 22 10 f0    	mov    $0xf0102248,%edx
f0100d61:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d65:	83 c4 10             	add    $0x10,%esp
f0100d68:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0100d6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100d6e:	eb 1e                	jmp    f0100d8e <debuginfo_eip+0x160>
  	        panic("User address");
f0100d70:	83 ec 04             	sub    $0x4,%esp
f0100d73:	8d 83 33 0d ff ff    	lea    -0xf2cd(%ebx),%eax
f0100d79:	50                   	push   %eax
f0100d7a:	6a 7f                	push   $0x7f
f0100d7c:	8d 83 40 0d ff ff    	lea    -0xf2c0(%ebx),%eax
f0100d82:	50                   	push   %eax
f0100d83:	e8 c0 f3 ff ff       	call   f0100148 <_panic>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100d88:	83 ee 01             	sub    $0x1,%esi
f0100d8b:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d8e:	39 f7                	cmp    %esi,%edi
f0100d90:	7f 3c                	jg     f0100dce <debuginfo_eip+0x1a0>
	       && stabs[lline].n_type != N_SOL
f0100d92:	0f b6 10             	movzbl (%eax),%edx
f0100d95:	80 fa 84             	cmp    $0x84,%dl
f0100d98:	74 0b                	je     f0100da5 <debuginfo_eip+0x177>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d9a:	80 fa 64             	cmp    $0x64,%dl
f0100d9d:	75 e9                	jne    f0100d88 <debuginfo_eip+0x15a>
f0100d9f:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100da3:	74 e3                	je     f0100d88 <debuginfo_eip+0x15a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100da5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100da8:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100dab:	c7 c0 48 22 10 f0    	mov    $0xf0102248,%eax
f0100db1:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100db4:	c7 c0 71 71 10 f0    	mov    $0xf0107171,%eax
f0100dba:	81 e8 31 5b 10 f0    	sub    $0xf0105b31,%eax
f0100dc0:	39 c2                	cmp    %eax,%edx
f0100dc2:	73 0d                	jae    f0100dd1 <debuginfo_eip+0x1a3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100dc4:	81 c2 31 5b 10 f0    	add    $0xf0105b31,%edx
f0100dca:	89 17                	mov    %edx,(%edi)
f0100dcc:	eb 03                	jmp    f0100dd1 <debuginfo_eip+0x1a3>
f0100dce:	8b 7d 0c             	mov    0xc(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dd1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100dd6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100dd9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100ddc:	39 ce                	cmp    %ecx,%esi
f0100dde:	7d 4a                	jge    f0100e2a <debuginfo_eip+0x1fc>
		for (lline = lfun + 1;
f0100de0:	8d 56 01             	lea    0x1(%esi),%edx
f0100de3:	8d 0c 76             	lea    (%esi,%esi,2),%ecx
f0100de6:	c7 c0 48 22 10 f0    	mov    $0xf0102248,%eax
f0100dec:	8d 44 88 10          	lea    0x10(%eax,%ecx,4),%eax
f0100df0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100df3:	eb 07                	jmp    f0100dfc <debuginfo_eip+0x1ce>
			info->eip_fn_narg++;
f0100df5:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100df9:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100dfc:	39 d1                	cmp    %edx,%ecx
f0100dfe:	74 25                	je     f0100e25 <debuginfo_eip+0x1f7>
f0100e00:	83 c0 0c             	add    $0xc,%eax
f0100e03:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100e07:	74 ec                	je     f0100df5 <debuginfo_eip+0x1c7>
	return 0;
f0100e09:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e0e:	eb 1a                	jmp    f0100e2a <debuginfo_eip+0x1fc>
		return -1;
f0100e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e15:	eb 13                	jmp    f0100e2a <debuginfo_eip+0x1fc>
f0100e17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e1c:	eb 0c                	jmp    f0100e2a <debuginfo_eip+0x1fc>
		return -1;
f0100e1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e23:	eb 05                	jmp    f0100e2a <debuginfo_eip+0x1fc>
	return 0;
f0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e2d:	5b                   	pop    %ebx
f0100e2e:	5e                   	pop    %esi
f0100e2f:	5f                   	pop    %edi
f0100e30:	5d                   	pop    %ebp
f0100e31:	c3                   	ret    

f0100e32 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e32:	55                   	push   %ebp
f0100e33:	89 e5                	mov    %esp,%ebp
f0100e35:	57                   	push   %edi
f0100e36:	56                   	push   %esi
f0100e37:	53                   	push   %ebx
f0100e38:	83 ec 2c             	sub    $0x2c,%esp
f0100e3b:	e8 07 06 00 00       	call   f0101447 <__x86.get_pc_thunk.cx>
f0100e40:	81 c1 c8 04 01 00    	add    $0x104c8,%ecx
f0100e46:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e49:	89 c7                	mov    %eax,%edi
f0100e4b:	89 d6                	mov    %edx,%esi
f0100e4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e50:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e53:	89 d1                	mov    %edx,%ecx
f0100e55:	89 c2                	mov    %eax,%edx
f0100e57:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e5a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100e5d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e60:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e63:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e66:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e6d:	39 c2                	cmp    %eax,%edx
f0100e6f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100e72:	72 41                	jb     f0100eb5 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e74:	83 ec 0c             	sub    $0xc,%esp
f0100e77:	ff 75 18             	push   0x18(%ebp)
f0100e7a:	83 eb 01             	sub    $0x1,%ebx
f0100e7d:	53                   	push   %ebx
f0100e7e:	50                   	push   %eax
f0100e7f:	83 ec 08             	sub    $0x8,%esp
f0100e82:	ff 75 e4             	push   -0x1c(%ebp)
f0100e85:	ff 75 e0             	push   -0x20(%ebp)
f0100e88:	ff 75 d4             	push   -0x2c(%ebp)
f0100e8b:	ff 75 d0             	push   -0x30(%ebp)
f0100e8e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e91:	e8 3a 0a 00 00       	call   f01018d0 <__udivdi3>
f0100e96:	83 c4 18             	add    $0x18,%esp
f0100e99:	52                   	push   %edx
f0100e9a:	50                   	push   %eax
f0100e9b:	89 f2                	mov    %esi,%edx
f0100e9d:	89 f8                	mov    %edi,%eax
f0100e9f:	e8 8e ff ff ff       	call   f0100e32 <printnum>
f0100ea4:	83 c4 20             	add    $0x20,%esp
f0100ea7:	eb 13                	jmp    f0100ebc <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ea9:	83 ec 08             	sub    $0x8,%esp
f0100eac:	56                   	push   %esi
f0100ead:	ff 75 18             	push   0x18(%ebp)
f0100eb0:	ff d7                	call   *%edi
f0100eb2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100eb5:	83 eb 01             	sub    $0x1,%ebx
f0100eb8:	85 db                	test   %ebx,%ebx
f0100eba:	7f ed                	jg     f0100ea9 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ebc:	83 ec 08             	sub    $0x8,%esp
f0100ebf:	56                   	push   %esi
f0100ec0:	83 ec 04             	sub    $0x4,%esp
f0100ec3:	ff 75 e4             	push   -0x1c(%ebp)
f0100ec6:	ff 75 e0             	push   -0x20(%ebp)
f0100ec9:	ff 75 d4             	push   -0x2c(%ebp)
f0100ecc:	ff 75 d0             	push   -0x30(%ebp)
f0100ecf:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ed2:	e8 19 0b 00 00       	call   f01019f0 <__umoddi3>
f0100ed7:	83 c4 14             	add    $0x14,%esp
f0100eda:	0f be 84 03 4e 0d ff 	movsbl -0xf2b2(%ebx,%eax,1),%eax
f0100ee1:	ff 
f0100ee2:	50                   	push   %eax
f0100ee3:	ff d7                	call   *%edi
}
f0100ee5:	83 c4 10             	add    $0x10,%esp
f0100ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eeb:	5b                   	pop    %ebx
f0100eec:	5e                   	pop    %esi
f0100eed:	5f                   	pop    %edi
f0100eee:	5d                   	pop    %ebp
f0100eef:	c3                   	ret    

f0100ef0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ef0:	55                   	push   %ebp
f0100ef1:	89 e5                	mov    %esp,%ebp
f0100ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ef6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100efa:	8b 10                	mov    (%eax),%edx
f0100efc:	3b 50 04             	cmp    0x4(%eax),%edx
f0100eff:	73 0a                	jae    f0100f0b <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f01:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f04:	89 08                	mov    %ecx,(%eax)
f0100f06:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f09:	88 02                	mov    %al,(%edx)
}
f0100f0b:	5d                   	pop    %ebp
f0100f0c:	c3                   	ret    

f0100f0d <printfmt>:
{
f0100f0d:	55                   	push   %ebp
f0100f0e:	89 e5                	mov    %esp,%ebp
f0100f10:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f13:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f16:	50                   	push   %eax
f0100f17:	ff 75 10             	push   0x10(%ebp)
f0100f1a:	ff 75 0c             	push   0xc(%ebp)
f0100f1d:	ff 75 08             	push   0x8(%ebp)
f0100f20:	e8 05 00 00 00       	call   f0100f2a <vprintfmt>
}
f0100f25:	83 c4 10             	add    $0x10,%esp
f0100f28:	c9                   	leave  
f0100f29:	c3                   	ret    

f0100f2a <vprintfmt>:
{
f0100f2a:	55                   	push   %ebp
f0100f2b:	89 e5                	mov    %esp,%ebp
f0100f2d:	57                   	push   %edi
f0100f2e:	56                   	push   %esi
f0100f2f:	53                   	push   %ebx
f0100f30:	83 ec 3c             	sub    $0x3c,%esp
f0100f33:	e8 58 f8 ff ff       	call   f0100790 <__x86.get_pc_thunk.ax>
f0100f38:	05 d0 03 01 00       	add    $0x103d0,%eax
f0100f3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f40:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f43:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f49:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f0100f4f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100f52:	eb 0a                	jmp    f0100f5e <vprintfmt+0x34>
			putch(ch, putdat);
f0100f54:	83 ec 08             	sub    $0x8,%esp
f0100f57:	57                   	push   %edi
f0100f58:	50                   	push   %eax
f0100f59:	ff d6                	call   *%esi
f0100f5b:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f5e:	83 c3 01             	add    $0x1,%ebx
f0100f61:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100f65:	83 f8 25             	cmp    $0x25,%eax
f0100f68:	74 0c                	je     f0100f76 <vprintfmt+0x4c>
			if (ch == '\0')
f0100f6a:	85 c0                	test   %eax,%eax
f0100f6c:	75 e6                	jne    f0100f54 <vprintfmt+0x2a>
}
f0100f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f71:	5b                   	pop    %ebx
f0100f72:	5e                   	pop    %esi
f0100f73:	5f                   	pop    %edi
f0100f74:	5d                   	pop    %ebp
f0100f75:	c3                   	ret    
		padc = ' ';
f0100f76:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100f7a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0100f81:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100f88:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0100f8f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f94:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100f97:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f9a:	8d 43 01             	lea    0x1(%ebx),%eax
f0100f9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fa0:	0f b6 13             	movzbl (%ebx),%edx
f0100fa3:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fa6:	3c 55                	cmp    $0x55,%al
f0100fa8:	0f 87 fd 03 00 00    	ja     f01013ab <.L20>
f0100fae:	0f b6 c0             	movzbl %al,%eax
f0100fb1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fb4:	89 ce                	mov    %ecx,%esi
f0100fb6:	03 b4 81 d8 0d ff ff 	add    -0xf228(%ecx,%eax,4),%esi
f0100fbd:	ff e6                	jmp    *%esi

f0100fbf <.L68>:
f0100fbf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100fc2:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100fc6:	eb d2                	jmp    f0100f9a <vprintfmt+0x70>

f0100fc8 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fc8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fcb:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100fcf:	eb c9                	jmp    f0100f9a <vprintfmt+0x70>

f0100fd1 <.L31>:
f0100fd1:	0f b6 d2             	movzbl %dl,%edx
f0100fd4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100fd7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fdc:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100fdf:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100fe2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100fe6:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100fe9:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100fec:	83 f9 09             	cmp    $0x9,%ecx
f0100fef:	77 58                	ja     f0101049 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0100ff1:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0100ff4:	eb e9                	jmp    f0100fdf <.L31+0xe>

f0100ff6 <.L34>:
			precision = va_arg(ap, int);
f0100ff6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff9:	8b 00                	mov    (%eax),%eax
f0100ffb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ffe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101001:	8d 40 04             	lea    0x4(%eax),%eax
f0101004:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101007:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010100a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010100e:	79 8a                	jns    f0100f9a <vprintfmt+0x70>
				width = precision, precision = -1;
f0101010:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101013:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101016:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010101d:	e9 78 ff ff ff       	jmp    f0100f9a <vprintfmt+0x70>

f0101022 <.L33>:
f0101022:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101025:	85 d2                	test   %edx,%edx
f0101027:	b8 00 00 00 00       	mov    $0x0,%eax
f010102c:	0f 49 c2             	cmovns %edx,%eax
f010102f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101032:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101035:	e9 60 ff ff ff       	jmp    f0100f9a <vprintfmt+0x70>

f010103a <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010103a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010103d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101044:	e9 51 ff ff ff       	jmp    f0100f9a <vprintfmt+0x70>
f0101049:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010104c:	89 75 08             	mov    %esi,0x8(%ebp)
f010104f:	eb b9                	jmp    f010100a <.L34+0x14>

f0101051 <.L27>:
			lflag++;
f0101051:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101055:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101058:	e9 3d ff ff ff       	jmp    f0100f9a <vprintfmt+0x70>

f010105d <.L30>:
			putch(va_arg(ap, int), putdat);
f010105d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101060:	8b 45 14             	mov    0x14(%ebp),%eax
f0101063:	8d 58 04             	lea    0x4(%eax),%ebx
f0101066:	83 ec 08             	sub    $0x8,%esp
f0101069:	57                   	push   %edi
f010106a:	ff 30                	push   (%eax)
f010106c:	ff d6                	call   *%esi
			break;
f010106e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101071:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101074:	e9 c8 02 00 00       	jmp    f0101341 <.L25+0x45>

f0101079 <.L28>:
			err = va_arg(ap, int);
f0101079:	8b 75 08             	mov    0x8(%ebp),%esi
f010107c:	8b 45 14             	mov    0x14(%ebp),%eax
f010107f:	8d 58 04             	lea    0x4(%eax),%ebx
f0101082:	8b 10                	mov    (%eax),%edx
f0101084:	89 d0                	mov    %edx,%eax
f0101086:	f7 d8                	neg    %eax
f0101088:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010108b:	83 f8 06             	cmp    $0x6,%eax
f010108e:	7f 27                	jg     f01010b7 <.L28+0x3e>
f0101090:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101093:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101096:	85 d2                	test   %edx,%edx
f0101098:	74 1d                	je     f01010b7 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010109a:	52                   	push   %edx
f010109b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010109e:	8d 80 82 08 ff ff    	lea    -0xf77e(%eax),%eax
f01010a4:	50                   	push   %eax
f01010a5:	57                   	push   %edi
f01010a6:	56                   	push   %esi
f01010a7:	e8 61 fe ff ff       	call   f0100f0d <printfmt>
f01010ac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010af:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01010b2:	e9 8a 02 00 00       	jmp    f0101341 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010b7:	50                   	push   %eax
f01010b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010bb:	8d 80 66 0d ff ff    	lea    -0xf29a(%eax),%eax
f01010c1:	50                   	push   %eax
f01010c2:	57                   	push   %edi
f01010c3:	56                   	push   %esi
f01010c4:	e8 44 fe ff ff       	call   f0100f0d <printfmt>
f01010c9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010cc:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010cf:	e9 6d 02 00 00       	jmp    f0101341 <.L25+0x45>

f01010d4 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01010d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01010d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010da:	83 c0 04             	add    $0x4,%eax
f01010dd:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01010e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01010e5:	85 d2                	test   %edx,%edx
f01010e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010ea:	8d 80 5f 0d ff ff    	lea    -0xf2a1(%eax),%eax
f01010f0:	0f 45 c2             	cmovne %edx,%eax
f01010f3:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01010f6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010fa:	7e 06                	jle    f0101102 <.L24+0x2e>
f01010fc:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101100:	75 0d                	jne    f010110f <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101102:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101105:	89 c3                	mov    %eax,%ebx
f0101107:	03 45 d4             	add    -0x2c(%ebp),%eax
f010110a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010110d:	eb 58                	jmp    f0101167 <.L24+0x93>
f010110f:	83 ec 08             	sub    $0x8,%esp
f0101112:	ff 75 d8             	push   -0x28(%ebp)
f0101115:	ff 75 c8             	push   -0x38(%ebp)
f0101118:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010111b:	e8 48 04 00 00       	call   f0101568 <strnlen>
f0101120:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101123:	29 c2                	sub    %eax,%edx
f0101125:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101128:	83 c4 10             	add    $0x10,%esp
f010112b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010112d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101131:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101134:	eb 0f                	jmp    f0101145 <.L24+0x71>
					putch(padc, putdat);
f0101136:	83 ec 08             	sub    $0x8,%esp
f0101139:	57                   	push   %edi
f010113a:	ff 75 d4             	push   -0x2c(%ebp)
f010113d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010113f:	83 eb 01             	sub    $0x1,%ebx
f0101142:	83 c4 10             	add    $0x10,%esp
f0101145:	85 db                	test   %ebx,%ebx
f0101147:	7f ed                	jg     f0101136 <.L24+0x62>
f0101149:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010114c:	85 d2                	test   %edx,%edx
f010114e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101153:	0f 49 c2             	cmovns %edx,%eax
f0101156:	29 c2                	sub    %eax,%edx
f0101158:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010115b:	eb a5                	jmp    f0101102 <.L24+0x2e>
					putch(ch, putdat);
f010115d:	83 ec 08             	sub    $0x8,%esp
f0101160:	57                   	push   %edi
f0101161:	52                   	push   %edx
f0101162:	ff d6                	call   *%esi
f0101164:	83 c4 10             	add    $0x10,%esp
f0101167:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010116a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010116c:	83 c3 01             	add    $0x1,%ebx
f010116f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101173:	0f be d0             	movsbl %al,%edx
f0101176:	85 d2                	test   %edx,%edx
f0101178:	74 4b                	je     f01011c5 <.L24+0xf1>
f010117a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010117e:	78 06                	js     f0101186 <.L24+0xb2>
f0101180:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101184:	78 1e                	js     f01011a4 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101186:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010118a:	74 d1                	je     f010115d <.L24+0x89>
f010118c:	0f be c0             	movsbl %al,%eax
f010118f:	83 e8 20             	sub    $0x20,%eax
f0101192:	83 f8 5e             	cmp    $0x5e,%eax
f0101195:	76 c6                	jbe    f010115d <.L24+0x89>
					putch('?', putdat);
f0101197:	83 ec 08             	sub    $0x8,%esp
f010119a:	57                   	push   %edi
f010119b:	6a 3f                	push   $0x3f
f010119d:	ff d6                	call   *%esi
f010119f:	83 c4 10             	add    $0x10,%esp
f01011a2:	eb c3                	jmp    f0101167 <.L24+0x93>
f01011a4:	89 cb                	mov    %ecx,%ebx
f01011a6:	eb 0e                	jmp    f01011b6 <.L24+0xe2>
				putch(' ', putdat);
f01011a8:	83 ec 08             	sub    $0x8,%esp
f01011ab:	57                   	push   %edi
f01011ac:	6a 20                	push   $0x20
f01011ae:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01011b0:	83 eb 01             	sub    $0x1,%ebx
f01011b3:	83 c4 10             	add    $0x10,%esp
f01011b6:	85 db                	test   %ebx,%ebx
f01011b8:	7f ee                	jg     f01011a8 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01011ba:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01011bd:	89 45 14             	mov    %eax,0x14(%ebp)
f01011c0:	e9 7c 01 00 00       	jmp    f0101341 <.L25+0x45>
f01011c5:	89 cb                	mov    %ecx,%ebx
f01011c7:	eb ed                	jmp    f01011b6 <.L24+0xe2>

f01011c9 <.L29>:
	if (lflag >= 2)
f01011c9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01011cc:	8b 75 08             	mov    0x8(%ebp),%esi
f01011cf:	83 f9 01             	cmp    $0x1,%ecx
f01011d2:	7f 1b                	jg     f01011ef <.L29+0x26>
	else if (lflag)
f01011d4:	85 c9                	test   %ecx,%ecx
f01011d6:	74 63                	je     f010123b <.L29+0x72>
		return va_arg(*ap, long);
f01011d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011db:	8b 00                	mov    (%eax),%eax
f01011dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011e0:	99                   	cltd   
f01011e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e7:	8d 40 04             	lea    0x4(%eax),%eax
f01011ea:	89 45 14             	mov    %eax,0x14(%ebp)
f01011ed:	eb 17                	jmp    f0101206 <.L29+0x3d>
		return va_arg(*ap, long long);
f01011ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01011f2:	8b 50 04             	mov    0x4(%eax),%edx
f01011f5:	8b 00                	mov    (%eax),%eax
f01011f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0101200:	8d 40 08             	lea    0x8(%eax),%eax
f0101203:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101206:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101209:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f010120c:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0101211:	85 db                	test   %ebx,%ebx
f0101213:	0f 89 0e 01 00 00    	jns    f0101327 <.L25+0x2b>
				putch('-', putdat);
f0101219:	83 ec 08             	sub    $0x8,%esp
f010121c:	57                   	push   %edi
f010121d:	6a 2d                	push   $0x2d
f010121f:	ff d6                	call   *%esi
				num = -(long long) num;
f0101221:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101224:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101227:	f7 d9                	neg    %ecx
f0101229:	83 d3 00             	adc    $0x0,%ebx
f010122c:	f7 db                	neg    %ebx
f010122e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101231:	ba 0a 00 00 00       	mov    $0xa,%edx
f0101236:	e9 ec 00 00 00       	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, int);
f010123b:	8b 45 14             	mov    0x14(%ebp),%eax
f010123e:	8b 00                	mov    (%eax),%eax
f0101240:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101243:	99                   	cltd   
f0101244:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101247:	8b 45 14             	mov    0x14(%ebp),%eax
f010124a:	8d 40 04             	lea    0x4(%eax),%eax
f010124d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101250:	eb b4                	jmp    f0101206 <.L29+0x3d>

f0101252 <.L23>:
	if (lflag >= 2)
f0101252:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101255:	8b 75 08             	mov    0x8(%ebp),%esi
f0101258:	83 f9 01             	cmp    $0x1,%ecx
f010125b:	7f 1e                	jg     f010127b <.L23+0x29>
	else if (lflag)
f010125d:	85 c9                	test   %ecx,%ecx
f010125f:	74 32                	je     f0101293 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101261:	8b 45 14             	mov    0x14(%ebp),%eax
f0101264:	8b 08                	mov    (%eax),%ecx
f0101266:	bb 00 00 00 00       	mov    $0x0,%ebx
f010126b:	8d 40 04             	lea    0x4(%eax),%eax
f010126e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101271:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0101276:	e9 ac 00 00 00       	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010127b:	8b 45 14             	mov    0x14(%ebp),%eax
f010127e:	8b 08                	mov    (%eax),%ecx
f0101280:	8b 58 04             	mov    0x4(%eax),%ebx
f0101283:	8d 40 08             	lea    0x8(%eax),%eax
f0101286:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101289:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f010128e:	e9 94 00 00 00       	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101293:	8b 45 14             	mov    0x14(%ebp),%eax
f0101296:	8b 08                	mov    (%eax),%ecx
f0101298:	bb 00 00 00 00       	mov    $0x0,%ebx
f010129d:	8d 40 04             	lea    0x4(%eax),%eax
f01012a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012a3:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f01012a8:	eb 7d                	jmp    f0101327 <.L25+0x2b>

f01012aa <.L26>:
	if (lflag >= 2)
f01012aa:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012ad:	8b 75 08             	mov    0x8(%ebp),%esi
f01012b0:	83 f9 01             	cmp    $0x1,%ecx
f01012b3:	7f 1b                	jg     f01012d0 <.L26+0x26>
	else if (lflag)
f01012b5:	85 c9                	test   %ecx,%ecx
f01012b7:	74 2c                	je     f01012e5 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01012b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01012bc:	8b 08                	mov    (%eax),%ecx
f01012be:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012c3:	8d 40 04             	lea    0x4(%eax),%eax
f01012c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012c9:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f01012ce:	eb 57                	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d3:	8b 08                	mov    (%eax),%ecx
f01012d5:	8b 58 04             	mov    0x4(%eax),%ebx
f01012d8:	8d 40 08             	lea    0x8(%eax),%eax
f01012db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012de:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f01012e3:	eb 42                	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01012e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e8:	8b 08                	mov    (%eax),%ecx
f01012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012ef:	8d 40 04             	lea    0x4(%eax),%eax
f01012f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012f5:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f01012fa:	eb 2b                	jmp    f0101327 <.L25+0x2b>

f01012fc <.L25>:
			putch('0', putdat);
f01012fc:	8b 75 08             	mov    0x8(%ebp),%esi
f01012ff:	83 ec 08             	sub    $0x8,%esp
f0101302:	57                   	push   %edi
f0101303:	6a 30                	push   $0x30
f0101305:	ff d6                	call   *%esi
			putch('x', putdat);
f0101307:	83 c4 08             	add    $0x8,%esp
f010130a:	57                   	push   %edi
f010130b:	6a 78                	push   $0x78
f010130d:	ff d6                	call   *%esi
			num = (unsigned long long)
f010130f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101312:	8b 08                	mov    (%eax),%ecx
f0101314:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0101319:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010131c:	8d 40 04             	lea    0x4(%eax),%eax
f010131f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101322:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0101327:	83 ec 0c             	sub    $0xc,%esp
f010132a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010132e:	50                   	push   %eax
f010132f:	ff 75 d4             	push   -0x2c(%ebp)
f0101332:	52                   	push   %edx
f0101333:	53                   	push   %ebx
f0101334:	51                   	push   %ecx
f0101335:	89 fa                	mov    %edi,%edx
f0101337:	89 f0                	mov    %esi,%eax
f0101339:	e8 f4 fa ff ff       	call   f0100e32 <printnum>
			break;
f010133e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101341:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101344:	e9 15 fc ff ff       	jmp    f0100f5e <vprintfmt+0x34>

f0101349 <.L21>:
	if (lflag >= 2)
f0101349:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010134c:	8b 75 08             	mov    0x8(%ebp),%esi
f010134f:	83 f9 01             	cmp    $0x1,%ecx
f0101352:	7f 1b                	jg     f010136f <.L21+0x26>
	else if (lflag)
f0101354:	85 c9                	test   %ecx,%ecx
f0101356:	74 2c                	je     f0101384 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101358:	8b 45 14             	mov    0x14(%ebp),%eax
f010135b:	8b 08                	mov    (%eax),%ecx
f010135d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101362:	8d 40 04             	lea    0x4(%eax),%eax
f0101365:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101368:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010136d:	eb b8                	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010136f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101372:	8b 08                	mov    (%eax),%ecx
f0101374:	8b 58 04             	mov    0x4(%eax),%ebx
f0101377:	8d 40 08             	lea    0x8(%eax),%eax
f010137a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010137d:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0101382:	eb a3                	jmp    f0101327 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101384:	8b 45 14             	mov    0x14(%ebp),%eax
f0101387:	8b 08                	mov    (%eax),%ecx
f0101389:	bb 00 00 00 00       	mov    $0x0,%ebx
f010138e:	8d 40 04             	lea    0x4(%eax),%eax
f0101391:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101394:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0101399:	eb 8c                	jmp    f0101327 <.L25+0x2b>

f010139b <.L35>:
			putch(ch, putdat);
f010139b:	8b 75 08             	mov    0x8(%ebp),%esi
f010139e:	83 ec 08             	sub    $0x8,%esp
f01013a1:	57                   	push   %edi
f01013a2:	6a 25                	push   $0x25
f01013a4:	ff d6                	call   *%esi
			break;
f01013a6:	83 c4 10             	add    $0x10,%esp
f01013a9:	eb 96                	jmp    f0101341 <.L25+0x45>

f01013ab <.L20>:
			putch('%', putdat);
f01013ab:	8b 75 08             	mov    0x8(%ebp),%esi
f01013ae:	83 ec 08             	sub    $0x8,%esp
f01013b1:	57                   	push   %edi
f01013b2:	6a 25                	push   $0x25
f01013b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013b6:	83 c4 10             	add    $0x10,%esp
f01013b9:	89 d8                	mov    %ebx,%eax
f01013bb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01013bf:	74 05                	je     f01013c6 <.L20+0x1b>
f01013c1:	83 e8 01             	sub    $0x1,%eax
f01013c4:	eb f5                	jmp    f01013bb <.L20+0x10>
f01013c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013c9:	e9 73 ff ff ff       	jmp    f0101341 <.L25+0x45>

f01013ce <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013ce:	55                   	push   %ebp
f01013cf:	89 e5                	mov    %esp,%ebp
f01013d1:	53                   	push   %ebx
f01013d2:	83 ec 14             	sub    $0x14,%esp
f01013d5:	e8 24 ee ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f01013da:	81 c3 2e ff 00 00    	add    $0xff2e,%ebx
f01013e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01013e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01013e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01013ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01013f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01013f7:	85 c0                	test   %eax,%eax
f01013f9:	74 2b                	je     f0101426 <vsnprintf+0x58>
f01013fb:	85 d2                	test   %edx,%edx
f01013fd:	7e 27                	jle    f0101426 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01013ff:	ff 75 14             	push   0x14(%ebp)
f0101402:	ff 75 10             	push   0x10(%ebp)
f0101405:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101408:	50                   	push   %eax
f0101409:	8d 83 e8 fb fe ff    	lea    -0x10418(%ebx),%eax
f010140f:	50                   	push   %eax
f0101410:	e8 15 fb ff ff       	call   f0100f2a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101415:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101418:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010141e:	83 c4 10             	add    $0x10,%esp
}
f0101421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101424:	c9                   	leave  
f0101425:	c3                   	ret    
		return -E_INVAL;
f0101426:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010142b:	eb f4                	jmp    f0101421 <vsnprintf+0x53>

f010142d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010142d:	55                   	push   %ebp
f010142e:	89 e5                	mov    %esp,%ebp
f0101430:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101433:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101436:	50                   	push   %eax
f0101437:	ff 75 10             	push   0x10(%ebp)
f010143a:	ff 75 0c             	push   0xc(%ebp)
f010143d:	ff 75 08             	push   0x8(%ebp)
f0101440:	e8 89 ff ff ff       	call   f01013ce <vsnprintf>
	va_end(ap);

	return rc;
}
f0101445:	c9                   	leave  
f0101446:	c3                   	ret    

f0101447 <__x86.get_pc_thunk.cx>:
f0101447:	8b 0c 24             	mov    (%esp),%ecx
f010144a:	c3                   	ret    

f010144b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010144b:	55                   	push   %ebp
f010144c:	89 e5                	mov    %esp,%ebp
f010144e:	57                   	push   %edi
f010144f:	56                   	push   %esi
f0101450:	53                   	push   %ebx
f0101451:	83 ec 1c             	sub    $0x1c,%esp
f0101454:	e8 a5 ed ff ff       	call   f01001fe <__x86.get_pc_thunk.bx>
f0101459:	81 c3 af fe 00 00    	add    $0xfeaf,%ebx
f010145f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101462:	85 c0                	test   %eax,%eax
f0101464:	74 13                	je     f0101479 <readline+0x2e>
		cprintf("%s", prompt);
f0101466:	83 ec 08             	sub    $0x8,%esp
f0101469:	50                   	push   %eax
f010146a:	8d 83 82 08 ff ff    	lea    -0xf77e(%ebx),%eax
f0101470:	50                   	push   %eax
f0101471:	e8 af f6 ff ff       	call   f0100b25 <cprintf>
f0101476:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101479:	83 ec 0c             	sub    $0xc,%esp
f010147c:	6a 00                	push   $0x0
f010147e:	e8 07 f3 ff ff       	call   f010078a <iscons>
f0101483:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101486:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101489:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010148e:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101494:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101497:	eb 45                	jmp    f01014de <readline+0x93>
			cprintf("read error: %e\n", c);
f0101499:	83 ec 08             	sub    $0x8,%esp
f010149c:	50                   	push   %eax
f010149d:	8d 83 30 0f ff ff    	lea    -0xf0d0(%ebx),%eax
f01014a3:	50                   	push   %eax
f01014a4:	e8 7c f6 ff ff       	call   f0100b25 <cprintf>
			return NULL;
f01014a9:	83 c4 10             	add    $0x10,%esp
f01014ac:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014b4:	5b                   	pop    %ebx
f01014b5:	5e                   	pop    %esi
f01014b6:	5f                   	pop    %edi
f01014b7:	5d                   	pop    %ebp
f01014b8:	c3                   	ret    
			if (echoing)
f01014b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014bd:	75 05                	jne    f01014c4 <readline+0x79>
			i--;
f01014bf:	83 ef 01             	sub    $0x1,%edi
f01014c2:	eb 1a                	jmp    f01014de <readline+0x93>
				cputchar('\b');
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	6a 08                	push   $0x8
f01014c9:	e8 9b f2 ff ff       	call   f0100769 <cputchar>
f01014ce:	83 c4 10             	add    $0x10,%esp
f01014d1:	eb ec                	jmp    f01014bf <readline+0x74>
			buf[i++] = c;
f01014d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01014d6:	89 f0                	mov    %esi,%eax
f01014d8:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01014db:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01014de:	e8 96 f2 ff ff       	call   f0100779 <getchar>
f01014e3:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01014e5:	85 c0                	test   %eax,%eax
f01014e7:	78 b0                	js     f0101499 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01014e9:	83 f8 08             	cmp    $0x8,%eax
f01014ec:	0f 94 c0             	sete   %al
f01014ef:	83 fe 7f             	cmp    $0x7f,%esi
f01014f2:	0f 94 c2             	sete   %dl
f01014f5:	08 d0                	or     %dl,%al
f01014f7:	74 04                	je     f01014fd <readline+0xb2>
f01014f9:	85 ff                	test   %edi,%edi
f01014fb:	7f bc                	jg     f01014b9 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01014fd:	83 fe 1f             	cmp    $0x1f,%esi
f0101500:	7e 1c                	jle    f010151e <readline+0xd3>
f0101502:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101508:	7f 14                	jg     f010151e <readline+0xd3>
			if (echoing)
f010150a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010150e:	74 c3                	je     f01014d3 <readline+0x88>
				cputchar(c);
f0101510:	83 ec 0c             	sub    $0xc,%esp
f0101513:	56                   	push   %esi
f0101514:	e8 50 f2 ff ff       	call   f0100769 <cputchar>
f0101519:	83 c4 10             	add    $0x10,%esp
f010151c:	eb b5                	jmp    f01014d3 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f010151e:	83 fe 0a             	cmp    $0xa,%esi
f0101521:	74 05                	je     f0101528 <readline+0xdd>
f0101523:	83 fe 0d             	cmp    $0xd,%esi
f0101526:	75 b6                	jne    f01014de <readline+0x93>
			if (echoing)
f0101528:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010152c:	75 13                	jne    f0101541 <readline+0xf6>
			buf[i] = 0;
f010152e:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0101535:	00 
			return buf;
f0101536:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f010153c:	e9 70 ff ff ff       	jmp    f01014b1 <readline+0x66>
				cputchar('\n');
f0101541:	83 ec 0c             	sub    $0xc,%esp
f0101544:	6a 0a                	push   $0xa
f0101546:	e8 1e f2 ff ff       	call   f0100769 <cputchar>
f010154b:	83 c4 10             	add    $0x10,%esp
f010154e:	eb de                	jmp    f010152e <readline+0xe3>

f0101550 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101550:	55                   	push   %ebp
f0101551:	89 e5                	mov    %esp,%ebp
f0101553:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101556:	b8 00 00 00 00       	mov    $0x0,%eax
f010155b:	eb 03                	jmp    f0101560 <strlen+0x10>
		n++;
f010155d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101560:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101564:	75 f7                	jne    f010155d <strlen+0xd>
	return n;
}
f0101566:	5d                   	pop    %ebp
f0101567:	c3                   	ret    

f0101568 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101568:	55                   	push   %ebp
f0101569:	89 e5                	mov    %esp,%ebp
f010156b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010156e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101571:	b8 00 00 00 00       	mov    $0x0,%eax
f0101576:	eb 03                	jmp    f010157b <strnlen+0x13>
		n++;
f0101578:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010157b:	39 d0                	cmp    %edx,%eax
f010157d:	74 08                	je     f0101587 <strnlen+0x1f>
f010157f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101583:	75 f3                	jne    f0101578 <strnlen+0x10>
f0101585:	89 c2                	mov    %eax,%edx
	return n;
}
f0101587:	89 d0                	mov    %edx,%eax
f0101589:	5d                   	pop    %ebp
f010158a:	c3                   	ret    

f010158b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010158b:	55                   	push   %ebp
f010158c:	89 e5                	mov    %esp,%ebp
f010158e:	53                   	push   %ebx
f010158f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101595:	b8 00 00 00 00       	mov    $0x0,%eax
f010159a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010159e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01015a1:	83 c0 01             	add    $0x1,%eax
f01015a4:	84 d2                	test   %dl,%dl
f01015a6:	75 f2                	jne    f010159a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015a8:	89 c8                	mov    %ecx,%eax
f01015aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015ad:	c9                   	leave  
f01015ae:	c3                   	ret    

f01015af <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015af:	55                   	push   %ebp
f01015b0:	89 e5                	mov    %esp,%ebp
f01015b2:	53                   	push   %ebx
f01015b3:	83 ec 10             	sub    $0x10,%esp
f01015b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015b9:	53                   	push   %ebx
f01015ba:	e8 91 ff ff ff       	call   f0101550 <strlen>
f01015bf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01015c2:	ff 75 0c             	push   0xc(%ebp)
f01015c5:	01 d8                	add    %ebx,%eax
f01015c7:	50                   	push   %eax
f01015c8:	e8 be ff ff ff       	call   f010158b <strcpy>
	return dst;
}
f01015cd:	89 d8                	mov    %ebx,%eax
f01015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015d2:	c9                   	leave  
f01015d3:	c3                   	ret    

f01015d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01015d4:	55                   	push   %ebp
f01015d5:	89 e5                	mov    %esp,%ebp
f01015d7:	56                   	push   %esi
f01015d8:	53                   	push   %ebx
f01015d9:	8b 75 08             	mov    0x8(%ebp),%esi
f01015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015df:	89 f3                	mov    %esi,%ebx
f01015e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01015e4:	89 f0                	mov    %esi,%eax
f01015e6:	eb 0f                	jmp    f01015f7 <strncpy+0x23>
		*dst++ = *src;
f01015e8:	83 c0 01             	add    $0x1,%eax
f01015eb:	0f b6 0a             	movzbl (%edx),%ecx
f01015ee:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01015f1:	80 f9 01             	cmp    $0x1,%cl
f01015f4:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01015f7:	39 d8                	cmp    %ebx,%eax
f01015f9:	75 ed                	jne    f01015e8 <strncpy+0x14>
	}
	return ret;
}
f01015fb:	89 f0                	mov    %esi,%eax
f01015fd:	5b                   	pop    %ebx
f01015fe:	5e                   	pop    %esi
f01015ff:	5d                   	pop    %ebp
f0101600:	c3                   	ret    

f0101601 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101601:	55                   	push   %ebp
f0101602:	89 e5                	mov    %esp,%ebp
f0101604:	56                   	push   %esi
f0101605:	53                   	push   %ebx
f0101606:	8b 75 08             	mov    0x8(%ebp),%esi
f0101609:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010160c:	8b 55 10             	mov    0x10(%ebp),%edx
f010160f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101611:	85 d2                	test   %edx,%edx
f0101613:	74 21                	je     f0101636 <strlcpy+0x35>
f0101615:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101619:	89 f2                	mov    %esi,%edx
f010161b:	eb 09                	jmp    f0101626 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010161d:	83 c1 01             	add    $0x1,%ecx
f0101620:	83 c2 01             	add    $0x1,%edx
f0101623:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0101626:	39 c2                	cmp    %eax,%edx
f0101628:	74 09                	je     f0101633 <strlcpy+0x32>
f010162a:	0f b6 19             	movzbl (%ecx),%ebx
f010162d:	84 db                	test   %bl,%bl
f010162f:	75 ec                	jne    f010161d <strlcpy+0x1c>
f0101631:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101633:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101636:	29 f0                	sub    %esi,%eax
}
f0101638:	5b                   	pop    %ebx
f0101639:	5e                   	pop    %esi
f010163a:	5d                   	pop    %ebp
f010163b:	c3                   	ret    

f010163c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010163c:	55                   	push   %ebp
f010163d:	89 e5                	mov    %esp,%ebp
f010163f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101642:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101645:	eb 06                	jmp    f010164d <strcmp+0x11>
		p++, q++;
f0101647:	83 c1 01             	add    $0x1,%ecx
f010164a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010164d:	0f b6 01             	movzbl (%ecx),%eax
f0101650:	84 c0                	test   %al,%al
f0101652:	74 04                	je     f0101658 <strcmp+0x1c>
f0101654:	3a 02                	cmp    (%edx),%al
f0101656:	74 ef                	je     f0101647 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101658:	0f b6 c0             	movzbl %al,%eax
f010165b:	0f b6 12             	movzbl (%edx),%edx
f010165e:	29 d0                	sub    %edx,%eax
}
f0101660:	5d                   	pop    %ebp
f0101661:	c3                   	ret    

f0101662 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101662:	55                   	push   %ebp
f0101663:	89 e5                	mov    %esp,%ebp
f0101665:	53                   	push   %ebx
f0101666:	8b 45 08             	mov    0x8(%ebp),%eax
f0101669:	8b 55 0c             	mov    0xc(%ebp),%edx
f010166c:	89 c3                	mov    %eax,%ebx
f010166e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101671:	eb 06                	jmp    f0101679 <strncmp+0x17>
		n--, p++, q++;
f0101673:	83 c0 01             	add    $0x1,%eax
f0101676:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101679:	39 d8                	cmp    %ebx,%eax
f010167b:	74 18                	je     f0101695 <strncmp+0x33>
f010167d:	0f b6 08             	movzbl (%eax),%ecx
f0101680:	84 c9                	test   %cl,%cl
f0101682:	74 04                	je     f0101688 <strncmp+0x26>
f0101684:	3a 0a                	cmp    (%edx),%cl
f0101686:	74 eb                	je     f0101673 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101688:	0f b6 00             	movzbl (%eax),%eax
f010168b:	0f b6 12             	movzbl (%edx),%edx
f010168e:	29 d0                	sub    %edx,%eax
}
f0101690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101693:	c9                   	leave  
f0101694:	c3                   	ret    
		return 0;
f0101695:	b8 00 00 00 00       	mov    $0x0,%eax
f010169a:	eb f4                	jmp    f0101690 <strncmp+0x2e>

f010169c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010169c:	55                   	push   %ebp
f010169d:	89 e5                	mov    %esp,%ebp
f010169f:	8b 45 08             	mov    0x8(%ebp),%eax
f01016a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016a6:	eb 03                	jmp    f01016ab <strchr+0xf>
f01016a8:	83 c0 01             	add    $0x1,%eax
f01016ab:	0f b6 10             	movzbl (%eax),%edx
f01016ae:	84 d2                	test   %dl,%dl
f01016b0:	74 06                	je     f01016b8 <strchr+0x1c>
		if (*s == c)
f01016b2:	38 ca                	cmp    %cl,%dl
f01016b4:	75 f2                	jne    f01016a8 <strchr+0xc>
f01016b6:	eb 05                	jmp    f01016bd <strchr+0x21>
			return (char *) s;
	return 0;
f01016b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016bd:	5d                   	pop    %ebp
f01016be:	c3                   	ret    

f01016bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016bf:	55                   	push   %ebp
f01016c0:	89 e5                	mov    %esp,%ebp
f01016c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01016c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01016cc:	38 ca                	cmp    %cl,%dl
f01016ce:	74 09                	je     f01016d9 <strfind+0x1a>
f01016d0:	84 d2                	test   %dl,%dl
f01016d2:	74 05                	je     f01016d9 <strfind+0x1a>
	for (; *s; s++)
f01016d4:	83 c0 01             	add    $0x1,%eax
f01016d7:	eb f0                	jmp    f01016c9 <strfind+0xa>
			break;
	return (char *) s;
}
f01016d9:	5d                   	pop    %ebp
f01016da:	c3                   	ret    

f01016db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01016db:	55                   	push   %ebp
f01016dc:	89 e5                	mov    %esp,%ebp
f01016de:	57                   	push   %edi
f01016df:	56                   	push   %esi
f01016e0:	53                   	push   %ebx
f01016e1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01016e7:	85 c9                	test   %ecx,%ecx
f01016e9:	74 2f                	je     f010171a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01016eb:	89 f8                	mov    %edi,%eax
f01016ed:	09 c8                	or     %ecx,%eax
f01016ef:	a8 03                	test   $0x3,%al
f01016f1:	75 21                	jne    f0101714 <memset+0x39>
		c &= 0xFF;
f01016f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01016f7:	89 d0                	mov    %edx,%eax
f01016f9:	c1 e0 08             	shl    $0x8,%eax
f01016fc:	89 d3                	mov    %edx,%ebx
f01016fe:	c1 e3 18             	shl    $0x18,%ebx
f0101701:	89 d6                	mov    %edx,%esi
f0101703:	c1 e6 10             	shl    $0x10,%esi
f0101706:	09 f3                	or     %esi,%ebx
f0101708:	09 da                	or     %ebx,%edx
f010170a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010170c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010170f:	fc                   	cld    
f0101710:	f3 ab                	rep stos %eax,%es:(%edi)
f0101712:	eb 06                	jmp    f010171a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101714:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101717:	fc                   	cld    
f0101718:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010171a:	89 f8                	mov    %edi,%eax
f010171c:	5b                   	pop    %ebx
f010171d:	5e                   	pop    %esi
f010171e:	5f                   	pop    %edi
f010171f:	5d                   	pop    %ebp
f0101720:	c3                   	ret    

f0101721 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101721:	55                   	push   %ebp
f0101722:	89 e5                	mov    %esp,%ebp
f0101724:	57                   	push   %edi
f0101725:	56                   	push   %esi
f0101726:	8b 45 08             	mov    0x8(%ebp),%eax
f0101729:	8b 75 0c             	mov    0xc(%ebp),%esi
f010172c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010172f:	39 c6                	cmp    %eax,%esi
f0101731:	73 32                	jae    f0101765 <memmove+0x44>
f0101733:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101736:	39 c2                	cmp    %eax,%edx
f0101738:	76 2b                	jbe    f0101765 <memmove+0x44>
		s += n;
		d += n;
f010173a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010173d:	89 d6                	mov    %edx,%esi
f010173f:	09 fe                	or     %edi,%esi
f0101741:	09 ce                	or     %ecx,%esi
f0101743:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101749:	75 0e                	jne    f0101759 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010174b:	83 ef 04             	sub    $0x4,%edi
f010174e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101751:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101754:	fd                   	std    
f0101755:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101757:	eb 09                	jmp    f0101762 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101759:	83 ef 01             	sub    $0x1,%edi
f010175c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010175f:	fd                   	std    
f0101760:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101762:	fc                   	cld    
f0101763:	eb 1a                	jmp    f010177f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101765:	89 f2                	mov    %esi,%edx
f0101767:	09 c2                	or     %eax,%edx
f0101769:	09 ca                	or     %ecx,%edx
f010176b:	f6 c2 03             	test   $0x3,%dl
f010176e:	75 0a                	jne    f010177a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101770:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101773:	89 c7                	mov    %eax,%edi
f0101775:	fc                   	cld    
f0101776:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101778:	eb 05                	jmp    f010177f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f010177a:	89 c7                	mov    %eax,%edi
f010177c:	fc                   	cld    
f010177d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010177f:	5e                   	pop    %esi
f0101780:	5f                   	pop    %edi
f0101781:	5d                   	pop    %ebp
f0101782:	c3                   	ret    

f0101783 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101783:	55                   	push   %ebp
f0101784:	89 e5                	mov    %esp,%ebp
f0101786:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101789:	ff 75 10             	push   0x10(%ebp)
f010178c:	ff 75 0c             	push   0xc(%ebp)
f010178f:	ff 75 08             	push   0x8(%ebp)
f0101792:	e8 8a ff ff ff       	call   f0101721 <memmove>
}
f0101797:	c9                   	leave  
f0101798:	c3                   	ret    

f0101799 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101799:	55                   	push   %ebp
f010179a:	89 e5                	mov    %esp,%ebp
f010179c:	56                   	push   %esi
f010179d:	53                   	push   %ebx
f010179e:	8b 45 08             	mov    0x8(%ebp),%eax
f01017a1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017a4:	89 c6                	mov    %eax,%esi
f01017a6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017a9:	eb 06                	jmp    f01017b1 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017ab:	83 c0 01             	add    $0x1,%eax
f01017ae:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01017b1:	39 f0                	cmp    %esi,%eax
f01017b3:	74 14                	je     f01017c9 <memcmp+0x30>
		if (*s1 != *s2)
f01017b5:	0f b6 08             	movzbl (%eax),%ecx
f01017b8:	0f b6 1a             	movzbl (%edx),%ebx
f01017bb:	38 d9                	cmp    %bl,%cl
f01017bd:	74 ec                	je     f01017ab <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01017bf:	0f b6 c1             	movzbl %cl,%eax
f01017c2:	0f b6 db             	movzbl %bl,%ebx
f01017c5:	29 d8                	sub    %ebx,%eax
f01017c7:	eb 05                	jmp    f01017ce <memcmp+0x35>
	}

	return 0;
f01017c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017ce:	5b                   	pop    %ebx
f01017cf:	5e                   	pop    %esi
f01017d0:	5d                   	pop    %ebp
f01017d1:	c3                   	ret    

f01017d2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01017d2:	55                   	push   %ebp
f01017d3:	89 e5                	mov    %esp,%ebp
f01017d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01017db:	89 c2                	mov    %eax,%edx
f01017dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01017e0:	eb 03                	jmp    f01017e5 <memfind+0x13>
f01017e2:	83 c0 01             	add    $0x1,%eax
f01017e5:	39 d0                	cmp    %edx,%eax
f01017e7:	73 04                	jae    f01017ed <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01017e9:	38 08                	cmp    %cl,(%eax)
f01017eb:	75 f5                	jne    f01017e2 <memfind+0x10>
			break;
	return (void *) s;
}
f01017ed:	5d                   	pop    %ebp
f01017ee:	c3                   	ret    

f01017ef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01017ef:	55                   	push   %ebp
f01017f0:	89 e5                	mov    %esp,%ebp
f01017f2:	57                   	push   %edi
f01017f3:	56                   	push   %esi
f01017f4:	53                   	push   %ebx
f01017f5:	8b 55 08             	mov    0x8(%ebp),%edx
f01017f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01017fb:	eb 03                	jmp    f0101800 <strtol+0x11>
		s++;
f01017fd:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0101800:	0f b6 02             	movzbl (%edx),%eax
f0101803:	3c 20                	cmp    $0x20,%al
f0101805:	74 f6                	je     f01017fd <strtol+0xe>
f0101807:	3c 09                	cmp    $0x9,%al
f0101809:	74 f2                	je     f01017fd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010180b:	3c 2b                	cmp    $0x2b,%al
f010180d:	74 2a                	je     f0101839 <strtol+0x4a>
	int neg = 0;
f010180f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101814:	3c 2d                	cmp    $0x2d,%al
f0101816:	74 2b                	je     f0101843 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101818:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010181e:	75 0f                	jne    f010182f <strtol+0x40>
f0101820:	80 3a 30             	cmpb   $0x30,(%edx)
f0101823:	74 28                	je     f010184d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101825:	85 db                	test   %ebx,%ebx
f0101827:	b8 0a 00 00 00       	mov    $0xa,%eax
f010182c:	0f 44 d8             	cmove  %eax,%ebx
f010182f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101834:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101837:	eb 46                	jmp    f010187f <strtol+0x90>
		s++;
f0101839:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010183c:	bf 00 00 00 00       	mov    $0x0,%edi
f0101841:	eb d5                	jmp    f0101818 <strtol+0x29>
		s++, neg = 1;
f0101843:	83 c2 01             	add    $0x1,%edx
f0101846:	bf 01 00 00 00       	mov    $0x1,%edi
f010184b:	eb cb                	jmp    f0101818 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010184d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101851:	74 0e                	je     f0101861 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101853:	85 db                	test   %ebx,%ebx
f0101855:	75 d8                	jne    f010182f <strtol+0x40>
		s++, base = 8;
f0101857:	83 c2 01             	add    $0x1,%edx
f010185a:	bb 08 00 00 00       	mov    $0x8,%ebx
f010185f:	eb ce                	jmp    f010182f <strtol+0x40>
		s += 2, base = 16;
f0101861:	83 c2 02             	add    $0x2,%edx
f0101864:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101869:	eb c4                	jmp    f010182f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010186b:	0f be c0             	movsbl %al,%eax
f010186e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101871:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101874:	7d 3a                	jge    f01018b0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101876:	83 c2 01             	add    $0x1,%edx
f0101879:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f010187d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010187f:	0f b6 02             	movzbl (%edx),%eax
f0101882:	8d 70 d0             	lea    -0x30(%eax),%esi
f0101885:	89 f3                	mov    %esi,%ebx
f0101887:	80 fb 09             	cmp    $0x9,%bl
f010188a:	76 df                	jbe    f010186b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f010188c:	8d 70 9f             	lea    -0x61(%eax),%esi
f010188f:	89 f3                	mov    %esi,%ebx
f0101891:	80 fb 19             	cmp    $0x19,%bl
f0101894:	77 08                	ja     f010189e <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101896:	0f be c0             	movsbl %al,%eax
f0101899:	83 e8 57             	sub    $0x57,%eax
f010189c:	eb d3                	jmp    f0101871 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010189e:	8d 70 bf             	lea    -0x41(%eax),%esi
f01018a1:	89 f3                	mov    %esi,%ebx
f01018a3:	80 fb 19             	cmp    $0x19,%bl
f01018a6:	77 08                	ja     f01018b0 <strtol+0xc1>
			dig = *s - 'A' + 10;
f01018a8:	0f be c0             	movsbl %al,%eax
f01018ab:	83 e8 37             	sub    $0x37,%eax
f01018ae:	eb c1                	jmp    f0101871 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018b4:	74 05                	je     f01018bb <strtol+0xcc>
		*endptr = (char *) s;
f01018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018b9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01018bb:	89 c8                	mov    %ecx,%eax
f01018bd:	f7 d8                	neg    %eax
f01018bf:	85 ff                	test   %edi,%edi
f01018c1:	0f 45 c8             	cmovne %eax,%ecx
}
f01018c4:	89 c8                	mov    %ecx,%eax
f01018c6:	5b                   	pop    %ebx
f01018c7:	5e                   	pop    %esi
f01018c8:	5f                   	pop    %edi
f01018c9:	5d                   	pop    %ebp
f01018ca:	c3                   	ret    
f01018cb:	66 90                	xchg   %ax,%ax
f01018cd:	66 90                	xchg   %ax,%ax
f01018cf:	90                   	nop

f01018d0 <__udivdi3>:
f01018d0:	f3 0f 1e fb          	endbr32 
f01018d4:	55                   	push   %ebp
f01018d5:	57                   	push   %edi
f01018d6:	56                   	push   %esi
f01018d7:	53                   	push   %ebx
f01018d8:	83 ec 1c             	sub    $0x1c,%esp
f01018db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01018df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01018e3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01018e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	75 19                	jne    f0101908 <__udivdi3+0x38>
f01018ef:	39 f3                	cmp    %esi,%ebx
f01018f1:	76 4d                	jbe    f0101940 <__udivdi3+0x70>
f01018f3:	31 ff                	xor    %edi,%edi
f01018f5:	89 e8                	mov    %ebp,%eax
f01018f7:	89 f2                	mov    %esi,%edx
f01018f9:	f7 f3                	div    %ebx
f01018fb:	89 fa                	mov    %edi,%edx
f01018fd:	83 c4 1c             	add    $0x1c,%esp
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    
f0101905:	8d 76 00             	lea    0x0(%esi),%esi
f0101908:	39 f0                	cmp    %esi,%eax
f010190a:	76 14                	jbe    f0101920 <__udivdi3+0x50>
f010190c:	31 ff                	xor    %edi,%edi
f010190e:	31 c0                	xor    %eax,%eax
f0101910:	89 fa                	mov    %edi,%edx
f0101912:	83 c4 1c             	add    $0x1c,%esp
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	5d                   	pop    %ebp
f0101919:	c3                   	ret    
f010191a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101920:	0f bd f8             	bsr    %eax,%edi
f0101923:	83 f7 1f             	xor    $0x1f,%edi
f0101926:	75 48                	jne    f0101970 <__udivdi3+0xa0>
f0101928:	39 f0                	cmp    %esi,%eax
f010192a:	72 06                	jb     f0101932 <__udivdi3+0x62>
f010192c:	31 c0                	xor    %eax,%eax
f010192e:	39 eb                	cmp    %ebp,%ebx
f0101930:	77 de                	ja     f0101910 <__udivdi3+0x40>
f0101932:	b8 01 00 00 00       	mov    $0x1,%eax
f0101937:	eb d7                	jmp    f0101910 <__udivdi3+0x40>
f0101939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101940:	89 d9                	mov    %ebx,%ecx
f0101942:	85 db                	test   %ebx,%ebx
f0101944:	75 0b                	jne    f0101951 <__udivdi3+0x81>
f0101946:	b8 01 00 00 00       	mov    $0x1,%eax
f010194b:	31 d2                	xor    %edx,%edx
f010194d:	f7 f3                	div    %ebx
f010194f:	89 c1                	mov    %eax,%ecx
f0101951:	31 d2                	xor    %edx,%edx
f0101953:	89 f0                	mov    %esi,%eax
f0101955:	f7 f1                	div    %ecx
f0101957:	89 c6                	mov    %eax,%esi
f0101959:	89 e8                	mov    %ebp,%eax
f010195b:	89 f7                	mov    %esi,%edi
f010195d:	f7 f1                	div    %ecx
f010195f:	89 fa                	mov    %edi,%edx
f0101961:	83 c4 1c             	add    $0x1c,%esp
f0101964:	5b                   	pop    %ebx
f0101965:	5e                   	pop    %esi
f0101966:	5f                   	pop    %edi
f0101967:	5d                   	pop    %ebp
f0101968:	c3                   	ret    
f0101969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101970:	89 f9                	mov    %edi,%ecx
f0101972:	ba 20 00 00 00       	mov    $0x20,%edx
f0101977:	29 fa                	sub    %edi,%edx
f0101979:	d3 e0                	shl    %cl,%eax
f010197b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010197f:	89 d1                	mov    %edx,%ecx
f0101981:	89 d8                	mov    %ebx,%eax
f0101983:	d3 e8                	shr    %cl,%eax
f0101985:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101989:	09 c1                	or     %eax,%ecx
f010198b:	89 f0                	mov    %esi,%eax
f010198d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101991:	89 f9                	mov    %edi,%ecx
f0101993:	d3 e3                	shl    %cl,%ebx
f0101995:	89 d1                	mov    %edx,%ecx
f0101997:	d3 e8                	shr    %cl,%eax
f0101999:	89 f9                	mov    %edi,%ecx
f010199b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010199f:	89 eb                	mov    %ebp,%ebx
f01019a1:	d3 e6                	shl    %cl,%esi
f01019a3:	89 d1                	mov    %edx,%ecx
f01019a5:	d3 eb                	shr    %cl,%ebx
f01019a7:	09 f3                	or     %esi,%ebx
f01019a9:	89 c6                	mov    %eax,%esi
f01019ab:	89 f2                	mov    %esi,%edx
f01019ad:	89 d8                	mov    %ebx,%eax
f01019af:	f7 74 24 08          	divl   0x8(%esp)
f01019b3:	89 d6                	mov    %edx,%esi
f01019b5:	89 c3                	mov    %eax,%ebx
f01019b7:	f7 64 24 0c          	mull   0xc(%esp)
f01019bb:	39 d6                	cmp    %edx,%esi
f01019bd:	72 19                	jb     f01019d8 <__udivdi3+0x108>
f01019bf:	89 f9                	mov    %edi,%ecx
f01019c1:	d3 e5                	shl    %cl,%ebp
f01019c3:	39 c5                	cmp    %eax,%ebp
f01019c5:	73 04                	jae    f01019cb <__udivdi3+0xfb>
f01019c7:	39 d6                	cmp    %edx,%esi
f01019c9:	74 0d                	je     f01019d8 <__udivdi3+0x108>
f01019cb:	89 d8                	mov    %ebx,%eax
f01019cd:	31 ff                	xor    %edi,%edi
f01019cf:	e9 3c ff ff ff       	jmp    f0101910 <__udivdi3+0x40>
f01019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019db:	31 ff                	xor    %edi,%edi
f01019dd:	e9 2e ff ff ff       	jmp    f0101910 <__udivdi3+0x40>
f01019e2:	66 90                	xchg   %ax,%ax
f01019e4:	66 90                	xchg   %ax,%ax
f01019e6:	66 90                	xchg   %ax,%ax
f01019e8:	66 90                	xchg   %ax,%ax
f01019ea:	66 90                	xchg   %ax,%ax
f01019ec:	66 90                	xchg   %ax,%ax
f01019ee:	66 90                	xchg   %ax,%ax

f01019f0 <__umoddi3>:
f01019f0:	f3 0f 1e fb          	endbr32 
f01019f4:	55                   	push   %ebp
f01019f5:	57                   	push   %edi
f01019f6:	56                   	push   %esi
f01019f7:	53                   	push   %ebx
f01019f8:	83 ec 1c             	sub    $0x1c,%esp
f01019fb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01019ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0101a07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0101a0b:	89 f0                	mov    %esi,%eax
f0101a0d:	89 da                	mov    %ebx,%edx
f0101a0f:	85 ff                	test   %edi,%edi
f0101a11:	75 15                	jne    f0101a28 <__umoddi3+0x38>
f0101a13:	39 dd                	cmp    %ebx,%ebp
f0101a15:	76 39                	jbe    f0101a50 <__umoddi3+0x60>
f0101a17:	f7 f5                	div    %ebp
f0101a19:	89 d0                	mov    %edx,%eax
f0101a1b:	31 d2                	xor    %edx,%edx
f0101a1d:	83 c4 1c             	add    $0x1c,%esp
f0101a20:	5b                   	pop    %ebx
f0101a21:	5e                   	pop    %esi
f0101a22:	5f                   	pop    %edi
f0101a23:	5d                   	pop    %ebp
f0101a24:	c3                   	ret    
f0101a25:	8d 76 00             	lea    0x0(%esi),%esi
f0101a28:	39 df                	cmp    %ebx,%edi
f0101a2a:	77 f1                	ja     f0101a1d <__umoddi3+0x2d>
f0101a2c:	0f bd cf             	bsr    %edi,%ecx
f0101a2f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a36:	75 40                	jne    f0101a78 <__umoddi3+0x88>
f0101a38:	39 df                	cmp    %ebx,%edi
f0101a3a:	72 04                	jb     f0101a40 <__umoddi3+0x50>
f0101a3c:	39 f5                	cmp    %esi,%ebp
f0101a3e:	77 dd                	ja     f0101a1d <__umoddi3+0x2d>
f0101a40:	89 da                	mov    %ebx,%edx
f0101a42:	89 f0                	mov    %esi,%eax
f0101a44:	29 e8                	sub    %ebp,%eax
f0101a46:	19 fa                	sbb    %edi,%edx
f0101a48:	eb d3                	jmp    f0101a1d <__umoddi3+0x2d>
f0101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a50:	89 e9                	mov    %ebp,%ecx
f0101a52:	85 ed                	test   %ebp,%ebp
f0101a54:	75 0b                	jne    f0101a61 <__umoddi3+0x71>
f0101a56:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a5b:	31 d2                	xor    %edx,%edx
f0101a5d:	f7 f5                	div    %ebp
f0101a5f:	89 c1                	mov    %eax,%ecx
f0101a61:	89 d8                	mov    %ebx,%eax
f0101a63:	31 d2                	xor    %edx,%edx
f0101a65:	f7 f1                	div    %ecx
f0101a67:	89 f0                	mov    %esi,%eax
f0101a69:	f7 f1                	div    %ecx
f0101a6b:	89 d0                	mov    %edx,%eax
f0101a6d:	31 d2                	xor    %edx,%edx
f0101a6f:	eb ac                	jmp    f0101a1d <__umoddi3+0x2d>
f0101a71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a78:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a7c:	ba 20 00 00 00       	mov    $0x20,%edx
f0101a81:	29 c2                	sub    %eax,%edx
f0101a83:	89 c1                	mov    %eax,%ecx
f0101a85:	89 e8                	mov    %ebp,%eax
f0101a87:	d3 e7                	shl    %cl,%edi
f0101a89:	89 d1                	mov    %edx,%ecx
f0101a8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a8f:	d3 e8                	shr    %cl,%eax
f0101a91:	89 c1                	mov    %eax,%ecx
f0101a93:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a97:	09 f9                	or     %edi,%ecx
f0101a99:	89 df                	mov    %ebx,%edi
f0101a9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a9f:	89 c1                	mov    %eax,%ecx
f0101aa1:	d3 e5                	shl    %cl,%ebp
f0101aa3:	89 d1                	mov    %edx,%ecx
f0101aa5:	d3 ef                	shr    %cl,%edi
f0101aa7:	89 c1                	mov    %eax,%ecx
f0101aa9:	89 f0                	mov    %esi,%eax
f0101aab:	d3 e3                	shl    %cl,%ebx
f0101aad:	89 d1                	mov    %edx,%ecx
f0101aaf:	89 fa                	mov    %edi,%edx
f0101ab1:	d3 e8                	shr    %cl,%eax
f0101ab3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ab8:	09 d8                	or     %ebx,%eax
f0101aba:	f7 74 24 08          	divl   0x8(%esp)
f0101abe:	89 d3                	mov    %edx,%ebx
f0101ac0:	d3 e6                	shl    %cl,%esi
f0101ac2:	f7 e5                	mul    %ebp
f0101ac4:	89 c7                	mov    %eax,%edi
f0101ac6:	89 d1                	mov    %edx,%ecx
f0101ac8:	39 d3                	cmp    %edx,%ebx
f0101aca:	72 06                	jb     f0101ad2 <__umoddi3+0xe2>
f0101acc:	75 0e                	jne    f0101adc <__umoddi3+0xec>
f0101ace:	39 c6                	cmp    %eax,%esi
f0101ad0:	73 0a                	jae    f0101adc <__umoddi3+0xec>
f0101ad2:	29 e8                	sub    %ebp,%eax
f0101ad4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101ad8:	89 d1                	mov    %edx,%ecx
f0101ada:	89 c7                	mov    %eax,%edi
f0101adc:	89 f5                	mov    %esi,%ebp
f0101ade:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101ae2:	29 fd                	sub    %edi,%ebp
f0101ae4:	19 cb                	sbb    %ecx,%ebx
f0101ae6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101aeb:	89 d8                	mov    %ebx,%eax
f0101aed:	d3 e0                	shl    %cl,%eax
f0101aef:	89 f1                	mov    %esi,%ecx
f0101af1:	d3 ed                	shr    %cl,%ebp
f0101af3:	d3 eb                	shr    %cl,%ebx
f0101af5:	09 e8                	or     %ebp,%eax
f0101af7:	89 da                	mov    %ebx,%edx
f0101af9:	83 c4 1c             	add    $0x1c,%esp
f0101afc:	5b                   	pop    %ebx
f0101afd:	5e                   	pop    %esi
f0101afe:	5f                   	pop    %edi
f0101aff:	5d                   	pop    %ebp
f0101b00:	c3                   	ret    
