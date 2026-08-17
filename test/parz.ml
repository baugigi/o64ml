
let print n = print_endline (string_of_int n)

let x2 f x = 2 * (f x)
                 
let g1 f x = x2 (fun x' -> x2 f x') x
let g2 f x = x2 (x2 f) x
let g3 f   = x2 (x2 f)

let myfun = succ

;;

print (g1 myfun 10);
print (g2 myfun 10);
print (g3 myfun 10);




