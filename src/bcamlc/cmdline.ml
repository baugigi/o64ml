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
(* SYNOPSIS:
   command [-o outfile] [OPTIONS] [OCAMLC_OPTIONS] FILE... [-- [ACME_OPTIONS]]
   command -c [OCAMLC_OPTIONS] FILE...
   command (-where|-ocamlc|-acme|-version|-help|--help)
   OPTIONS:[-db dbfile][-mem address][-stack npages][-showmem][-verbose]
 *)

(* Some useful operators *)
let ( ^+ ) s1 s2 = s1 ^ " " ^ s2        (* "str1" ^+ "str2" is "str1 str2" *)
let ( => ) b1 b2 = b2 || not b1         (* logical implication *)




(* The type for the result of command line parsing *)
type t =
  | Fullprocess of fullprocess_t        (* no -c option *)
  | Compileonly of compileonly_t        (* -c option *)
  | Show of show_t                      (* -where, -ocamlc, -acme, -version *)
and fullprocess_t =
  { ocamlc_cmdline : string;
    acme_cmdline   : string;
    prgfile        : string;
    top_of_mem     : int;
    stack_pages    : int;
    externs        : string list;
    verbose        : bool }
and compileonly_t =
  { ocamlc_cmdline : string;
    verbose        : bool }
and show_t = Where | Ocamlc | Acme | Version

(* Default values for options, option arguments, and file type flags *)
let compile_only = ref false
let o_arg        = ref ""
let db_arg       = ref ""
let mem_arg      = ref 0x9FFF
let stack_arg    = ref 4
let showmem      = ref false
let verbose      = ref false
let input_files  = ref []
let ocamlc_opts  = ref []
let show_opt     = ref None
let ml, mli, cmo, asm = ref false, ref false, ref false, ref false

(* Set comp_desc and acme_opts according to the compiler name *)
let comp_desc, acme_opts = match Filename.basename Sys.argv.(0) with
  | "bcamlopt" -> "native code", ref []
  | "bcamlc"   -> "bytecode",    ref ["-Dcaml_INTERP=1"]
  | unknown    -> Printf.eprintf "Unknown compiler: %s\n%!" unknown; exit 1

(* Treat anonymous arguments as input FILEs or OCAMLC_OPTIONS *)
let anon_fun arg = match Filename.extension arg with
  | ".ml"  -> ml  := true; input_files := arg :: !input_files
  | ".mli" -> mli := true; input_files := arg :: !input_files
  | ".cmo" -> cmo := true; input_files := arg :: !input_files
  | ".asm" -> asm := true; input_files := arg :: !input_files
  | _ -> ocamlc_opts := arg :: !ocamlc_opts

(* Treat all options following '--' as ACME_OPTIONS *)
let rest_all args = acme_opts := !acme_opts @ args

(* -where, -ocamlc, -acme, -version: the early bird gets the worm. *)
let show info () = match !show_opt with
  | None -> show_opt := Some info
  | _ -> ()

(* Usage message *)
let usage =
  let me = Sys.argv.(0) in
  Printf.sprintf
    ("Usage:\n\
      %s [-o outfile] [OPTIONS] [OCAMLC_OPTS] FILE... [-- [ACME_OPTS]]\n\
      %s -c [OCAMLC_OPTS] FILE...\n\
      %s (-where|-ocamlc|-acme|-version|-help|--help )\n\
      \n\
      Compile and links the given FILEs into a standalone %s executable\n\
      file for Commodore 64 computers.\n\
      See also <https://github/baugigi/breadcaml> and the %s(1) man page.\n\
      \n\
      FILE type is determined by extension:\n\
      \  .ml:  OCaml compilation unit, implementation source code\n\
      \  .mli: OCaml compilation unit, interface source code\n\
      \  .cmo: OCaml compiled bytecode\n\
      \  .cma: OCaml bytecode library\n\
      \  .c:   C source code\n\
      \  .o:   C object code\n\
      \  .asm: ACME assembly source code\n\n\
      Options:")
    me me me comp_desc (Filename.basename me)

(* Arg.(key * spec * doc) list for Arg.align and Arg.parse *)
let speclist =
  let nl_tab s = "\n" ^ String.make 18 ' ' ^ s in
  Arg.[
      "-o", Set_string o_arg,
      "<outfile>"
      ^ " Specify the name of the output file. If the -o option is not"
      ^ nl_tab "present, <outfile> defaults to the last FILE specified,"
      ^ nl_tab "without its extension (if present), and ‘.prg’ appended."
    ; 
      "-c", Set compile_only,
      " Compile only: run ocamlc with [OCAMLC_OPTIONS] on given FILEs."
      ^ nl_tab "The -c and -o options are incompatible."
    ;
      "-mem", Set_int mem_arg,
      "<address>"
      ^ " Set the maximum available memory address for the executable."
      ^ nl_tab (Printf.sprintf "Default: %#4x (%5d)." !mem_arg !mem_arg)
    ;
      "-stack", Set_int stack_arg,
      "<pages>"
      ^ " Define the stack size, in 256-byte pages."
      ^ nl_tab (Printf.sprintf "Default: %d pages." !stack_arg)
    ;
      "-showmem", Set showmem,
      " Show information on memory allocation."
    ;
      "-db", Set_string db_arg,
      "<dbfile>"
      ^ " Set the pathname for the BreadCaml preprocessor database. If the"
      ^ nl_tab "-db option is not present, <dbfile> defaults to <outfile>,"
      ^ nl_tab "without its extension (if present), and ‘.db’ appended."
    ;
      "-verbose", Set verbose,
      " Verbose mode."
    ;
      "-where", Unit (show Where),
      " Show the location of the BreadCaml standard library and exit."
    ;
      "-ocamlc", Unit (show Ocamlc),
      " Show the location of the OCaml bytecode compiler and exit."
    ;
      "-acme", Unit (show Acme),
      " Show the location of the ACME cross-assembler and exit."
    ;
      "-version", Unit (show Version),
      " Show version and exit."
    ;
      "--", Rest_all rest_all,
      "ACME_OPTIONS Pass the options following ‘--’ to acme.\n"
      ^ "  OCAMLC_OPTIONS  Pass any options not listed above to ocamlc."
  ]

(* Add to ocamlc_opts any options not listed above and not following '--' *)
let rec dyn_add_ocamlc_opts i accu =
  let nargs = Array.length Sys.argv in
  if i = nargs then accu
  else
    match Sys.argv.(i) with
    | "--" | "-help" | "--help" -> accu
    | opt when opt.[0] = '-'
               && not (List.exists (fun (o, _, _) -> o = opt) speclist) ->
       let add opt () = ocamlc_opts := opt :: !ocamlc_opts in
       dyn_add_ocamlc_opts (succ i) ((opt, Arg.Unit(add opt), "") :: accu)
    | _ ->
       dyn_add_ocamlc_opts (succ i) accu

(* Check all arguments according to a checklist *)
let check_args () =
  let missing = List.filter (fun f -> not (Sys.file_exists f)) !input_files in
  let check (cond, err) = if not cond then failwith err in
  let checklist =
    [| (* condition to check, error message when condition is false *)
      !input_files <> [], "no input file specified.";
      missing = [], "file(s) ‘" ^ String.concat "’, ‘" missing ^ "’ not found.";
      !stack_arg > 0, "-stack argument must be greater than 0.";
      0x1000 <= !mem_arg && !mem_arg < 0xD000, "-mem argument out of range.";
      !compile_only => not !asm, ".asm files not allowed with the -c option.";
      !compile_only => not !cmo, ".cmo files not allowed with the -c option.";
      !compile_only => (!o_arg = ""), "options -c and -o are incompatible.";
      !compile_only => (!ml || !mli), "no .ml or .mli files specified.";
      not !compile_only => (!ml || !cmo), "no .ml or .cmo files specified.";
    |] in
  try Array.iter check checklist
  with Failure err ->
    let me = Sys.argv.(0) in
    Printf.eprintf
      "Error: %s\nTry ‘%s -help’ or ‘man %s’ for more info.\n%!" err me me;
    exit 1

(* Main *)
let parse () =
  let specs () = dyn_add_ocamlc_opts 1 speclist in
  Arg.parse (Arg.align (specs ())) anon_fun usage;
  match !show_opt with
  | Some info -> Show info
  | None ->
     check_args ();    
     let last_file =
       Filename.remove_extension (List.hd !input_files (* cannot fail *) ) in
     ocamlc_opts := List.rev !ocamlc_opts;
     input_files := List.rev !input_files;
     let dbfile = match !db_arg, !o_arg with
       | "", "" -> last_file ^ ".db"
       | "", o_arg -> (Filename.remove_extension o_arg) ^ ".db"
       | _ , _  -> !db_arg in
     let externs, ocamlc_files =
       List.partition (fun f -> Filename.check_suffix f ".asm") !input_files in
     let ocamlc_cmdline =
       "CAMLLIB=" ^ Filename.quote Config.libdir
       ^+ Filename.quote Config.ocamlc
       ^+ "-custom"
       ^+ (if !verbose then "-verbose" else "")
       ^+ (if !compile_only then "-c" else "")
       ^+ "-ppx"
       ^+ Filename.quote (Config.bindir ^ "/bcamlppx" ^+ dbfile)
       ^+ String.concat " "
            (!ocamlc_opts @ List.map Filename.quote ocamlc_files) in
     if !compile_only then Compileonly { ocamlc_cmdline; verbose = !verbose }
     else
       let prgfile = if !o_arg = "" then last_file ^ ".prg" else !o_arg in
       let acme_cmdline =
         Filename.quote Config.acme
         ^+ (if !showmem then "-Dcaml_SHOWMEM=1" else "")
         ^+ (if !verbose then "-v9" else "")
         ^+ String.concat " " !acme_opts in
       Fullprocess { ocamlc_cmdline; acme_cmdline; prgfile; externs;
                     top_of_mem  = !mem_arg; stack_pages = !stack_arg;
                     verbose = !verbose }


