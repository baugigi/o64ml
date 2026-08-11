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

let s0 = "0123456789ABCDEF" in
let s1 = "0123456789ABCDEF" in
for i = 0 to 100 do
  String.blit s0 3 s0 5 4;
  print_string s0;
  print_newline ();
  String.blit s1 5 s1 3 4;
  print_string s1;
  print_newline ();
done

