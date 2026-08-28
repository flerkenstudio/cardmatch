type knowledge = { pair_id : int; confidence : float }
type t

val create : unit -> t
val remember : t -> index:int -> pair_id:int -> unit
val forget : t -> int -> unit
val forget_matched : t -> int list -> unit
val decay : t -> retention:float -> unit
val next_turn : t -> unit
val known_pair : t -> int list option
val known_indices : t -> int list
val memory_size : t -> int
val find_pair_id : t -> int -> int option
val find_partner : t -> exclude:int -> pair_id:int -> int option
