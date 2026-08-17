
let rec fibo_rec n =
  if n <= 1 then n else (fibo_rec (n - 1)) + (fibo_rec (n - 2))

let fibo_tail n =
  let rec aux n b a =
    if n <= 0 then a else aux (n - 1) (a + b) b
  in aux n 1 0
   
let n = 20

let _ =
  print_string ("fibo_tail " ^ (string_of_int n) ^ "=");
  print_int (fibo_tail n);
  print_newline ();
  print_string ("fibo_rec  " ^ (string_of_int n) ^ "=");
  print_int (fibo_rec n);
  print_newline ();
    
