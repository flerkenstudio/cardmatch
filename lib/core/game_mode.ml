type t =
  | Classic
  | TimeAttack of int        (* seconds countdown *)
  | Perfect
  | Blitz
  | Zen
  | Streak
  | Daily of string          (* date string, e.g. "2026-08-28" *)

let name = function
  | Classic -> "Classic"
  | TimeAttack _ -> "Time Attack"
  | Perfect -> "Perfect"
  | Blitz -> "Blitz"
  | Zen -> "Zen"
  | Streak -> "Streak"
  | Daily _ -> "Daily Challenge"

let all =
  [ Classic; TimeAttack 180; Perfect; Blitz; Zen; Streak;
    Daily "2026-08-28" ]

let uses_timer = function
  | Classic | Zen | Perfect | Streak -> false
  | TimeAttack _ | Blitz | Daily _ -> true

let allows_hints = function
  | Perfect -> false
  | _ -> true

let mismatch_is_fatal = function
  | Perfect -> true
  | _ -> false

(** Daily challenges derive their seed from the date - everyone gets
    the same board on the same day. *)
let daily_seed date =
  let h = Hashtbl.create 8 in
  String.iteri (fun i c ->
    Hashtbl.replace h i (Char.code c * (i + 1) * 31)) date;
  Hashtbl.fold (fun _ v acc -> acc + v) h 0

let seed_of = function
  | Daily date -> daily_seed date
  | _ -> 0 (* engine uses an explicit seed anyway *)

let daily_challenge_number date =
  String.to_seq date
  |> Seq.filter (fun c -> c >= '0' && c <= '9')
  |> String.of_seq
