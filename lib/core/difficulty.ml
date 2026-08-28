type t =
  | Easy
  | Normal
  | Hard
  | Expert
  | Extreme
  | Custom of int * int

type preset = {
  name : string;
  rows : int;
  cols : int;
  score_multiplier : float;
}

let presets =
  [ (Easy, { name = "Easy"; rows = 2; cols = 2; score_multiplier = 1.0 });
    (Normal, { name = "Normal"; rows = 4; cols = 4; score_multiplier = 1.5 });
    (Hard, { name = "Hard"; rows = 4; cols = 6; score_multiplier = 2.0 });
    (Expert, { name = "Expert"; rows = 6; cols = 6; score_multiplier = 3.0 });
    (Extreme, { name = "Extreme"; rows = 8; cols = 8; score_multiplier = 4.0 });
  ]

let preset_of = function
  | Custom (r, c) ->
      { name = Printf.sprintf "Custom %dx%d" r c;
        rows = r; cols = c;
        score_multiplier = 1.5 +. float_of_int (r * c) /. 32.0 }
  | d -> List.assoc d presets

let all = List.map fst presets

let of_string = function
  | "easy" | "Easy" | "E" -> Some Easy
  | "normal" | "Normal" | "N" -> Some Normal
  | "hard" | "Hard" | "H" -> Some Hard
  | "expert" | "Expert" | "X" -> Some Expert
  | "extreme" | "Extreme" | "M" -> Some Extreme
  | _ -> None

(** Validation rules:
    - rows and cols must be within [2, 10]
    - rows * cols must be even (cards come in pairs) *)
let valid_dimensions rows cols =
  rows >= 2 && rows <= 10 && cols >= 2 && cols <= 10
  && (rows * cols) mod 2 = 0

let card_count d =
  let p = preset_of d in
  p.rows * p.cols

let pair_count d = card_count d / 2

let name d = (preset_of d).name

let score_multiplier d = (preset_of d).score_multiplier
