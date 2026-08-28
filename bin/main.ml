open Core
open Ui

let clock_ms () = int_of_float (Unix.gettimeofday () *. 1000.0)

let player_name = ref "Player"
let theme_name = ref "Classic"

let current_theme () =
  match Theme.of_name !theme_name with Some t -> t | None -> Theme.classic

let pause_ms ms =
  ignore (Unix.select [] [] [] (float_of_int ms /. 1000.0))

let elapsed_ms = ref 0

let limit_seconds mode =
  match mode with
  | Game_mode.TimeAttack s -> s
  | Game_mode.Blitz -> 30
  | Game_mode.Daily _ -> 300
  | _ -> 0

let time_str game =
  if Game_mode.uses_timer (Game.mode game) then
    Timer.format_ms (max 0 (limit_seconds (Game.mode game) * 1000 - !elapsed_ms))
  else
    Timer.format_ms !elapsed_ms

let show_screen game cursor message =
  Ansi.clear ();
  print_string
    (Renderer.render_screen ~theme:(current_theme ()) ~game ~cursor
       ~time_str:(time_str game) ~message ());
  flush stdout

let victory_screen game =
  Printf.printf "\n GAME COMPLETE!\n Score: %s\n Moves: %d\n Best combo: x%d\n"
    (Renderer.fmt_int (Game.score game)) (Game.attempts game)
    (Game.best_combo game)

let game_over_screen game =
  Printf.printf "\n GAME OVER\n Pairs found: %d/%d\n"
    (Game.matched_pairs game) (Game.total_pairs game)

(* ------------------------------------------------------------------ *)
(* Statistics persistence (simple append-only line log)                *)
(* ------------------------------------------------------------------ *)

let append_stats ~won ~perfect ~score ~moves ~time_ms =
  Persist.Store.ensure_dir ();
  let oc =
    open_out_gen [ Open_append; Open_creat ] 0o644 Persist.Store.stats_path
  in
  Printf.fprintf oc "%d|%b|%b|%d|%d|%d\n"
    (int_of_float (Unix.gettimeofday ())) won perfect score moves time_ms;
  close_out oc

let load_stats () =
  match Persist.Store.read_file Persist.Store.stats_path with
  | None -> Statistics.create ()
  | Some s ->
      let st = Statistics.create () in
      String.split_on_char '\n' s
      |> List.filter (fun l -> l <> "")
      |> List.iter (fun line ->
          match String.split_on_char '|' line with
          | [ _; won; perfect; score; moves; ms ] ->
              let i x = match int_of_string_opt x with
                | Some v -> v | None -> 0 in
              Statistics.record st ~won:(won = "true")
                ~perfect:(perfect = "true")
                ~score:(i score) ~moves:(i moves) ~time_ms:(i ms)
          | _ -> ());
      st

(* ------------------------------------------------------------------ *)
(* Save / leaderboard glue                                             *)
(* ------------------------------------------------------------------ *)

let save_game game =
  let matched =
    List.filter (fun i -> Game.is_matched game i)
      (List.init (Board.card_count (Game.board game)) (fun i -> i))
  in
  Persist.Save.save
    { Persist.Save.seed = Game.seed game;
      difficulty = Game.difficulty game;
      mode = Game.mode game;
      revealed = Game.revealed game;
      matched;
      score = Game.score game;
      attempts = Game.attempts game;
      moves = Game.moves game;
      combo = Game.combo game;
      best_combo = Game.best_combo game;
      hints_used = Game.hints_used game;
      elapsed_ms = !elapsed_ms;
      player = !player_name }

let record_leaderboard ~won game =
  if won then begin
    let t = Unix.localtime (Unix.gettimeofday ()) in
    let date = Printf.sprintf "%04d-%02d-%02d"
        (t.Unix.tm_year + 1900) (t.Unix.tm_mon + 1) t.Unix.tm_mday in
    ignore (Persist.Leaderboard.add
              { Persist.Leaderboard.player = !player_name;
                score = Game.score game; time_ms = !elapsed_ms;
                difficulty = Difficulty.name (Game.difficulty game);
                mode = Game_mode.name (Game.mode game);
                date; seed = Game.seed game })
  end

(** Replay saved matched pairs through the live engine so the resumed
    game re-derives an equivalent score/combo/attempts trail, rather
    than reaching into Game.state's (deliberately abstract) fields. *)
let restore_matched game matched =
  let rec pairs = function
    | a :: b :: r -> (a, b) :: pairs r
    | _ -> []
  in
  List.fold_left (fun g (a, b) ->
      if Game.is_matched g a || Game.is_matched g b then g
      else
        let g1, _ = Game.flip g a in
        let g2, _ = Game.flip g1 b in
        if Game.is_matched g2 b then g2 else Game.hide_all_revealed g2)
    game (pairs matched)

(* ------------------------------------------------------------------ *)
(* Main gameplay loop                                                  *)
(* ------------------------------------------------------------------ *)

let play ~difficulty ~mode ~seed ~restore =
  let game = ref (Game.make ~difficulty ~mode ~seed) in
  (match (restore : Persist.Save.t option) with
   | Some s ->
       game := restore_matched !game s.matched;
       elapsed_ms := s.elapsed_ms
   | None -> elapsed_ms := 0);
  let cursor = ref 0 in
  let message = ref "" in
  let quit_to_menu = ref false in
  let finished = ref false in
  let now_ms_ref = ref (clock_ms ()) in

  Input.with_raw (fun () ->
    while not !finished && not !quit_to_menu do
      let now = clock_ms () in
      let delta = now - !now_ms_ref in
      now_ms_ref := now;
      elapsed_ms := !elapsed_ms + delta;

      show_screen !game !cursor !message;

      let b = Game.board !game in
      let rows = Board.rows b and cols = Board.cols b in
      let n = rows * cols in

      (match Input.read_key () with
       | Input.Up -> cursor := (!cursor - cols + n) mod n
       | Input.Down -> cursor := (!cursor + cols) mod n
       | Input.Left -> cursor := (!cursor - 1 + n) mod n
       | Input.Right -> cursor := (!cursor + 1) mod n
       | Input.Enter ->
           (try
              let g, outcome = Game.flip !game !cursor in
              game := g;
              (match outcome with
               | Game.First_flip -> message := ""
               | Game.Second_flip true ->
                   message := Ansi.(wrap green " MATCH!")
               | Game.Second_flip false ->
                   message := Ansi.(wrap red " no match");
                   show_screen !game !cursor !message;
                   pause_ms 700;
                   game := Game.hide_all_revealed !game
               | Game.Game_over_win ->
                   finished := true; message := ""
               | Game.Game_over_loss ->
                   finished := true; message := "")
            with Game.Illegal_move m -> message := " " ^ m)
       | Input.Char ('h' | 'H') ->
           (try
              game := Game.hint_pair !game (Rng.create (clock_ms ()));
              message := Ansi.(wrap yellow " hint (-50)");
              show_screen !game !cursor !message;
              pause_ms 900;
              game := Game.hide_all_revealed !game
            with Game.Illegal_move m -> message := " " ^ m)
       | Input.Char ('r' | 'R') ->
           game := Game.make ~difficulty:(Game.difficulty !game)
                     ~mode:(Game.mode !game) ~seed:(Game.seed !game);
           elapsed_ms := 0; message := " restarted"
       | Input.Char ('p' | 'P') ->
           message := " paused";
           show_screen !game !cursor !message;
           (match Menu.run ~title:"PAUSED"
                    ~items:[ "Resume"; "Save & Exit"; "Restart"; "Main Menu" ] with
            | Some 1 ->
                save_game !game;
                quit_to_menu := true; finished := true
            | Some 2 ->
                game := Game.make ~difficulty:(Game.difficulty !game)
                          ~mode:(Game.mode !game) ~seed:(Game.seed !game);
                elapsed_ms := 0
            | Some 3 -> quit_to_menu := true; finished := true
            | _ -> ());
           message := ""
       | Input.Char ('q' | 'Q') | Input.Eof ->
           quit_to_menu := true; finished := true
       | _ -> ());

      if not !finished && Game_mode.uses_timer (Game.mode !game) then begin
        if !elapsed_ms >= limit_seconds (Game.mode !game) * 1000 then
          finished := true
      end
    done);

  if !finished && Game.won !game then begin
    record_leaderboard ~won:true !game;
    append_stats ~won:true
      ~perfect:(Game.attempts !game = Game.total_pairs !game)
      ~score:(Game.score !game) ~moves:(Game.attempts !game)
      ~time_ms:!elapsed_ms;
    Ansi.clear ();
    victory_screen !game;
    Persist.Save.clear ();
    print_string "\n Press any key...";
    flush stdout;
    Input.with_raw (fun () -> ignore (Input.read_key ()))
  end else if !finished && Game.lost !game then begin
    append_stats ~won:false ~perfect:false ~score:(Game.score !game)
      ~moves:(Game.attempts !game) ~time_ms:!elapsed_ms;
    Ansi.clear ();
    game_over_screen !game;
    Persist.Save.clear ();
    print_string "\n Press any key...";
    flush stdout;
    Input.with_raw (fun () -> ignore (Input.read_key ()))
  end;
  !game

(* ------------------------------------------------------------------ *)
(* AI match                                                            *)
(* ------------------------------------------------------------------ *)

let play_vs_ai ~difficulty ~seed =
  let human = ref (Game.make ~difficulty ~mode:Game_mode.Classic ~seed) in
  let ai_score = ref 0 in
  let ai = Ai.Ai_player.create ~difficulty:Ai.Ai_player.Normal ~seed in
  let cursor = ref 0 in
  let message = ref "" in
  let quit = ref false in
  elapsed_ms := 0;

  let ai_turn () =
    let continue_ = ref true in
    while !continue_ && not (Game.won !human) do
      let first = Ai.Ai_player.choose_first !human ai in
      (try
         let g1, _ = Game.flip !human first in
         human := g1;
         Ai.Ai_player.observe ai ~index:first
           (Board.card_at (Game.board !human) first);
         let second = Ai.Ai_player.choose_second !human ai ~first in
         let g2, outcome = Game.flip !human second in
         human := g2;
         Ai.Ai_player.observe ai ~index:second
           (Board.card_at (Game.board !human) second);
         (match outcome with
          | Game.Second_flip true | Game.Game_over_win ->
              Ai.Ai_player.observe_matched ai [ first; second ];
              ai_score := !ai_score + 100;
              message := Printf.sprintf " AI matched (%d, %d)" first second;
              if outcome = Game.Game_over_win then continue_ := false
          | _ ->
              ai_score := max 0 (!ai_score - 20);
              message := " AI missed";
              continue_ := false)
       with Game.Illegal_move _ -> continue_ := false);
      if not (Game.won !human) then begin
        pause_ms 600;
        human := Game.hide_all_revealed !human
      end
    done
  in

  Input.with_raw (fun () ->
    while not !quit && not (Game.won !human) do
      Ansi.clear ();
      print_string
        (Renderer.render_screen ~theme:(current_theme ()) ~game:!human
           ~cursor:!cursor ~time_str:(time_str !human) ~message:!message ());
      Printf.printf "\n %s - AI score: %d\n"
        (Ai.Ai_player.name Ai.Ai_player.Normal) !ai_score;
      flush stdout;
      let b = Game.board !human in
      let rows = Board.rows b and cols = Board.cols b in
      let n = rows * cols in
      (match Input.read_key () with
       | Input.Up -> cursor := (!cursor - cols + n) mod n
       | Input.Down -> cursor := (!cursor + cols) mod n
       | Input.Left -> cursor := (!cursor - 1 + n) mod n
       | Input.Right -> cursor := (!cursor + 1) mod n
       | Input.Enter ->
           (try
              let g, outcome = Game.flip !human !cursor in
              human := g;
              (match outcome with
               | Game.Second_flip true | Game.Game_over_win ->
                   message := Ansi.(wrap green " YOU matched!")
               | Game.Second_flip false ->
                   message := Ansi.(wrap red " no match");
                   pause_ms 700;
                   human := Game.hide_all_revealed !human;
                   ai_turn ()
               | Game.First_flip -> message := ""
               | Game.Game_over_loss -> ())
            with Game.Illegal_move m -> message := " " ^ m)
       | Input.Char ('q' | 'Q') | Input.Eof -> quit := true
       | _ -> ())
    done);
  if Game.won !human then begin
    Ansi.clear ();
    victory_screen !human;
    Printf.printf " AI score: %d\n%s\n" !ai_score
      (if Game.score !human >= !ai_score then " You win!"
       else " AI wins!");
    record_leaderboard ~won:true !human;
    print_string "\n Press any key...";
    flush stdout;
    Input.with_raw (fun () -> ignore (Input.read_key ()))
  end

(* ------------------------------------------------------------------ *)
(* Stats / leaderboard screens                                         *)
(* ------------------------------------------------------------------ *)

let show_leaderboard () =
  Ansi.clear ();
  Printf.printf "LEADERBOARD\n----------------------------------------\n";
  Printf.printf "%-3s %-12s %-7s %-8s %-8s\n" "#" "PLAYER" "SCORE" "DIFF" "MODE";
  let entries = Persist.Leaderboard.top ~limit:10 () in
  if entries = [] then print_string " (no entries yet - go play!)\n";
  List.iteri (fun i (e : Persist.Leaderboard.entry) ->
      Printf.printf "%-3d %-12s %-7d %-8s %-8s\n"
        (i + 1) (Persist.Leaderboard.sanitize e.player) e.score
        (Persist.Leaderboard.sanitize e.difficulty)
        (Persist.Leaderboard.sanitize e.mode))
    entries;
  print_string "\n Press any key...";
  flush stdout;
  Input.with_raw (fun () -> ignore (Input.read_key ()))

let show_stats () =
  Ansi.clear ();
  let st = load_stats () in
  Printf.printf "PLAYER STATISTICS\n--------------------------------\n";
  Printf.printf " Games Played    %d\n" (Statistics.games_played st);
  Printf.printf " Games Won       %d\n" (Statistics.games_won st);
  Printf.printf " Win Rate        %.0f%%\n" (Statistics.win_rate st);
  Printf.printf " Best Score      %s\n"
    (Renderer.fmt_int (Statistics.best_score st));
  (match Statistics.best_time_ms st with
   | Some ms -> Printf.printf " Best Time       %s\n" (Timer.format_ms ms)
   | None -> ());
  Printf.printf " Average Score   %d\n" (Statistics.average_score st);
  Printf.printf " Perfect Games   %d\n" (Statistics.perfect_games st);
  print_string "\n Press any key...";
  flush stdout;
  Input.with_raw (fun () -> ignore (Input.read_key ()))

(* ------------------------------------------------------------------ *)
(* Menus                                                               *)
(* ------------------------------------------------------------------ *)

let choose_difficulty () =
  let names = List.map Difficulty.name Difficulty.all in
  let items = names @ [ "Back" ] in
  match Menu.run ~title:"DIFFICULTY" ~items with
  | None -> None
  | Some i when i = List.length items - 1 -> None
  | Some i -> Some (List.nth Difficulty.all i)

let run_mode mode =
  let restore =
    if Persist.Save.exists () then begin
      Ansi.clear ();
      print_string "Saved game found.\n[1] Continue [2] New Game [3] Delete Save\n> ";
      flush stdout;
      match (try Some (input_line stdin) with End_of_file -> None) with
      | Some "1" -> Persist.Save.load ()
      | Some "3" -> Persist.Save.clear (); None
      | _ -> None
    end else None
  in
  match restore with
  | Some s ->
      ignore (play ~difficulty:s.Persist.Save.difficulty
                ~mode:s.Persist.Save.mode ~seed:s.Persist.Save.seed
                ~restore:(Some s))
  | None ->
      Option.iter (fun difficulty ->
          let seed =
            match mode with
            | Game_mode.Daily d -> Game_mode.daily_seed d
            | _ -> clock_ms ()
          in
          ignore (play ~difficulty ~mode ~seed ~restore:None))
        (choose_difficulty ())

let rec main_menu () =
  match Menu.run ~title:"CARDMATCH 2.0"
      ~items:[ "Classic"; "Time Attack"; "Blitz"; "Perfect"; "Zen";
               "Daily Challenge"; "Play vs AI"; "Leaderboard";
               "Statistics"; "Quit" ] with
  | None | Some 9 -> ()
  | Some 0 -> run_mode Game_mode.Classic; main_menu ()
  | Some 1 -> run_mode (Game_mode.TimeAttack 180); main_menu ()
  | Some 2 -> run_mode Game_mode.Blitz; main_menu ()
  | Some 3 -> run_mode Game_mode.Perfect; main_menu ()
  | Some 4 -> run_mode Game_mode.Zen; main_menu ()
  | Some 5 ->
      let t = Unix.localtime (Unix.gettimeofday ()) in
      let date = Printf.sprintf "%04d-%02d-%02d"
          (t.Unix.tm_year + 1900) (t.Unix.tm_mon + 1) t.Unix.tm_mday in
      run_mode (Game_mode.Daily date);
      main_menu ()
  | Some 6 ->
      Option.iter (fun d -> play_vs_ai ~difficulty:d ~seed:(clock_ms ()))
        (choose_difficulty ());
      main_menu ()
  | Some 7 -> show_leaderboard (); main_menu ()
  | Some 8 -> show_stats (); main_menu ()
  | Some _ -> main_menu ()

let () =
  (try main_menu () with
   | End_of_file | Sys.Break -> ());
  Ansi.show_cursor ();
  Ansi.clear ();
  print_string "Thanks for playing CardMatch 2.0!\n"
