type entry = {
  player : string;
  score : int;
  time_ms : int;
  difficulty : string;
  mode : string;
  date : string;
  seed : int;
}

exception Corrupted of string

val add : entry -> int option   (* returns rank if it made the board *)
val load : unit -> entry list
val top : ?limit:int -> ?mode:string -> ?difficulty:string -> unit -> entry list
val sanitize : string -> string
val better : entry -> entry -> bool
