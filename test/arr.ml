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

open Array
let _ = Random.self_init ()
let a = init Sys.max_array_length
          (fun _ -> char_of_int(Random.bits() land 0xff))
let print a =
  iteri
    (fun i x ->
      print_int i;
      print_string {| = "\|};
      let s = "00" ^ (string_of_int (int_of_char x)) in
      print_string String.(sub s (length s - 3) 3);
      print_endline {|"|})
    a
let cmp a b =
  if a < b then -1 else if a > b then 1 else 0
;;
print a;
sort cmp a;
print a;

(* se si usa cmp = compare, il sort non avviene: compare BUGgata! *)
(* se si usa fast_sort, il programma termina improvvisamente: BUG dove? *)
