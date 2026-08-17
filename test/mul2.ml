
for i = -256 to 256 do
  for j = -10 to 10 do
    print_int i;
    print_string " X ";
    print_int j;
    print_string "=";
    print_int(i * j);
    print_newline()
  done
done
  
