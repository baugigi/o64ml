
type 'a t = { mutable fld: 'a }
let make el = { fld = el }
let get x = x.fld
let set x e = x.fld <- e
let map f x = make (f (get x))

