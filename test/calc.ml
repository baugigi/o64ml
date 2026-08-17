
let f () =
  let a = ref 0
  and b = ref 0
  and c = ref 0
  in begin
    for i = 1 to 10000 do
      a := i;
      b := i;
      c := !c + !a * !b;
    done;
    !c;
  end;;
f();;
