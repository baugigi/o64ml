
exception Mia
let glob = [|Out_of_memory; Division_by_zero; Mia|]
let f x = raise glob.(x)
let _ = f 2
