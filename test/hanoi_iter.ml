
type pole = int list
type state = pole * pole * pole

let move_smallest_disc_rightwards = function
  | (1::ds, m, r) -> (ds, 1::m, r)
  | (l, 1::ds, r) -> (l, ds, 1::r)
  | (l, m, 1::ds) -> (1::l, m, ds)
  | _ -> raise Exit
       
let move_smallest_disc_leftwards = function
  | (1::ds, m, r) -> (ds, m, 1::r)
  | (l, 1::ds, r) -> (1::l, ds, r)
  | (l, m, 1::ds) -> (l, 1::m, ds)
  | _ -> raise Exit

let find_legal_move = function
  | d::ds, [] -> (ds, [d])
  | [], d::ds -> ([d], ds)
  | d1::ds1, d2::ds2 ->
     if d1 < d2
     then (ds1, d1::d2::ds2)
     else (d2::d1::ds1, ds2) 
  | _ -> raise Exit

let move_another_disc (l, m, r) = match (l, m, r) with
  | (1::_, _, _) -> let m, r = find_legal_move (m, r) in (l, m, r)
  | (_, 1::_, _) -> let l, r = find_legal_move (l, r) in (l, m, r)
  | (_, _, 1::_) -> let l, m = find_legal_move (l, m) in (l, m, r)
  | _ -> raise Exit

let string_of_move = function
  | (d::_, _, _), (_, d'::_, _) when d = d' -> "A->B"
  | (d::_, _, _), (_, _, d'::_) when d = d' -> "A->C"
  | (_, d::_, _), (d'::_, _, _) when d = d' -> "B->A"
  | (_, d::_, _), (_, _, d'::_) when d = d' -> "B->C"
  | (_, _, d::_), (d'::_, _, _) when d = d' -> "C->A"
  | (_, _, _), (_, _, _) -> "C->B"

let print_move =
  let count = ref 0 in
  fun s1 s2 ->
  (incr count;
   print_int !count;
   print_string (":" ^ (string_of_move (s1,s2)));
   print_newline ())

let solved = function
  | [],[],_ -> true
  | _ -> false

let rec mklist l = function
  | 0 -> l
  | n -> mklist (n::l) (pred n)

let hanoi discs =
 let move_smallest_disc =
   if discs mod 2 = 0
   then move_smallest_disc_rightwards
   else move_smallest_disc_leftwards in
 let curstate = ref (mklist [] discs, [], []) in
 let newstate = ref (move_smallest_disc !curstate) in
 print_move !curstate !newstate;
 while not (solved !newstate) do
   curstate := !newstate;
   newstate := move_another_disc !curstate;
   print_move !curstate !newstate;
   curstate := !newstate;
   newstate := move_smallest_disc !curstate;
   print_move !curstate !newstate;
 done


let _ =
  print_string "Numero di dischi? ";
  hanoi(read_int ());
  print_newline ()

