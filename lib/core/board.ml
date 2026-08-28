exception Invalid_dimensions of string

type t = {
  rows : int;
  cols : int;
  cards : Card.t array;   (* cards[row * cols + col] *)
}

let make_unshuffled rows cols =
  if not (Difficulty.valid_dimensions rows cols) then
    raise (Invalid_dimensions
      (Printf.sprintf "invalid board %dx%d" rows cols));
  let cards = Array.init (rows * cols) (fun i ->
    Card.make ~id:i ~pair_id:(i / 2))
  in
  { rows; cols; cards }

(** Fisher-Yates with seeded Rng - deterministic per seed. *)
let shuffle board seed =
  let rng = Rng.create seed in
  let cards = Array.copy board.cards in
  for i = Array.length cards - 1 downto 1 do
    let j = Rng.int rng (i + 1) in
    let tmp = cards.(i) in
    cards.(i) <- cards.(j);
    cards.(j) <- tmp
  done;
  { board with cards }

let generate difficulty seed =
  let p = Difficulty.preset_of difficulty in
  make_unshuffled p.rows p.cols |> fun b -> shuffle b seed

let rows b = b.rows
let cols b = b.cols
let card_count b = Array.length b.cards

let valid_index b i = i >= 0 && i < card_count b

let card_at b i = b.cards.(i)

let position b i = (i / b.cols, i mod b.cols)

(** Every card in the array must have exactly one partner. *)
let is_consistent b =
  let n = card_count b in
  if n mod 2 <> 0 then false
  else begin
    let counts = Hashtbl.create 16 in
    Array.iter (fun c ->
      let pid = Card.pair_id c in
      let cur = try Hashtbl.find counts pid with Not_found -> 0 in
      Hashtbl.replace counts pid (1 + cur))
      b.cards;
    Hashtbl.fold (fun _ v acc -> acc && v = 2) counts true
  end
