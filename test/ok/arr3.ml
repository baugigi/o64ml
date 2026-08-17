
let f a =
  let l = (Array.length a) - 1
  and v = a.(0)
  in (a.(0) <- a.(l);
      a.(l) <- v)
let arr = [| 1; 2; 3; 4; 5 |]
let x () = f arr
;;
x ()
;;
arr.(0)
;;
