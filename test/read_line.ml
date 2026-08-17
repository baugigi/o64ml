
let rec loop () =
  let a = read_line () in
  print_endline a;
  if a = [%pet "fine"] then () else loop ()

let () = loop ()
