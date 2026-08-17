
let a = 1000
let b = ref 2000
let c = [| a; !b |]
let _ = print_int (c.(0))
let _ = print_int (c.(1))

