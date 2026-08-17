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

(* Module [Int64]: 64-bit integers *)

external neg : int64 -> int64 = "%int64_neg"
external add : int64 -> int64 -> int64 = "%int64_add"
external sub : int64 -> int64 -> int64 = "%int64_sub"
external mul : int64 -> int64 -> int64 = "%int64_mul"
(*--
external div : int64 -> int64 -> int64 = "%int64_div"
external rem : int64 -> int64 -> int64 = "%int64_mod"
--*)
external logand : int64 -> int64 -> int64 = "%int64_and"
external logor : int64 -> int64 -> int64 = "%int64_or"
external logxor : int64 -> int64 -> int64 = "%int64_xor"
external shift_left : int64 -> int -> int64 = "%int64_lsl"
external shift_right : int64 -> int -> int64 = "%int64_asr"
external shift_right_logical : int64 -> int -> int64 = "%int64_lsr"
external of_int : int -> int64 = "%int64_of_int"
external to_int : int64 -> int = "%int64_to_int"
external of_float : float -> int64
  = "caml_int64_of_float" "caml_int64_of_float_unboxed"
  [@@unboxed] [@@noalloc]
external to_float : int64 -> float
  = "caml_int64_to_float" "caml_int64_to_float_unboxed"
  [@@unboxed] [@@noalloc]
external of_int32 : int32 -> int64 = "%int64_of_int32"
external to_int32 : int64 -> int32 = "%int64_to_int32"
(*--
external of_nativeint : nativeint -> int64 = "%int64_of_nativeint"
external to_nativeint : int64 -> nativeint = "%int64_to_nativeint"
--*)
(*++ *)
let div n m = of_float (to_float n /. to_float m)
let rem n m = sub n (mul (div n m) m)
(* ++*)

let zero = 0L
let one = 1L
let minus_one = -1L
let succ n = add n 1L
let pred n = sub n 1L
let abs n = if n >= 0L then n else neg n
let min_int = 0x8000000000000000L
let max_int = 0x7FFFFFFFFFFFFFFFL
let lognot n = logxor n (-1L)

(*--
let unsigned_to_int =
  let max_int = of_int Stdlib.max_int in
  fun n ->
    if compare zero n <= 0 && compare n max_int <= 0 then
      Some (to_int n)
    else
      None

external format : string -> int64 -> string = "caml_int64_format"
let to_string n = format "%d" n
external of_string : string -> int64 = "caml_int64_of_string"
--*)
(*++ *)
let unsigned_to_int n =
  let n = to_int (logand n 0x7FFFL) in
  if n >= 0 then Some n else None

external unsafe_char_of_int : int -> char = "%identity"

let to_string n =
  let str = Bytes.create 20 in
  let rec f i k =
    if k < 10L then
      (Bytes.set str i (unsafe_char_of_int (to_int k + int_of_char '0'));
       i)
    else
      (Bytes.set str i (unsafe_char_of_int (to_int (rem k 10L) + int_of_char '0'));
       f (i - 1) (div k 10L)) in
  if n >= zero then
    let b = f 19 n in Bytes.sub_string str b (20 - b)
  else if n = min_int then
    let _ = f 19 max_int in
    Bytes.set str 19 '8';
    Bytes.set str 0 '-';
    Bytes.unsafe_to_string str
  else
    let b = f 19 (neg n) - 1 in
    Bytes.set str b '-';
    Bytes.sub_string str b (20 - b)

let of_string s =
  let fail_if cond = if cond then failwith "Int64.of_string" in
  let len = String.length s in
  let rec gen_conv f i acc =
    if i = len then acc
    else gen_conv f (i + 1) (f acc (String.get s i)) in
  let dec i =
    let dec_conv acc c =
      let ofs = match c with
        | '0' .. '9' -> int_of_char c - int_of_char '0'
        | _ -> fail_if true; 0 in
      let acc10 = mul acc 10L in
      let res = add acc10 (of_int ofs) in
      fail_if ((div acc10 10L) <> acc || (sub res one) < minus_one);
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
               fail_if (shift_right_logical acc 60 <> zero);
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
               fail_if (shift_right_logical acc 61 <> zero);
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
               | _ -> fail_if true; 0L in
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

external bits_of_float : float -> int64
  = "caml_int64_bits_of_float" "caml_int64_bits_of_float_unboxed"
  [@@unboxed] [@@noalloc]
external float_of_bits : int64 -> float
  = "caml_int64_float_of_bits" "caml_int64_float_of_bits_unboxed"
  [@@unboxed] [@@noalloc]

type t = int64

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
