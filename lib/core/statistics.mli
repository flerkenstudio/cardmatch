type t

val create : unit -> t
val games_played : t -> int
val games_won : t -> int
val win_rate : t -> float
val best_score : t -> int
val best_time_ms : t -> int option
val average_score : t -> int
val average_moves : t -> int
val perfect_games : t -> int

val record :
  t -> won:bool -> perfect:bool -> score:int -> moves:int -> time_ms:int -> unit

type serializable
val to_serializable : t -> serializable
val of_serializable : serializable -> t
