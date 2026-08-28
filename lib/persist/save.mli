type t = {
  seed : int;
  difficulty : Core.Difficulty.t;
  mode : Core.Game_mode.t;
  revealed : int list;
  matched : int list;
  score : int;
  attempts : int;
  moves : int;
  combo : int;
  best_combo : int;
  hints_used : int;
  elapsed_ms : int;
  player : string;
}

exception Corrupted of string

val to_string : t -> string
val of_string : string -> t
val save : t -> unit
val load : unit -> t option
val clear : unit -> unit
val exists : unit -> bool
