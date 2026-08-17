(* Show info *)
let show = function
  | Cmdline.Where ->  print_endline Config.libdir
  | Cmdline.Ocamlc -> print_endline Config.ocamlc
  | Cmdline.Acme ->   print_endline Config.acme
  | Cmdline.Version ->
     let comp_desc = match Filename.basename Sys.argv.(0) with
       | "bcamlopt" -> "native code"
       | "bcamlc"   -> "bytecode"
       | _ -> failwith "unknown compiler!" in
     Printf.printf
       "The OCaml %s compiler for the Commodore C64, version %s\n%!"
       comp_desc Config.version

(* Sys.command wrapper *)
let sys_command ~verbose ~command =
  if verbose then
    Printf.printf "BreadCaml> Executing: '%s'\n%!" command;
  match Sys.command command with
  | 0 -> ()
  | n -> Printf.eprintf
           "BreadCaml> Error: '%s' exited with status code %u.\n%!" command n;
         raise Exit

(* Sys.remove wrapper *)
let sys_remove file =
  try Sys.remove file
  with _ -> Printf.printf "BreadCaml> Warning: file '%s' not removed\n%!" file

(* Run ocamlc *)
let ocamlc ?bytefile ~verbose cmdline =
  match bytefile with
  | None ->
     sys_command ~verbose ~command:cmdline
  | Some file ->
     sys_command ~verbose ~command:(cmdline ^ " -o " ^  Filename.quote file)

(* Run acme *)
let acme ~verbose ~asmfile cmdline =
  sys_command ~verbose ~command:(cmdline ^ " " ^ Filename.quote asmfile)


(* Main *)
let () = match Cmdline.parse () with
  | Show info -> show info
  | Compileonly { ocamlc_cmdline; verbose } ->
     ocamlc ocamlc_cmdline ~verbose
  | Fullprocess { ocamlc_cmdline; acme_cmdline; prgfile;
                  top_of_mem; stack_pages; externs; verbose } ->
     let asmfile  = Filename.temp_file ~temp_dir:"." prgfile ".asm~" in
     let bytefile = Filename.temp_file ~temp_dir:"." prgfile ".bc~" in
     let rm files = List.iter sys_remove files in
     try 
       ocamlc ~bytefile ~verbose ocamlc_cmdline;
       Export.export
         ~bytefile ~asmfile ~stack_pages ~top_of_mem ~prgfile ~externs;
       acme ~asmfile ~verbose acme_cmdline;
       rm [asmfile; bytefile]
     with
     | Sys_error err ->
        Printf.eprintf "BreadCaml> Sys_error: %s\n%!" err;
        rm [asmfile; bytefile];
        exit 1
     | Exit ->
        rm [asmfile; bytefile];
        exit 1
