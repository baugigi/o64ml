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

let x = 1;;

let a = "ABCDEFGHI";;
(*
let strcpy a =
  let b = String.create (String.length a) in
  for i = 0 to pred (String.length a) do
    String.set b i (String.get a i);
  done;
  b;;

let b = strcpy a in
xxxxxxxx
 *)
let b = "01234567890123456789"
and c = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789" in
try
  Bytes.fill b 10 11 '*';
  Bytes.fill c 290 11 '*';
  print_string b;
  print_newline ();
  print_string c;
  print_newline ();
with _ -> print_string "EXCEPTION CAUGHT.\013"
;;

