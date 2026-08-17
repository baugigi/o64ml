
let rec map f = function
  | [] -> []
  | x::xs -> (f x) :: (map f xs)
let rec nth l n =
  match n, l with
  | 0, x::_ -> Some x
  | p, _::r when p > 0 -> nth r (pred p)
  | _ -> None
let x () =
  let l = map (fun n -> n * n) [1;2;3;4;5] in
  match nth l 2 with
  | Some n -> n
  | None -> -1
;;

x ()
    
