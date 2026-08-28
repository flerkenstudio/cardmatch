type t

val create : unit -> t
val current : t -> int
val combo : t -> int
val best_combo : t -> int
val hints_used : t -> int

val base_match : int
val fast_match_bonus : int
val combo_bonus_per_level : int
val wrong_penalty : int
val hint_penalty : int
val streak_complete_bonus : int

val register_match :
  t -> fast:bool -> streak_complete:bool -> difficulty_multiplier:float -> int
val register_mismatch : t -> unit
val register_hint : t -> unit
val reset : t -> unit
