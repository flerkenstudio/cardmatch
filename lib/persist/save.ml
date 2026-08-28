open Core

type t = {
  seed : int;
  difficulty : Difficulty.t;
  mode : Game_mode.t;
  revealed : int list;
  matched : int list;          (* indices *)
  score : int;
  attempts : int;
  moves : int;
  combo : int;
  best_combo : int;
  hints_used : int;
  elapsed_ms : int;
  player : string;
}

exception Corrupted of string

let encode_int = string_of_int

let encode_list l = String.concat "," (List.map string_of_int l)

let parse_int_list s =
  String.split_on_char ',' s
  |> List.filter (fun x -> x <> "")
  |> List.map (fun x ->
      match int_of_string_opt x with
      | Some i -> i
      | None -> raise (Corrupted ("bad int list: " ^ s)))

let escape s = String.concat "\\n" (String.split_on_char '\n' s)

let unescape s =
  let buf = Buffer.create (String.length s) in
  let n = String.length s in
  let i = ref 0 in
  while !i < n do
    if !i + 1 < n && s.[!i] = '\\' && s.[!i + 1] = 'n' then begin
      Buffer.add_char buf '\n'; i := !i + 2
    end else begin
      Buffer.add_char buf s.[!i]; incr i
    end
  done;
  Buffer.contents buf

let to_string t =
  String.concat "\n" [
    "v=2";
    "seed=" ^ encode_int t.seed;
    "difficulty=" ^ Difficulty.name t.difficulty;
    "rows=" ^ string_of_int (Difficulty.preset_of t.difficulty).rows;
    "cols=" ^ string_of_int (Difficulty.preset_of t.difficulty).cols;
    "mode=" ^ (match t.mode with
      | Classic -> "classic"
      | TimeAttack s -> "timeattack:" ^ string_of_int s
      | Perfect -> "perfect"
      | Blitz -> "blitz"
      | Zen -> "zen"
      | Streak -> "streak"
      | Daily d -> "daily:" ^ d);
    "revealed=" ^ encode_list t.revealed;
    "matched=" ^ encode_list t.matched;
    "score=" ^ encode_int t.score;
    "attempts=" ^ encode_int t.attempts;
    "moves=" ^ encode_int t.moves;
    "combo=" ^ encode_int t.combo;
    "best_combo=" ^ encode_int t.best_combo;
    "hints=" ^ encode_int t.hints_used;
    "elapsed=" ^ encode_int t.elapsed_ms;
    "player=" ^ escape t.player;
  ]

let of_string s =
  let fields = Hashtbl.create 24 in
  String.split_on_char '\n' s
  |> List.iter (fun line ->
      match String.index_opt line '=' with
      | Some i ->
          Hashtbl.replace fields (String.sub line 0 i)
            (String.sub line (i + 1) (String.length line - i - 1))
      | None -> ());
  let get k =
    match Hashtbl.find_opt fields k with
    | Some v -> v
    | None -> raise (Corrupted ("missing field: " ^ k))
  in
  let get_int k = match int_of_string_opt (get k) with
    | Some v -> v | None -> raise (Corrupted ("bad int: " ^ k)) in
  if get "v" <> "2" then raise (Corrupted "unsupported version");
  let rows = get_int "rows" and cols = get_int "cols" in
  if not (Difficulty.valid_dimensions rows cols) then
    raise (Corrupted "invalid board dimensions in save");
  let difficulty = Difficulty.Custom (rows, cols) in
  let mode =
    match String.split_on_char ':' (get "mode") with
    | [ "classic" ] -> Game_mode.Classic
    | [ "timeattack"; s ] ->
        (match int_of_string_opt s with
         | Some n when n > 0 -> Game_mode.TimeAttack n
         | _ -> raise (Corrupted "bad timeattack"))
    | [ "perfect" ] -> Game_mode.Perfect
    | [ "blitz" ] -> Game_mode.Blitz
    | [ "zen" ] -> Game_mode.Zen
    | [ "streak" ] -> Game_mode.Streak
    | "daily" :: rest -> Game_mode.Daily (String.concat ":" rest)
    | _ -> raise (Corrupted "bad mode")
  in
  let revealed = parse_int_list (get "revealed") in
  let matched = parse_int_list (get "matched") in
  List.iter (fun i ->
    if i < 0 || i >= rows * cols then raise (Corrupted "index out of range"))
    (revealed @ matched);
  { seed = get_int "seed"; difficulty; mode;
    revealed; matched;
    score = get_int "score"; attempts = get_int "attempts";
    moves = get_int "moves"; combo = get_int "combo";
    best_combo = get_int "best_combo"; hints_used = get_int "hints";
    elapsed_ms = get_int "elapsed";
    player = unescape (get "player") }

let save t = Store.write_file Store.save_path (to_string t)

let load () =
  match Store.read_file Store.save_path with
  | Some s -> Some (of_string s)
  | None -> None

let clear () = Store.delete_file Store.save_path
let exists () = Store.file_exists Store.save_path
