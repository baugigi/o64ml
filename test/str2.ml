
let s0 = "0123456789ABCDEF" in
let s1 = "0123456789ABCDEF" in
for i = 0 to 100 do
  String.blit s0 3 s0 5 4;
  print_string s0;
  print_newline ();
  String.blit s1 5 s1 3 4;
  print_string s1;
  print_newline ();
done

