
let rec loop () =
  match read_line () with
  | "*" -> ()
  | s -> print_endline s;
         loop ()
;;
loop ()
