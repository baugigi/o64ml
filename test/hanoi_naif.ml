
let print_move (* org dst *) =
  let count = ref 0 in
  (fun org dst ->
    incr count;
    print_int !count;
    print_char ':';
    print_int org;
    print_char '>';
    print_int dst;
    print_newline ())

let rec solve org aux dst = function
  | 1 -> print_move org dst
  | n -> solve org dst aux (pred n);
         print_move org dst;
         solve aux org dst (pred n)

let _ =
  solve 1 2 3 (read_int())
