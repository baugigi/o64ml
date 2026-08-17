
let print_frexp x =
  let p = frexp x in
  print_string " (";
  print_float (fst p);
  print_string ",";
  print_int (snd p);
  print_string ") ";
;;
let f x n =
  print_float x;
  print_string " ";
  print_int n;
  print_frexp x;
  (try
     let x' = ldexp x n in
     print_float x';
     print_frexp x';
   with _ ->
     print_string "overflow");
  print_newline();
;;

f (2.0) (-200);
f (2.0) (-2);
f (2.0) (-1);
f (-2.0) (-200);
f (-2.0) (-2);
f (-2.0) (-1);
f (2.0) (+200);
f (2.0) (+2);
f (2.0) (+1);
f (-2.0) (+200);
f (-2.0) (+2);
f (-2.0) (+1);

