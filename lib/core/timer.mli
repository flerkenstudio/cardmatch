type t

val make : ?limit_s:int -> unit -> t
val start : t -> unit
val pause : t -> unit
val resume : t -> unit
val stop : t -> unit
val tick : t -> int -> unit        (* advance by ms if running *)
val elapsed_ms : t -> int
val remaining_ms : t -> int option
val expired : t -> bool
val is_running : t -> bool
val format_ms : int -> string
