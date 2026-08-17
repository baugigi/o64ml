open OByteLib.Instr

let opc_of = function
  (* stack *)
  | ACC0 -> 0 | ACC1 -> 1 | ACC2 -> 2 | ACC3 -> 3 | ACC4 -> 4 | ACC5 -> 5
  | ACC6 -> 6 | ACC7 -> 7 | ACC _ -> 8 | PUSH -> 9  | POP _ -> 19
  | ASSIGN _ -> 20
  (* environment *)
  | ENVACC1 -> 21 | ENVACC2 -> 22 | ENVACC3 -> 23 | ENVACC4 -> 24
  | ENVACC _ -> 25
  (* closures *)
  | PUSH_RETADDR _ -> 31 | APPLY _ -> 32 | APPLY1 -> 33 | APPLY2 -> 34
  | APPLY3 -> 35 | APPTERM (_, _) -> 36 | APPTERM1 _ -> 37 | APPTERM2 _ -> 38
  | APPTERM3 _ -> 39 | RETURN _ -> 40 | RESTART -> 41 | GRAB _ -> 42
  | CLOSURE (_, _) -> 43 | CLOSUREREC (_, _, _, _) -> 44 | OFFSETCLOSUREM2 -> 45
  | OFFSETCLOSURE0 -> 46 | OFFSETCLOSURE2 -> 47 | OFFSETCLOSURE _ -> 48
  (* globals *)
  | GETGLOBAL _ -> 53 | GETGLOBALFIELD (_, _) -> 55 | SETGLOBAL _ -> 57
  (* blocks *)
  | ATOM0 -> 58 | ATOM _ -> 59 | MAKEBLOCK (_, _) -> 62 | MAKEBLOCK1 _ -> 63
  | MAKEBLOCK2 _ -> 64 | MAKEBLOCK3 _ -> 65 | GETFIELD0 -> 67 | GETFIELD1 -> 68
  | GETFIELD2 -> 69 | GETFIELD3 -> 70 | GETFIELD _ -> 71 | SETFIELD0 -> 73
  | SETFIELD1 -> 74 | SETFIELD2 -> 75 | SETFIELD3 -> 76 | SETFIELD _ -> 77
  (* arrays *)
  | VECTLENGTH -> 79 | GETVECTITEM -> 80 | SETVECTITEM -> 81
  (* float arrays *)
  | MAKEFLOATBLOCK _ -> 66 | GETFLOATFIELD _ -> 72 | SETFLOATFIELD _ -> 78
  (* bytes/strings *)
  | GETBYTESCHAR -> 82 | SETBYTESCHAR -> 83 | GETSTRINGCHAR -> 148
  (* exceptions *)
  | PUSHTRAP _ -> 89 | POPTRAP -> 90 | RAISE -> 91 | RERAISE -> 146
  | RAISE_NOTRACE -> 147
  (* externals *)
  | C_CALL1 _ -> 93 | C_CALL2 _ -> 94 | C_CALL3 _ -> 95 | C_CALL4 _ -> 96
  | C_CALL5 _ -> 97 | C_CALLN (_, _) -> 98
  (* constants *)
  | CONST0 -> 99 | CONST1 -> 100 | CONST2 -> 101 | CONST3 -> 102
  | CONSTINT _ -> 103
  (* arithm.-logical *)
  | BOOLNOT -> 88 | NEGINT -> 109 | ADDINT -> 110 | SUBINT -> 111
  | MULINT -> 112 | DIVINT -> 113 | MODINT -> 114 | ANDINT -> 115
  | ORINT -> 116 | XORINT -> 117 | LSLINT -> 118 | LSRINT -> 119 | ASRINT -> 120
  | EQ -> 121 | NEQ -> 122 | LTINT -> 123 | LEINT -> 124 | GTINT -> 125
  | GEINT -> 126 | OFFSETINT _ -> 127 | OFFSETREF _ -> 128 | ISINT -> 129
  | ULTINT -> 137 | UGEINT -> 138
  (* branches *)
  | BRANCH _ -> 84 | BRANCHIF _ -> 85 | BRANCHIFNOT _ -> 86
  | SWITCH (_, _) -> 87 | BEQ (_, _) -> 131 | BNEQ (_, _) -> 132
  | BLTINT (_, _) -> 133 | BLEINT (_, _) -> 134 | BGTINT (_, _) -> 135
  | BGEINT (_, _) -> 136 | BULTINT (_, _) -> 139 | BUGEINT (_, _) -> 140
  (* objects *)
  | GETMETHOD -> 130  | GETPUBMET (_, _) -> 141 | GETDYNMET -> 142
  (* PUSH- combined *)
  | PUSHACC0 -> 10 | PUSHACC1 -> 11 | PUSHACC2 -> 12 | PUSHACC3 -> 13
  | PUSHACC4 -> 14 | PUSHACC5 -> 15 | PUSHACC6 -> 16 | PUSHACC7 -> 17
  | PUSHACC _ -> 18 | PUSHENVACC1 -> 26 | PUSHENVACC2 -> 27 | PUSHENVACC3 -> 28
  | PUSHENVACC4 -> 29 | PUSHENVACC _ -> 30 | PUSHOFFSETCLOSUREM2 -> 49
  | PUSHOFFSETCLOSURE0 -> 50 | PUSHOFFSETCLOSURE2 -> 51
  | PUSHOFFSETCLOSURE _ -> 52 | PUSHGETGLOBAL _ -> 54
  | PUSHGETGLOBALFIELD (_, _) -> 56 | PUSHATOM0 -> 60 | PUSHATOM _ -> 61
  | PUSHCONST0 -> 104 | PUSHCONST1 -> 105 | PUSHCONST2 -> 106
  | PUSHCONST3 -> 107 | PUSHCONSTINT _ -> 108
  (* halt/debug/misc. *)
  | CHECK_SIGNALS -> 92 | STOP -> 143 | EVENT -> 144 | BREAK -> 145

type instr_arg =
  | Num of int
  | Ptr of int
  | Ptrs of int array

let lbl_fmt = format_of_string "caml_%04x"
let opc_fmt = format_of_string "+i%02x"
let arg_fmt = format_of_string "%d"
let cmd_sep = ":"
let arg_sep = ","
let cmdarg_sep = " "
let tab = 10
let max_col = 80
let col = ref 0

let (~%) f x y = f y x
let (#%) fold f = ~%(fold ~%f)
let (^...) str1 str2 =
  let spaces = String.(make (max 1 (tab - length str1)) ' ') in
  str1 ^ spaces ^ str2

let str_of_arg = function
  | Num n -> Printf.sprintf arg_fmt n
  | Ptr p -> Printf.sprintf lbl_fmt p
  | Ptrs ps ->
     let args = Array.(to_list (map (Printf.sprintf lbl_fmt) ps)) in
     "[" ^ String.concat arg_sep args ^ "]"

let str_of_lbl label = Printf.sprintf lbl_fmt label

let emit_asm oc label instr args =
  let args_str = String.concat arg_sep (List.map str_of_arg args) in
  let cmd = Printf.sprintf opc_fmt (opc_of instr)
            ^ if args_str = "" then "" else cmdarg_sep ^ args_str in
  let len_cmd = String.length cmd in
  match label with
  | Some lbl ->
     output_string oc ("\n" ^ str_of_lbl lbl ^... cmd);
     col := tab + len_cmd
  | None ->
     let new_col = !col + String.length arg_sep + len_cmd in
     if new_col <= max_col
     then (output_string oc (cmd_sep ^ cmd);
           col := new_col)
     else (output_string oc ("\n" ^ "" ^... cmd);
           col := tab + len_cmd)

let export oc code =
  let module AdrSet = Set.Make(Int) in
  let pointers =
    let init = AdrSet.add 0 AdrSet.empty in
    let add_ptrs instr =
      List.fold_left #% AdrSet.add (get_ptrs instr) in
    Array.fold_left #% add_ptrs code init in
  let export_lbl_instr adr instr =
    let label = if AdrSet.mem adr pointers then Some adr else None in
    match instr with
    | ACC n | APPLY n | ASSIGN n | CONSTINT n | ENVACC n | GETFIELD n
      | GETFLOATFIELD n | GETGLOBAL n | GRAB n | OFFSETCLOSURE n
      | OFFSETINT n | OFFSETREF n | POP n | PUSHACC n | PUSHCONSTINT n
      | PUSHENVACC n | PUSHGETGLOBAL n | PUSHOFFSETCLOSURE n | RETURN n
      | SETFIELD n | SETFLOATFIELD n | SETGLOBAL n | APPTERM1 n
      | APPTERM2 n | APPTERM3 n | ATOM n | MAKEBLOCK1 n | MAKEBLOCK2 n
      | MAKEBLOCK3 n | PUSHATOM n | MAKEFLOATBLOCK n | C_CALL1 n
      | C_CALL2 n | C_CALL3 n | C_CALL4 n | C_CALL5 n ->
       emit_asm oc label instr [Num n]
    | BRANCH ptr | BRANCHIF ptr | BRANCHIFNOT ptr | PUSHTRAP ptr
      | PUSH_RETADDR ptr ->
       emit_asm oc label instr [Ptr ptr]
    | BEQ (n, ptr) | BGEINT (n, ptr) | BGTINT (n, ptr) | BLEINT (n, ptr)
      | BLTINT (n, ptr) | BNEQ (n, ptr) | BUGEINT (n, ptr) | BULTINT (n, ptr)
      | CLOSURE (n, ptr) ->
       emit_asm oc label instr [Num n; Ptr ptr]
    | APPTERM (n, m) | MAKEBLOCK (n, m) | C_CALLN (n, m)
      | GETGLOBALFIELD (n, m) | PUSHGETGLOBALFIELD (n, m) ->
       emit_asm oc label instr [Num n; Num m]
    | GETPUBMET (tag, _) ->
       emit_asm oc label instr [Num (tag land 0x7FFF)]
    | SWITCH (n, ptrs) ->
       emit_asm oc label instr [Num (n land 0xFFFF); Ptrs ptrs]
    | CLOSUREREC (f, v, o, t) ->
       emit_asm oc label instr [Num f; Num v; Ptr o; Ptrs t]
    | _instr_with_no_args_ ->
       emit_asm oc label instr [] in
  output_string oc "\ncaml_program\n";
  Array.iteri export_lbl_instr code;
  output_string oc "\ncaml_program_end\n"
