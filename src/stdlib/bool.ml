(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCaml Core System - Stdlib          (C) 1996 INRIA - https://ocaml.org

   Modifiche/Modifications: 21-Apr-2026 Piero Furiesi

   Questo file  è distribuito con  licenza GNU LGPL 2.1,  con l’eccezione
   riportata nel file LICENSE (in  inglese).  Il codice originale rimosso
   o sostituito  è incluso tra (*--  e --*); (*++ e  ++*) identificano le
   aggiunte, {i {b BreadCaml Note} testo… } i nuovi commenti di OCamldoc.

   This file  is distributed  under the  GNU LGPL  2.1 license,  with the
   exception stated in the LICENSE  file. (*-- and --*) indicate original
   code that has been removed/replaced; (*++ and ++*) indicate additions;
   {i {b BreadCaml Note} text…  } indicates new OCamldoc comments.
   —————————————————————————————————————————————————————————————————————— *)
(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*                         The OCaml programmers                          *)
(*                                                                        *)
(*   Copyright 2018 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

type t = bool = false | true

external not : bool -> bool = "%boolnot"
external ( && ) : bool -> bool -> bool = "%sequand"
external ( || ) : bool -> bool -> bool = "%sequor"
let equal : bool -> bool -> bool = ( = )
let compare : bool -> bool -> int = Stdlib.compare
external to_int : bool -> int = "%identity"
let to_float = function false -> 0. | true -> 1.

(*
let of_string = function
| "false" -> Some false
| "true" -> Some true
| _ -> None
*)

let to_string = function false -> "false" | true -> "true"
