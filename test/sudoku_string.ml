
let sz = 9

let m =
  "906070403\
   300400200\
   070023010\
   500000104\
   040208060\
   703040005\
   030700050\
   007005000\
   405010708"
  
let print() =
  for i = 0 to sz - 1 do
    print_endline (String.sub m (sz * i) 9);
  done;
  print_newline()


let rec invalid ?(i=0) x y n =
  i < sz &&
    (m.[sz * y + i] = n
     || m.[sz * i + x] = n
     || m.[sz * (y / 3 * 3 + i / 3) + (x / 3 * 3 + i mod 3)] = n
     || invalid ~i:(succ i) x y n)
  
                             
let rec fold f accu l u =
  if l = u then
    accu
  else
    fold f (f accu l) (succ l) u

  
let rec search ?(x=0) ?(y=0) f accu =
  match x, y with
  | s, y when s = sz -> search ~x:0 ~y:(succ y) f accu 	(* Next row *)
  | 0, s when s = sz -> f accu                        	(* Found a solution *)
  | x, y ->
     if m.[sz * y + x] <> '0' then
       search ~x:(succ x) ~y f accu
     else
       let brute_force accu n =
         let n = char_of_int(n + int_of_char '0') in
         if invalid x y n then
           accu
         else
           begin
             m.[sz * y + x] <- n; 
             let accu = search ~x:(succ x) ~y f accu in
             m.[sz *  y + x] <- '0';
             accu
           end in
       fold brute_force accu 1 (succ sz)

let _ =
  print_int (search (fun i -> print(); succ i) 0);
  print_string " solution(s)";

