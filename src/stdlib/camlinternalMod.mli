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
(*          Xavier Leroy, projet Cristal, INRIA Rocquencourt              *)
(*                                                                        *)
(*   Copyright 2004 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Run-time support for recursive modules.
    All functions in this module are for system use only, not for the
    casual user. *)

type shape =
  | Function
  | Lazy
(*--
  | Class
--*)
  | Module of shape array
  | Value of Obj.t

val init_mod: string * int * int -> shape -> Obj.t
val update_mod: shape -> Obj.t -> Obj.t -> unit
