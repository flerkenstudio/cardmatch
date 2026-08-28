type t = {
  name : string;
  symbols : string array;
  card_face : string;
  hidden : string;
}

val card_backs : string array
val classic : t
val animals : t
val space : t
val programming : t
val all : t list
val of_name : string -> t option
val symbol : t -> pair_id:int -> pair_count:int -> string
