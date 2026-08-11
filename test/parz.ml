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

let print n = print_endline (string_of_int n)

let x2 f x = 2 * (f x)
                 
let g1 f x = x2 (fun x' -> x2 f x') x
let g2 f x = x2 (x2 f) x
let g3 f   = x2 (x2 f)

let myfun = succ

;;

print (g1 myfun 10);
print (g2 myfun 10);
print (g3 myfun 10);




