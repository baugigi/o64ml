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

let clean code =
  let f i bc =
    match bc with
      | BRANCH ptr | BRANCHIF ptr | BRANCHIFNOT ptr | COMPBRANCH (_, _, ptr) ->
        if ptr = i + 1 then code.(i) <- Step1.nop;
      | _ -> ()
  in
  Array.iteri f code;
;;
