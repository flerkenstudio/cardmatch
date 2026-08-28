type t =
  | Easy
  | Normal
  | Hard
  | Expert
  | Extreme
  | Custom of int * int

type preset = {
  name : string;
  rows : int;
  cols : int;
  score_multiplier : float;
}

val presets : (t * preset) list
val preset_of : t -> preset
val all : t list
val of_string : string -> t option
val valid_dimensions : int -> int -> bool
val card_count : t -> int
val pair_count : t -> int
val name : t -> string
val score_multiplier : t -> float
