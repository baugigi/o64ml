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

let rec numeri_primi n =
  if n = 0
  then []
  else numeri_primi_aux (pred n) [2]
and numeri_primi_aux n r =
  if n = 0
  then r
  else numeri_primi_aux
         (pred n)
         (primo_successivo (List.hd r + 1) r :: r)
and primo_successivo n l =
  if primo n l
  then n
  else primo_successivo (n+1) l
and primo n = function
  | [] ->
     true
  | e::tl ->
     if n mod e = 0
     then false
     else primo n tl
let _ =
  for i = 1 to 80 do
    ignore (numeri_primi 250)
  done
