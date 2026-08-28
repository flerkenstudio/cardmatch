val data_dir : unit -> string
val ensure_dir : unit -> unit
val read_file : string -> string option
val write_file : string -> string -> unit
val delete_file : string -> unit
val file_exists : string -> bool

val save_path : string
val stats_path : string
val leaderboard_path : string
val config_path : string
