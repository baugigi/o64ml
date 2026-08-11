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
type game_params = {
  snake_len : int;
  delay_max : int;
  delay_step : int;
  food_at_wall : int;
  bricks_score : int;
  bricks_period : int;
}
val params : game_params
type status = { head : snake_end; tail : snake_end; score : int; }
and snake_end = { pos : IOtools.coord; dir : direction; }
and direction = Up | Down | Left | Right
val opposite_dir : direction -> direction
val dist : int * int -> int * int -> int
val next_to : int * int -> direction -> int * int
type player_action =
    No_action
  | Move of direction
  | Pause
  | Answer_yes
  | Answer_no
  | Unknown
val action_of_key : char -> player_action
type cell =
    Space
  | Wall
  | Food
  | Snake_head
  | Snake_tail of direction * direction
val get_cell : IOtools.coord -> cell
val near_wall : int * int -> bool
val rnd : int -> int -> int
val put_cell : IOtools.coord -> cell -> unit
val delay : int -> unit
val print_center : int -> string -> unit
val print_score : status -> unit
val move_head : direction -> status -> snake_end
val move_tail : status -> snake_end
val feed_snake : status -> unit
val put_brick : status -> unit
val get_new_dir : ?pause:bool -> direction -> direction
val init : unit -> status
val game_loop : status -> unit
