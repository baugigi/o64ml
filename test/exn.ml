type t = [ `Favarati of string ]
exception Mia_Ecc of t
let () = raise (Mia_Ecc (`Favarati "CCC"))
