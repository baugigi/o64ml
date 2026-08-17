
open LargeArray

let a = init 500 float_of_int

let () =
  print_endline "iter";
  iter print_float a;
  print_endline "map";
  let b = map sqrt a in
  print_endline "iter2";
  iter2 (fun x y ->
      print_float x;
      print_float y;
      print_newline ()) a b
