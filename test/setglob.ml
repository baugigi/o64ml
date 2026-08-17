
let a = ref 0;;
let b = "0";;
let incr_str s =
  let c = s.[0] in
  s.[0] <- char_of_int(succ (int_of_char c));;

print_int(incr a; !a); print_newline();
print_string(incr_str b; b); print_newline();

