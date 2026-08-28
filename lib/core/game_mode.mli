type t =
  | Classic
  | TimeAttack of int
  | Perfect
  | Blitz
  | Zen
  | Streak
  | Daily of string

val name : t -> string
val all : t list
val uses_timer : t -> bool
val allows_hints : t -> bool
val mismatch_is_fatal : t -> bool
val daily_seed : string -> int
val seed_of : t -> int
val daily_challenge_number : string -> string
