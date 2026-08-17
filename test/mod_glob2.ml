
let a = "0";;
a.[0] <- char_of_int(succ (int_of_char a.[0]));;
print_string a;;
