
let rec f n =
  if n <= 1 then
    1
  else
    f (pred n) + 1;;

f 127;; (* 127 chiamate ricorsive, -stacksize 4 *)
f 255;; (* 255 chiamate ricorsive, -stacksize 8 *)
f 511;; (* 511 chiamate ricorsive, -stacksize 16 *)


