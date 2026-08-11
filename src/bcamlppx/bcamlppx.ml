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
(* PPX rewriter for BreadCaml *)

open Ast_mapper

let self = Sys.argv.(0)
let bn_self = Filename.basename self

let usage () =
  Printf.printf
    "%s - The BreadCaml preprocessor.\n\
     Usage:\t%s <db_file> <in_file> <out_file>\n\
     \t%s -d|--dump <db_file>\n\
     \t%s -h|-help|--help\n\
     Read the AST from <in_file>, pre-process it using the <db_file> database\n\
     and save the resulting AST in <out_file>.\n\
     \n\
     Options:\n\
     \  -d, --dump <db_file>\n\
     \tshow the list of polymorphic variant renamings saved in <db_file>\n\
     \  -h, -help, --help\n\
     \tprint this message\n"
    bn_self bn_self bn_self bn_self

let ppx _argv =
  let m1 = PolyvarPPX.mapper in
  let m2 = PetsciiPPX.mapper in
  { default_mapper with
    expr = (fun mapper expr' -> m2.expr m2 (m1.expr m1 expr'));
    pat  = (fun mapper pat'  -> m2.pat  m2 (m1.pat  m1 pat'));
    typ  = (fun mapper typ'  -> m2.typ  m2 (m1.typ  m1 typ')) }

let () =
  match Sys.argv with
  | [| self; dbfile; infile; outfile |] ->
     let fd = Unix.(openfile dbfile [O_RDWR; O_CREAT] 0o666) in
     Unix.(lockf fd F_LOCK 0);
     begin (* critical section *)
       if Unix.((fstat fd).st_size) > 0 then
         PolyvarPPX.db_load (Unix.in_channel_of_descr fd);
       run_main (fun _ -> ppx [| self; infile; outfile |]);
       ignore Unix.(lseek fd 0 SEEK_SET);
       Unix.ftruncate fd 0;
       PolyvarPPX.db_save (Unix.out_channel_of_descr fd);
     end; (* critical section *)
     Unix.(lockf fd F_ULOCK 0);
     Unix.close fd
  | [| _; opt; dbfile |] when List.mem opt ["-d"; "--dump"] ->
     Unix.handle_unix_error
       (fun file -> 
         let fd = Unix.(openfile file [O_RDONLY; O_NONBLOCK] 0o666) in
         PolyvarPPX.db_dump (Unix.in_channel_of_descr fd) stdout;
         Unix.close fd)
       dbfile
  | [| _; opt |] when List.mem opt ["-h"; "-help"; "--help"] ->
     usage ();
     exit 0
  | _ ->
     Printf.eprintf
       "Illegal option or argument in command line:\n«%s»\n\n%!"
       (String.concat " " (Array.to_list Sys.argv));
     usage ();
     exit 1
