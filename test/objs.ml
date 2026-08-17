
let o =
  object
    method m = print_string "HELLO WORLD";
  end

let _ =
  o#m
