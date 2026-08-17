
let x = (-340.405);;
let p = frexp x;;
print_string "(";
print_float (fst p);
print_string ",";
print_int (snd p);
print_string ")";
print_newline();
