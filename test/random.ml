
let ntrue = ref 0
let nfalse = ref 0
let count = 10000
;; 
for i = 1 to count do
    if Random.bool () then incr ntrue else incr nfalse;
    print_int i;
done;
print_newline ();
print_string "#true = ";
print_int !ntrue;
print_newline ();
print_string "#false= ";
print_int !nfalse;

