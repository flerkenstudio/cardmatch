val pad_to : string -> int -> string
val render_board :
  theme:Theme.t -> game:Core.Game.state -> cursor:int -> unit -> string
val status_bar : game:Core.Game.state -> time_str:string -> string
val help_bar : string
val render_screen :
  theme:Theme.t -> game:Core.Game.state -> cursor:int -> time_str:string ->
  message:string -> unit -> string
val fmt_int : int -> string
