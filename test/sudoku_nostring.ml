
let m =   (* Array.init 9 (fun _ -> input_line stdin) *)
  [| [| 9; 0; 6; 0; 7; 0; 4; 0; 3 |];
     [| 0; 0; 0; 4; 0; 0; 2; 0; 0 |];
     [| 0; 7; 0; 0; 2; 3; 0; 1; 0 |];
     [| 5; 0; 0; 0; 0; 0; 1; 0; 0 |];
     [| 0; 4; 0; 2; 0; 8; 0; 6; 0 |];
     [| 0; 0; 3; 0; 0; 0; 0; 0; 5 |];
     [| 0; 3; 0; 7; 0; 0; 0; 5; 0 |];
     [| 0; 0; 7; 0; 0; 5; 0; 0; 0 |];
     [| 4; 0; 5; 0; 1; 0; 7; 0; 8 |] |]
  
let print() =
  Array.iter (fun l -> Array.iter print_int l; print_newline()) m;
  print_newline()


let rec invalid ?(i=0; ) x y n =
  i < 9 &&
    (m.(y).(i) = n
     || m.(i).(x) = n
     || m.(y / 3 * 3 + i / 3).(x / 3 * 3 + i mod 3) = n 
     || invalid ~i:(succ i) x y n)
  
                             
let rec fold f accu l u =
  if l = u then
    accu
  else
    fold f (f accu l) (succ l) u

  
let rec search ?(x=0) ?(y=0) f accu =
  match x, y with
  | 9, y -> search ~x:0 ~y:(succ y) f accu 	(* Next row *)
  | 0, 9 -> f accu                        	(* Found a solution *)
  | x, y ->
     if m.(y).(x) <> 0 then
       search ~x:(succ x) ~y f accu
     else
       let brute_force accu n =
         if invalid x y n then
           accu
         else
           begin
             m.(y).(x) <- n; 
             let accu = search ~x:(succ x) ~y f accu in
             m.(y).(x) <- 0;
             accu
           end in
       fold brute_force accu 1 10

let _ =
  print_int (search (fun i -> (); succ i) 0);
  print_string " solution(s)";

