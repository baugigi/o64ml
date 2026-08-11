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

let number = 8
let rec fact_rec n = match n with
  | 0 | 1 -> 1
  | _ -> n * (fact_rec (pred n))
let rec fact_tail n accu = match n with
  | 0 | 1 -> accu
  | _ -> fact_tail (pred n) (n * accu)
let rec fact_cont n k = match n with
  | 0 | 1 -> k 1
  | _ -> fact_cont (pred n) (fun x -> (n * x)) |> k
let fact_iter n =
  let r = ref 1 in
  for i = 1 to n do
    r := !r * i
  done;
  !r

let _ =
  print_int (fact_rec number);
  print_newline ();
  print_int (fact_tail number 1);
  print_newline ();
  print_int (fact_cont number (fun x -> x));
  print_newline ();
  print_int (fact_iter number);
  print_newline ();
