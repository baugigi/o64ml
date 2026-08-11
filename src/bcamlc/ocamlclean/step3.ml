(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCamlclean       Benoît Vaugon - https://github.com/bvaugon/ocamlclean

   Questo file, originariamente distribuito con licenza CeCILL, è incluso
   nel Progetto Breadbin e, in accordo  con l'Art. 5.3.4 di detta licenza
   (vedere LICENSE-en, in  inglese, o LICENSE-fr, in  francese, in questa
   cartella), è ridistribuito con licenza GNU GPL versione 2.

   This  file,  originally  distributed  under  the  CeCILL  license,  is
   included in the Breadbin Project and, in accordance with Article 5.3.4
   of that license (see LICENSE-en, in English, or LICENSE-fr, in French,
   in this directory), is redistributed under the GNU GPL version 2.
   —————————————————————————————————————————————————————————————————————— *)
(*************************************************************************)
(*                                                                       *)
(*                              OCamlClean                               *)
(*                                                                       *)
(*                             Benoit Vaugon                             *)
(*                                                                       *)
(*    This file is distributed under the terms of the CeCILL license.    *)
(*    See file LICENSE-en.                                               *)
(*                                                                       *)
(*************************************************************************)

open OByteLib.Normalised_instr

let compute_used code =
  let nb_instr = Array.length code in
  let used = Array.make nb_instr false in
  let rec f i =
    if i < nb_instr && not used.(i) then (
      used.(i) <- true;
      match code.(i) with
        | BRANCH ptr ->
          f ptr
        | BRANCHIF ptr | BRANCHIFNOT ptr | COMPBRANCH (_, _, ptr)
        | PUSH_RETADDR ptr | CLOSURE (_, ptr) | PUSHTRAP ptr ->
          f (succ i);
          f ptr;
        | CLOSUREREC (_, ptrs) ->
          f (succ i);
          Array.iter f ptrs;
        | SWITCH (iptrs, pptrs) ->
          Array.iter f iptrs;
          Array.iter f pptrs;
        | GRAB _ -> f (pred i) ; f (succ i)
        | RETURN _ | APPTERM (_, _) | STOP | RAISE | RERAISE | RAISE_NOTRACE -> ()
        | _ ->
          f (succ i)
    )
  in
  f 0;
  used
;;

let clean_code code used =
  let nb_instr = Array.length code in
  for i = 0 to nb_instr - 1 do
    if not used.(i) then code.(i) <- Step1.nop;
  done
;;

let clean code =
  let used = compute_used code in
  clean_code code used;
;;
