# Bypass traceme

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Partial RELRO** | **Canary found** | **NX enabled** | No PIE  

## Context

```bash
$> ./level06
***********************************
*		level06		  *
***********************************
-> Enter Login: gottie
***********************************
***** NEW ACCOUNT DETECTED ********
***********************************
-> Enter Serial: 1
```

Main function wait a login (char [32]) and serials number (unsigned int)

It call auth with them as arguments.

```c
  return_auth = auth(buffer_32, serials);
```

If auth return 0, it spwan a shell:

```c
if (return_auth == 0)
	system("/bin/sh")
```

### In auth function:

```c
  ret = strnlen(user_login,0x20);
  if ((int)ret < 6) {
    return_value = 1;
```

It wait a login more longer than 5 char.

If you try ptrace the programm, ptrace return -1.

```c
	ptrace_value = ptrace(PTRACE_TRACEME);
    if (ptrace_value == -1) {
      return_value = 1;
    }
```

But we can easely bypass this protection bye `set $eax=0` before cmp instruction.

Last step is to go in gdb at 

```c
      if (serial == tmp) {
        return_value = 0;
      }
```

See the value store at this moment in tmp, and relaunch the program with the good serial:

login: gottie compared `0x005f1b05` with serials value.

```bash
./level06 
***********************************
*		level06		  *
***********************************
-> Enter Login: gottie
***********************************
***** NEW ACCOUNT DETECTED ********
***********************************
-> Enter Serial: 6232837
Authenticated!
```