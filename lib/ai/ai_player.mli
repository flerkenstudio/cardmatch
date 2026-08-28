type difficulty = Easy | Normal | Hard | Expert
type t

val create : difficulty:difficulty -> seed:int -> t
val choose_first : Core.Game.state -> t -> int
val choose_second : Core.Game.state -> t -> first:int -> int
val observe : t -> index:int -> Core.Card.t -> unit
val observe_matched : t -> int list -> unit
val name : difficulty -> string
val retention : difficulty -> float
val mistake_rate : difficulty -> float
