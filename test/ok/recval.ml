
let hd (x, _) = x
    
let tl (_, t) = t

let rec mycirc = ((fun _ -> 1), mycirc)

let rec f c = function
  | 0 -> hd c
  | n when n > 0 -> f (tl c) (pred n)
  | _ -> fun _ -> -1

let x() = f mycirc 8 ()

;;

x();;
