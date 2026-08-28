type t

val make : id:int -> pair_id:int -> t
val id : t -> int
val pair_id : t -> int

(** Two cards match iff [equal] holds (same pair_id). *)
val equal : t -> t -> bool
val compare : t -> t -> int
