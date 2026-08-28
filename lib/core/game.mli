type state
and status =
  | Playing
  | Won
  | Lost

type outcome =
  | First_flip
  | Second_flip of bool
  | Game_over_win
  | Game_over_loss

exception Illegal_move of string

val make : difficulty:Difficulty.t -> mode:Game_mode.t -> seed:int -> state
val set_clock : state -> int -> state

val status : state -> status
val board : state -> Board.t
val difficulty : state -> Difficulty.t
val mode : state -> Game_mode.t
val seed : state -> int
val attempts : state -> int
val moves : state -> int
val combo : state -> int
val best_combo : state -> int
val score : state -> int
val hints_used : state -> int
val revealed : state -> int list
val matched_pairs : state -> int
val total_pairs : state -> int

val is_matched : state -> int -> bool
val is_revealed : state -> int -> bool
val is_revealing_first : state -> bool
val can_flip : state -> int -> bool

val flip : state -> int -> state * outcome
val resolve_mismatch_keep : state -> int -> state
val hide_all_revealed : state -> state
val hint_pair : state -> Rng.t -> state

val won : state -> bool
val lost : state -> bool
