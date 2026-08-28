exception Invalid_dimensions of string

type t

val generate : Difficulty.t -> int -> t
val make_unshuffled : int -> int -> t
val shuffle : t -> int -> t

val rows : t -> int
val cols : t -> int
val card_count : t -> int
val valid_index : t -> int -> bool
val card_at : t -> int -> Card.t
val position : t -> int -> int * int   (* row, col *)

(** Invariant: even card count, every pair_id appears exactly twice. *)
val is_consistent : t -> bool
