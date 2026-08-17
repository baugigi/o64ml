
let rot a =
  let _ = match Array.length a with
    | 0 -> ()
    | l -> 
       let a0 = a.(0) in
       for i = 0 to l - 2 do
         a.(i) <- a.(succ i)
       done;
       a.(pred l) <- a0 in
  a
;;
let a = [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |]
    in (rot a).(0)
;;
