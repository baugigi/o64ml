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

type position = Left | Middle | Right
type move = Move of position * position

let string_of_position = function
  | Left -> "A"
  | Middle -> "B"
  | Right -> "C"

let string_of_move (Move(org, dst)) =
  string_of_position org
  ^ "->"
  ^ string_of_position dst

let print_move =
  let count = ref 0 in
  fun m ->
  (incr count;
   print_int !count;
   print_string (":" ^ (string_of_move m));
   print_newline ())

let rec solve org aux dst = function
  | 1 -> [Move(org, dst)]
  | n -> let sub1 = solve org dst aux (pred n)
         and sub2 = solve aux org dst (pred n)
         in sub1 @ Move(org, dst) :: sub2
  
let hanoi discs = 
  List.iter print_move (solve Left Middle Right discs)

let _ =
  print_string "Numero di dischi? ";
  hanoi(read_int ());
  print_newline ()
