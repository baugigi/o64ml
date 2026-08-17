
let print_bool = function
  | true -> print_string "true"
  | _ -> print_string "false"
       
let i, j = ref 0, ref 0
let si, sj = 47 * 17 * 3, 13 * 11 * 7
let _ =
  i := min_int;
  while (* !i <= max_int *) !i < !i + si do
    j := min_int;    
    while (* !j <= max_int *) !j < !j + sj do
      print_int !i;
      print_string " ";
      print_int !j;
      begin
        try
          let q, r = !i / !j, !i mod !j in
          print_string " ";
          print_int q;
          print_string " ";
          print_int r;
          print_string " ";
          print_bool (q * !j + r = !i)
        with _ ->
          print_string "exn"
      end;
      print_newline ();
      j := !j + sj
    done;
    i := !i + si
  done
    
