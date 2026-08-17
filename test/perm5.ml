
(* nb fino a sz = 4 funziona; da qui in poi svalvola. *)

let sz = 5

let m =   (* Array.init 9 (fun _ -> input_line stdin) *)
  [| "00000";
     "00000";
     "00000";
     "00000";
     "00000" |]
  
let print() =
  Array.iter print_endline m;
  print_newline()

let rec invalid ?(i=0) x y n =
  i < sz &&
    (m.(y).[i] = n
     || m.(i).[x] = n
(*
     || m.(y / 3 * 3 + i / 3).[x / 3 * 3 + i mod 3] = n
 *)
     || invalid ~i:(succ i) x y n)
  
                             
let rec fold f accu l u =
  if l = u then
    accu
  else
    fold f (f accu l) (succ l) u

  
let rec search ?(x=0) ?(y=0) f accu =
  match x, y with
  | s, y when s = sz ->
     search ~x:0 ~y:(succ y) f accu 	(* Next row *)
  | 0, s when s = sz ->
     f accu                        	(* Found a solution *)
  | x, y -> 
     if m.(y).[x] <> '0'
     then
       search ~x:(succ x) ~y f accu
     else
       let brute_force accu n =
         let n = Char.chr (n + Char.code '0') in
         if invalid x y n then
           accu
         else
           begin
             m.(y).[x] <- n; 
             let accu = search ~x:(succ x) ~y f accu in
             m.(y).[x] <- '0';
             accu
           end in
       fold brute_force accu 1 (succ sz)
let _ =
  print_int (search (fun i -> print(); succ i) 0);
  print_string " solution(s)";

