
let l = [100.; 200.]
let arr = [| 0.; 1.; 2.; 3.; 4.; 5. |]
let _ =
  arr.(0) <- 1000.;
  print_float arr.(1)
let _ =
  print_float ((List.hd l) +. arr.(0))
