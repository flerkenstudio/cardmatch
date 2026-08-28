type t = {
  mutable games_played : int;
  mutable games_won : int;
  mutable best_score : int;
  mutable best_time_ms : int;      (* 0 = none *)
  mutable total_score : int;
  mutable total_moves : int;
  mutable perfect_games : int;
  mutable daily_streak : int;
}

let create () =
  { games_played = 0; games_won = 0; best_score = 0;
    best_time_ms = 0; total_score = 0; total_moves = 0;
    perfect_games = 0; daily_streak = 0 }

let games_played s = s.games_played
let games_won s = s.games_won
let win_rate s =
  if s.games_played = 0 then 0.0
  else float_of_int s.games_won /. float_of_int s.games_played *. 100.0
let best_score s = s.best_score
let best_time_ms s = if s.best_time_ms = 0 then None else Some s.best_time_ms
let average_score s =
  if s.games_played = 0 then 0
  else s.total_score / s.games_played
let average_moves s =
  if s.games_played = 0 then 0
  else s.total_moves / s.games_played
let perfect_games s = s.perfect_games

let record s ~won ~perfect ~score ~moves ~time_ms =
  s.games_played <- s.games_played + 1;
  s.total_score <- s.total_score + score;
  s.total_moves <- s.total_moves + moves;
  if won then s.games_won <- s.games_won + 1;
  if perfect then s.perfect_games <- s.perfect_games + 1;
  if score > s.best_score then s.best_score <- score;
  if won && (s.best_time_ms = 0 || time_ms < s.best_time_ms) then
    s.best_time_ms <- time_ms

type serializable = {
  sp_games_played : int;
  sp_games_won : int;
  sp_best_score : int;
  sp_best_time_ms : int;
  sp_total_score : int;
  sp_total_moves : int;
  sp_perfect_games : int;
  sp_daily_streak : int;
}

let to_serializable s =
  { sp_games_played = s.games_played; sp_games_won = s.games_won;
    sp_best_score = s.best_score; sp_best_time_ms = s.best_time_ms;
    sp_total_score = s.total_score; sp_total_moves = s.total_moves;
    sp_perfect_games = s.perfect_games; sp_daily_streak = s.daily_streak }

let of_serializable p =
  { games_played = p.sp_games_played; games_won = p.sp_games_won;
    best_score = p.sp_best_score; best_time_ms = p.sp_best_time_ms;
    total_score = p.sp_total_score; total_moves = p.sp_total_moves;
    perfect_games = p.sp_perfect_games; daily_streak = p.sp_daily_streak }
