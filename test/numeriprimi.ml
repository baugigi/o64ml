
let rec numeri_primi n =
  if n = 0
  then []
  else numeri_primi_aux (pred n) [2]
and numeri_primi_aux n r =
  if n = 0
  then r
  else numeri_primi_aux
         (pred n)
         (primo_successivo (List.hd r + 1) r :: r)
and primo_successivo n l =
  if primo n l
  then n
  else primo_successivo (n+1) l
and primo n = function
  | [] ->
     true
  | e::tl ->
     if n mod e = 0
     then false
     else primo n tl
let _ =
  for i = 1 to 80 do
    ignore (numeri_primi 250)
  done
