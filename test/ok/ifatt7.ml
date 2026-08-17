
let f n =
  let r = ref 1 in
  for i = 2 to n do
    r := !r * i
  done;
  !r;;
f 7;;
