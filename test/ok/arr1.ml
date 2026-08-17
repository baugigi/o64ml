
let f x = [| x; x; x; x; x; x; x; x; x; x |];;
let a = f 2 in
    let () = for i = 0 to 9 do a.(i) <- 3 done in
    a.(0);;

