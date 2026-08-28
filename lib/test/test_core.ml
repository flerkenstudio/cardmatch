open Core

let passed = ref 0
let failed = ref 0

let check name cond =
  if cond then begin incr passed; Printf.printf "  [PASS] %s\n" name end
  else begin incr failed; Printf.printf "  [FAIL] %s\n" name end

let check_raises name f =
  (try ignore (f ()); check name false
   with _ -> check name true)

(* ---------------- board ---------------- *)

let test_board () =
  print_endline "board:";
  check "board has complete pairs"
    (Board.is_consistent (Board.generate Difficulty.Normal 42));

  let a = Board.generate Difficulty.Hard 7 in
  let b = Board.generate Difficulty.Hard 7 in
  let same_seed_same_board =
    let n = Board.card_count a in
    let ok = ref true in
    for i = 0 to n - 1 do
      if not (Card.equal (Board.card_at a i) (Board.card_at b i)) then ok := false
    done;
    !ok
  in
  check "deterministic per seed" same_seed_same_board;

  let a2 = Board.generate Difficulty.Hard 1 in
  let b2 = Board.generate Difficulty.Hard 2 in
  let differ =
    let n = Board.card_count a2 in
    let d = ref false in
    for i = 0 to n - 1 do
      if not (Card.equal (Board.card_at a2 i) (Board.card_at b2 i)) then d := true
    done;
    !d
  in
  check "different seeds differ" differ;

  check_raises "3x3 invalid" (fun () -> Board.make_unshuffled 3 3);

  check "1x4 invalid" (not (Difficulty.valid_dimensions 1 4));
  check "11x4 invalid" (not (Difficulty.valid_dimensions 11 4));
  check "4x5 valid (even count)" (Difficulty.valid_dimensions 4 5);
  check "3x5 invalid (odd count)" (not (Difficulty.valid_dimensions 3 5));
  check "2x2 valid" (Difficulty.valid_dimensions 2 2)

(* ---------------- game ---------------- *)

let find_pair b n =
  let rec go i j =
    if i >= n then failwith "no pair"
    else if j >= n then go (i + 1) (i + 2)
    else if Card.equal (Board.card_at b i) (Board.card_at b j) then (i, j)
    else go i (j + 1)
  in
  go 0 1

let find_mismatch b n =
  let rec go i j =
    if i >= n then failwith "no mismatch"
    else if j >= n then go (i + 1) (i + 2)
    else if not (Card.equal (Board.card_at b i) (Board.card_at b j)) then (i, j)
    else go i (j + 1)
  in
  go 0 1

let test_game () =
  print_endline "game:";
  let g = Game.make ~difficulty:Difficulty.Easy ~mode:Game_mode.Classic ~seed:1 in
  let b = Game.board g in
  let n = Board.card_count b in
  let (a, c) = find_pair b n in
  let g1, o1 = Game.flip g a in
  check "first flip" (match o1 with Game.First_flip -> true | _ -> false);
  let g2, o2 = Game.flip g1 c in
  check "second flip matches"
    (match o2 with Game.Second_flip true | Game.Game_over_win -> true | _ -> false);
  check "combo increments" (Game.combo g2 = 1);

  let g = Game.make ~difficulty:Difficulty.Easy ~mode:Game_mode.Classic ~seed:1 in
  check_raises "bad index" (fun () -> Game.flip g 999);
  let g1, _ = Game.flip g 0 in
  check_raises "same card twice" (fun () -> Game.flip g1 0);

  let g = Game.make ~difficulty:Difficulty.Normal ~mode:Game_mode.Perfect ~seed:5 in
  let b = Game.board g in
  let n = Board.card_count b in
  let (a, c) = find_mismatch b n in
  let g1, _ = Game.flip g a in
  let _, o2 = Game.flip g1 c in
  check "perfect mode: mismatch is fatal"
    (match o2 with Game.Game_over_loss -> true | _ -> false)

(* ---------------- scoring ---------------- *)

let test_scoring () =
  print_endline "scoring:";
  let s = Scoring.create () in
  let p1 = Scoring.register_match s ~fast:true ~streak_complete:false ~difficulty_multiplier:1.0 in
  check "first match = 150" (p1 = 150);
  let p2 = Scoring.register_match s ~fast:false ~streak_complete:false ~difficulty_multiplier:1.0 in
  check "combo x2 bonus = 150" (p2 = 150);
  check "combo tracked as 2" (Scoring.combo s = 2);
  Scoring.register_mismatch s;
  check "combo resets to 0" (Scoring.combo s = 0);

  let s = Scoring.create () in
  Scoring.register_mismatch s;
  Scoring.register_mismatch s;
  check "score never negative" (Scoring.current s = 0)

(* ---------------- timer ---------------- *)

let test_timer () =
  print_endline "timer:";
  let t = Timer.make ~limit_s:1 () in
  Timer.start t;
  Timer.tick t 500;
  check "not expired at 500ms/1s" (not (Timer.expired t));
  Timer.tick t 600;
  check "expired past 1s" (Timer.expired t);

  let t = Timer.make ~limit_s:10 () in
  Timer.start t;
  Timer.pause t;
  Timer.tick t 5000;
  check "no tick while paused" (Timer.elapsed_ms t = 0)

(* ---------------- ai ---------------- *)

let test_ai () =
  print_endline "ai:";
  let ai = Ai.Ai_player.create ~difficulty:Ai.Ai_player.Expert ~seed:3 in
  let g = Game.make ~difficulty:Difficulty.Normal ~mode:Game_mode.Classic ~seed:3 in
  let b = Game.board g in
  let n = Board.card_count b in
  let (a, c) = find_pair b n in
  Ai.Ai_player.observe ai ~index:a (Board.card_at b a);
  Ai.Ai_player.observe ai ~index:c (Board.card_at b c);
  let choice = Ai.Ai_player.choose_first g ai in
  check "expert AI plays a known card" (choice = a || choice = c)

let () =
  test_board ();
  test_game ();
  test_scoring ();
  test_timer ();
  test_ai ();
  Printf.printf "\n%d passed, %d failed\n" !passed !failed;
  if !failed > 0 then exit 1
