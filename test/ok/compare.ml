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

let f = (+);;
let p1 = (1, f, [3; 4; 5]);;
let p1' = p1;;
let p2 = (1, f, [3; 4; 5]);;

let rec test = function
  | [] -> ()
  | (s, v)::rest ->
     print_string s;
     let s =
       try match v () with
           | true -> ": TRUE"
           | false -> ": FALSE"
       with _ -> ": EXCEPTION" in
     print_string s;
     print_newline ();
     test rest;;

let l = [
    "f == f", (fun _ -> f == f);
    "f = f", (fun _ -> f = f);
    "compare f f = 0", (fun _ -> compare f f = 0);
    "p1 == p1'", (fun _ -> p1 == p1');
    "p1 = p1'", (fun _ -> p1 = p1');
    "compare p1 p1' = 0", (fun _ -> compare p1 p1' = 0);
    "p1 == p2", (fun _ -> p1 == p2);
    "p1 = p2", (fun _ -> p1 = p2);
    "compare p1 p2 < 0", (fun _ -> compare p1 p2 < 0);
    "compare p1 p2 > 0", (fun _ -> compare p1 p2 > 0);
    "compare p1 p2 = 0", (fun _ -> compare p1 p2 = 0);
  ];;

print_string "\014";;
print_string "let f = (+);;\013let p1 = (1, f, [3; 4; 5]);;\013let p1' = p1;;\013let p2 = (1, f, [3; 4; 5]);;\013";;
test l;;
