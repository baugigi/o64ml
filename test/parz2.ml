let l = [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]
let myiter = List.iter
let myiter' f = List.iter f
let f = print_int
;;
myiter f l;
myiter' f l;
