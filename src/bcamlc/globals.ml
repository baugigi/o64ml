type item =
  (* Near memory-level representation of a global value *)
  | Bytes of int array  (* a row of bytes that encode (part of) a value *)
  | Pointer of int      (* a pointer to a block *)
  | Label of string     (* an assembly label standing for a memory address *)

type t =
  (* Type for the collection of global values *)
  { size : int;	        (* total size, in bytes, of all stored items *)
    store : item list;  (* the storage area for global values *)
    table : item list } (* the global table of integers and pointers *)

let item_size = function
  (* Size, in bytes, of an item *)
  | Bytes a -> Array.length a
  | _ -> 2

let empty =
  (* The initial empty collection *)
  { size  = 0; store  = []; table = [] }

let store_item item glob =
  (* Store an item *)
  { glob with size = glob.size + item_size item;
              store = item :: glob.store }

let add_item_to_table item glob =
  (* Insert an item into the global table *)
  assert (item_size item mod 2 = 0);
  { glob with table = item :: glob.table }

let add_new_pointer_to_table glob =
  (* Insert a new pointer to the current location of the storage area
     into the global table *)
  assert (glob.size mod 2 = 0);
  add_item_to_table (Pointer glob.size) glob

let fail_if cond msg =
  (* Failures *)
  if cond then failwith (msg ^ " in global store.")

let c64float x =
  (* Return the Commodore 64 MFLP representation of a floating point number *)
  let mantissa, exponent = frexp x in
  let float_class = classify_float mantissa in
  let bytes = [| 0; 0; 0; 0; 0; 0xFF (* unused *) |] in
  let add1 () =
    let rec incr_with_carry i =
      bytes.(i) <- succ bytes.(i) land 0xFF;
      if i > 0 && bytes.(i) = 0 then incr_with_carry (pred i) in
    incr_with_carry 4;
    fail_if (bytes.(0) = 0) "Float out of range"
  in
  fail_if (float_class = FP_infinite) "Float.infinity or Float.neg_infinity";
  fail_if (float_class = FP_nan) "Float.nan";
  fail_if (exponent > 127) "Float out of range";
  if exponent >= -127 && x <> 0. && x <> -0. then
    (bytes.(0) <- exponent + 128;
     let remainder = ref (Float.abs mantissa) in
     for i = 1 to 4 do
       let curr_byte = !remainder *. 256. in
       bytes.(i) <- truncate curr_byte;
       remainder := curr_byte -. float bytes.(i)
     done;
     if !remainder >= 0.5 then add1 ();
     let sign = if mantissa < 0. then 0x80 else 0x00 in
     bytes.(1) <- sign lor (bytes.(1) land 0x7F));
  bytes

let list_rev_split n l =
  (* list_rev_split 3 [a; b; c; d; e] is [c; b; a], [d; e] *)
  let rec f acc n l = match n, l with
    | 0, xs  -> acc, xs
    | _, []  -> acc, []
    | _, x::xs -> f (x::acc) (pred n) xs
  in f [] n l

let ( #% ) fold_fun f =
  (* Sugar to make using |> with List.fold_left, etc. sweeter *)
  let swap f a b = f b a in swap(fold_fun (swap f))

let rec add_global value globals =
  (* Add a global value to the collection *)
  match value with
  | OByteLib.Value.Block (tag, fields) ->
     (match Array.length fields with
      | 0 ->
         fail_if (tag > 0) "Atom with tag > 0";
         globals
         |> add_item_to_table (Label "caml_atom0")
      | size ->
         fail_if (size > 255) "Block too large";
         fail_if (tag = Obj.custom_tag) "Unknown custom block";
         let g = Array.fold_left #% add_global fields globals in
         let (fields, rest) = list_rev_split size g.table in
         { g with table = rest }
         |> store_item (Bytes [| tag; size |])
         |> add_new_pointer_to_table
         |> List.fold_left #% store_item fields)
  | Int n ->
     fail_if (n < -0x4000 || n > 0x7FFF) "Integer out of range";
     let v = (n lsl 1) lor 1 in
     globals
     |> add_item_to_table (Bytes [| 0xFF land v; 0xFF land (v lsr 8) |])
  | Int32 n ->
     let bytes i = Int32.(shift_right n (8 * i) |> logand 255l |> to_int) in
     globals
     |> store_item (Bytes [| 255 (* Custom_tag *); 3 |])
     |> add_new_pointer_to_table
     |> store_item (Label "caml_int32_custom")
     |> store_item (Bytes (Array.init 4 bytes))
  | Int64 n ->
     let bytes i = Int64.(shift_right n (8 * i) |> logand 255L |> to_int) in
     globals
     |> store_item (Bytes [| 255 (* Custom_tag *); 5 |])
     |> add_new_pointer_to_table
     |> store_item (Label "caml_int64_custom")
     |> store_item (Bytes (Array.init 8 bytes))
  | Nativeint _ -> failwith "Nativeint not impleented."
  | Float x ->
     globals
     |> store_item (Bytes [| 253 (* Double_tag *); 3 |])
     |> add_new_pointer_to_table
     |> store_item (Bytes (c64float x))
  | Float_array tab ->
     let size = 3 * Array.length tab in
     fail_if (size = 0) "Empty float array";
     fail_if (size > 255) "Float array too large";
     let add_float_item x = store_item (Bytes (c64float x)) in
     globals
     |> store_item (Bytes [| 254 (* Double_array_tag *); size |])
     |> add_new_pointer_to_table
     |> Array.fold_left #% add_float_item tab
  | String str ->
     let len = String.length str in
     let size = len / 2 + 1 in
     fail_if (size > 255) "String too long";
     let suffix = if len mod 2 = 0 then "\000\001" else "\000" in
     let bytes i = int_of_char (str ^ suffix).[i] in
     globals
     |> store_item (Bytes [| 252 (* String_tag *); size |])
     |> add_new_pointer_to_table
     |> store_item (Bytes (Array.init (2 * size) bytes))
  | Object data ->
     globals
     |> add_global (Block (248 (* Object_tag *), data))

let col, last_cmd =
  (* References for pretty-printing asm commands *)
  ref 0, ref None

let emit_asm ch asm_cmd asm_arg =
  (* Pretty-print an asm command *)
  let max_col = 75 in
  let emit_cmd sep inline_cmd newline_cmd =
    let len_sep, len_inline_cmd, len_newline_cmd =
      String.(length sep, length inline_cmd, length newline_cmd) in
    let new_col = len_inline_cmd + if !col > 0 then !col + len_sep else 0 in 
    if new_col <= max_col then
      (output_string ch ((if !col > 0 then sep else "") ^ inline_cmd);
       col := new_col)
    else
      (output_string ch ("\n" ^ newline_cmd);
       col := len_newline_cmd) in
  match asm_cmd with
  | Some cmd ->
     if asm_cmd = !last_cmd then
       emit_cmd " " asm_arg (cmd ^ asm_arg)
     else
       (emit_cmd ":" (cmd ^ asm_arg) (cmd ^ asm_arg);
        last_cmd := asm_cmd)
  | None ->
     emit_cmd ":" asm_arg asm_arg;
     last_cmd := asm_cmd

let export ch globals =
  (* Convert an array of OCaml global values to asm code and output it *)
  let glob_no_exn = Array.(sub globals 12 (length globals - 12)) in
  let glob_no_exn = Array.fold_left #% add_global glob_no_exn empty in
  let store = List.rev glob_no_exn.store in
  let table = List.rev glob_no_exn.table in
  let export_item = function
    | Pointer ptr ->
       emit_asm ch None (Printf.sprintf "+p $%04x" ptr)
    | Label lbl ->
       emit_asm ch None (Printf.sprintf "!wo %s" lbl)
    | Bytes bytes ->
       let emit_byte by = emit_asm ch (Some "!h ") (Printf.sprintf "%02x" by) in
       Array.iter emit_byte bytes in
  output_string ch "!macro p .ptr { !wo caml_glob_data + .ptr }\n";
  output_string ch "!align $01, $00\n";
  output_string ch "caml_glob_table\n";
  List.iter export_item table;
  output_string ch "\ncaml_glob_data\n";
  col := 0; last_cmd := None;
  List.iter export_item store;
  output_string ch "\ncaml_glob_end\n"
