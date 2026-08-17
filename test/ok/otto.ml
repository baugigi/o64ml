
let rec f n = if n = 0 then 0 else f (f (n - 1));;
let g n = 8;;
g (f 0);;

