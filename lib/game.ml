(* ---- Types ---- *)

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
  | Hidden of card (* face-down *)
  | Revealed of card (* face-up, this turn only *)
  | Matched of card (* solved pair *)

type board = cell array (* 1D array, index = row * cols + col *)

type state = { board : board; attempts : int; pairs_found : int }

type outcome =
  | In_progress
  | Won of state

(* ---- Small helpers ---- *)

let rank_char = function
  | Ace -> "A"
  | Two -> "2"
  | Three -> "3"
  | Four -> "4"
  | Five -> "5"
  | Six -> "6"
  | Seven -> "7"
  | Eight -> "8"
  | Nine -> "9"
  | Ten -> "T"

let suit_char = function
  | Hearts -> "H"
  | Diamonds -> "D"
  | Clubs -> "C"
  | Spades -> "S"

let card_to_string (Card (r, s)) = rank_char r ^ suit_char s

(* ---- Setup ---- *)

let full_deck : card list =
  List.concat_map
    (fun r -> List.map (fun s -> Card (r, s)) [ Hearts; Diamonds; Clubs; Spades ])
    [ Ace; Two; Three; Four; Five; Six; Seven; Eight; Nine; Ten ]

(* Fisher-Yates on a copy, driven by a seeded [Random.State.t] so games are
   reproducible: same seed => same board. *)
let shuffle_with (rng : Random.State.t) (a : 'a array) : 'a array =
  let a = Array.copy a in
  for i = Array.length a - 1 downto 1 do
    let j = Random.State.int rng (i + 1) in
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp
  done;
  a

let all_ranks =
  [| Ace; Two; Three; Four; Five; Six; Seven; Eight; Nine; Ten |]

(* Cards match on rank, so a board uses each rank at most once: one pair =
   one rank in two different suits. *)
let make_board rows cols seed : board =
  let n = rows * cols in
  if n <= 0 || n mod 2 <> 0 then
    invalid_arg "make_board: rows * cols must be positive and even";
  let pairs = n / 2 in
  if pairs > Array.length all_ranks then
    invalid_arg "make_board: board too large for the deck";
  let rng = Random.State.make [| seed |] in
  let chosen = Array.sub (shuffle_with rng all_ranks) 0 pairs in
  let doubled =
    Array.concat
      [
        Array.map (fun r -> Card (r, Hearts)) chosen;
        Array.map (fun r -> Card (r, Spades)) chosen;
      ]
  in
  Array.map (fun c -> Hidden c) (shuffle_with rng doubled)


(* ---- Rules (all pure functions!) ---- *)

let can_reveal (b : board) (i : int) : bool =
  i >= 0
  && i < Array.length b
  && match b.(i) with Hidden _ -> true | Revealed _ | Matched _ -> false

let reveal (b : board) (i : int) : board =
  let b' = Array.copy b in
  (match b'.(i) with
   | Hidden c -> b'.(i) <- Revealed c
   | Revealed _ | Matched _ -> ());
  b'

let card_of_cell = function Hidden c | Revealed c | Matched c -> c

let is_match (c1 : cell) (c2 : cell) : bool =
  let (Card (r1, _)) = card_of_cell c1 in
  let (Card (r2, _)) = card_of_cell c2 in
  r1 = r2

let play_turn (s : state) (i1 : int) (i2 : int) : state =
  if i1 = i2 || not (can_reveal s.board i1) || not (can_reveal s.board i2) then
    invalid_arg "play_turn: both indices must be distinct and hidden";
  let b = reveal (reveal s.board i1) i2 in
  let matched = is_match b.(i1) b.(i2) in
  let b' = Array.copy b in
  if matched then begin
    b'.(i1) <- Matched (card_of_cell b.(i1));
    b'.(i2) <- Matched (card_of_cell b.(i2))
  end
  else begin
    b'.(i1) <- Hidden (card_of_cell b.(i1));
    b'.(i2) <- Hidden (card_of_cell b.(i2))
  end;
  {
    board = b';
    attempts = s.attempts + 1;
    pairs_found = (if matched then s.pairs_found + 1 else s.pairs_found);
  }

let is_won (s : state) : bool =
  Array.for_all (function Matched _ -> true | _ -> false) s.board

let outcome (s : state) : outcome = if is_won s then Won s else In_progress

(* ---- Accessors (state is abstract outside this module) ---- *)

let make_state (board : board) : state = { board; attempts = 0; pairs_found = 0 }
let board (s : state) : board = s.board
let attempts (s : state) : int = s.attempts
let pairs_found (s : state) : int = s.pairs_found
