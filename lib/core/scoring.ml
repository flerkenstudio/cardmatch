type t = {
  mutable score : int;
  mutable combo : int;
  mutable best_combo : int;
  mutable hints_used : int;
}

let create () =
  { score = 0; combo = 0; best_combo = 0; hints_used = 0 }

let current t = t.score
let combo t = t.combo
let best_combo t = t.best_combo
let hints_used t = t.hints_used

let base_match = 100
let fast_match_bonus = 50
let combo_bonus_per_level = 25
let wrong_penalty = 20
let hint_penalty = 50
let streak_complete_bonus = 250

let add t pts = t.score <- max 0 (t.score + pts)

(** Called on a successful match. [fast=true] if matched within
    the fast window (seconds since last flip, decided by shell). *)
let register_match t ~fast ~streak_complete ~difficulty_multiplier =
  t.combo <- t.combo + 1;
  t.best_combo <- max t.best_combo t.combo;
  let pts = ref base_match in
  if fast then pts := !pts + fast_match_bonus;
  if t.combo > 1 then
    pts := !pts + (t.combo * combo_bonus_per_level);
  if streak_complete then pts := !pts + streak_complete_bonus;
  let total =
    int_of_float (float_of_int !pts *. difficulty_multiplier)
  in
  add t total;
  total

let register_mismatch t =
  t.combo <- 0;
  add t (-wrong_penalty)

let register_hint t =
  t.hints_used <- t.hints_used + 1;
  add t (-hint_penalty)

let reset t =
  t.score <- 0; t.combo <- 0; t.best_combo <- 0; t.hints_used <- 0
