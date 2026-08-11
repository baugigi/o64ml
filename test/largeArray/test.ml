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

open LargeArray

let a = init 500 float_of_int

let () =
  print_endline "iter";
  iter print_float a;
  print_endline "map";
  let b = map sqrt a in
  print_endline "iter2";
  iter2 (fun x y ->
      print_float x;
      print_float y;
      print_newline ()) a b
