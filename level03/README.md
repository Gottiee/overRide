# Reverse Password

## Protection

RELRO | STACK CANARY | NX | PIE
--- | --- | --- | --- 
**Partial RELRO** | **Canary found** | **NX enabled** | No PIE  

## Context

There is 3 principas function.

Main(), reading stdin int a %d scanf, calling function test(322424845, user_input);

```c
  scanf("%d", scan);
  test(scan, 322424845);
```

Function Test() call function decrypt, but there is two way, if 322424845 - user_input <= 21 decrypt is call with the nbr. Else he is call with rand().

```c
	param_1 -= param_2;
	if (param_1 <= 21)
		decrypt(param_1);
	else
		decrypt(rand());
```

Without reading decrypt fucntion, we can write a script, trying each number between 322424845 and 322424845 - 21.

[Script.sh](/level03/Ressource/script.sh)

322424827 seems spawn a shell !