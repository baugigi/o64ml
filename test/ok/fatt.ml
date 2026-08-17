
let rec f n = if n < 2 then 1 else n * (f (pred n));;
f 7;;
