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
open Printf

module Primitives = struct
  let export_used_prims ch prim =
    let l = Array.length prim in
    if l > 256 then failwith (sprintf "Too many primitives: %d > 256" l)
    else Array.iter (fprintf ch "caml_PRIM__%s = 1\n") prim
  let export_jumptable ch prim =
    output_string ch "caml_externals_lo\n";
    Array.iter (fprintf ch "\t!byte <(%s)\n") prim;
    output_string ch "caml_externals_hi\n";
    Array.iter (fprintf ch "\t!byte >(%s)\n") prim
end

module Includes = struct
  let source ch ?(dir = Config.libdir ^ "/") incl_list =
    List.iter (fprintf ch "!source \"%s%s\"\n" dir) incl_list
  let verbatim ch ?(dir = Config.libdir ^ "/") incl_list =
    let rec copy in_ch = 
      try output_string ch (input_line in_ch ^ "\n");
          copy in_ch
      with End_of_file -> close_in in_ch in
    List.iter (fun file -> copy (open_in (dir ^ file))) incl_list
end

module OCamlclean = struct
  let rec compress_loop (orig_code, prim, data) =
    let code = Step1.clean orig_code data in
    Step2.clean code prim;
    Step3.clean code;
    let data = Data.clean code data in
    Cleanbra.clean code;
    let code = Rmnop.clean code in
    if orig_code = code then (code, prim, data)
    else compress_loop (code, prim, data)
  let clean bytecode =
    let code, prim, data =
      OByteLib.(let to_obj = Value.make_to_obj () in
                Normalised_code.of_code bytecode.Bytefile.code,
                bytecode.prim,
                Array.map to_obj bytecode.data) in
    let code, prim, data = compress_loop (code, prim, data) in
    let code, data = Globalise.globalise_closures code data in
    let code, data = Cleanenvs.clean_environments code data in
    let code, prim, data = compress_loop (code, prim, data) in
    (code, Prim.clean code prim, data)
end

let export ~bytefile ~asmfile ~prgfile ~externs ~top_of_mem ~stack_pages =
  let stack_end = top_of_mem + (top_of_mem land 1) in
  let stack_start = 256 * ((stack_end lsr 8) - stack_pages) in
  try
    let ch = open_out_bin asmfile in
    fprintf ch
      ";; Created by BreadCaml - The OCaml Compiler for the Commodore 64\n\n\
       !to \"%s\", cbm\n\
       caml_stack_start = $%04x\n\
       caml_stack_end = $%04x\n\n"
      prgfile stack_start stack_end;
    Includes.source ch Config.header_includes;
    let bytecode = OByteLib.Bytefile.read bytefile in
    let code, prim, data = OCamlclean.clean bytecode in
    Primitives.export_used_prims ch prim;
    Includes.source ch Config.pre_code_includes;
    Opcodes.export ch (OByteLib.Normalised_code.to_code code);
    fprintf ch "\n";
    Includes.source ch ~dir:"" externs;
    Includes.source ch Config.post_code_includes;
    fprintf ch "!align $01, $00\n";
    Primitives.export_jumptable ch prim;
    Globals.export ch (Array.map OByteLib.Value.of_obj data);    
    fprintf ch
      "!if caml_stack_start < caml_glob_end {\n\
       \t!serious \"ERROR: Not enough memory for stack.\"\n\
       }\n";
    Includes.source ch Config.trailer_includes;
    close_out ch
  with Failure msg ->
    (try Sys.remove asmfile with _ -> ());
    eprintf "Error: %s\n%!" msg;
    exit 1
