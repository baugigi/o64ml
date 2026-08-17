
open Array
let _ = Random.self_init ()
let a = init Sys.max_array_length
          (fun _ -> char_of_int(Random.bits() land 0xff))
let print a =
  iteri
    (fun i x ->
      print_int i;
      print_string {| = "\|};
      let s = "00" ^ (string_of_int (int_of_char x)) in
      print_string String.(sub s (length s - 3) 3);
      print_endline {|"|})
    a
let cmp a b =
  if a < b then -1 else if a > b then 1 else 0
;;
print a;
sort cmp a;
print a;

(* se si usa cmp = compare, il sort non avviene: compare BUGgata! *)
(* se si usa fast_sort, il programma termina improvvisamente: BUG dove? *)
