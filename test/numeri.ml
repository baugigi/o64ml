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

let n = fst(100,0) in print_int n;
(* print_int(int_of_char('\010')); (\* ok *\) *)
(* print_string "9"; (\* KO *\) *)
(* print_int 8; (\* ok *\) *)
(* print_float 7.; (\* KO *\) *)
(* print_int 6; (\* ok *\) *)
(* print_int (int_of_float 666.); (\* KO *\) *)
(* print_string "5"; (\* KO *\) *)
