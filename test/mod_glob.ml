(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della licenza GNU GPL ver. 2,  come specificato
   nel file LICENZA-it nella cartella principale del progetto.
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the GNU  General Public License (GPL) ver. 2, as
   specified in the LICENSE-en file in the project root folder.
   —————————————————————————————————————————————————————————————————————— *)

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
