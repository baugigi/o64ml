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
let a = "dl{RED}aàs"
let b = "{CLR}ciao" ^ a
let c = 'a'
let d = b ^ "{RVSOFF}"
let e = b ^ [%ascii "{RVSOFF}"]
let f = function
| [%ascii "{CLR}gigi"] -> 1
| "{CLR}gigi" -> 2
| _ -> 0

