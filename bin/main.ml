open Cardmatch_lib.Game

let cols = 4
let rows = 4

let render_cell = function
  | Hidden _ -> " ?? "
  | Revealed (Card (r, _)) -> String.concat "" [ " "; rank_char r; "  " ]
  | Matched _ -> " ** "

let print_board (b : cell array) =
  print_newline ();
  print_string "     ";
  for c = 0 to cols - 1 do
    Printf.printf " c%d  " c
  done;
  print_newline ();
  for r = 0 to rows - 1 do
    Printf.printf "r%d  " r;
    for c = 0 to cols - 1 do
      print_string (render_cell b.((r * cols) + c))
    done;
    print_newline ()
  done;
  print_newline ()

(* Ask for one index until it is a legal, hidden cell. *)
let rec read_index (b : cell array) (prompt : string) : int =
  Printf.printf "%s (0-%d, or q to quit): %!" prompt (Array.length b - 1);
  match input_line stdin with
  | exception End_of_file -> exit 0
  | "q" | "Q" -> exit 0
  | line -> (
      match int_of_string_opt (String.trim line) with
      | Some i when can_reveal b i -> i
      | Some _ ->
          print_endline "That card is not available. Try another.";
          read_index b prompt
      | None ->
          print_endline "Please type a number.";
          read_index b prompt)

let rec game_loop (state : state) : unit =
  print_board (board state);
  if is_won state then
    Printf.printf "You won in %d attempts! Pairs found: %d\n%!" (attempts state)
      (pairs_found state)
  else begin
    let b = board state in
    let i1 = read_index b "First card" in
    let i2 =
      let rec pick () =
        let i = read_index b "Second card" in
        if i = i1 then (
          print_endline "You already picked that one.";
          pick ())
        else i
      in
      pick ()
    in
    let peeked = reveal (reveal b i1) i2 in
    print_board peeked;
    let next = play_turn state i1 i2 in
    if pairs_found next > pairs_found state then print_endline "Match!"
    else print_endline "No match.";
    game_loop next
  end

let () =
  let seed =
    Random.self_init ();
    Random.int 1000
  in
  Printf.printf "CardMatch  (seed %d)\n" seed;
  game_loop (make_state (make_board rows cols seed))
