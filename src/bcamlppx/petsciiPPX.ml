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
open Asttypes
open Parsetree
open Ast_mapper
open Ast_helper

let err_token = "invalid PETSCII token in string literal."
let err_ascii = "%%ascii: invalid payload."
let error ~loc err =
  extension_of_error (Location.errorf ~loc (Scanf.format_from_string err ""))

let expr_rewriter mapper expr = match expr.pexp_desc with
  | Pexp_extension({ txt = "ascii"; loc }, PStr[item]) ->
     (match item.pstr_desc with
      | Pstr_eval
        ({ pexp_desc = Pexp_constant(Pconst_string _ | Pconst_char _ as k) },
         attrs) ->
         Exp.constant ~loc ~attrs k
      | _ ->
         Exp.extension ~loc (error ~loc err_ascii))
  | Pexp_constant(Pconst_string(str, str_loc, delim)) ->
     (try
        Exp.constant ~loc:expr.pexp_loc ~attrs:expr.pexp_attributes
          (Pconst_string(Petscii.of_string str, str_loc, delim))
      with Invalid_argument _ ->
        Exp.extension ~loc:expr.pexp_loc (error ~loc:str_loc err_token))
  | Pexp_constant(Pconst_char ch) ->
     Exp.constant ~loc:expr.pexp_loc ~attrs:expr.pexp_attributes
       (Pconst_char(Petscii.of_char ch))
  | _ ->
     default_mapper.expr mapper expr

let pat_rewriter mapper pat = match pat.ppat_desc with
  | Ppat_extension({ txt = "ascii"; loc }, PStr[item]) ->
     (match item.pstr_desc with
      | Pstr_eval
        ({ pexp_desc = Pexp_constant(Pconst_string _ | Pconst_char _ as k) },
         attrs) ->
         Pat.constant ~loc ~attrs k
      | _ ->
         Pat.extension ~loc (error ~loc err_ascii))
  | Ppat_constant(Pconst_string(str, str_loc, delim)) ->
     (try
        Pat.constant ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
          (Pconst_string(Petscii.of_string str, str_loc, delim))
      with Invalid_argument _ ->
        Pat.extension ~loc:pat.ppat_loc (error ~loc:str_loc err_token))
  | Ppat_constant(Pconst_char ch) ->
     Pat.constant ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
       (Pconst_char(Petscii.of_char ch))
  | Ppat_interval(Pconst_char c1, Pconst_char c2) ->
     Pat.interval ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
       (Pconst_char(Petscii.of_char c1))
       (Pconst_char(Petscii.of_char c2))
  | _ ->
     default_mapper.pat mapper pat

let mapper =
  { default_mapper with
    expr = expr_rewriter;
    pat  = pat_rewriter }
