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
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Module [Int32]: 32-bit integers *)

external neg : int32 -> int32 = "%int32_neg"
external add : int32 -> int32 -> int32 = "%int32_add"
external sub : int32 -> int32 -> int32 = "%int32_sub"
external mul : int32 -> int32 -> int32 = "%int32_mul"
(*--
external div : int32 -> int32 -> int32 = "%int32_div"
external rem : int32 -> int32 -> int32 = "%int32_mod"
--*)
external logand : int32 -> int32 -> int32 = "%int32_and"
external logor : int32 -> int32 -> int32 = "%int32_or"
external logxor : int32 -> int32 -> int32 = "%int32_xor"
external shift_left : int32 -> int -> int32 = "%int32_lsl"
external shift_right : int32 -> int -> int32 = "%int32_asr"
external shift_right_logical : int32 -> int -> int32 = "%int32_lsr"
external of_int : int -> int32 = "%int32_of_int"
external to_int : int32 -> int = "%int32_to_int"
external of_float : float -> int32
  = "caml_int32_of_float" "caml_int32_of_float_unboxed"
  [@@unboxed] [@@noalloc]
external to_float : int32 -> float
  = "caml_int32_to_float" "caml_int32_to_float_unboxed"
  [@@unboxed] [@@noalloc]
external bits_of_float : float -> int32
  = "caml_int32_bits_of_float" "caml_int32_bits_of_float_unboxed"
  [@@unboxed] [@@noalloc]
external float_of_bits : int32 -> float
  = "caml_int32_float_of_bits" "caml_int32_float_of_bits_unboxed"
  [@@unboxed] [@@noalloc]

(*++ *)
let div n m = of_float (to_float n /. to_float m)
let rem n m = sub n (mul (div n m) m)
(* ++*)

let zero = 0l
let one = 1l
let minus_one = -1l
let succ n = add n 1l
let pred n = sub n 1l
let abs n = if n >= 0l then n else neg n
let min_int = 0x80000000l
let max_int = 0x7FFFFFFFl
let lognot n = logxor n (-1l)
(*--
let unsigned_to_int =
  match Sys.word_size with
  | 32 ->
      let max_int = of_int Stdlib.max_int in
      fun n ->
        if compare zero n <= 0 && compare n max_int <= 0 then
          Some (to_int n)
        else
          None
  | 64 ->
      (* So that it compiles in 32-bit *)
      let mask = 0xFFFF lsl 16 lor 0xFFFF in
      fun n -> Some (to_int n land mask)
  | _ ->
      assert false

external format : string -> int32 -> string = "caml_int32_format"
let to_string n = format "%d" n
external of_string : string -> int32 = "caml_int32_of_string"
--*)
(*++ *)
let unsigned_to_int n =
  let n = to_int (logand n 0x7FFFl) in
  if n >= 0 then Some n else None

external unsafe_char_of_int : int -> char = "%identity"
let to_string n =
  let str = Bytes.create 11 in
  let rec f i k =
    if k < 10l then
      (Bytes.set str i (unsafe_char_of_int (to_int k + int_of_char '0'));
       i)
    else
      (Bytes.set str i (unsafe_char_of_int
                          (to_int (rem k 10l) + int_of_char '0'));
       f (i - 1) (div k 10l)) in
  if n >= zero then let b = f 10 n in Bytes.sub_string str b (11 - b)
  else if n = min_int then
    let _ = f 10 max_int in
    Bytes.set str 10 '8';
    Bytes.set str 0 '-';
    Bytes.unsafe_to_string str
  else
    let b = f 10 (neg n) - 1 in
    Bytes.set str b '-';
    Bytes.sub_string str b (11 - b)

let of_string s =
  let fail_if cond = if cond then failwith "Int32.of_string" in
  let len = String.length s in
  let rec gen_conv f i acc =
    if i = len then acc
    else gen_conv f (i + 1) (f acc (String.get s i)) in
  let dec i =
    let dec_conv acc c =
      let ofs = match c with
        | '0' .. '9' -> int_of_char c - int_of_char '0'
        | _ -> fail_if true; 0 in
      let acc10 = mul acc 10l in
      let res = add acc10 (of_int ofs) in
      fail_if ((div acc10 10l) <> acc || (sub res one) < minus_one);
      res in
    gen_conv dec_conv i zero in
  let gen i = match String.get s i with
    | '0' ->
       if len = i + 1 then zero
       else
         (match String.get s (i + 1) with
          | 'x' | 'X' ->
             fail_if (len = i + 2);
             let hex_conv acc c =
               fail_if (shift_right_logical acc 28 <> zero);
               let ofs = match c with
                 | '0' .. '9' -> (int_of_char c - int_of_char '0')
                 | 'a' .. 'f' -> (int_of_char c - int_of_char 'a' + 10)
                 | 'A' .. 'F' -> (int_of_char c - int_of_char 'A' + 10)
                 | _ -> fail_if true; 0 in
               add (shift_left acc 4) (of_int ofs) in
             gen_conv hex_conv (i + 2) zero
          | 'o' | 'O' ->
             fail_if (len = i + 2);
             let oct_conv acc c =
               fail_if (shift_right_logical acc 29 <> zero);
               let ofs = match c with
                 | '0' .. '7' -> int_of_char c - int_of_char '0'
                 | _ -> fail_if true; 0 in
               add (shift_left acc 3) (of_int ofs) in
             gen_conv oct_conv (i + 2) zero
          | 'b' | 'B' ->
             fail_if (len = i + 2);
             let bin_conv acc c =
               fail_if (acc < zero);
               match c with
               | '0' -> shift_left acc 1
               | '1' -> add (shift_left acc 1) one
               | _ -> fail_if true; 0l in
             gen_conv bin_conv (i + 2) zero
          | _ -> dec (i + 1))
    | _ -> dec i in
  fail_if (len = 0);
  if String.get s 0 = '-' then (fail_if (len = 1); neg (gen 1))
  else gen 0
(* ++*)

let of_string_opt s =
  (* TODO: expose a non-raising primitive directly. *)
  try Some (of_string s)
  with Failure _ -> None

type t = int32

let compare (x: t) (y: t) = Stdlib.compare x y
let equal (x: t) (y: t) = compare x y = 0

let unsigned_compare n m =
  compare (sub n min_int) (sub m min_int)

let min x y : t = if x <= y then x else y
let max x y : t = if x >= y then x else y

(* Unsigned division from signed division of the same
   bitness. See Warren Jr., Henry S. (2013). Hacker's Delight (2 ed.), Sec 9-3.
*)
let unsigned_div n d =
  if d < zero then
    if unsigned_compare n d < 0 then zero else one
  else
    let q = shift_left (div (shift_right_logical n 1) d) 1 in
    let r = sub n (mul q d) in
    if unsigned_compare r d >= 0 then succ q else q

let unsigned_rem n d =
  sub n (mul (unsigned_div n d) d)
