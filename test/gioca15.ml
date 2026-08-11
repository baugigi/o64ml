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

module Puzzle =
struct
  type t = int array
  let make () =
    [| 15;  0;  1;  2;
        3;  4;  5;  6;
        7;  8;  9; 10;
       11; 12; 13; 14; |]
 
  let move p n =
    let hole, i = p.(0), p.(n) in
    p.(0) <- i;
    p.(n) <- hole

  let str_of_int i =
    if i < 10 then "  " ^ string_of_int i
    else " " ^ string_of_int i
    
  let print p =
    let out = Array.make 16 "   " in
    for i = 1 to 15 do
      out.(p.(i)) <- str_of_int i
    done;
    for i = 0 to 15 do
      if (i mod 4) = 0 then print_newline ();
      print_string out.(i);
    done
 
  let shuffle p n =
    for i = 1 to n do
	move p (1 + Random.int 15)
    done
end
 
let play () =
  let p = Puzzle.make () in
  Puzzle.shuffle p 20;
  while true do
    Puzzle.print p;
    print_string " > ";
    Puzzle.move p (read_line () |> int_of_string)
  done
    
let _ =
  play ()
