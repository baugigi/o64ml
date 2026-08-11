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

let rec fibo_rec n =
  if n <= 1 then n else (fibo_rec (n - 1)) + (fibo_rec (n - 2))

let fibo_tail n =
  let rec aux n b a =
    if n <= 0 then a else aux (n - 1) (a + b) b
  in aux n 1 0
   
let n = 20

let _ =
  print_string ("fibo_tail " ^ (string_of_int n) ^ "=");
  print_int (fibo_tail n);
  print_newline ();
  print_string ("fibo_rec  " ^ (string_of_int n) ^ "=");
  print_int (fibo_rec n);
  print_newline ();
    
