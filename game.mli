(** CardMatch: the pure game core.

    [state] is abstract: callers can only build it with [make_state] and
    change it with [play_turn], so [attempts]/[pairs_found] can never drift
    out of sync with the board. [cell] stays concrete because the renderer
    and the tests pattern match on it. *)

type suit = Hearts | Diamonds | Clubs | Spades

type rank =
  | Ace
  | Two
  | Three
  | Four
  | Five
  | Six
  | Seven
  | Eight
  | Nine
  | Ten

type card = Card of rank * suit

type cell =
  | Hidden of card
  | Revealed of card
  | Matched of card

type state

type outcome =
  | In_progress
  | Won of state

val rank_char : rank -> string
val suit_char : suit -> string
val card_to_string : card -> string
val full_deck : card list

(** [make_board rows cols seed] builds a shuffled board of [rows * cols]
    cells (must be even). The same [seed] always yields the same board. *)
val make_board : int -> int -> int -> cell array

val can_reveal : cell array -> int -> bool
val reveal : cell array -> int -> cell array
val is_match : cell -> cell -> bool
val play_turn : state -> int -> int -> state
val is_won : state -> bool
val outcome : state -> outcome
val make_state : cell array -> state
val board : state -> cell array
val attempts : state -> int
val pairs_found : state -> int
