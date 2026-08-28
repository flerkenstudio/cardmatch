open Core

type difficulty = Easy | Normal | Hard | Expert

type t = {
  difficulty : difficulty;
  memory : Memory.t;
  rng : Rng.t;
}

let retention = function
  | Easy -> 0.55   (* forgets fast *)
  | Normal -> 0.80
  | Hard -> 0.95
  | Expert -> 1.0  (* perfect memory *)

let mistake_rate = function
  | Easy -> 0.35
  | Normal -> 0.15
  | Hard -> 0.05
  | Expert -> 0.0

let create ~difficulty ~seed =
  { difficulty; memory = Memory.create (); rng = Rng.create seed }

let all_unmatched game =
  let n = Board.card_count (Game.board game) in
  List.filter (fun i -> not (Game.is_matched game i))
    (List.init n (fun i -> i))

let choose_first game t =
  Memory.decay t.memory ~retention:(retention t.difficulty);
  Memory.next_turn t.memory;
  match Memory.known_pair t.memory with
  | Some (a :: _b :: _) -> a
  | _ ->
      let unknown =
        List.filter (fun i ->
          not (List.mem i (Memory.known_indices t.memory)))
          (all_unmatched game)
      in
      (match unknown with
       | [] ->
           (* knows everything - pick any known card *)
           (match Memory.known_indices t.memory with
            | i :: _ -> i | [] -> 0)
       | _ ->
           List.nth unknown (Rng.int t.rng (List.length unknown)))

let choose_second game t ~first =
  (* If memory reveals the partner of [first], play it - unless
     we make a deliberate mistake (lower difficulties). *)
  let card = Board.card_at (Game.board game) first in
  let pid = Card.pair_id card in
  let partner = Memory.find_partner t.memory ~exclude:first ~pair_id:pid in
  let make_mistake = Rng.float t.rng < mistake_rate t.difficulty in
  match partner with
  | Some p when not make_mistake -> p
  | _ ->
      let unknown =
        List.filter (fun i ->
          i <> first && not (Game.is_matched game i)
          && not (List.mem i (Memory.known_indices t.memory)))
          (all_unmatched game)
      in
      (match unknown with
       | [] ->
           let others = List.filter (fun i -> i <> first)
                          (all_unmatched game) in
           (match others with
            | i :: _ -> i | [] -> first)
       | _ ->
           List.nth unknown (Rng.int t.rng (List.length unknown)))

(** Call after each flip is revealed, so the AI "sees" the card. *)
let observe t ~index card =
  Memory.remember t.memory ~index ~pair_id:(Card.pair_id card)

(** Call when a pair is matched, to forget those indices. *)
let observe_matched t indices =
  Memory.forget_matched t.memory indices

let name = function
  | Easy -> "AI Easy" | Normal -> "AI Normal"
  | Hard -> "AI Hard" | Expert -> "AI Expert"
