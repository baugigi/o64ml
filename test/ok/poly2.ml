
let f x =
  match x with
  | `Ab -> 100
  | `W n -> 2 * n
  | _ -> 34;;

f `I;;
