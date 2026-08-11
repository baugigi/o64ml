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

exception Exn of string

let parse ic index =
  let (offset, _) =
    try
      OByteLib.Index.find_section index OByteLib.Section.DATA
    with Not_found ->
      raise (Exn "code section not found")
  in
  seek_in ic offset;
  let (data : Obj.t array) = input_value ic in
  data
;;

let clean code orig_data =
  let nb_data = Array.length orig_data in
  let nb_instr = Array.length code in
  let map = Array.make nb_data None in
  let invmap = Array.make nb_data 0 in
  let counter = ref 12 in
  let remap p =
    match map.(p) with
      | None ->
        let new_p = !counter in
        counter := succ new_p;
        map.(p) <- Some new_p;
        invmap.(new_p) <- p;
        new_p
      | Some new_p -> new_p
  in
  for i = 0 to !counter - 1 do
    map.(i) <- Some i;
    invmap.(i) <- i;
  done;
  for i = 0 to nb_instr - 1 do
    match code.(i) with
      | GETGLOBAL p -> code.(i) <- GETGLOBAL (remap p);
      | _ -> ()
  done;
  for i = 0 to nb_instr - 1 do
    match code.(i) with
      | SETGLOBAL p ->
        begin match map.(p) with
          | None -> code.(i) <- Step1.nop;
          | Some new_p -> code.(i) <- SETGLOBAL new_p;
        end
      | _ -> ()
  done;
  let new_data = Array.init !counter (fun p -> orig_data.(invmap.(p))) in
  new_data
;;

let export oc data =
  output_value oc data;
;;
