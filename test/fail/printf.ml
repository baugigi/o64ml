
let printf n =
  print_string (Printf.sprintf "%d\013" n)
let l = 
  List.sort compare [65;2;4;63;42;46]
;;
List.iter printf l



