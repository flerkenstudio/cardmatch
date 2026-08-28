type t
val create : int -> t
val next64 : t -> int64
val int : t -> int -> int   (* [0, n) *)
val bool : t -> bool
val float : t -> float      (* [0.0, 1.0) *)
