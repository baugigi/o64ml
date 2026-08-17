
let rec f n accu =
  if n > 1
  then f (n - 1) (n * accu)
  else accu;;
f 7 1;;
