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

let i, j = ref 0, ref 0

let _ =
  i := -10;
  while !i <= 10 do
    print_string "i="; 
    print_int !i;
    print_string "; j=";
    j := -10;
    while !j <= 10 do
      print_int !j;
      print_string ", ";
      j := !j + 1
    done;
    print_newline();
    i := !i + 1
  done
    
