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
(*         Gabriel Scherer, projet Parsifal, INRIA Saclay                 *)
(*                                                                        *)
(*   Copyright 2019 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

type ('a, 'b) t = Left of 'a | Right of 'b

let left v = Left v
let right v = Right v

let is_left = function
| Left _ -> true
| Right _ -> false

let is_right = function
| Left _ -> false
| Right _ -> true

let find_left = function
| Left v -> Some v
| Right _ -> None

let find_right = function
| Left _ -> None
| Right v -> Some v

let map_left f = function
| Left v -> Left (f v)
| Right _ as e -> e

let map_right f = function
| Left _ as e -> e
| Right v -> Right (f v)

let map ~left ~right = function
| Left v -> Left (left v)
| Right v -> Right (right v)

let fold ~left ~right = function
| Left v -> left v
| Right v -> right v

let iter = fold

let for_all = fold

let equal ~left ~right e1 e2 = match e1, e2 with
| Left v1, Left v2 -> left v1 v2
| Right v1, Right v2 -> right v1 v2
| Left _, Right _ | Right _, Left _ -> false

let compare ~left ~right e1 e2 = match e1, e2 with
| Left v1, Left v2 -> left v1 v2
| Right v1, Right v2 -> right v1 v2
| Left _, Right _ -> (-1)
| Right _, Left _ -> 1
