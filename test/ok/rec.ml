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

let rec f n =
  if n <= 1 then
    1
  else
    f (pred n) + 1;;

f 127;; (* 127 chiamate ricorsive, -stacksize 4 *)
f 255;; (* 255 chiamate ricorsive, -stacksize 8 *)
f 511;; (* 511 chiamate ricorsive, -stacksize 16 *)


