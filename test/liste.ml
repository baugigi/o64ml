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

let mymap f l =
  let rec aux accu f = function
    | [] -> accu
    | x :: xs -> aux ((f x) :: accu) f xs in
  aux [] f l
let f n = 3 * n
let l = [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]
let l1 = mymap f l
let l2 = List.map f l
let rec p l1 l2 = match l1,l2 with
  |[],_ -> ()
  |x::xs,y::ys ->
    print_int x;
    print_string ",";
    print_int y;
    print_newline ();
    p xs ys
  |_ -> failwith "p"

let _ = p l1 l2
          
