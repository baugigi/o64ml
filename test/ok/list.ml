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

let rec map f = function
  | [] -> []
  | x::xs -> (f x) :: (map f xs)
let rec nth l n =
  match n, l with
  | 0, x::_ -> Some x
  | p, _::r when p > 0 -> nth r (pred p)
  | _ -> None
let x () =
  let l = map (fun n -> n * n) [1;2;3;4;5] in
  match nth l 2 with
  | Some n -> n
  | None -> -1
;;

x ()
    
