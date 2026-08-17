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


(* Exceptions *)

(*--
external register_named_value : string -> 'a -> unit
                              = "caml_register_named_value"
let () =
  (* for runtime/fail_nat.c *)
  register_named_value "Pervasives.array_bound_error"
    (Invalid_argument "index out of bounds")
--*)

external raise : exn -> 'a = "%raise"
external raise_notrace : exn -> 'a = "%raise_notrace"

let failwith s = raise(Failure s)
let invalid_arg s = raise(Invalid_argument s)

exception Exit
exception Match_failure = Match_failure
exception Assert_failure = Assert_failure
exception Invalid_argument = Invalid_argument
exception Failure = Failure
exception Not_found = Not_found
exception Out_of_memory = Out_of_memory
exception Stack_overflow = Stack_overflow
exception Sys_error = Sys_error
exception End_of_file = End_of_file
exception Division_by_zero = Division_by_zero
exception Sys_blocked_io = Sys_blocked_io
exception Undefined_recursive_module = Undefined_recursive_module

(* Composition operators *)

external ( |> ) : 'a -> ('a -> 'b) -> 'b = "%revapply"
external ( @@ ) : ('a -> 'b) -> 'a -> 'b = "%apply"

(* Debugging *)

external __LOC__ : string = "%loc_LOC"
external __FILE__ : string = "%loc_FILE"
external __LINE__ : int = "%loc_LINE"
external __MODULE__ : string = "%loc_MODULE"
external __POS__ : string * int * int * int = "%loc_POS"
external __FUNCTION__ : string = "%loc_FUNCTION"

external __LOC_OF__ : 'a -> string * 'a = "%loc_LOC"
external __LINE_OF__ : 'a -> int * 'a = "%loc_LINE"
external __POS_OF__ : 'a -> (string * int * int * int) * 'a = "%loc_POS"

(* Comparisons *)

external ( = ) : 'a -> 'a -> bool = "%equal"
external ( <> ) : 'a -> 'a -> bool = "%notequal"
external ( < ) : 'a -> 'a -> bool = "%lessthan"
external ( > ) : 'a -> 'a -> bool = "%greaterthan"
external ( <= ) : 'a -> 'a -> bool = "%lessequal"
external ( >= ) : 'a -> 'a -> bool = "%greaterequal"
external compare : 'a -> 'a -> int = "%compare"

let min x y = if x <= y then x else y
let max x y = if x >= y then x else y

external ( == ) : 'a -> 'a -> bool = "%eq"
external ( != ) : 'a -> 'a -> bool = "%noteq"

(* Boolean operations *)

external not : bool -> bool = "%boolnot"
external ( & ) : bool -> bool -> bool = "%sequand"
external ( && ) : bool -> bool -> bool = "%sequand"
external ( or ) : bool -> bool -> bool = "%sequor"
external ( || ) : bool -> bool -> bool = "%sequor"

(* Integer operations *)

external ( ~- ) : int -> int = "%negint"
external ( ~+ ) : int -> int = "%identity"
external succ : int -> int = "%succint"
external pred : int -> int = "%predint"
external ( + ) : int -> int -> int = "%addint"
external ( - ) : int -> int -> int = "%subint"
external ( * ) : int -> int -> int = "%mulint"
external ( / ) : int -> int -> int = "%divint"
external ( mod ) : int -> int -> int = "%modint"

let abs x = if x >= 0 then x else -x

external ( land ) : int -> int -> int = "%andint"
external ( lor ) : int -> int -> int = "%orint"
external ( lxor ) : int -> int -> int = "%xorint"

let lnot x = x lxor (-1)

external ( lsl ) : int -> int -> int = "%lslint"
external ( lsr ) : int -> int -> int = "%lsrint"
external ( asr ) : int -> int -> int = "%asrint"

let max_int = (-1) lsr 1
let min_int = max_int + 1

(* Floating-point operations *)

external ( ~-. ) : float -> float = "%negfloat"
external ( ~+. ) : float -> float = "%identity"
external ( +. ) : float -> float -> float = "%addfloat"
external ( -. ) : float -> float -> float = "%subfloat"
external ( *. ) : float -> float -> float = "%mulfloat"
external ( /. ) : float -> float -> float = "%divfloat"
external ( ** ) : float -> float -> float = "caml_power_float" "pow"
  [@@unboxed] [@@noalloc]
external exp : float -> float = "caml_exp_float" "exp" [@@unboxed] [@@noalloc]
external expm1 : float -> float = "caml_expm1_float" "caml_expm1"
  [@@unboxed] [@@noalloc]

(*--
external acos : float -> float = "caml_acos_float" "acos"
  [@@unboxed] [@@noalloc]
external asin : float -> float = "caml_asin_float" "asin"
  [@@unboxed] [@@noalloc]
--*)

external atan : float -> float = "caml_atan_float" "atan"
  [@@unboxed] [@@noalloc]

(*--
external atan2 : float -> float -> float = "caml_atan2_float" "atan2"
  [@@unboxed] [@@noalloc]
external hypot : float -> float -> float
               = "caml_hypot_float" "caml_hypot" [@@unboxed] [@@noalloc]
--*)

external cos : float -> float = "caml_cos_float" "cos" [@@unboxed] [@@noalloc]

(*--
external cosh : float -> float = "caml_cosh_float" "cosh"
  [@@unboxed] [@@noalloc]
external acosh : float -> float = "caml_acosh_float" "caml_acosh"
  [@@unboxed] [@@noalloc]
--*)

external log : float -> float = "caml_log_float" "log" [@@unboxed] [@@noalloc]
external log10 : float -> float = "caml_log10_float" "log10"
  [@@unboxed] [@@noalloc]
external log1p : float -> float = "caml_log1p_float" "caml_log1p"
  [@@unboxed] [@@noalloc]
external sin : float -> float = "caml_sin_float" "sin" [@@unboxed] [@@noalloc]

(*--
external sinh : float -> float = "caml_sinh_float" "sinh"
  [@@unboxed] [@@noalloc]
external asinh : float -> float = "caml_asinh_float" "caml_asinh"
  [@@unboxed] [@@noalloc]
--*)

external sqrt : float -> float = "caml_sqrt_float" "sqrt"
  [@@unboxed] [@@noalloc]
external tan : float -> float = "caml_tan_float" "tan" [@@unboxed] [@@noalloc]

(*--
external tanh : float -> float = "caml_tanh_float" "tanh"
  [@@unboxed] [@@noalloc]
external atanh : float -> float = "caml_atanh_float" "caml_atanh"
  [@@unboxed] [@@noalloc]
--*)

external ceil : float -> float = "caml_ceil_float" "ceil"
  [@@unboxed] [@@noalloc]
external floor : float -> float = "caml_floor_float" "floor"
  [@@unboxed] [@@noalloc]
external abs_float : float -> float = "%absfloat"
external copysign : float -> float -> float
                  = "caml_copysign_float" "caml_copysign"
                  [@@unboxed] [@@noalloc]
(*--
external mod_float : float -> float -> float = "caml_fmod_float" "fmod"
  [@@unboxed] [@@noalloc]
--*)
(*++ *)
external sign: float -> int =
  "caml_nonstd_sign_float" (* sign x is -1|0|1 if x is neg|zero|pos*)
let mod_float a b =
  let n = a /. b in
  match sign n with
  | 1 -> a -. floor n *. b
  | -1 -> a -. ceil n *. b
  | _ -> 0.
(* ++*)

external frexp : float -> float * int = "caml_frexp_float"
external ldexp : (float [@unboxed]) -> (int [@untagged]) -> (float [@unboxed]) =
  "caml_ldexp_float" "caml_ldexp_float_unboxed" [@@noalloc]

(*--
external modf : float -> float * float = "caml_modf_float"
--*)
(*++ *)
let modf x = match sign x with
  | 1 -> let y = floor x in (x -. y, y)
  | -1 -> let y = ceil x in (x -. y, y)
  | _ -> 0.0, 0.0
(* ++*)

external float : int -> float = "%floatofint"
external float_of_int : int -> float = "%floatofint"
external truncate : float -> int = "%intoffloat"
external int_of_float : float -> int = "%intoffloat"

(*--
external float_of_bits : int64 -> float
  = "caml_int64_float_of_bits" "caml_int64_float_of_bits_unboxed"
  [@@unboxed] [@@noalloc]
let infinity =
  float_of_bits 0x7F_F0_00_00_00_00_00_00L
let neg_infinity =
  float_of_bits 0xFF_F0_00_00_00_00_00_00L
let nan =
  float_of_bits 0x7F_F0_00_00_00_00_00_01L
let max_float =
  float_of_bits 0x7F_EF_FF_FF_FF_FF_FF_FFL
let min_float =
  float_of_bits 0x00_10_00_00_00_00_00_00L
let epsilon_float =
  float_of_bits 0x3C_B0_00_00_00_00_00_00L
--*)

type fpclass =
    FP_normal
  | FP_subnormal
  | FP_zero
  | FP_infinite
  | FP_nan

external classify_float : (float [@unboxed]) -> fpclass =
  "caml_classify_float" "caml_classify_float_unboxed" [@@noalloc]

(*++ *)
let pi = 3.14159265358979312
let max_float     = 1.70141183420855150E+38
let min_float     = 2.93873587705571877E-39
let epsilon_float = 4.65661287307739258E-10
let hypot x y = sqrt(x *. x +. y *. y)
let acos x = match sign x with
  | 1 when x <= 1. ->
     (try atan ((sqrt (1. -. x *. x)) /. x) with _ -> pi /. 2.)
  | -1 when -1. <= x ->
     pi +. (try atan ((sqrt (1. -. x *. x)) /. x) with _ -> pi /. 2.)
  | 0 -> pi /. 2.
  | _ -> invalid_arg "acos"
let asin x = match sign x with
  | 1 when x <= 1. ->
     (try atan (x /. (sqrt (1. -. x *. x))) with _ -> pi /. 2.)
  | -1 when -1. <= x ->
     (try atan (x /. (sqrt (1. -. x *. x))) with _ -> -.pi /. 2.)
  | 0 -> 0.
  | _ -> invalid_arg "asin"
let atan2 y x = match sign y with
  | 0 -> (match sign x with
         | 0 -> invalid_arg "atan2"
         | 1 -> 0.
         | _ -> pi)
  | 1 -> (try 2. *. atan (((hypot x y) -. x) /. y) with _ -> pi)
  | _ -> (try 2. *. atan (((hypot x y) -. x) /. y) with _ -> -.pi)
let sinh x = expm1 (2. *. x) /. (2. *. exp x)
let cosh x = (1. +. exp (2. *. x)) /. (2. *. exp x)
let tanh x = expm1 (2. *. x) /. (1. +. exp (2. *. x))
let asinh x = log (x +. sqrt(x *. x +. 1.))
let acosh x =
  if x >= 1. then log (x +. sqrt(x *. x -. 1.))
  else invalid_arg "acosh"
let atanh x =
  if -1. < x && x < 1. then log ((1. +. x) /. (1. -. x)) /. 2.
  else invalid_arg "atanh"
let modf x =
  let i = float(truncate x) in (x -. i, i) 
(* ++*)

(* String and byte sequence operations -- more in modules String and Bytes *)

external string_length : string -> int = "%string_length"

(*--
external bytes_length : bytes -> int = "%bytes_length"
--*)

external bytes_create : int -> bytes = "caml_create_bytes"
external string_blit : string -> int -> bytes -> int -> int -> unit
                     = "caml_blit_string" [@@noalloc]

(*--
external bytes_blit : bytes -> int -> bytes -> int -> int -> unit
                        = "caml_blit_bytes" [@@noalloc]
--*)

external bytes_unsafe_to_string : bytes -> string = "%bytes_to_string"

let ( ^ ) s1 s2 =
  let l1 = string_length s1 and l2 = string_length s2 in
  let s = bytes_create (l1 + l2) in
  string_blit s1 0 s 0 l1;
  string_blit s2 0 s l1 l2;
  bytes_unsafe_to_string s

(* Character operations -- more in module Char *)

external int_of_char : char -> int = "%identity"
external unsafe_char_of_int : int -> char = "%identity"
let char_of_int n =
  if n < 0 || n > 255 then invalid_arg "char_of_int" else unsafe_char_of_int n

(* Unit operations *)

external ignore : 'a -> unit = "%ignore"

(* Pair operations *)

external fst : 'a * 'b -> 'a = "%field0"
external snd : 'a * 'b -> 'b = "%field1"

(* References *)

type 'a ref = { mutable contents : 'a }
external ref : 'a -> 'a ref = "%makemutable"
external ( ! ) : 'a ref -> 'a = "%field0"
external ( := ) : 'a ref -> 'a -> unit = "%setfield0"
external incr : int ref -> unit = "%incr"
external decr : int ref -> unit = "%decr"

(* Result type *)

type ('a,'b) result = Ok of 'a | Error of 'b

(* String conversion functions *)

(*--
external format_int : string -> int -> string = "caml_format_int"
external format_float : string -> float -> string = "caml_format_float"
--*)

let string_of_bool b =
  if b then "true" else "false"
let bool_of_string = function
  | "true" -> true
  | "false" -> false
  | _ -> invalid_arg "bool_of_string"

let bool_of_string_opt = function
  | "true" -> Some true
  | "false" -> Some false
  | _ -> None

(*--
let string_of_int n =
  format_int "%d" n

external int_of_string : string -> int = "caml_int_of_string"
--*)
(*++ *)
external string_of_int: int -> string = "caml_nonstd_string_of_int"
external string_of_float: float -> string = "caml_nonstd_string_of_float"
external float_of_string : string -> float = "caml_float_of_string"
let int_of_string s = int_of_float (float_of_string s)
(* ++*)

let int_of_string_opt s =
  (* TODO: provide this directly as a non-raising primitive. *)
  try Some (int_of_string s)
  with Failure _ -> None

external string_get : string -> int -> char = "%string_safe_get"

(*--
let valid_float_lexem s =
  let l = string_length s in
  let rec loop i =
    if i >= l then s ^ "." else
    match string_get s i with
    | '0' .. '9' | '-' -> loop (i + 1)
    | _ -> s
  in
  loop 0

let string_of_float f = valid_float_lexem (format_float "%.12g" f)

external float_of_string : string -> float = "caml_float_of_string"

let float_of_string_opt s =
  (* TODO: provide this directly as a non-raising primitive. *)
  try Some (float_of_string s)
  with Failure _ -> None
--*)
(*++ *)
let float_of_string_opt s = Some(float_of_string s) (* never fails *)
(* ++*)

(* List operations -- more in module List *)

let rec ( @ ) l1 l2 =
  match l1 with
    [] -> l2
  | hd :: tl -> hd :: (tl @ l2)

(* I/O operations *)

(*--
type in_channel
type out_channel
--*)
(*++ *)
type in_channel = unit -> char
type out_channel = char -> unit
(* ++*)

(*--
external open_descriptor_out : int -> out_channel
                             = "caml_ml_open_descriptor_out"
external open_descriptor_in : int -> in_channel = "caml_ml_open_descriptor_in"

let stdin = open_descriptor_in 0
let stdout = open_descriptor_out 1
let stderr = open_descriptor_out 2

(* General output functions *)

type open_flag =
    Open_rdonly | Open_wronly | Open_append
  | Open_creat | Open_trunc | Open_excl
  | Open_binary | Open_text | Open_nonblock

external open_desc : string -> open_flag list -> int -> int = "caml_sys_open"

external set_out_channel_name: out_channel -> string -> unit =
  "caml_ml_set_channel_name"

let open_out_gen mode perm name =
  let c = open_descriptor_out(open_desc name mode perm) in
  set_out_channel_name c name;
  c

let open_out name =
  open_out_gen [Open_wronly; Open_creat; Open_trunc; Open_text] 0o666 name

let open_out_bin name =
  open_out_gen [Open_wronly; Open_creat; Open_trunc; Open_binary] 0o666 name

external flush : out_channel -> unit = "caml_ml_flush"

external out_channels_list : unit -> out_channel list
                           = "caml_ml_out_channels_list"

let flush_all () =
  let rec iter = function
      [] -> ()
    | a::l ->
        begin try
            flush a
        with Sys_error _ ->
          () (* ignore channels closed during a preceding flush. *)
        end;
        iter l
  in iter (out_channels_list ())

external unsafe_output : out_channel -> bytes -> int -> int -> unit
                       = "caml_ml_output_bytes"
external unsafe_output_string : out_channel -> string -> int -> int -> unit
                              = "caml_ml_output"

external output_char : out_channel -> char -> unit = "caml_ml_output_char"
--*)
(*++ *)
let output_char oc = oc
(* ++*)

(*--
let output_bytes oc s =
  unsafe_output oc s 0 (bytes_length s)
let output_string oc s =
  unsafe_output_string oc s 0 (string_length s)
--*)
(*++ *)
let output_string oc str =
  for i = 0 to string_length str - 1 do oc (string_get str i) done
let output_bytes oc bytes =
  output_string oc (bytes_unsafe_to_string bytes)
(* ++*)

(*--
let output oc s ofs len =
  if ofs < 0 || len < 0 || ofs > bytes_length s - len
  then invalid_arg "output"
  else unsafe_output oc s ofs len
--*)
(*++ *)
let output oc s ofs len =
  let s = bytes_unsafe_to_string s in
  if ofs < 0 || len < 0 || ofs > string_length s - len
  then invalid_arg "output";
  for i = ofs to ofs + len - 1 do oc (string_get s i) done
(* ++*)

(*--
let output_substring oc s ofs len =
  if ofs < 0 || len < 0 || ofs > string_length s - len
  then invalid_arg "output_substring"
  else unsafe_output_string oc s ofs len
--*)
(*++ *)
let output_substring oc s ofs len =
  if ofs < 0 || len < 0 || ofs > string_length s - len
  then invalid_arg "output_substring"
  else for i = ofs to ofs + len - 1 do oc (string_get s i) done
(* ++*)

(*--
external output_byte : out_channel -> int -> unit = "caml_ml_output_char"
--*)
(*++ *)
let output_byte oc n = oc (unsafe_char_of_int (n land 0xFF))
(* ++*)

(*--
external output_binary_int : out_channel -> int -> unit = "caml_ml_output_int"

external marshal_to_channel : out_channel -> 'a -> unit list -> unit
     = "caml_output_value"
let output_value chan v = marshal_to_channel chan v []

external seek_out : out_channel -> int -> unit = "caml_ml_seek_out"
external pos_out : out_channel -> int = "caml_ml_pos_out"
external out_channel_length : out_channel -> int = "caml_ml_channel_size"
external close_out_channel : out_channel -> unit = "caml_ml_close_channel"
let close_out oc = flush oc; close_out_channel oc
let close_out_noerr oc =
  (try flush oc with _ -> ());
  (try close_out_channel oc with _ -> ())
external set_binary_mode_out : out_channel -> bool -> unit
                             = "caml_ml_set_binary_mode"

(* General input functions *)

external set_in_channel_name: in_channel -> string -> unit =
  "caml_ml_set_channel_name"

let open_in_gen mode perm name =
  let c = open_descriptor_in(open_desc name mode perm) in
  set_in_channel_name c name;
  c

let open_in name =
  open_in_gen [Open_rdonly; Open_text] 0 name

let open_in_bin name =
  open_in_gen [Open_rdonly; Open_binary] 0 name

external input_char : in_channel -> char = "caml_ml_input_char"

external unsafe_input : in_channel -> bytes -> int -> int -> int
                      = "caml_ml_input"

let input ic s ofs len =
  if ofs < 0 || len < 0 || ofs > bytes_length s - len
  then invalid_arg "input"
  else unsafe_input ic s ofs len

let rec unsafe_really_input ic s ofs len =
  if len <= 0 then () else begin
    let r = unsafe_input ic s ofs len in
    if r = 0
    then raise End_of_file
    else unsafe_really_input ic s (ofs + r) (len - r)
  end

let really_input ic s ofs len =
  if ofs < 0 || len < 0 || ofs > bytes_length s - len
  then invalid_arg "really_input"
  else unsafe_really_input ic s ofs len

let really_input_string ic len =
  let s = bytes_create len in
  really_input ic s 0 len;
  bytes_unsafe_to_string s

external input_scan_line : in_channel -> int = "caml_ml_input_scan_line"

let input_line chan =
  let rec build_result buf pos = function
    [] -> buf
  | hd :: tl ->
      let len = bytes_length hd in
      bytes_blit hd 0 buf (pos - len) len;
      build_result buf (pos - len) tl in
  let rec scan accu len =
    let n = input_scan_line chan in
    if n = 0 then begin                   (* n = 0: we are at EOF *)
      match accu with
        [] -> raise End_of_file
      | _  -> build_result (bytes_create len) len accu
    end else if n > 0 then begin          (* n > 0: newline found in buffer *)
      let res = bytes_create (n - 1) in
      ignore (unsafe_input chan res 0 (n - 1));
      ignore (input_char chan);           (* skip the newline *)
      match accu with
        [] -> res
      |  _ -> let len = len + n - 1 in
              build_result (bytes_create len) len (res :: accu)
    end else begin                        (* n < 0: newline not found *)
      let beg = bytes_create (-n) in
      ignore(unsafe_input chan beg 0 (-n));
      scan (beg :: accu) (len - n)
    end
  in bytes_unsafe_to_string (scan [] 0)

external input_byte : in_channel -> int = "caml_ml_input_char"
external input_binary_int : in_channel -> int = "caml_ml_input_int"
external input_value : in_channel -> 'a = "caml_input_value"
external seek_in : in_channel -> int -> unit = "caml_ml_seek_in"
external pos_in : in_channel -> int = "caml_ml_pos_in"
external in_channel_length : in_channel -> int = "caml_ml_channel_size"
external close_in : in_channel -> unit = "caml_ml_close_channel"
let close_in_noerr ic = (try close_in ic with _ -> ())
external set_binary_mode_in : in_channel -> bool -> unit
                            = "caml_ml_set_binary_mode"
--*)

(* Output functions on standard output *)

(*--
let print_char c = output_char stdout c
let print_string s = output_string stdout s
let print_bytes s = output_bytes stdout s
let print_int i = output_string stdout (string_of_int i)
let print_float f = output_string stdout (string_of_float f)
let print_endline s =
  output_string stdout s; output_char stdout '\n'; flush stdout
let print_newline () = output_char stdout '\n'; flush stdout
--*)
(*++ *)
external bytes_fill: bytes -> int -> int -> char -> unit
  = "caml_fill_bytes" [@@noalloc]
external print_string: string -> unit = "caml_nonstd_print_string"
let print_bytes by = print_string (bytes_unsafe_to_string by)
external print_char : char -> unit = "caml_nonstd_print_char"
let print_int n = print_string (string_of_int n)
let print_float x = print_string (string_of_float x)
let print_newline () = print_char '\013'
let print_endline s = print_string s; print_newline ()
(* ++*)

(* Output functions on standard error *)

(*--
let prerr_char c = output_char stderr c
let prerr_string s = output_string stderr s
let prerr_bytes s = output_bytes stderr s
let prerr_int i = output_string stderr (string_of_int i)
let prerr_float f = output_string stderr (string_of_float f)
let prerr_endline s =
  output_string stderr s; output_char stderr '\n'; flush stderr
let prerr_newline () = output_char stderr '\n'; flush stderr
--*)
(*++ *)
let prerr_char = print_char
let prerr_string = print_string
let prerr_bytes = print_bytes
let prerr_int = print_int
let prerr_float = print_float
let prerr_endline = print_endline
let prerr_newline = print_newline
(* ++*)

(* Input functions on standard input *)

(*--
let read_line () = flush stdout; input_line stdin
--*)
(*++  *)
external read_line: unit -> string = "caml_nonstd_read_line"
(* ++*)

let read_int () = int_of_string(read_line())
let read_int_opt () = int_of_string_opt(read_line())
let read_float () = float_of_string(read_line())
let read_float_opt () = float_of_string_opt(read_line())

(*--
(* Operations on large files *)

module LargeFile =
  struct
    external seek_out : out_channel -> int64 -> unit = "caml_ml_seek_out_64"
    external pos_out : out_channel -> int64 = "caml_ml_pos_out_64"
    external out_channel_length : out_channel -> int64
                                = "caml_ml_channel_size_64"
    external seek_in : in_channel -> int64 -> unit = "caml_ml_seek_in_64"
    external pos_in : in_channel -> int64 = "caml_ml_pos_in_64"
    external in_channel_length : in_channel -> int64 = "caml_ml_channel_size_64"
  end


(* Formats *)

type ('a, 'b, 'c, 'd, 'e, 'f) format6
   = ('a, 'b, 'c, 'd, 'e, 'f) CamlinternalFormatBasics.format6
   = Format of ('a, 'b, 'c, 'd, 'e, 'f) CamlinternalFormatBasics.fmt
               * string

type ('a, 'b, 'c, 'd) format4 = ('a, 'b, 'c, 'c, 'c, 'd) format6

type ('a, 'b, 'c) format = ('a, 'b, 'c, 'c) format4

let string_of_format (Format (_fmt, str)) = str

external format_of_string :
 ('a, 'b, 'c, 'd, 'e, 'f) format6 ->
 ('a, 'b, 'c, 'd, 'e, 'f) format6 = "%identity"

let ( ^^ ) (Format (fmt1, str1)) (Format (fmt2, str2)) =
  Format (CamlinternalFormatBasics.concat_fmt fmt1 fmt2,
          str1 ^ "%," ^ str2)

(* Miscellaneous *)

external sys_exit : int -> 'a = "caml_sys_exit"

let exit_function = CamlinternalAtomic.make flush_all

let rec at_exit f =
  let module Atomic = CamlinternalAtomic in
  (* MPR#7253, MPR#7796: make sure "f" is executed only once *)
  let f_yet_to_run = Atomic.make true in
  let old_exit = Atomic.get exit_function in
  let new_exit () =
    if Atomic.compare_and_set f_yet_to_run true false then f () ;
    old_exit ()
  in
  let success = Atomic.compare_and_set exit_function old_exit new_exit in
  if not success then at_exit f

let do_at_exit () = (CamlinternalAtomic.get exit_function) ()

let exit retcode =
  do_at_exit ();
  sys_exit retcode

let _ = register_named_value "Pervasives.do_at_exit" do_at_exit

external major : unit -> unit = "caml_gc_major"
external naked_pointers_checked : unit -> bool
  = "caml_sys_const_naked_pointers_checked"
let () = if naked_pointers_checked () then at_exit major

(*MODULE_ALIASES*)
module Arg          = Arg
module Array        = Array
module ArrayLabels  = ArrayLabels
module Atomic       = Atomic
module Bigarray     = Bigarray
module Bool         = Bool
module Buffer       = Buffer
module Bytes        = Bytes
module BytesLabels  = BytesLabels
module Callback     = Callback
module Char         = Char
module Complex      = Complex
module Digest       = Digest
module Either       = Either
module Ephemeron    = Ephemeron
module Filename     = Filename
module Float        = Float
module Format       = Format
module Fun          = Fun
module Gc           = Gc
module Genlex       = Genlex
module Hashtbl      = Hashtbl
module In_channel   = In_channel
module Int          = Int
module Int32        = Int32
module Int64        = Int64
module Lazy         = Lazy
module Lexing       = Lexing
module List         = List
module ListLabels   = ListLabels
module Map          = Map
module Marshal      = Marshal
module MoreLabels   = MoreLabels
module Nativeint    = Nativeint
module Obj          = Obj
module Oo           = Oo
module Option       = Option
module Out_channel  = Out_channel
module Parsing      = Parsing
module Pervasives   = Pervasives
module Printexc     = Printexc
module Printf       = Printf
module Queue        = Queue
module Random       = Random
module Result       = Result
module Scanf        = Scanf
module Seq          = Seq
module Set          = Set
module Stack        = Stack
module StdLabels    = StdLabels
module Stream       = Stream
module String       = String
module StringLabels = StringLabels
module Sys          = Sys
module Uchar        = Uchar
module Unit         = Unit
module Weak         = Weak
--*)
(*++ *)
(* removed: module Arg *)
module Array        = Stdlib__array
module ArrayLabels  = Stdlib__arrayLabels
(* removed: module Atomic *)
(* removed: module Bigarray *)
module Bool         = Stdlib__bool
module Buffer       = Stdlib__buffer
module Bytes        = Stdlib__bytes
module BytesLabels  = Stdlib__bytesLabels
(* removed: module Callback *)
module Char         = Stdlib__char
module Complex      = Stdlib__complex
(* removed: module Digest *)
module Either       = Stdlib__either
(* removed: module Ephemeron *)
(* removed: module Filename *)
module Float        = Stdlib__float
(* removed: module Format *)
(* removed: module Fun *)
(* removed: module Gc *)
(* removed: module Genlex *)
module Hashtbl      = Stdlib__hashtbl
(* removed: module In_channel *)
module Int          = Stdlib__int
module Int32        = Stdlib__int32
module Int64        = Stdlib__int64
module Lazy         = Stdlib__lazy
(* removed: module Lexing *)
module List         = Stdlib__list
module ListLabels   = Stdlib__listLabels
module Map          = Stdlib__map
(* removed: module Marshal *)
module MoreLabels   = Stdlib__moreLabels
(* removed: module Nativeint *)
module Obj          = Stdlib__obj  
(* removed: module Oo *)
module Option       = Stdlib__option
(* removed: module Out_channel *)
(* removed: module Parsing *)
(* removed: module Pervasives *)
(* removed: module Printexc *)
(* removed: module Printf *)
module Queue        = Stdlib__queue
module Random       = Stdlib__random
module Result       = Stdlib__result
(* removed: module Scanf *)
module Seq          = Stdlib__seq
module Set          = Stdlib__set
module Stack        = Stdlib__stack
module StdLabels    = Stdlib__stdLabels
(* removed: module Stream *)
module String       = Stdlib__string
module StringLabels = Stdlib__stringLabels
module Sys          = Stdlib__sys
(* removed: module Uchar *)
module Unit         = Stdlib__unit
(* removed: module Weak *)
(* ++*)
