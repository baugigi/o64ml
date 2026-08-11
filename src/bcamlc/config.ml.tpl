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
(* If this file is named 'config.ml' then it has been created by 'make':
   edit 'config.ml.tpl' instead. *)

let header_includes	= ["c64defs.asm"]
let pre_code_includes	= ["loader.asm"; "codegen.asm"]
let post_code_includes	= ["runtime.asm"; "memory.asm"; "stdlib.asm"]
let trailer_includes	= ["showmem.asm"]

(* Auto-generated lines below this point *)

