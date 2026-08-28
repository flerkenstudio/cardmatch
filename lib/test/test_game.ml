open Cardmatch_lib.Game

let test_is_match () =
  Alcotest.(check bool)
    "same rank matches" true
    (is_match (Hidden (Card (Ace, Hearts))) (Hidden (Card (Ace, Spades))));
  Alcotest.(check bool)
    "different cards don't match" false
    (is_match (Hidden (Card (Ace, Hearts))) (Hidden (Card (Two, Hearts))))

let test_make_board () =
  let b = make_board 4 4 42 in
  Alcotest.(check int) "16 cells" 16 (Array.length b);
  Alcotest.(check bool)
    "all hidden" true
    (Array.for_all (function Hidden _ -> true | _ -> false) b);
  let ranks = Array.map (function Hidden (Card (r, _)) -> r | _ -> Ace) b in
  List.iter
    (fun r ->
      let n = Array.fold_left (fun acc x -> if x = r then acc + 1 else acc) 0 ranks in
      Alcotest.(check bool) "each rank appears 0 or 2 times" true (n = 0 || n = 2))
    [ Ace; Two; Three; Four; Five; Six; Seven; Eight; Nine; Ten ]

let test_seed_is_reproducible () =
  Alcotest.(check bool)
    "same seed, same board" true
    (make_board 4 4 7 = make_board 4 4 7)

let test_reveal_is_pure () =
  let b = make_board 2 2 1 in
  let b' = reveal b 0 in
  Alcotest.(check bool)
    "original untouched" true
    (match b.(0) with Hidden _ -> true | _ -> false);
  Alcotest.(check bool)
    "copy revealed" true
    (match b'.(0) with Revealed _ -> true | _ -> false);
  Alcotest.(check bool) "cannot reveal twice" false (can_reveal b' 0)

(* Hand-built board so the two winning turns are deterministic. *)
let test_play_turn_and_win () =
  let s =
    make_state
      [|
        Hidden (Card (Ace, Hearts));
        Hidden (Card (Two, Hearts));
        Hidden (Card (Ace, Spades));
        Hidden (Card (Two, Spades));
      |]
  in
  let s1 = play_turn s 0 2 in
  Alcotest.(check int) "attempts counted" 1 (attempts s1);
  Alcotest.(check int) "pair found" 1 (pairs_found s1);
  Alcotest.(check bool) "not won yet" false (is_won s1);
  let s2 = play_turn s1 1 3 in
  Alcotest.(check int) "two attempts" 2 (attempts s2);
  Alcotest.(check int) "two pairs" 2 (pairs_found s2);
  Alcotest.(check bool) "won" true (is_won s2);
  Alcotest.(check bool)
    "outcome is Won" true
    (match outcome s2 with Won _ -> true | In_progress -> false)


let test_mismatch_flips_back () =
  (* Build a board by hand so we control the mismatch. *)
  let s =
    make_state
      [|
        Hidden (Card (Ace, Hearts));
        Hidden (Card (Two, Hearts));
        Hidden (Card (Ace, Spades));
        Hidden (Card (Two, Spades));
      |]
  in
  let s1 = play_turn s 0 1 in
  Alcotest.(check int) "attempt counted" 1 (attempts s1);
  Alcotest.(check int) "no pair" 0 (pairs_found s1);
  Alcotest.(check bool)
    "cards back to hidden" true
    (match (board s1).(0), (board s1).(1) with
     | Hidden _, Hidden _ -> true
     | _ -> false);
  Alcotest.(check bool) "not won" false (is_won s1)

let test_illegal_turn () =
  let s = make_state (make_board 2 2 5) in
  Alcotest.check_raises "same index twice" (Invalid_argument
    "play_turn: both indices must be distinct and hidden")
    (fun () -> ignore (play_turn s 0 0))

let () =
  Alcotest.run "CardMatch"
    [
      ( "game logic",
        [
          Alcotest.test_case "is_match" `Quick test_is_match;
          Alcotest.test_case "make_board" `Quick test_make_board;
          Alcotest.test_case "seeded shuffle" `Quick test_seed_is_reproducible;
          Alcotest.test_case "reveal is pure" `Quick test_reveal_is_pure;
          Alcotest.test_case "play_turn wins" `Quick test_play_turn_and_win;
          Alcotest.test_case "mismatch flips back" `Quick test_mismatch_flips_back;
          Alcotest.test_case "illegal turn raises" `Quick test_illegal_turn;
        ] );
    ]
