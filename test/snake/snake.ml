(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della licenza GNU GPL ver. 2,  come specificato
   nel file LICENZA-it nella cartella principale del progetto.
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the GNU  General Public License (GPL) ver. 2, as
   specified in the LICENSE-en file in the project root folder.
   —————————————————————————————————————————————————————————————————————— *)

(** The Snake game *)

open IOtools
;;

(** Game parameters *)
type game_params = {
  snake_len     : int; (** Initial snake length *)
  delay_max     : int; (** Max no. of idle cycles to slow the snake *)
  delay_step    : int; (** No. of cycles to reduce for each point gained *)
  food_at_wall  : int; (** Score beyond which food can be next to a wall *)
  bricks_score  : int; (** Score beyond which bricks can appear *)
  bricks_period : int  (** Points ( > 0 ) between two brick apparitions *) 
}
;;

let params = {
  snake_len     =  10;
  delay_max     = 250;
  delay_step    =   4;
  food_at_wall  =  50;
  bricks_score  =  20;
  bricks_period =   3
}
;;

(** Game status *)
type status = {
  head : snake_end; (** Snake's head data *)
  tail : snake_end; (** Snake's tail data *)
  score : int       (** Gamer's current score *)
}
(** Snake's extremities *)
and snake_end = {
  pos : coord;      (** Position *)
  dir : direction   (** Direction the end is facing *)
}
(** Directions *)
and direction = Up | Down | Left | Right
;;

(** [opposite_dir dir] returns the opposite direction of [dir] *)
let opposite_dir = function
  | Up    -> Down
  | Down  -> Up
  | Left  -> Right
  | Right -> Left
;;

(** [dist pos0 pos1] returns the "Manhattan distance" between two positions *)
let dist (x, y) (x', y') = abs (x - x') + abs (y - y')
;;

(** [next_to coord dir] returns the coordinates of the location next to [coord]
    in the direction [dir] *)
let next_to (x, y) = function
  | Up    -> (x, succ y)
  | Down  -> (x, pred y)
  | Left  -> (pred x, y)
  | Right -> (succ x, y)
;;

(*****)

(** type: player actions *)
type player_action =
  | No_action
  | Move of direction
  | Pause
  | Answer_yes
  | Answer_no
  | Unknown
;;

(** [action_of_key keypress] returns the action corresponding to a [keypress] *)
let action_of_key = function
  | '\145' -> Move Up
  | '\017' -> Move Down
  | '\157' -> Move Left
  | '\029' -> Move Right
  | 'p'    -> Pause
  | 'y'    -> Answer_yes
  | 'n'    -> Answer_no
  | '\000' -> No_action
  | _      -> Unknown
;;

(*****)

(** type: drawable cells *)
type cell =
  | Space
  | Wall
  | Food
  | Snake_head
  | Snake_tail of direction * direction
;;

(** [get_cell pos] returns the cell at position [pos] *) 
let get_cell pos = match get_char pos with
  | 0x20 -> Space
  | 0x5a -> Food
  | 0x51 -> Snake_head
  | 0x42 -> Snake_tail(Up, Down)
  | 0x4b -> Snake_tail(Up, Left)
  | 0x4a -> Snake_tail(Up, Right)
  | 0x49 -> Snake_tail(Down, Left)
  | 0x55 -> Snake_tail(Down, Right)
  | 0x43 -> Snake_tail(Left, Right)
  | _ -> Wall
;;

(** [near_wall cell] is [true] if [cell] shares a border or a corner with
    a wall *)
let near_wall (x, y) =
  let (px, sx, py, sy) = (pred x, succ x, pred y, succ y) in
  let rec f_aux = function
    | cell :: cells -> get_cell cell = Wall || f_aux cells
    | [] -> false in
  f_aux [(px, sy);   (x, sy);   (sx, sy);
         (px,  y); (*(x,  y);*) (sx,  y);
         (px, py);   (x, py);   (sx, py)]
;;

(** [rnd min max] returns a random integer from [min] to [max];
    [min] should be >= 0 (not checked) *)
let rnd min max = min + Random.int (succ max - min)
;;

(** [put_cell pos cell] draws a [cell] at position [pos] *)
let put_cell pos cell = put_char pos (match cell with
    | Space      -> 0x20
    | Wall       -> 0x66
    | Food       -> 0x5a
    | Snake_head -> 0x51
    | Snake_tail(Up, Down)    | Snake_tail(Down, Up)    -> 0x42
    | Snake_tail(Up, Left)    | Snake_tail(Left, Up)    -> 0x4b
    | Snake_tail(Up, Right)   | Snake_tail(Right, Up)   -> 0x4a
    | Snake_tail(Down, Left)  | Snake_tail(Left, Down)  -> 0x49
    | Snake_tail(Down, Right) | Snake_tail(Right, Down) -> 0x55 
    | Snake_tail(Left, Right) | Snake_tail(Right, Left) -> 0x43
    | _ -> failwith "put_cell")
;;

(** [delay n] does an idle loop [n] times to slow down the snake's run *)
let rec delay n = if n > 0 then delay (pred n)
;;

(** [print_center y str] prints [str] centered on the line of coordinate [y] *)
let print_center y str = print_at ((40 - String.length str) / 2, y) str
;;

(** [print_score st] gets the player's score from [st] and print it *)
let print_score st =
  let score = string_of_int st.score in
  let score = String.(sub score 1 (pred (length score))) in
  print_at (2, 24) ("score:" ^ score)
;;

(*****)

(** [move_head new_dir st] moves the snake's head from [st.head.pos] one step
    in the [new_dir] direction, adds a piece of body next to the head and
    returns the new value for the [st.head] field *)
let move_head new_dir st =
  let current_pos = st.head.pos in
  let new_pos = next_to current_pos new_dir in
  put_cell new_pos Snake_head;
  put_cell current_pos (Snake_tail(new_dir, opposite_dir st.head.dir));
  { pos = new_pos; dir = new_dir }
;;

(** [move_tail st] deletes the snake's tail end from [st.tail.pos] and returns
    the new value for the [st.tail] field *)
let move_tail st =
  let tail = st.tail in
  let pos = tail.pos in
  match get_cell pos with
  | Snake_tail(a, b) ->
    let towards_body = if tail.dir = a then b else a in
    put_cell pos Space;
    { pos = next_to pos towards_body; dir = opposite_dir towards_body }
  | _ -> failwith "move_tail"
;;

(** [feed_snake st] put a piece of food in a random empty place; if
    [st.score] is greater than [params.food_at_wall], the food may be placed
    next to a wall. Teorically this function may not terminate; practically,
    you should have filled all the available holes with your long snake ;) *)
let rec feed_snake st =
  let ok_walls = st.score > params.food_at_wall in
  let pos = if ok_walls then (rnd 1 38, rnd 1 23) else (rnd 2 37, rnd 2 22) in
  match get_cell pos with
  | Space when ok_walls || not (near_wall pos) -> put_cell pos Food
  | _ -> feed_snake st
;;

(** [put_brick st] chooses a random place and puts a wall brick in it when
    [st.score] is greater than [params.bricks_score] and a multiple of
    [params.bricks_period]; the brick is not put if there are other ones in
    the neighbourhood or the place is too near the snake's head *)
let put_brick =
  let cnt = ref params.bricks_period in fun st ->
    if st.score > params.bricks_score then
      if !cnt > 0 then decr cnt
      else (let pos = (rnd 2 37, rnd 2 22) in
            if get_cell pos = Space && dist st.head.pos pos > 5
               && not (near_wall pos) then
              (put_cell pos Wall;
               cnt := params.bricks_period))
;;
           
(** [get_new_dir current_dir] returns the new snake direction entered by the
    player, if any, or [current_dir]; if the player requests a [Pause], it waits
    for a new player action *)
let rec get_new_dir ?(pause=false) cur_dir = match action_of_key(get_key()) with
  | Move new_dir when new_dir <> opposite_dir cur_dir -> new_dir
  | Pause when not pause -> get_new_dir ~pause:true cur_dir
  | No_action when pause -> get_new_dir ~pause cur_dir
  | _ -> cur_dir
;;

(*****)

(** [init ()] performs the game initialization and returns the first game
    status *)
let init () =
  let (x, y) = ((40 - params.snake_len) / 2, 12) in
  let st = { head = { pos = (x, y); dir = Left };
             tail = { pos = (x + params.snake_len, y); dir = Right };
             score = 0 } in
  clear_screen ();
  set_uppercase ();
  for x = 0 to 39 do
    let y = 24 * x / 39 in
    put_cell (x, 0) Wall;       (* top wall *)
    put_cell (39 - x, 24) Wall; (* bottom wall *)
    put_cell (0, y) Wall;       (* left wall *)
    put_cell (39, 24 - y) Wall  (* right wall *)
  done;
  print_score st;
  put_cell (x, y) Snake_head;
  for i = 1 to params.snake_len do
    put_cell (x + i, y) (Snake_tail (Left, Right))
  done;
  Random.self_init ();
  feed_snake st;
  st
;;

(** [game_loop st] performs the game loop, starting from [st] status *)
let rec game_loop st =
  delay (params.delay_max - st.score * params.delay_step);
  let dir = get_new_dir st.head.dir in
  match get_cell (next_to st.head.pos dir) with
  | Space -> game_loop { st with head = move_head dir st; tail = move_tail st }
  | Food ->
    let st = { st with head = move_head dir st; score = succ st.score } in
    print_score st;
    put_brick st;
    feed_snake st;
    game_loop st
  | _ ->
    let rec get_answer () = match action_of_key (get_key ()) with
      | Answer_yes -> true
      | Answer_no -> false
      | _ -> get_answer () in
    print_center 12 " *** you lost! *** ";
    print_center 11 " play again (y/n)? ";
    if get_answer () then game_loop (init ())
;;

(* main *)
game_loop (init ())
