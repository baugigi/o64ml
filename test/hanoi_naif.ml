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
