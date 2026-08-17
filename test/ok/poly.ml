
let f = function
  | `S x -> x * x
  | `D x -> x + x
  | `N -> 0
  | `C -> 100
  | `I x -> x
  | _ -> -1
;;

f (`I 100);;
