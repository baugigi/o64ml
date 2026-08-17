
let x = 1;;

let a = "ABCDEFGHI";;
(*
let strcpy a =
  let b = String.create (String.length a) in
  for i = 0 to pred (String.length a) do
    String.set b i (String.get a i);
  done;
  b;;

let b = strcpy a in
xxxxxxxx
 *)
let b = "01234567890123456789"
and c = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789" in
try
  Bytes.fill b 10 11 '*';
  Bytes.fill c 290 11 '*';
  print_string b;
  print_newline ();
  print_string c;
  print_newline ();
with _ -> print_string "EXCEPTION CAUGHT.\013"
;;

