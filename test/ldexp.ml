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

let print_frexp x =
  let p = frexp x in
  print_string " (";
  print_float (fst p);
  print_string ",";
  print_int (snd p);
  print_string ") ";
;;
let f x n =
  print_float x;
  print_string " ";
  print_int n;
  print_frexp x;
  (try
     let x' = ldexp x n in
     print_float x';
     print_frexp x';
   with _ ->
     print_string "overflow");
  print_newline();
;;

f (2.0) (-200);
f (2.0) (-2);
f (2.0) (-1);
f (-2.0) (-200);
f (-2.0) (-2);
f (-2.0) (-1);
f (2.0) (+200);
f (2.0) (+2);
f (2.0) (+1);
f (-2.0) (+200);
f (-2.0) (+2);
f (-2.0) (+1);

