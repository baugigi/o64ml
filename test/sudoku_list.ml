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

let sz = 9

let m' =
  [[9; 0; 6; 0; 7; 0; 4; 0; 3];
   [3; 0; 0; 4; 0; 0; 2; 0; 0];
   [0; 7; 0; 0; 2; 3; 0; 1; 0];
   [5; 0; 0; 0; 0; 0; 1; 0; 4];
   [0; 4; 0; 2; 0; 8; 0; 6; 0];
   [7; 0; 3; 0; 4; 0; 0; 0; 5];
   [0; 3; 0; 7; 0; 0; 0; 5; 0];
   [0; 0; 7; 0; 0; 5; 0; 0; 0];
   [4; 0; 5; 0; 1; 0; 7; 0; 8]]

let m =
  let makeref n = ref n in
  List.map (List.map makeref) m'

let get x y = !(List.nth (List.nth m y) x)
let set x y n = (List.nth (List.nth m y) x) := n
  
let print() =
  let print_line l =
    let z = int_of_char '0' in
    List.iter (fun r -> print_char (char_of_int(!r + z))) l;
    print_newline() in
  List.iter print_line m

let rec invalid ?(i=0) x y n =
  i < sz &&
    (get i y = n
     || get x i = n
     || get  (x / 3 * 3 + i mod 3) (y / 3 * 3 + i / 3) = n
     || invalid ~i:(succ i) x y n)
  
                             
let rec fold f accu l u =
  if l = u then
    accu
  else
    fold f (f accu l) (succ l) u

  
let rec search ?(x=0) ?(y=0) f accu =
  match x, y with
  | s, y when s = sz -> search ~x:0 ~y:(succ y) f accu 	(* Next row *)
  | 0, s when s = sz -> f accu                        	(* Found a solution *)
  | x, y ->
     if get x y <> 0 then
       search ~x:(succ x) ~y f accu
     else
       let brute_force accu n =
         if invalid x y n then
           accu
         else
           begin
             set x y n;
             let accu = search ~x:(succ x) ~y f accu in
             set x y 0;
             accu
           end in
       fold brute_force accu 1 (succ sz)

let _ =
  print_int (search (fun i -> print(); succ i) 0);
  print_string " solution(s)";

