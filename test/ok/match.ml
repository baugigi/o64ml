
type t = A of int | B of bool | C | D of (int -> int);;
let f = function
  | A n -> n
  | B b -> if b then 1 else 2
  | C -> 0
  | D g -> g 100;;
f (D (fun n -> n));;
