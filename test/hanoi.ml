
type position = Left | Middle | Right
type move = Move of position * position

let string_of_position = function
  | Left -> "A"
  | Middle -> "B"
  | Right -> "C"

let string_of_move (Move(org, dst)) =
  string_of_position org
  ^ "->"
  ^ string_of_position dst

let print_move =
  let count = ref 0 in
  fun m ->
  (incr count;
   print_int !count;
   print_string (":" ^ (string_of_move m));
   print_newline ())

let rec solve org aux dst = function
  | 1 -> [Move(org, dst)]
  | n -> let sub1 = solve org dst aux (pred n)
         and sub2 = solve aux org dst (pred n)
         in sub1 @ Move(org, dst) :: sub2
  
let hanoi discs = 
  List.iter print_move (solve Left Middle Right discs)

let _ =
  print_string "Numero di dischi? ";
  hanoi(read_int ());
  print_newline ()
