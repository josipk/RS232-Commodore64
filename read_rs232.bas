10 rem this program receives true ascii data
100 open 5,2,3,chr$(10)+chr$(161)
310 get#5,a$
320 if asc(a$+" ")=8 then printchr$(20);:goto310
330 if a$<>"" then print" "chr$(157);:printa$;
350 goto310
