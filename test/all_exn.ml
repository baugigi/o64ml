
exception Exn12
exception Exn13 of string * int * float * (int * int)
;;
match read_int() with
| 0 -> raise Out_of_memory
| 1 -> raise (Sys_error "aaa")
| 2 -> raise (Failure "aaa")
| 3 -> raise (Invalid_argument "aaa")
| 4 -> raise End_of_file	
| 5 -> raise Division_by_zero	
| 6 -> raise Not_found	
| 7 -> raise (Match_failure("aaa", 1, 2))
| 8 -> raise Stack_overflow	
| 9 -> raise Sys_blocked_io	
|10 -> raise (Assert_failure("aaa", 1, 2))
|11 -> raise (Undefined_recursive_module("aaa", 1, 2))
|12 -> raise Exn12
|13 -> raise (Exn13("1", 2, 3.0, (4, 5)))
| _ -> 0
