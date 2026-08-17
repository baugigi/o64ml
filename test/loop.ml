
let i, j = ref 0, ref 0

let _ =
  i := -10;
  while !i <= 10 do
    print_string "i="; 
    print_int !i;
    print_string "; j=";
    j := -10;
    while !j <= 10 do
      print_int !j;
      print_string ", ";
      j := !j + 1
    done;
    print_newline();
    i := !i + 1
  done
    
