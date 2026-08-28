type state = {
  board : Board.t;
  difficulty : Difficulty.t;
  mode : Game_mode.t;
  seed : int;
  revealed : int list;        (* indices currently face-up (1 or 2) *)
  matched : bool array;       (* per index *)
  attempts : int;
  moves : int;
  combo : int;
  best_combo : int;
  score : int;
  hints_used : int;
  status : status;
  started_at_ms : int;        (* caller-provided clock snapshot *)
}

and status =
  | Playing
  | Won
  | Lost

exception Illegal_move of string

let make ~difficulty ~mode ~seed =
  let board = Board.generate difficulty seed in
  { board; difficulty; mode; seed;
    revealed = [];
    matched = Array.make (Board.card_count board) false;
    attempts = 0; moves = 0; combo = 0; best_combo = 0; score = 0;
    hints_used = 0;
    status = Playing;
    started_at_ms = 0 }

let set_clock st ms = { st with started_at_ms = ms }

let status st = st.status
let board st = st.board
let difficulty st = st.difficulty
let mode st = st.mode
let seed st = st.seed
let attempts st = st.attempts
let moves st = st.moves
let combo st = st.combo
let best_combo st = st.best_combo
let score st = st.score
let hints_used st = st.hints_used
let revealed st = st.revealed

let is_matched st i = st.matched.(i)

let is_revealed st i =
  List.mem i st.revealed || st.matched.(i)

let matched_pairs st =
  Array.fold_left (fun acc m -> if m then acc + 1 else acc) 0 st.matched / 2

let total_pairs st = Difficulty.pair_count st.difficulty

let is_revealing_first st = List.length st.revealed = 0

let can_flip st i =
  st.status = Playing
  && Board.valid_index st.board i
  && not (List.mem i st.revealed)
  && not st.matched.(i)

(** Flip a card. Returns (new_state, outcome) where outcome tells the
    shell what happened so it can score/notify. *)
type outcome =
  | First_flip
  | Second_flip of bool      (* matched? *)
  | Game_over_win
  | Game_over_loss

let flip st i =
  if not (can_flip st i) then
    raise (Illegal_move
      (if not (Board.valid_index st.board i) then "invalid index"
       else if st.matched.(i) then "card already matched"
       else if List.mem i st.revealed then "card already revealed"
       else "game not active"));
  match st.revealed with
  | [] -> { st with revealed = [ i ]; moves = st.moves + 1 }, First_flip
  | [ j ] ->
      if i = j then raise (Illegal_move "cannot flip the same card twice");
      let attempts = st.attempts + 1 in
      let card_i = Board.card_at st.board i in
      let card_j = Board.card_at st.board j in
      if Card.equal card_i card_j then begin
        let matched = Array.copy st.matched in
        matched.(i) <- true;
        matched.(j) <- true;
        let combo = st.combo + 1 in
        let best_combo = max st.best_combo combo in
        let matched_count =
          Array.fold_left (fun a m -> if m then a + 1 else a) 0 matched in
        let pairs_done = matched_count / 2 in
        let won = pairs_done = total_pairs st in
        let status = if won then Won else Playing in
        let multiplier = Difficulty.score_multiplier st.difficulty in
        let fast = st.attempts <= matched_count / 2 in
        let streak_complete = won && Game_mode.uses_timer st.mode in
        let base = 100 in
        let bonus = if fast then 50 else 0 in
        let combo_bonus = if combo > 1 then combo * 25 else 0 in
        let streak_bonus = if streak_complete then 250 else 0 in
        let pts =
          int_of_float
            (float_of_int (base + bonus + combo_bonus + streak_bonus)
             *. multiplier)
        in
        let outcome = if won then Game_over_win else Second_flip true in
        ( { st with revealed = []; matched; attempts; combo; best_combo;
                   moves = st.moves + 1; score = st.score + pts; status },
          outcome )
      end else begin
        let combo = 0 in
        let lost = Game_mode.mismatch_is_fatal st.mode in
        let status = if lost then Lost else Playing in
        let outcome = if lost then Game_over_loss else Second_flip false in
        let penalty = if lost then 0 else -20 in
        ( { st with revealed = [ i; j ]; attempts; combo;
                   moves = st.moves + 1; score = max 0 (st.score + penalty);
                   status },
          outcome )
      end
  | _ -> raise (Illegal_move "two cards already revealed - resolve first")

let resolve_mismatch_keep st keep =
  (* shell decides: after showing mismatch, keep [keep] revealed, hide other *)
  { st with revealed = [ keep ] }

let hide_all_revealed st = { st with revealed = [] }

let hint_pair st rng =
  (* find an unmatched pair and reveal both indices briefly *)
  if not (Game_mode.allows_hints st.mode) then
    raise (Illegal_move "hints disabled in this mode");
  let by_pair = Hashtbl.create 16 in
  let n = Board.card_count st.board in
  for idx = 0 to n - 1 do
    if not st.matched.(idx) then begin
      let pid = Card.pair_id (Board.card_at st.board idx) in
      match Hashtbl.find_opt by_pair pid with
      | None -> Hashtbl.add by_pair pid [ idx ]
      | Some l -> Hashtbl.replace by_pair pid (idx :: l)
    end
  done;
  let candidates =
    Hashtbl.fold (fun _ v acc -> if List.length v = 2 then v :: acc else acc)
      by_pair []
  in
  match candidates with
  | [] -> raise (Illegal_move "no hints available")
  | _ ->
      let pick = List.nth candidates (Rng.int rng (List.length candidates)) in
      let a, b = match pick with a :: b :: _ -> a, b | _ -> assert false in
      { st with revealed = [ a; b ]; hints_used = st.hints_used + 1;
                score = max 0 (st.score - 50) }

let won st = st.status = Won
let lost st = st.status = Lost
