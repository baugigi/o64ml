
let glob = "A"
         
let mod_glob () =
  let ch = Char.code glob.[0] in
  print_string glob;
  print_int ch;
  print_string " -> ";
  glob.[0] <- Char.chr(succ ch);
  print_endline glob
  
let _ =
  while (ignore (read_line ()); true) do
    mod_glob ()
  done
