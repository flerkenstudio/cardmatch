open Core

let pad_to s w =
  let len = String.length s in
  if len >= w then s else s ^ String.make (w - len) ' '

let render_card ?(selected = false) ~theme:(_ : Theme.t) ~symbol ~state () =
  (* state: `Hidden | `Revealed | `Matched *)
  let sym =
    match state with
    | `Hidden -> "??"
    | `Revealed | `Matched -> symbol
  in
  let body = pad_to sym 4 in
  let inner = " " ^ body ^ " " in
  let (tl, tr, bl, br), hline =
    if selected then ("+", "+", "+", "+"), "="
    else ("+", "+", "+", "+"), "-"
  in
  let top = tl ^ String.make 6 hline.[0] ^ tr in
  let bottom = bl ^ String.make 6 hline.[0] ^ br in
  let colored =
    match state with
    | `Matched -> Ansi.wrap Ansi.green inner
    | `Revealed -> Ansi.wrap Ansi.yellow inner
    | `Hidden -> inner
  in
  [ top; "|" ^ colored ^ "|"; bottom ]

let render_board ~theme ~game ~cursor () =
  let b = Game.board game in
  let rows = Board.rows b and cols = Board.cols b in
  let pc = Game.total_pairs game in
  let out = Buffer.create 1024 in
  for r = 0 to rows - 1 do
    (* render each card in 3 stacked lines *)
    let lines = Array.init 3 (fun _ -> Buffer.create 64) in
    for c = 0 to cols - 1 do
      let i = r * cols + c in
      let state =
        if Game.is_matched game i then `Matched
        else if Game.is_revealed game i then `Revealed
        else `Hidden
      in
      let card = Board.card_at b i in
      let sym = Theme.symbol theme ~pair_id:(Card.pair_id card) ~pair_count:pc in
      let cl = render_card ~selected:(cursor = i) ~theme ~symbol:sym ~state () in
      Array.iteri (fun li _ -> Buffer.add_string lines.(li) (List.nth cl li ^ " ")) lines
    done;
    Array.iter (fun l -> Buffer.add_string out (Buffer.contents l ^ "\n")) lines
  done;
  Buffer.contents out

let fmt_int n =
  let s = string_of_int n in
  let rec group s =
    if String.length s > 3 then
      group (String.sub s 0 (String.length s - 3))
      ^ "," ^ String.sub s (String.length s - 3) 3
    else s
  in
  group s

let status_bar ~game ~time_str =
  Printf.sprintf
    " SCORE %s | MOVES %d TIME %s | COMBO x%d | PAIRS %d/%d "
    (fmt_int (Game.score game)) (Game.attempts game) time_str
    (Game.combo game) (Game.matched_pairs game) (Game.total_pairs game)

let help_bar =
  " Arrows Select   ENTER Flip   H Hint   P Pause   R Restart   Q Quit "

let render_screen ~theme ~game ~cursor ~time_str ~message () =
  let b = Buffer.create 2048 in
  Buffer.add_string b
    (Ansi.wrap Ansi.cyan "+--------------------------------------------+\n");
  Buffer.add_string b
    (Ansi.wrap Ansi.cyan "|              CARDMATCH 2.0                 |\n");
  Buffer.add_string b "+--------------------------------------------+\n";
  Buffer.add_string b
    (Printf.sprintf " Mode: %-12s Difficulty: %s\n"
       (Game_mode.name (Game.mode game))
       (Difficulty.name (Game.difficulty game)));
  Buffer.add_string b (render_board ~theme ~game ~cursor ());
  Buffer.add_string b "+--------------------------------------------+\n";
  Buffer.add_string b (status_bar ~game ~time_str ^ "\n");
  (if message <> "" then Buffer.add_string b (message ^ "\n"));
  Buffer.add_string b "+--------------------------------------------+\n";
  Buffer.add_string b (help_bar ^ "\n");
  Buffer.add_string b "+--------------------------------------------+\n";
  Buffer.contents b
